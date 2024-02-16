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
	`define ActType 49:46
	`define QuantScale 65:50
	`define QuantShift 70:66
	`define PoolType 73:71
	`define PoolWidth 77:74
	`define PoolHeight 81:78
	`define PoolStride 85:82
	`define PoolPadding 89:86

