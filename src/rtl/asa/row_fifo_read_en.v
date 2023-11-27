`timescale 1ns / 1ps
module row_fifo_read_en#(
    parameter ROW = 9
)(
    input i_clk,
    input i_data,
    input [3:0] i_sel,
    output [ROW-1 :0] o_read_enable
    );

    reg [ROW-1:0] rden = 0;
    assign o_read_enable = rden;

    always @(*) begin
        case(i_sel)
            0: begin
                rden <= 0;
            end

            1: begin
                rden <= {8'd0, i_data};
            end

            2: begin
                rden <= {7'd0, i_data, 1'd0};
            end

            3: begin
                rden <= {6'd0, i_data, 2'd0};
            end

            4: begin
                rden <= {5'd0, i_data, 3'd0};
            end

            5: begin
                rden <= {4'd0, i_data, 4'd0};
            end

            6: begin
                rden <= {3'd0,i_data, 5'd0};
            end

            7: begin
                rden <= {2'd0, i_data, 6'd0};
            end

            8: begin
                rden <= {1'd0,i_data, 7'd0};
            end

            9: begin
                rden <= {i_data, 8'd0};
            end
        endcase
    end
endmodule
