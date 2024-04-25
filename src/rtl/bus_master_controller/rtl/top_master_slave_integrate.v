module top_master_slave_integrate #(parameter OP_CODE_WIDTH = 4, 
            parameter CNT = (INPUT_WIDTH/OUTPUT_WIDTH),
            parameter INPUT_WIDTH = 256,
            parameter OUTPUT_WIDTH = 8) (
                input [(INPUT_WIDTH)-1 : 0] din,
                input start,
                input clk,
                input [(OP_CODE_WIDTH)-1 : 0] opcode,
                output [(OP_CODE_WIDTH)-1 : 0] valid,
                output [3:0] opcode_conv,
                output [9:0] IW,
                output [9:0] IH,
                output [9:0] OW,
                output [9:0] OH,
                output [9:0] IC,
                output [9:0] KN,
                output [13:0] KW,
                output [3:0] KH,
                output [3:0] STRIDE,
                output [2:0] PAD,
                output [31:0] INPUT_ADDRESS,
                output [11:0] channelItr_conv,
                output [11:0] kernelItr_conv,
                output [31:0] stop_addr_conv,
                output [3:0] opcode_FC,
                output [15:0] weightrows,
                output [15:0] weightcols,
                output [15:0] inputrows,
                output [7:0] dropoutconstant,
                output [31:0] address,
                output flatten,
                output [19:0] imagedim_FC,
                output [31:0] imageendaddr,
                output [31:0] FCbias,
                output [31:0] stop_addr_FC,
                output [3:0] opcode_OB,
                output [31:0] accumulantaddr,
                output [31:0] outputaddr,
                output [11:0] channelItr_OB,
                output [11:0] kernelItr_OB,
                output [15:0] imagedim_OB,
                output [31:0] stop_addr_OB,
                output [7:0] relu_clip,
                output [7:0] maxpool_threshold,
                output [31:0] stop_addr_TB,
                output [3:0] opcode_TB,
                output [9:0] BNchannels,
                output [31:0] BNaddress,
                output [31:0] BIASaddr,
                output [3:0] acttype,
                output [15:0] quantscale,
                output [4:0] quantshift,
                output [2:0] pooltype,
                output [3:0] poolwidth,
                output [3:0] poolheight,
                output [3:0] poolstride,
                output [3:0] poolpadding
    );

wire [(OUTPUT_WIDTH)-1 : 0] dout_top_master; 
wire select_line; 
wire wr;
wire done_top_master;
wire [(OP_CODE_WIDTH)-1 : 0] ready;
wire ready_conv;
wire ready_FC;
wire ready_OB;
wire ready_TB;

top_master top_master(
    .din(din),
    .start(start),
    .clk(clk),
    .op_code(opcode),
    .ready_in(ready),
    .dout(dout_top_master),
    .sel(select_line),
    .write(wr),
    .done(done_top_master)
);

OP_CONV OP_CONV(
    .din(dout_top_master),
    .sel(select_line),
    .write(wr),
    .done(done_top_master),
    .clk(clk),
    .opcode(opcode_conv),
    .IW(IW),
    .IH(IH),
    .OW(OW),
    .OH(OH),
    .IC(IC),
    .KN(KN),
    .KW(KW),
    .KH(KH),
    .STRIDE(STRIDE),
    .PAD(PAD),
    .INPUT_ADDRESS(INPUT_ADDRESS),
    .channelItr(channelItr_conv),
    .kernelItr(kernelItr_conv),
    .valid(valid),
    .ready(ready_conv),
    .stop_addr(stop_addr_conv)
);

OP_FC OP_FC(
    .din(dout_top_master),
    .sel(select_line),
    .write(wr),
    .done(done_top_master),
    .clk(clk),
    .valid(valid),
    .ready(ready_Fc),
    .opcode(opcode_FC),
    .weightrows(weightrows),
    .weightcols(weightcols),
    .inputrows(inputrows),
    .dropoutconstant(dropoutconstant),
    .address(address),
    .flatten(flatten),
    .imagedim(imagedim_FC),
    .imageendaddr(imageendaddr),
    .FCbias(FCbias),
    .stop_addr(stop_addr_FC)
);

OP_Outputblock OP_Outputblock(
    .din(dout_top_master),
    .sel(select_line),
    .write(wr),
    .done(done_top_master),
    .clk(clk),
    .valid(valid),
    .ready(ready_OB),
    .opcode(opcode_OB),
    .accumulantaddr(accumulantaddr),
    .outputaddr(outputaddr),
    .channelItr(channelItr_OB),
    .kernelItr(kernelItr_OB),
    .imagedim(imagedim_OB),
    .stop_addr(stop_addr_OB)
);

OP_Tailblock OP_Tailblock(
    .din(dout_top_master),
    .sel(select_line),
    .write(wr),
    .done(done_top_master),
    .clk(clk),
    .ready(ready_TB),
    .valid(valid),
    .opcode(opcode_TB),
    .BNchannels(BNchannels),
    .BNaddress(BNaddress),
    .BIASaddr(BIASaddr),
    .acttype(acttype),
    .quantscale(quantscale),
    .quantshift(quantshift),
    .pooltype(pooltype),
    .poolwidth(poolwidth),
    .poolheight(poolheight),
    .poolstride(poolstride),
    .poolpadding(poolpadding),
    .relu_clip(relu_clip),
    .maxpool_threshold(maxpool_threshold),
    .stop_addr(stop_addr_TB)
);

assign ready = (ready_conv | ready_FC | ready_OB | ready_TB);

endmodule