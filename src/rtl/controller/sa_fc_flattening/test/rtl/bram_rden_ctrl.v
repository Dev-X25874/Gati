/*
    image dimension is 7x7x16 = 784
    counting 7 0's for each bank, after every 49 elements in a bank, 7x16 = 112
    784 + 112 = 896 (total elements for first set of kernals)
*/
module bram_rden_controller#(
    parameter W_KERNAL_CNT = 16,
    parameter W_IMG_DIM = 20,
    parameter W_IMG_ROWS = 16,
    parameter N_BRAM = 8,
    parameter N_BANK = 4,
    parameter W_ADDR = 9
)(
    input clk,
    input rst,
    input w_done,
    input accumulator_valid,
    input flatten,
    input [W_KERNAL_CNT-1 : 0] kernal_count, //4096
    input [(N_BANK * N_BRAM)-1 : 0] weight_ff_array_empty,  //common weight fifo array for sa and fc
    input [W_IMG_DIM-1 : 0] image_dimension,   //7
    input [W_IMG_ROWS-1 : 0] image_rows, //7x7x16
    output [N_BRAM-1 : 0] o_read_enable,
    output o_done,
    output [(N_BANK * (W_ADDR + 1))-1 : 0] o_bank_address,
    output [N_BANK-1 : 0] o_bank_enable,
    output [15:0] kernal_counter
);
reg [1:0] state = 0;
reg [N_BRAM-1 : 0] rden = 0;
reg done = 0;
reg [N_BANK-1 : 0]bank_en = 0;
reg [(N_BANK * (W_ADDR + 1))-1 : 0] addr = 0;

assign o_done = done;
assign o_read_enable = rden;
assign o_bank_address = addr;
assign o_bank_enable = bank_en;

reg [1:0] rd_state = 0;

//count number of elements in a bank, 1-49
reg [5:0] element_counter = 0;
//count number of reads in one row of a bank, 1-8
reg [3:0] rden_counter = 0;
//holds value of an address to be incremented in a bank, 1-7/8
reg [5:0] addr_counter = 0;
//hold adress of previous BRAM BANK
reg [5:0] next_addr = 0;
//counts number of banks, 1-4 
reg [2:0] bank_counter = 0;
//counts how many times does shifting of bank enable signal need to be done, for flatten = 0 counts is 1-28, for flatten = 1 counts is 1-4
reg [15:0] bank_shift_counter = 0;
//counts how many times the image will be used again for different sets of kernals, 1 - 128
reg [15:0] kernal_counter = 0;

//Asserts bank enable signal and handles address incrementation
always @(posedge clk) begin
    if(rst)begin
        bank_en <= 0;
        addr <= 0;
        bank_shift_counter <= 0;
        bank_counter <= 0;
        element_counter <= 0;
    end else begin
       case(flatten)
            1'b0:begin
                case (state)
                    0:begin
                        done <= 0;
                        bank_en <= 0;
                        element_counter <= 0;
                        bank_counter <= 0;
                        bank_shift_counter <= 0;
                        kernal_counter <= 0;
                       if(w_done)begin
                        state <= 1;
                       end 
                    end
                    1: begin
                        if(weight_ff_array_empty == 0)begin
                            if(kernal_counter < (kernal_count >> 5))begin
                                if(bank_shift_counter < (image_rows >> 5))begin   //need to keep shifting bank enable signal for each row
                                    if(bank_counter == N_BANK)begin
                                        bank_counter <= 0;
                                        bank_shift_counter <= bank_shift_counter + 1;
                                    end else begin
                                        if(element_counter == (N_BRAM))begin
                                            
                                            if(bank_counter == 3) next_addr = addr_counter + 1;

                                            bank_counter <= bank_counter + 1;
                                            element_counter <= 0;
                                            addr[((W_ADDR + 1) * (bank_counter + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                            addr_counter <= next_addr;
                                            rden_counter <= 0;
                                            rden <= 0;
                                        end else begin
                                            addr_counter <= addr_counter;
                                            element_counter <= element_counter + 1;
                                            bank_counter <= bank_counter;
                                            addr[((W_ADDR + 1) * (bank_counter + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                            
                                            //update read counter conditions
                                            if(addr_counter == (image_rows >> 5))begin
                                                rden <= 0;    
                                            end else begin
                                                if(rden_counter == N_BRAM-1)begin
                                                    rden_counter <= 0;
                                                end else begin
                                                    rden_counter <= rden_counter + 1;
                                                end
                                                rden[rden_counter] <= 1;
                                                if(N_BRAM > 1)begin
                                                    if(rden_counter == 0)
                                                        rden[N_BRAM-1] <= 0;
                                                    else
                                                        rden[rden_counter-1] <= 0;
                                                end else begin
                                                    rden <= 0;
                                                    rden_counter <= 0;
                                                end
                                            end
                                        end
                                    bank_en[bank_counter] <= 1;

                                    if(N_BANK > 1)begin
                                        if(bank_counter == 0)
                                            bank_en[N_BANK - 1] <= 0;
                                        else
                                            bank_en[bank_counter - 1] <= 0;
                                    end else begin
                                        bank_counter <= 0;
                                        bank_en <= 0;
                                    end

                                    bank_shift_counter <= bank_shift_counter;
                                end
                                end else begin
                                    state <= 2;
                                    addr <= 0;
                                end
                            end else begin
                                done <= 1'b1;
                                state <= 0;
                            end
                        end
                    end
                    2: begin
                        if(accumulator_valid)begin
                            bank_shift_counter <= 0;
                            kernal_counter <= kernal_counter + 1;
                            state <= 1;
                        end else begin
                            bank_shift_counter <= bank_shift_counter;
                        end
                    end
                    default: state <= 0;
                endcase
            end
            1'b1: begin
                case (state)
                    0:begin
                        done <= 0;
                        bank_en <= 0;
                        element_counter <= 0;
                        bank_counter <= 0;
                        bank_shift_counter <= 0;
                        kernal_counter <= 0;
                        next_addr <= 0;
                    if(w_done)begin
                        state <= 1;
                    end 
                    end
                    1: begin
                        if(weight_ff_array_empty == 0)begin
                            if(kernal_counter < (kernal_count >> 5))begin
                                if(bank_shift_counter < 4)begin   //need to keep shifting bank enable signal for 4 times, 1-7  addresses in one shifting of a bank's enable
                                    if(bank_counter == N_BANK)begin
                                        bank_counter <= 0;
                                        bank_shift_counter <= bank_shift_counter + 1;
                                    end else begin
                                        if(element_counter == (image_dimension))begin
                                            
                                            if(bank_counter == 3) next_addr = addr_counter + 1;

                                            bank_counter <= bank_counter + 1;
                                            element_counter <= 0;
                                            addr[((W_ADDR + 1) * (bank_counter + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                            addr_counter <= next_addr;
                                            rden_counter <= 0;
                                            rden <= 0;
                                        end else begin
                                            element_counter <= element_counter + 1;
                                            bank_counter <= bank_counter;
                                            addr[((W_ADDR + 1) * (bank_counter + 1))-1 -: (W_ADDR + 1)] <= addr_counter;
                                            
                                            //update read counter conditions
                                            if(addr_counter == (image_rows >> 5))begin
                                                rden <= 0;
                                            end else begin
                                                if(rden_counter == N_BRAM-1)begin
                                                    rden_counter <= 0;
                                                    addr_counter <= addr_counter + 1;
                                                end else begin
                                                    rden_counter <= rden_counter + 1;
                                                    addr_counter <= addr_counter;
                                                end
                                                rden[rden_counter] <= 1;
                                                if(N_BRAM > 1)begin
                                                    if(rden_counter == 0)
                                                        rden[N_BRAM-1] <= 0;
                                                    else
                                                        rden[rden_counter-1] <= 0;
                                                end else begin
                                                    rden <= 0;
                                                    rden_counter <= 0;
                                                end
                                            end
                                        end
                                    bank_en[bank_counter] <= 1;

                                    if(N_BANK > 1)begin
                                        if(bank_counter == 0)
                                            bank_en[N_BANK - 1] <= 0;
                                        else
                                            bank_en[bank_counter - 1] <= 0;
                                    end else begin
                                        bank_counter <= 0;
                                        bank_en <= 0;
                                    end

                                    bank_shift_counter <= bank_shift_counter;
                                end
                                end else begin
                                    state <= 2;
                                    addr <= 0;
                                end
                            end else begin
                                done <= 1'b1;
                                state <= 0;
                            end
                        end
                    end
                    2: begin
                        if(accumulator_valid)begin
                            bank_shift_counter <= 0;
                            kernal_counter <= kernal_counter + 1;
                            state <= 1;
                        end else begin
                            bank_shift_counter <= bank_shift_counter;
                        end
                    end
                    default: state <= 0;
                endcase
            end
       endcase 
    end
end
endmodule