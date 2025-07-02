module bram_rd_ctrl #(
    parameter ELEMENTS = 2,
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter IMG_HEIGHT = 16,
    parameter IMG_CHANNELS = 16,
    parameter N_BRAM = 32)
(
    input  clk,
    input  rst,
    input  [(2*IMG_HEIGHT)-1:0] image_size,
    input  [IMG_CHANNELS-1:0] input_channels,
    input  start, //from transpose block
    output [N_BRAM-1:0] rd_en, //read enables for brams
    output reg valid, //valid for fifo write controller
    output reg next_req, //start signal for write request controller
    output reg done, //done signal for write request contoller 
    output [(N_BRAM*W_ADDR)-1:0] rd_addr //read address for brams
);

localparam SHIFTS = N_BRAM >> $clog2(ELEMENTS); //dividing bram array into sets of brams according to number of ELEMENTS

reg [3:0] state = 0;
reg [W_ADDR-1:0] r_addr = 0;
reg [5:0] bram_counter = 0; //counter for brams
reg [9:0] class_counter = 0; //counter for channels
reg [(2*W_DATA)-1:0] element_counter = 0; // counter for elements in the image
reg [4:0] shift_counter = 0; //counter for sets of brams according to number of ELEMENTS
reg [N_BRAM-1:0] r_en = 0;
reg count = 0;

assign rd_addr = {N_BRAM{r_addr}};
assign rd_en = r_en;

always @ (posedge clk) begin
    if(!rst) begin
        state <= 0;
        bram_counter <= 0;
        r_addr <= 0;
        r_en <= 0;
        done <= 0;
        valid <= 0;
        count <= 0;
        shift_counter <= 0;
        element_counter <= 0;
        class_counter <= 0;
    end

    else begin
        case(state)
        0: begin
            done <= 0;
            if(start) begin
                r_addr <= 9'b000000001;
                r_en[N_BRAM-1] <= 1;
                valid <= 1;
                class_counter <= class_counter + 1;
                //bram_counter <= bram_counter + 1;
                state <= 1;
            end
            else begin
                r_addr <= 0;
                r_en <= 0;
                class_counter <= 0;
                bram_counter <= 0;
                state <= 0;
            end
        end

        1: begin
            if(class_counter == (input_channels + 2)) begin //to manage the delay of brams
                class_counter <= 0;
                bram_counter <= 0;
                r_addr <= r_addr;
                r_en <= 0;
                valid <= 0;
                state <= 2;
            end
            else if (class_counter >= input_channels) begin //to manage the delay of brams
                class_counter <= class_counter + 1;
                bram_counter <= 0;
                r_addr <= r_addr;
                valid <= 0;
                r_en <= 0;
                state <= 1;
            end
            else begin
                if(bram_counter  == (SHIFTS - 1)) begin //shifting read enable when bram counter reaches maximum shifts of a set
                    bram_counter <= 0;
                    class_counter <= class_counter + 1;
                    r_en[N_BRAM - 1 - (SHIFTS * shift_counter)] <= 1;
                    r_en[N_BRAM - SHIFTS - (SHIFTS * shift_counter)] <= 0;
                    valid <= 1;
                    r_addr <= r_addr + 1;
                    state <= 1;
                end
                else begin //shifting read enable acording to bram counter
                    bram_counter <= bram_counter + 1; 
                    class_counter <= class_counter + 1;
                    r_en <= r_en >> 1;
                    valid <= 1;
                    r_addr <= r_addr;
                    state <= 1;
                end
            end
        end

        2: begin
            if(element_counter == (image_size-1)) begin //checking for all the elements are read from bram
                r_addr <= 0;
                r_en <= 0;
                valid <= 0;
                element_counter <= 0;
                shift_counter <= 0;
                bram_counter <= 0;
                class_counter <= 0;
                done <= 1;
                state <= 0;
            end
            else begin
                next_req <= 0;
                if(shift_counter == (ELEMENTS - 1)) begin //update address and reset read enable after all sets are done
                    if(start) begin
                        r_addr <= r_addr + 1;
                        r_en[N_BRAM-1] <= 1;
                        valid <= 1;
                        element_counter <= element_counter  + 1;
                        class_counter <= class_counter + 1;
                        shift_counter <= 0;
                        count <= 0;
                        state <= 1;
                    end
                    else begin // hold the values untill start comes
                        r_addr <= r_addr;
                        r_en <= 0;
                        valid <= 0;
                        element_counter <= element_counter;
                        class_counter <= 0;
                        shift_counter <= shift_counter;
                        state <= 2;
                        if(count == 0) begin
                            count <= count + 1;
                            next_req <= 1;
                        end
                    end
                end
                else begin // update the address and read enable after all channels of that set are completed
                    r_addr <= r_addr - (input_channels >> $clog2(SHIFTS));
                    r_en[N_BRAM - 1 - (SHIFTS * (shift_counter + 1))] <= 1;
                    valid <= 1;
                    element_counter <= element_counter  + 1;
                    class_counter <= class_counter + 1;
                    shift_counter <= shift_counter + 1;
                    state <= 1;
                end
            end
        end
        endcase
    end
end
endmodule