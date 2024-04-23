module top_master_slave #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (INPUT_WIDTH/OUTPUT_WIDTH),
            parameter INPUT_WIDTH = 256,
            parameter OUTPUT_WIDTH = 8) (
                input [(INPUT_WIDTH)-1 : 0] din,
                input start,
                input clk,
                input [(OP_CODE_WIDTH)-1 : 0] opcode,
                //input ready,
                output reg [209:0] dout_final = 0,
                output reg valid = 0
            );

wire [175:0] dout_op_conv;
wire [207:0] dout_op_fc;
wire [138:0] dout_op_ob;
wire [166:0] dout_op_tb;
reg [(OUTPUT_WIDTH)-1 : 0] din_op_conv = 0;
reg [(OUTPUT_WIDTH)-1 : 0] din_op_fc = 0;
reg [(OUTPUT_WIDTH)-1 : 0] din_op_ob = 0;
reg [(OUTPUT_WIDTH)-1 : 0] din_op_tb = 0;
wire [(OUTPUT_WIDTH)-1 : 0] dout_top_master;
reg wr_op_conv = 0;
reg wr_op_fc = 0;
reg wr_op_ob = 0;
reg wr_op_tb = 0;
wire wr_top_master;
reg done_op_conv = 0;
reg done_op_fc = 0;
reg done_op_ob = 0;
reg done_op_tb = 0;
wire done_top_master;
wire [(OP_CODE_WIDTH)-1 : 0] sel_top_master;
reg sel_op_conv = 0;
reg sel_op_fc = 0;
reg sel_op_ob = 0;
reg sel_op_tb = 0;
wire ready_op_conv;
wire ready_op_fc;
wire ready_op_ob;
wire ready_op_tb;
reg [(1<<OP_CODE_WIDTH)-1 : 0] ready = 0;
wire valid_op_conv;
wire valid_op_fc;
wire valid_op_ob;
wire valid_op_tb;

top_master top_master(
    .din(din),
    .start(start),
    .clk(clk),
    .op_code(opcode),
    .ready_in(ready),
    .dout(dout_top_master),
    .sel(sel_top_master),
    .write(wr_top_master),
    .done(done_top_master)  
);

OP_CONV OP_CONV(
    .din(din_op_conv),
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
    .valid(valid_op_conv),
    .ready(ready_op_conv),
    .dout(dout_op_conv)
);

OP_FC OP_FC(
    .din(din_op_fc),
    .sel(sel_op_fc),
    .write(wr_op_fc),
    .done(done_op_fc),
    .clk(clk),
    .valid(valid_op_fc),
    .ready(ready_op_fc),
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
    .din(din_op_ob),
    .sel(sel_op_ob),
    .write(wr_op_ob),
    .done(done_op_ob),
    .clk(clk),
    .valid(valid_op_ob),
    .ready(ready_op_ob),
    .opcode(),
    .accumulantaddr(),
    .outputaddr(),
    .channelItr(),
    .kernelItr(),
    .imagedim(),
    .dout(dout_op_ob)
);

OP_Tailblock OP_Tailblock(
    .din(din_op_tb),
    .sel(sel_op_tb),
    .write(wr_op_tb),
    .done(done_op_tb),
    .clk(clk),
    .ready(ready_op_tb),
    .valid(valid_op_tb),
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

always @(posedge clk) begin
case(opcode) 
4'b000: begin
    dout_final <= dout_op_conv;
    sel_op_conv <= sel_top_master[0];
    wr_op_conv <= wr_top_master;
    done_op_conv <= done_top_master;
    din_op_conv <= dout_top_master;
    ready[0] <= ready_op_conv;
    valid <= valid_op_conv;
end
4'b001: begin
    dout_final <= dout_op_fc;
    sel_op_fc <= sel_top_master[1];
    wr_op_fc <= wr_top_master;
    done_op_fc <= done_top_master;
    din_op_fc <= dout_top_master;
    ready[1] <= ready_op_fc;
    valid <= valid_op_fc;
end
4'b011: begin
    dout_final <= dout_op_ob;
    sel_op_ob <= sel_top_master[2];
    wr_op_ob <= wr_top_master;
    done_op_ob <= done_top_master;
    din_op_ob <= dout_top_master;
    ready[2] <= ready_op_ob;
    valid <= valid_op_ob;
end
4'b101: begin
    dout_final <= dout_op_tb;
    sel_op_tb <= sel_top_master[3];
    wr_op_tb <= wr_top_master;
    done_op_tb <= done_top_master;
    din_op_tb <= dout_top_master;
    ready[3] <= ready_op_tb;
    valid <= valid_op_tb;
end
endcase
end
endmodule