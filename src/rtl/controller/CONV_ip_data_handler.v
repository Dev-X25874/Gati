/* 
    This module is used to duplicate the data from the DRAM across the N_SA
    number of SA engines. The data is duplicated only when the 'dup_flag' is high.
    This is required to compute the regular convolution with SA arch has COL_SA = 1.
    While computing the depthwise convolution, the 'dup_flag' is low and the data is not duplicated.
*/
module CONV_ip_data_handler #(
    parameter AXI_WIDTH = 256,
    parameter N_FIFO = 32,
    parameter DATA_WIDTH = 8,
    parameter N_SA = 16
)(
    input clk,
    input rstn,
    input [AXI_WIDTH-1 : 0] i_data,
    input i_dv,
    input dup_flag,
    input iter_done,
    input c_done,
    
    output [AXI_WIDTH-1 : 0] o_data,
    output o_dv
);
    localparam MUX_DATA_WIDTH = (N_FIFO/N_SA)*DATA_WIDTH;
    
    reg [$clog2(N_SA)-1 : 0] sel;
    wire [MUX_DATA_WIDTH - 1 : 0] mux_op;
    reg mux_o_dv;
    
    assign o_data = dup_flag ? {N_SA{mux_op}} : i_data;
    assign o_dv   = dup_flag ? mux_o_dv       : i_dv;
    
    always@(posedge clk) begin
        if(!rstn) sel <= 0;
        else begin
            if(!dup_flag) sel <= 0;
            else begin
                if(c_done) sel <= 0;
                else if(iter_done) sel <= sel+1;
            end
        end
    end
    
    always@(posedge clk) begin
        mux_o_dv <= (!dup_flag)? 0 : i_dv;
    end
    
    mux_param #(
        .PORT_SIZE(MUX_DATA_WIDTH),
        .NO_PORT(N_SA)
    ) mux_param_inst(
        .clk(clk),
        .sel(sel),
        .in(i_data),
        .out(mux_op)
    );

endmodule