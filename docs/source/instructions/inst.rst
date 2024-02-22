.. code::

	`define OP_CONV 'h00
	`define Opcode 3:0
	`define IW 13:4
	`define IH 23:14
	`define OW 33:24
	`define OH 43:34
	`define IC 53:44
	`define KN 63:54
	`define KW 67:64
	`define KH 71:68
	`define STRIDE 75:72
	`define PAD 78:76
	`define INPUT_ADDRESS 110:79

	`define OP_FC 'h04
	`define OPCODE 3:0
	`define WeightRows 19:4
	`define WeightCols 35:20
	`define InputRows 51:36
	`define DropoutConstant 59:52
	`define Address 91:60

	`define OP_OutputBlock 'h03
	`define AccumulantAddr 31:0
	`define OutputAddr 63:32

	`define OP_TailBlock 'h01
	`define Opcode 3:0
	`define BNChannels 13:4
	`define BNAddress 45:14
	`define BIASAddr 77:46
	`define ActType 81:78
	`define QuantScale 97:82
	`define QuantShift 102:98
	`define PoolType 105:103
	`define PoolWidth 109:106
	`define PoolHeight 113:110
	`define PoolStride 117:114
	`define PoolPadding 121:118

