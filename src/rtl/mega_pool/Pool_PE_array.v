`include "../common/arch_param.vh"

`ifdef MEGA_MAX
module top_pool_PE_array#(
    parameter ROW = 9,
    parameter W_DATA = 8,
    parameter IMG_FF_DEPTH = 512,
    parameter N_MOD_STAGES = 8,
    parameter I_OP_SIZE_WIDTH = 16
)(
    input i_clk,
    input i_rstn,
    input i_mode,
    input i_start,
    input pool_stall,
    input i_done,
    input im2col_done,
    input [I_OP_SIZE_WIDTH-1 : 0] i_img_dim_Op,

    output [W_DATA-1 : 0] o_data,
    output o_datavalid,

    output [ROW-1 : 0] read_rden_ctrl_image_ff_array_delayed,
    input wire [(ROW * W_DATA)-1 : 0] data_image_ff_array_append_dv,
    input wire [ROW-1 : 0] empty_image_ff_array_rden_ctrl,
    input wire [ROW-1 : 0] almost_empty_image_ff_array_rden_ctrl,
    input wire [ROW-1 : 0] dv_image_ff_array_append_dv

);

    localparam IMG_FF_ADDR = $clog2(IMG_FF_DEPTH);

    wire read_rden_ctrl_image_ff_array;
    

    rden_delay_reg#(
        .ROW(ROW)
    ) rden_delay_reg_image_ff_array (
        .i_clk(i_clk),
        .i_rden(read_rden_ctrl_image_ff_array),
        .o_rden_img_fifo(read_rden_ctrl_image_ff_array_delayed)
    );

    //Appends data valid signal with image before sending it to delay registers
    append_dv#(
        .N_DIMENSION(ROW),
        .W_DATA(W_DATA)
    ) image_fifo_array_dv (
        .i_data(data_image_ff_array_append_dv),
        .i_data_valid(dv_image_ff_array_append_dv),
        .o_data(image_append_dv)
    );
    
    reg r_start;
    always @(posedge i_clk) begin
        if(!i_rstn) r_start <= 0;
        else begin
            if(i_start) r_start <= 1;
            else if(i_done) r_start <= 0;
            else r_start <= r_start;
        end
    end
    
    image_fifo_array_rden_pool#(
        .ROW(ROW),
        .W_ADDR(IMG_FF_ADDR),
        .W_DATA(W_DATA),
        .N_MOD_STAGES(N_MOD_STAGES),
        .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH)
    ) image_fifo_array_rden_ctrl_pool (
        .i_clk(i_clk),
        .i_rstn(i_rstn),
    	.i_trigger(r_start),
        .pool_stall(pool_stall),
        .i_fifo_empty(empty_image_ff_array_rden_ctrl),
        .i_fifo_almost_empty(almost_empty_image_ff_array_rden_ctrl),
        .i_img_dim_Op(i_img_dim_Op),
        .im2col_done(im2col_done),
        .o_read_enable(read_rden_ctrl_image_ff_array)
    );

    wire [((W_DATA + 1) * ROW)-1 : 0] image_append_dv;

    Pool_PE_array#(
        .W_DATA(W_DATA),
        .ROW(ROW)
    ) Pool_PE_array_inst (
        .i_clk(i_clk),
        .i_rstn(i_rstn),
        .i_mode(i_mode),
        .i_data(image_append_dv),
        .o_data(o_data),
        .o_datavalid(o_datavalid)
    );

endmodule


module Pool_PE_array#(
    parameter W_DATA = 8,
    parameter ROW = 9
)(
    input i_clk,
    input i_rstn,
    input i_mode,
    input [(ROW * (W_DATA + 1)) -1 : 0] i_data,
    output [W_DATA-1 : 0] o_data,
    output o_datavalid
);

genvar i;
wire [W_DATA : 0] op_data;

assign o_data = op_data[W_DATA-1 : 0];
assign o_datavalid = op_data[W_DATA];

reg [W_DATA : 0] r_i_data;

generate
    for(i = 0 ; i < ROW ; i = i+1) begin : COMP_PE
        
        wire [W_DATA : 0] w_data;
        if(i == 0) begin
            always@(posedge i_clk) r_i_data <= i_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]; 
            assign w_data = r_i_data;
        end
        
        else if(i == ROW-1) begin
            Pool_PE_block#(
                .W_DATA(W_DATA)
            ) Pool_PE_inst (
                .i_clk(i_clk),
                .i_rstn(i_rstn),
                .i_mode(i_mode),
                .i_data1(COMP_PE[i-1].w_data),
                .i_data2(i_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                .o_data(op_data)
            );
        end
        
        else begin
            Pool_PE_block#(
                .W_DATA(W_DATA)
            ) Pool_PE_inst (
                .i_clk(i_clk),
                .i_rstn(i_rstn),
                .i_mode(i_mode),
                .i_data1(COMP_PE[i-1].w_data),
                .i_data2(i_data[((ROW - i) * (W_DATA + 1))-1 -: (W_DATA + 1)]),
                .o_data(w_data)
            );
        end
    end
endgenerate

endmodule
`endif
