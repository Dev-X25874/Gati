//this module comprises of the connections between master and the slave for their communication

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
    output reg [(OP_CODE_WIDTH)-1 : 0] valid = 0
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
wire [175:0] dout_conv;
wire [207:0] dout_FC;
wire [138:0] dout_OB;
wire [166:0] dout_TB;
wire [209:0] dout;

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
.valid(valid_conv),
.ready(ready_conv),
.dout(dout_conv)
);

OP_FC OP_FC(
.din(dout_top_master),
.sel(select_line),
.write(wr),
.done(done_op_fc),
.clk(clk),
.valid(valid_FC),
.ready(ready_FC),
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
.dout(dout_FC)
);

OP_Outputblock OP_Outputblock(
.din(dout_top_master),
.sel(select_line),
.write(wr),
.done(done_top_master),
.clk(clk),
.valid(valid_OB),
.ready(ready_OB),
.opcode(),
.accumulantaddr(),
.outputaddr(),
.channelItr(),
.kernelItr(),
.imagedim(),
.dout(dout_OB)
);

OP_Tailblock OP_Tailblock(
.din(dout_top_master),
.sel(select_line),
.write(wr_op_tb),
.done(done_top_master),
.clk(clk),
.ready(ready_TB),
.valid(valid_TB),
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
.dout(dout_TB)
);

assign ready = (ready_conv | ready_FC | ready_OB | ready_TB);

always @(posedge clk) begin  //this is an internal mux so that the appropriate signal get connected with each other as opcode changes
    case(opcode) 
    4'b000: begin  //OP_CONV
        dout_final <= dout_conv;
        valid <= valid_conv;
    end
    4'b001: begin  //OP_FC
        dout_final <= dout_FC;
        valid <= valid_FC;
    end
    4'b011: begin  //OP_OUTPUTBLOCK
        dout_final <= dout_OB;
        valid <= valid_OB;
    end
    4'b101: begin  //OP_TAILBLOCK
        dout_final <= dout_TB;
        valid <= valid_TB;
    end
    endcase
    end

endmodule