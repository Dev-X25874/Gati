/*
    Takes partial sums from every FFO in the partial sum FFO array and
    returns the partial sum of each fifo one at a time, storing it in a single fifo.
    For every engine, this controller is generated N_SA times.
*/
module psum_fifo_ctrl#(
    parameter COL = 4,
    parameter W_PSUM = 19,
    parameter N_SA = 4
)(
    input i_clk,
    input i_rst,
    input  [((COL * W_PSUM) * N_SA)-1 : 0] i_data,
    input [(COL * N_SA)-1 : 0] i_fifo_empty,
    output [(COL * N_SA)-1 : 0] o_fifo_read_enable,
    output [N_SA-1 : 0] o_fifo_write_enable,
    output [(W_PSUM * N_SA)-1 : 0] o_data
);

genvar i;
generate
    for (i = 0; i < N_SA; i = i + 1) begin
        col_fifo_data#(
            .COL(COL),
            .W_PSUM(W_PSUM)
        ) last_ff_controller (
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_data(i_data[((COL * W_PSUM) * (N_SA - i))-1 -: (COL * W_PSUM)]),
            .i_fifo_empty(i_fifo_empty[(COL * (N_SA - i))-1 -: COL]),  
            .o_data(o_data[(W_PSUM * (N_SA - i))-1 -: W_PSUM]),
            .wr_en_final_fifo(o_fifo_write_enable[i]),
            .o_read_enable(o_fifo_read_enable[(COL * (N_SA - i))-1 -: COL])
        );
    end
endgenerate
    
endmodule

module col_fifo_data#(
    parameter COL = 3,
    parameter W_PSUM = 8
)(
    input i_clk,
    input i_rst,
    input [(W_PSUM * COL) -1:0] i_data,
    input [COL-1:0] i_fifo_empty,
    output [W_PSUM-1 : 0] o_data,
    output reg wr_en_final_fifo = 0,
    output [COL-1:0] o_read_enable
);

reg [W_PSUM : 0] data = 0;
reg [1:0] state = 0;
reg [COL-1:0] rden = 0;
reg [($clog2(COL)): 0] cnt = 0;

assign o_data = data;
assign o_read_enable = rden;

always @(posedge i_clk)begin
    if(i_rst)begin
        data <= 0;
        rden <= 0;
        state <= 0;
        cnt <= 0;
    end else begin
        case(state)
            0: begin
                if(i_fifo_empty == 0)begin
                    state <= 1;
                    rden <= {COL{1'b1}};
                end
                    cnt <= 0;
                    wr_en_final_fifo <= 0;
            end

            1: begin
                rden <= 0;
                state <= 2; 
            end

            2: begin
                if(cnt == COL)begin
                    state <= 0;
                    wr_en_final_fifo <= 0;
                    cnt <= 0;
                    data <= 0;
                end else begin
                    data <= i_data[(((COL - cnt) * W_PSUM)-1) -: W_PSUM];
                    wr_en_final_fifo <= 1;
                    cnt <= cnt + 1;
                end
            end
        endcase
    end
end

endmodule