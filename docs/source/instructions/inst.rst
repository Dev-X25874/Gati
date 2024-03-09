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
	`define ChannelItr 122:111
	`define KernelItr 134:123

	`define OP_FC 'h04
	`define Opcode 3:0
	`define WeightRows 19:4
	`define WeightCols 35:20
	`define InputRows 51:36
	`define DropoutConstant 59:52
	`define Address 91:60
	`define Flatten 92:92
	`define ImageDim 112:93
	`define ImageEndAddr 144:113
	`define FCBias 176:145

	`define OP_OutputBlock 'h03
	`define Opcode 3:0
	`define AccumulantAddr 35:4
	`define OutputAddr 67:36
	`define ChannelItr 79:68
	`define KernelItr 91:80
	`define ImageDim 107:92

	`define OP_START 'h02
	`define Opcode 3:0
	`define LayerNumber 15:4
	`define TotalLayers 27:16

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

