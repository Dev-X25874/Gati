

//`timescale 1ns / 1ps
//module col_fifo_read_en#(
//    parameter COL = 3
//)(
//    input i_clk,
//    input i_data,
//    input [$clog2(COL) - 1:0] i_sel,
//    output [COL-1 :0] o_read_enable
//    );

//    reg [COL-1:0] rden = 0;
//    reg wren = 0;
//    assign o_read_enable = rden;
//    assign o_write_enable = wren;

//    always @(*) begin
//        case(i_sel)
//            0: begin
//                rden <= 0;
//            end

//            1: begin
//                rden <= {i_data, 2'd0};
//            end

//            2: begin
//                rden <= {1'd0, i_data, 1'd0};
//            end
            
//            3: begin
//                rden <= {2'd0, i_data};
//            end
//        endcase
//    end
//endmodule
