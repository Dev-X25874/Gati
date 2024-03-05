module controller_after_main_design_gen#(
    parameter COL = 4,
    parameter W_DATA = 32
)(
    input i_clk,
    input [((W_DATA) * COL) -1:0] i_data,
    input [COL-1:0] i_fifo_empty,
    output [(W_DATA):0] o_data,
    output reg wr_en_final_fifo = 0,
    output [COL-1:0] o_read_enable
);
reg [(W_DATA):0] data = 0;
reg [1:0] state = 0;
reg [COL-1:0] rden = 0;
reg [($clog2(COL)): 0] cnt = 0;
reg [((W_DATA) * COL) -1:0] input_data = 0;
assign o_data = data;
assign o_read_enable = rden;
always @(posedge i_clk)begin
    case(state)
        0: begin
            cnt <= 0;
            wr_en_final_fifo <= 0;
            if(i_fifo_empty == 4'b0000)begin
                state <= 1;
                rden <= {COL{1'b1}};
            end
            else begin
                state <= 0;
                rden <= {COL{1'b0}};
            end
        end
        1: begin
            rden <= 0;
            state <= 2;
            input_data <= i_data;
        end
        2: begin
            if(cnt >= COL)begin
                state <= 0;
                wr_en_final_fifo <= 0;
                cnt <= 0;
                data <= 0;
                rden <= 0;
            end else begin
                rden <= 0;
                data <= input_data[(((COL - cnt) * (W_DATA))-1) -: (W_DATA)];
                wr_en_final_fifo <= 1;
                cnt <= cnt + 1;
                state <= 2;
            end
        end
    endcase
end
endmodule