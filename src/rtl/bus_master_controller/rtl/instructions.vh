`ifndef INSTRUCTIONS_VH
`define INSTRUCTIONS_VH

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
`define Stride 75:72
`define Pad 78:76
`define ChannelItr 90:79
`define KernelItr 102:91
`define ImageStartAddress 134:103
`define ImageEndAddress 166:135
`define WeightStartAddress 198:167
`define WeightEndAddress 230:199

`define OP_FC 'h04
`define Opcode 3:0
`define WeightRows 19:4
`define WeightCols 35:20
`define InputRows 51:36
`define DropoutConstant 59:52
`define Flatten 60:60
`define ImageDim 80:61
`define ImageStartAddress 112:81
`define ImageEndAddr 144:113
`define KernelIteration 160:145
`define RWAddressCountFlatten 176:161

`define OP_OutputBlock 'h03
`define Opcode 3:0
`define AccumulantAddr 35:4
`define OutputAddr 67:36
`define ChannelItr 79:68
`define KernelItr 91:80
`define ImageDimOutput 107:92
`define ImageDimAcc 123:108
`define AccEn 124:124

`define OP_START 'h11
`define Opcode 3:0
`define LayerNumber 15:4
`define TotalLayers 27:16

`define OP_TailBlock 'h01
`define Opcode 3:0
`define BNEn 4:4
`define BNChannels 14:5
`define BNStartAddress 46:15
`define BNEndAddress 78:47
`define ActEn 79:79
`define ActType 83:80
`define ActParam 91:84
`define QuantEn 92:92
`define QuantScale 108:93
`define QuantShift 113:109
`define PoolEn 114:114
`define PoolType 117:115
`define PoolWidth 121:118
`define PoolHeight 125:122
`define PoolStride 129:126
`define PoolPadding 133:130
`define BiasEn 134:134
`define FCBiasEn 135:135
`define BiasStartAddress 167:136
`define BiasEndAddress 199:168

`endif