/*
    Controls write enable signal of bram array
*/
module bram_wren_ctrl#(
    parameter N_BRAM = 8,
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_BANK = 4
)(
    input clk,
    input rst,
    input start,         //NOTE: Include this external start trigger while integration
    input data_valid,
    input [15:0] kernal_counter,
    input [19:0] image_dim,
    input [((N_BANK * N_BRAM) * W_DATA)-1 : 0] i_data,
    output write_done,
    output [(N_BANK * N_BRAM)-1 : 0] write_enable,
    output [((N_BANK * N_BRAM) * W_DATA)-1 : 0] o_data,
    output [(N_BANK * (W_ADDR + 1))-1 : 0] o_waddr
    // output [(N_BANK * (W_ADDR + 1))-1  :0] o_raddr,
    // output [N_BANK-1 : 0] o_bank_en,
    // output [(N_BANK * N_BRAM)-1 : 0] o_bram_rden
);

reg [6:0] counter = 0;
reg [1:0] state = 0;
reg w_done = 0;
reg [(N_BANK * N_BRAM)-1 : 0] wren = 0;
reg [((N_BANK * N_BRAM) * W_DATA)-1 : 0] data = 0;

// reg [W_ADDR : 0] raddr = 0;
// reg [N_BANK-1 : 0] bank_en = 0;
// reg [(N_BANK * N_BRAM)-1 : 0]rden = 0;

// reg [(N_BANK * (W_ADDR + 1))-1 : 0] waddr = 0;
reg [W_ADDR : 0] waddr = 0;
assign write_done = w_done;
assign write_enable = wren;
assign o_data = data;
assign o_waddr = {N_BANK{waddr}};
// assign o_raddr = {N_BANK{raddr}};
// assign o_bram_rden = rden;
// assign o_bank_en = bank_en;

wire w_start;
one_pulse start_pulse(
    .a(start),
    .rst(rst),
    .clk(clk),
    .b(w_start)
);

always @(posedge clk) begin
    if(rst)begin
        data <= 0;
        w_done <= 0;
        wren <= 0;
    end else begin
        case (state)
            0:begin
                if(data_valid)begin
                    data <= i_data;
                    counter <= counter + 1;
                    wren <= {(N_BANK * N_BRAM){1'b1}};
                    // waddr <= waddr + 1;
                    w_done <= 1'b0;
                    state <= 1;
                end
            end

            1: begin
                if(data_valid)begin
                    if(counter == (image_dim >> 5))begin
                        //  state <= 0;
                         counter <= 0;
                         waddr <= 0;
                         wren <= {(N_BANK * N_BRAM){1'b0}};
                         w_done <= 1'b1;
                         data <= 0;
                         state <= 2;
                    end else begin
                         data <= i_data;
                         counter <= counter + 1;
                         wren <= {(N_BANK * N_BRAM){1'b1}};
                         waddr <= waddr + 1;
                         w_done <= 1'b0;
                    end
                end else begin
                    counter <= counter;
                    waddr <= waddr;
                    w_done <= 1'b0;
                    wren <= 0;
                    data <= data;
                end
            end

            // 0:begin
            //     if(data_valid)begin
            //     if(counter == (image_dim >> 5))begin
            //             //  state <= 0;
            //             counter <= 0;
            //             waddr <= 0;
            //             wren <= {(N_BANK * N_BRAM){1'b0}};
            //             w_done <= 1'b1;
            //             data <= 0;
            //             state <= 1;
            //     end else begin
            //             data <= i_data;
            //             counter <= counter + 1;
            //             wren <= {(N_BANK * N_BRAM){1'b1}};
            //             waddr = waddr + 1;
            //             w_done <= 1'b0;
            //     end
            //     end else begin
            //         counter <= counter;
            //         waddr <= waddr;
            //         w_done <= 1'b0;
            //         wren <= 0;
            //         data <= data;
            //     end
            // end

            2: begin
                if(kernal_counter == 16'd128)  //32 weight are loaded at once into FC, so 4096/32 = 128
                    state <= 0;
            end

            //for testing whether data is correctly written into bram or not
            // 1: begin
            //     if(counter == (image_dim >> 5))begin
            //         //  state <= 0;
            //          counter <= 0;
            //          rden <= 32'h0;
            //          bank_en <= 4'd0;
            //          raddr <= 0;
            //          state <= 0;
            //     end else begin
            //          counter <= counter + 1;
            //          rden <= 32'hffffffff;
            //          bank_en <= 4'b1111;
            //          raddr <= raddr + 1;
            //     end
            // end
        endcase
        

        //Include below given code for integration

        // case (state)
        //     0:begin
        //         w_done <= 0;
        //         if(w_start)begin
        //             state <= 1;
        //         end
        //     end

        //     1: begin
        //         if(data_valid)begin
        //            if(counter == (image_dim >> 5))begin
        //                 state <= 0;
        //                 counter <= 0;
        //                 waddr <= 0;
        //                 wren <= {(N_BANK * N_BRAM){1'b0}};
        //                 w_done <= 1'b1;
        //                 data <= 0;
        //            end else begin
        //                 data <= i_data;
        //                 counter <= counter + 1;
        //                 wren <= {(N_BANK * N_BRAM){1'b1}};
        //                 waddr <= waddr + 1;
        //            end
        //         end
        //     end
        //     default: state <= 0;
        // endcase
    end
end

endmodule