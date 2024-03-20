module top_master_slave #(parameter op_code_width = 4, 
            parameter CNT = (data_in/data_out),
            parameter data_in = 256,
            parameter data_out = 8) (
                input [(data_in)-1 : 0] din,
                input start,
                input clk,
                input [(op_code_width)-1 : 0] op_code,
                //input ready,
                output [179:0] dout_final
            );

reg [144:0] dout_op_conv;
reg [176:0] dout_op_fc;
reg [107:0] dout_op_ob;
reg [121:0] dout_op_tb;
reg wr_op_conv;
reg wr_op_fc;
reg wr_op_ob;
reg wr_op_tb;
reg wr_top_master;
reg done_op_conv;
reg done_op_fc;
reg done_op_ob;
reg done_op_tb;
reg done_top_master;
reg [(1<<op_code_width)-1 : 0] sel_top_master;
reg [(1<<op_code_width)-1 : 0] sel_op_conv;
reg [(1<<op_code_width)-1 : 0] sel_op_fc;
reg [(1<<op_code_width)-1 : 0] sel_op_ob;
reg [(1<<op_code_width)-1 : 0] sel_op_tb;

top_master top_master(
    .din(din),
    .start(start),
    .clk(clk),
    .op_code(op_code),
    .ready_in(ready),
    .dout(dout_final),
    .sel(sel_top_master),
    .write(wr_top_master),
    .done(done_top_master)  
);

OP_CONV OP_CONV(
    .din(),
    .sel(sel_op_conv),
    .write(wr_op_conv),
    .done(done_op_conv),
    .clk(clk),
    .opcode(),
    .IW(),
    .IH(),
    .OW(),
    .OH(),
    .IC(),
    .KN(),
    .KW(),
    .KH(),
    .STRIDE(),
    .PAD(),
    .INPUT_ADDRESS(),
    .channelItr(),
    .kernelItr(),
    .valid(),
    .ready(),
    .dout(dout_op_conv)
);

OP_FC OP_FC(
    .din(),
    .sel(sel_op_fc),
    .write(wr_op_fc),
    .done(done_op_fc),
    .clk(clk),
    .valid(),
    .ready(),
    .opcode(),
    .weightrows(),
    .weightcols(),
    .inputrows(),
    .dropoutconstant(),
    .address(),
    .flatten(),
    .imagedim(),
    .imageendaddr(),
    .FCbias(),
    .dout(dout_op_fc)
);

OP_Outputblock OP_Outputblock(
    .din(),
    .sel(sel_op_ob),
    .write(wr_op_ob),
    .done(done_op_ob),
    .clk(clk),
    .valid(),
    .ready(),
    .opcode(),
    .accumulantaddr(),
    .outputaddr(),
    .channelItr(),
    .kernelItr(),
    .imagedim(),
    .dout(dout_op_ob)
);

OP_Tailblock OP_Tailblock(
    .din(),
    .sel(sel_op_tb),
    .write(wr_op_tb),
    .done(done_op_tb),
    .clk(clk),
    .ready(),
    .valid(),
    .opcode(),
    .BNchannels(),
    .BNaddress(),
    .BIASaddr(),
    .acttype(),
    .quantscale(),
    .quantshift(),
    .pooltype(),
    .poolwidth(),
    .poolheight(),
    .poolstride(),
    .poolpadding(),
    .dout(dout_op_tb)
);

case(opcode) 
4'b000: begin
    dout_final <= dout_op_conv;
    sel_op_conv <= sel_top_master;
    wr_op_conv <= wr_top_master;
    done_op_conv <= done_top_master;
end
4'b001: begin
    dout_final <= dout_op_fc;
    sel_op_fc <= sel_top_master;
    wr_op_fc <= wr_top_master;
    done_op_fc <= done_top_master;
end
4'b011: begin
    dout_final <= dout_op_ob;
    sel_op_ob <= sel_top_master;
    wr_op_ob <= wr_top_master;
    done_op_ob <= done_top_master;
end
4'b101: begin
    dout_final <= dout_op_tb;
    sel_op_tb <= sel_top_master;
    wr_op_tb <= wr_top_master;
    done_op_tb <= done_top_master;
end
endcase
endmodule