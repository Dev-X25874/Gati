module top_pool_engine#(
    parameter W_DATA = 8,
    parameter ROW = 9,
    parameter N_SA = 8,
    parameter IMG_FF_DEPTH = 512,
    parameter N_MOD_STAGES = 8,
    parameter I_OP_SIZE_WIDTH = 16
)(
    input i_clk,
    input i_rstn,
    input i_mode,
    input i_start,
    input i_done,
    input pool_stall,
    input im2col_done,
    input [I_OP_SIZE_WIDTH -1 : 0] i_img_dim_Op,
    output [(N_SA * W_DATA)-1 : 0] o_data,
    output [N_SA-1 : 0] o_datavalid,

    output [(N_SA * ROW)-1 : 0] read_rden_ctrl_image_ff_array_delayed,
    input wire [(N_SA * ROW * W_DATA)-1 : 0] data_image_ff_array_append_dv,
    input wire [(N_SA * ROW)-1 : 0] empty_image_ff_array_rden_ctrl,
    input wire [(N_SA * ROW)-1 : 0] almost_empty_image_ff_array_rden_ctrl,
    input wire [(N_SA * ROW)-1 : 0] dv_image_ff_array_append_dv
);


    genvar i;
    generate
    for(i = 0 ; i < N_SA ; i = i + 1) begin
        top_pool_PE_array #(
            .W_DATA(W_DATA),
            .ROW(ROW),
            .IMG_FF_DEPTH(IMG_FF_DEPTH),
            .N_MOD_STAGES(N_MOD_STAGES),
            .I_OP_SIZE_WIDTH(I_OP_SIZE_WIDTH)
        ) top_pool_PE_array_inst (
            .i_clk(i_clk),
            .i_rstn(i_rstn),
            .i_mode(i_mode),
            .i_start(i_start),
            .pool_stall(pool_stall),
            .i_done(i_done),
            .im2col_done(im2col_done),
            .i_img_dim_Op(i_img_dim_Op),
            .o_data(o_data[((N_SA-i) * W_DATA)-1 -: W_DATA]),
            .o_datavalid(o_datavalid[i]),

            .read_rden_ctrl_image_ff_array_delayed(read_rden_ctrl_image_ff_array_delayed[(ROW * (N_SA - i))-1 -: ROW]), // output

            .data_image_ff_array_append_dv(data_image_ff_array_append_dv[((ROW * W_DATA) * (N_SA - i))-1 -: (ROW * W_DATA)]), //input ROW*WDATA

            .empty_image_ff_array_rden_ctrl(empty_image_ff_array_rden_ctrl[(ROW * (N_SA - i))-1 -: ROW]), //input ROW-1
            .almost_empty_image_ff_array_rden_ctrl(almost_empty_image_ff_array_rden_ctrl[(ROW * (N_SA - i))-1 -: ROW]),
            .dv_image_ff_array_append_dv(dv_image_ff_array_append_dv[(ROW * (N_SA - i))-1 -: ROW])
        );
    end
    endgenerate

endmodule