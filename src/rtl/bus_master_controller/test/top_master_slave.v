//this module comprises of the connections between master and the slave for their communication

module top_master_slave #(parameter OP_CODE_WIDTH = 4, 
parameter CNT = (INPUT_WIDTH/OUTPUT_WIDTH),
parameter INPUT_WIDTH = 256,
parameter OUTPUT_WIDTH = 8,
parameter NO_OF_OPERATOR = 4,
parameter ADDRESS_WIDTH = 32,
parameter IW_WIDTH = 10,
parameter IH_WIDTH = 10,
parameter OW_WIDTH = 10,
parameter OH_WIDTH = 10,
parameter IC_WIDTH = 10
parameter KN_WIDTH = 10,
parameter KW_WIDTH = 4,
parameter KH_WIDTH = 4,
parameter STRIDE_WIDTH = 4,
parameter PAD_WIDTH = 3,
parameter WEIGHTROWS_WIDTH = 16,
parameter WEIGHTCOLS_WIDTH = 16,
parameter INPUTROWS_WIDTH = 16,
parameter DROPOUTCONSTANT_WIDTH = 8,
parameter FLATTEN_WIDTH = 1,
parameter IMAGEDIN_WIDTH = 20,
parameter RWADDRESSCOUNTFLATTEN_WIDTH = 16,
parameter CHANNELITR_WIDTH = 12,
parameter KERNELITR_WIDTH = 12,
parameter IMAGEDIMOUTPUT_WIDTH = 16,
parameter IMAGEDIMACC_WIDTH = 16,
parameter ACCEN_WIDTH = 1,
parameter BNEN_WIDTH = 1,
parameter ACTEN_WIDTH = 1,
parameter ACTTYPE_WIDTH = 4,
parameter ACTPARAM_WIDTN = 8,
parameter QUANTEN_WIDTH = 1,
parameter QUANTSCALE_WIDTH = 16,
parameter QUANTSHIFT_WIDTH = 5,
parameter POOLEN_WIDTH = 1,
parameter POOLTYPE_WIDTH = 3,
parameter POOLWIDTH_WIDTH = 4,
parameter POOLHEIGHT_WIDTH = 4,
parameter POOLSTRIDE_WIDTH = 4,
parameter POOLPADDING_WIDTH = 4,
parameter BIASEN_WIDTH = 1,
parameter BNCHANNELS_WIDTH = 10,
parameter FCBIASEN = 1) (
    input [(INPUT_WIDTH)-1 : 0] din,
    input start,
    input clk,
    input [(OP_CODE_WIDTH)-1 : 0] opcode,
    //input ready,
    output reg [378:0] dout_final = 0,
    output reg [(NO_OF_OPERATOR)-1 : 0] valid = 0
);

`include "instructions.vh"

wire [(OUTPUT_WIDTH)-1 : 0] dout_top_master; 
wire [(1<<OP_CODE_WIDTH)-1 : 0] select_line; 
wire wr;
wire done_top_master;
wire [(NO_OF_OPERATOR)-1 : 0] ready;
wire ready_conv;
wire ready_FC;
wire ready_OB;
wire ready_TB;
wire [272:0] dout_conv;
wire [151:0] dout_FC;
wire [117:0] dout_OB;
wire [378:0] dout_TB;
//wire [378:0] dout;
wire valid_conv;
wire valid_FC;
wire valid_OB;
wire valid_TB;

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
.sel(select_line[`CONV_Opcode]),
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
.channelItr(),
.kernelItr(),
.ImageStartAddress(),
.ImageEndAddress(), 
.WeightStartAddress(),
.WeightEndAddress(),
.valid(valid_conv[`CONV_Opcode]),
.ready(ready_conv[`CONV_Opcode]),
.dout(dout_conv)
);

OP_FC OP_FC(
.din(dout_top_master),
.sel(select_line[`FC_Opcode]),
.write(wr),
.done(done_top_master),
.clk(clk),
.valid(valid_FC[`FC_Opcode]),
.ready(ready_FC[`FC_Opcode]),
.opcode(),
.weightrows(),
.weightcols(),
.inputrows(),
.dropoutconstant(),
.flatten(),
.imagedim(),
.ImageStartAddress(),
.ImageEndAddr(),
.KernelIteration(),
.RWAddressCountFlatten(),
.dout(dout_FC)
);

OP_Outputblock OP_Outputblock(
.din(dout_top_master),
.sel(select_line[`OutputBlock_Opcode]),
.write(wr),
.done(done_top_master),
.clk(clk),
.valid(valid_OB[`OutputBlock_Opcode]),
.ready(ready_OB[`OutputBlock_Opcode]),
.opcode(),
.accumulantaddr(),
.outputaddr(),
.channelItr(),
.kernelItr(),
.ImageDimOutput(),
.ImageDimAcc(),
.AccEn(),
.dout(dout_OB)
);

OP_Tailblock OP_Tailblock(
.din(dout_top_master),
.sel(select_line[`TailBlock_Opcode]),
.write(wr_op_tb),
.done(done_top_master),
.clk(clk),
.ready(ready_TB[`TailBlock_Opcode]),
.valid(valid_TB[`TailBlock_Opcode]),
.opcode(),
.BNEn(),
.BNchannels(),
.BNStartAddress(),
.BNEndAddress(),
.ActEn(),
.acttype(),
.ActParam(),
.QuantEn(),
.quantscale(),
.quantshift(),
.PoolEn(),
.pooltype(),
.poolwidth(),
.poolheight(),
.poolstride(),
.poolpadding(),
.BiasEn(),
.FCBiasEn(),
.BiasStartAddress(),
.BiasEndAddress(),
.dout(dout_TB)
);

//assign ready = (ready_conv | ready_FC | ready_OB | ready_TB);

always @(posedge clk) begin  //this is an internal mux so that the appropriate signal get connected with each other as opcode changes
    case(opcode) 
    4'b000: begin  //OP_CONV
        dout_final <= dout_conv;
        //valid <= valid_conv;
    end
    4'b001: begin  //OP_FC
        dout_final <= dout_FC;
        //valid <= valid_FC;
    end
    4'b011: begin  //OP_OUTPUTBLOCK
        dout_final <= dout_OB;
        //valid <= valid_OB;
    end
    4'b101: begin  //OP_TAILBLOCK
        dout_final <= dout_TB;
        //valid <= valid_TB;
    end
    endcase
    end

endmodule