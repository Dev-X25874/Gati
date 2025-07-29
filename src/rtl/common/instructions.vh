`define OP_CONV 'h00
// Opcode
`define CONV_Opcode 3:0
`define CONV_Opcode_WIDTH 4
// Width of the input image
`define CONV_IW 13:4
`define CONV_IW_WIDTH 10
// Height of the input image
`define CONV_IH 23:14
`define CONV_IH_WIDTH 10
// Channel count for the input
`define CONV_IC 35:24
`define CONV_IC_WIDTH 12
// Kernel count for the input
`define CONV_KN 47:36
`define CONV_KN_WIDTH 12
// Kernel width
`define CONV_KW 51:48
`define CONV_KW_WIDTH 4
// Kernel Height
`define CONV_KH 55:52
`define CONV_KH_WIDTH 4
`define CONV_Stride 59:56
`define CONV_Stride_WIDTH 4
`define CONV_PadLeft 62:60
`define CONV_PadLeft_WIDTH 3
`define CONV_PadBottom 65:63
`define CONV_PadBottom_WIDTH 3
`define CONV_PadRight 68:66
`define CONV_PadRight_WIDTH 3
`define CONV_PadTop 71:69
`define CONV_PadTop_WIDTH 3
`define CONV_StartRowSkip 75:72
`define CONV_StartRowSkip_WIDTH 4
`define CONV_EndRowSkip 79:76
`define CONV_EndRowSkip_WIDTH 4
`define CONV_ImageStartAddress 111:80
`define CONV_ImageStartAddress_WIDTH 32
`define CONV_ImageEndAddress 143:112
`define CONV_ImageEndAddress_WIDTH 32
`define CONV_WeightStartAddress 175:144
`define CONV_WeightStartAddress_WIDTH 32
`define CONV_WeightEndAddress 207:176
`define CONV_WeightEndAddress_WIDTH 32
// Set if the entire image can be fetched in im2col blocks at o
// nce
`define CONV_Im2colPrefetch 208:208
`define CONV_Im2colPrefetch_WIDTH 1
// Channel count for weight
`define CONV_KC 220:209
`define CONV_KC_WIDTH 12
`define CONV_ConvType 222:221
`define CONV_ConvType_WIDTH 2
// If a regular conv is supposed to be performed on a pointwise
// -optimal architecture, this flag is set
`define CONV_ChannelDuplicate 223:223
`define CONV_ChannelDuplicate_WIDTH 1

`define OP_TailBlock 'h01
`define TailBlock_Opcode 3:0
`define TailBlock_Opcode_WIDTH 4
`define TailBlock_ActEn 4:4
`define TailBlock_ActEn_WIDTH 1
`define TailBlock_ActType 8:5
`define TailBlock_ActType_WIDTH 4
`define TailBlock_ActParam 16:9
`define TailBlock_ActParam_WIDTH 8
`define TailBlock_QuantEn 17:17
`define TailBlock_QuantEn_WIDTH 1
`define TailBlock_QuantScale 33:18
`define TailBlock_QuantScale_WIDTH 16
`define TailBlock_QuantShift 38:34
`define TailBlock_QuantShift_WIDTH 5
`define TailBlock_PoolEn 39:39
`define TailBlock_PoolEn_WIDTH 1
`define TailBlock_PoolType 42:40
`define TailBlock_PoolType_WIDTH 3
`define TailBlock_PoolScale 58:43
`define TailBlock_PoolScale_WIDTH 16
`define TailBlock_PoolShift 63:59
`define TailBlock_PoolShift_WIDTH 5
`define TailBlock_PoolWidth 73:64
`define TailBlock_PoolWidth_WIDTH 10
`define TailBlock_PoolHeight 83:74
`define TailBlock_PoolHeight_WIDTH 10
`define TailBlock_PoolStride 87:84
`define TailBlock_PoolStride_WIDTH 4
`define TailBlock_PoolPadding 91:88
`define TailBlock_PoolPadding_WIDTH 4
`define TailBlock_PoolCeil 92:92
`define TailBlock_PoolCeil_WIDTH 1
// For pools with input size that is not evenly divisible by ke
// rnel size, mod count is the ceil(input % kernel). For exampl
// e, 21x21 for kernel 2x2, mod count is 1 i.e. 1 extra column 
// to be considered.
`define TailBlock_PoolModCount 96:93
`define TailBlock_PoolModCount_WIDTH 4
// Same as above but for cols
`define TailBlock_PoolModCountCols 100:97
`define TailBlock_PoolModCountCols_WIDTH 4
// Same as PadSides for convolution
`define TailBlock_PoolPadSides 104:101
`define TailBlock_PoolPadSides_WIDTH 4
`define TailBlock_BiasEn 105:105
`define TailBlock_BiasEn_WIDTH 1
// There are two known bias widths 8/32. This is that field.
`define TailBlock_BiasWidth 113:106
`define TailBlock_BiasWidth_WIDTH 8
`define TailBlock_BiasStartAddress 145:114
`define TailBlock_BiasStartAddress_WIDTH 32
`define TailBlock_BiasEndAddress 177:146
`define TailBlock_BiasEndAddress_WIDTH 32
`define TailBlock_NegAlpha 187:178
`define TailBlock_NegAlpha_WIDTH 10
`define TailBlock_PosAlpha 197:188
`define TailBlock_PosAlpha_WIDTH 10

`define OP_OutputBlock 'h02
`define OutputBlock_Opcode 3:0
`define OutputBlock_Opcode_WIDTH 4
`define OutputBlock_AccumulantAddr 35:4
`define OutputBlock_AccumulantAddr_WIDTH 32
`define OutputBlock_AccumulantReadFirst 36:36
`define OutputBlock_AccumulantReadFirst_WIDTH 1
`define OutputBlock_OutputAddr 68:37
`define OutputBlock_OutputAddr_WIDTH 32
`define OutputBlock_ChannelItr 80:69
`define OutputBlock_ChannelItr_WIDTH 12
`define OutputBlock_KernelItr 92:81
`define OutputBlock_KernelItr_WIDTH 12
// Following the SA, there are tail blocks. Some of the tail bl
// ocks like maxpool modify the shape of the output, this field
//  accounts for that. In cases, when shape is not modified, th
// is field is equal to ImageDimAcc. Additionally, if FlatContr
// oller flag is set to 1, this field is the product of ceil_mo
// d(OC*OH*OW, AXI_WIDTH).
`define OutputBlock_ImageDimOutput 108:93
`define OutputBlock_ImageDimOutput_WIDTH 16
// Output of the conv operation (HxW)
`define OutputBlock_ImageDimAcc 124:109
`define OutputBlock_ImageDimAcc_WIDTH 16
// For layer with fewer channels than number of columns in the 
// systolic array, accumulation of partial sums across iteratio
// ns is disabled
`define OutputBlock_AccEn 125:125
`define OutputBlock_AccEn_WIDTH 1
// If this layer's output is supposed to be sent back to the CP
// U, this flag is set
`define OutputBlock_DispatchEn 126:126
`define OutputBlock_DispatchEn_WIDTH 1
// This is a integrity id that the FPGA should attach to the Ad
// dr part of the receiving DWP packet.
`define OutputBlock_DispatchID 158:127
`define OutputBlock_DispatchID_WIDTH 32
// If output dimensions of a conv operation can fit on the FPGA
//  output buffers, they should not be sent to the DRAM, all of
//  the conv can happen on chip saving latency. This flag sets 
// that bit.
`define OutputBlock_OnChipAcc 159:159
`define OutputBlock_OnChipAcc_WIDTH 1
`define OutputBlock_OH 169:160
`define OutputBlock_OH_WIDTH 10
`define OutputBlock_OW 179:170
`define OutputBlock_OW_WIDTH 10
// If 1, treat outputs from the megablock as flat bytes, not as
//  aligned bytes with zeros in it
`define OutputBlock_FlatController 180:180
`define OutputBlock_FlatController_WIDTH 1
`define OutputBlock_OpWidth 183:181
`define OutputBlock_OpWidth_WIDTH 3

`define OP_FC 'h03
`define FC_Opcode 3:0
`define FC_Opcode_WIDTH 4
`define FC_WeightRows 19:4
`define FC_WeightRows_WIDTH 16
`define FC_WeightCols 35:20
`define FC_WeightCols_WIDTH 16
`define FC_InputRows 51:36
`define FC_InputRows_WIDTH 16
`define FC_DropoutConstant 59:52
`define FC_DropoutConstant_WIDTH 8
// If this FC follows a CONV, the outputs of conv should be fla
// ttened, this bit signals flattening
`define FC_Flatten 60:60
`define FC_Flatten_WIDTH 1
// If flatten is 1, this is the Height x Width of the previous 
// conv. For example, if conv output is 128x7x7, ImageDim will 
// be 49
`define FC_ImageDim 80:61
`define FC_ImageDim_WIDTH 20
`define FC_ImageStartAddress 112:81
`define FC_ImageStartAddress_WIDTH 32
`define FC_ImageEndAddr 144:113
`define FC_ImageEndAddr_WIDTH 32
`define FC_WeightStartAddress 176:145
`define FC_WeightStartAddress_WIDTH 32
`define FC_WeightEndAddress 208:177
`define FC_WeightEndAddress_WIDTH 32
// Input vector (say of size 4096) can be seen to be a matrix o
// f size 32x128, vec2mat cols is the number of cols of this ma
// trix i.e. 128
`define FC_Vec2MatCols 224:209
`define FC_Vec2MatCols_WIDTH 16

`define OP_START 'hf
`define START_Opcode 3:0
`define START_Opcode_WIDTH 4
`define START_LayerNumber 15:4
`define START_LayerNumber_WIDTH 12
`define START_TotalLayers 27:16
`define START_TotalLayers_WIDTH 12

`define OP_NMS 'h04
// Opcode
`define NMS_Opcode 3:0
`define NMS_Opcode_WIDTH 4
// IOU Threshold
`define NMS_IOU 19:4
`define NMS_IOU_WIDTH 16
// Shift Value for integer IOU
`define NMS_IOUShift 23:20
`define NMS_IOUShift_WIDTH 4
// Score Threshold
`define NMS_ScoreThresh 39:24
`define NMS_ScoreThresh_WIDTH 16
// Total Boxes in Input
`define NMS_TotalInBoxes 59:40
`define NMS_TotalInBoxes_WIDTH 20
// Expected Output Boxes
`define NMS_MaxOutBoxes 67:60
`define NMS_MaxOutBoxes_WIDTH 8
// Whether its ((x1,y1),(x2,y2) or ((h,w),(c1,c2)) (center co-o
// rdinates)
`define NMS_CornerCord 68:68
`define NMS_CornerCord_WIDTH 1
// Total Classes in the dataset (for eg., COCO has 80)
`define NMS_TotalClasses 76:69
`define NMS_TotalClasses_WIDTH 8
`define NMS_BoxStartAddr 108:77
`define NMS_BoxStartAddr_WIDTH 32
`define NMS_BoxEndAddr 140:109
`define NMS_BoxEndAddr_WIDTH 32
`define NMS_ScoreStartAddr 172:141
`define NMS_ScoreStartAddr_WIDTH 32
`define NMS_ScoreEndAddr 204:173
`define NMS_ScoreEndAddr_WIDTH 32

`define OP_EltWise 'h05
// Opcode
`define EltWise_Opcode 3:0
`define EltWise_Opcode_WIDTH 4
// Whether its an Add, Sub, Mult etc.
`define EltWise_EltType 7:4
`define EltWise_EltType_WIDTH 4
`define EltWise_IW 17:8
`define EltWise_IW_WIDTH 10
`define EltWise_IH 27:18
`define EltWise_IH_WIDTH 10
`define EltWise_IC 39:28
`define EltWise_IC_WIDTH 12
`define EltWise_LeftOperandStartAddress 71:40
`define EltWise_LeftOperandStartAddress_WIDTH 32
`define EltWise_LeftOperandEndAddress 103:72
`define EltWise_LeftOperandEndAddress_WIDTH 32
`define EltWise_RightOperandStartAddress 135:104
`define EltWise_RightOperandStartAddress_WIDTH 32
`define EltWise_RightOperandEndAddress 167:136
`define EltWise_RightOperandEndAddress_WIDTH 32
// FixedPoint32 value of a_scale
`define EltWise_AScale 199:168
`define EltWise_AScale_WIDTH 32
// FixedPoint32 value of b_scale
`define EltWise_BScale 231:200
`define EltWise_BScale_WIDTH 32
`define EltWise_AZeroPoint 239:232
`define EltWise_AZeroPoint_WIDTH 8
`define EltWise_BZeroPoint 247:240
`define EltWise_BZeroPoint_WIDTH 8

`define OP_TRANSPOSE 'h07
`define TRANSPOSE_Opcode 3:0
`define TRANSPOSE_Opcode_WIDTH 4
`define TRANSPOSE_IC 15:4
`define TRANSPOSE_IC_WIDTH 12
`define TRANSPOSE_IH 25:16
`define TRANSPOSE_IH_WIDTH 10
`define TRANSPOSE_IW 35:26
`define TRANSPOSE_IW_WIDTH 10
`define TRANSPOSE_ImageStartAddress 67:36
`define TRANSPOSE_ImageStartAddress_WIDTH 32

`define OP_RESHAPE 'h06
`define RESHAPE_Opcode 3:0
`define RESHAPE_Opcode_WIDTH 4
`define RESHAPE_IC 15:4
`define RESHAPE_IC_WIDTH 12
`define RESHAPE_IH 25:16
`define RESHAPE_IH_WIDTH 10
`define RESHAPE_IW 35:26
`define RESHAPE_IW_WIDTH 10
`define RESHAPE_ImageStartAddress 67:36
`define RESHAPE_ImageStartAddress_WIDTH 32

`define ISA_VERSION 10
`define ACT_RELU 'h00
`define ACT_CLIP 'h01
`define ACT_LEAKYRELU 'h02
`define POOL_MAX 'h00
`define POOL_AVERAGE 'h01
`define POOL_GLOBAL_AVG 'h02
`define WORD_SIZE 32
`define ACC_SIZE 32
`define GATI_INST_ORG 0
`define DWP_HEADER_BYTES 12
`define DWP_PACKET_SZ 4
`define DWP_SOP 'hffffffff
`define DWP_SOP_INDEX 0
`define DWP_DS_INDEX 1
`define DWP_ADDR_INDEX 2
`define META_SOP 'hffffffffffff
`define META_TYPE_RESET 'h000000000000
`define META_TYPE_DISPATCH 'h000000000001
`define META_TYPE_PAYLOAD_SIZE 'h000000000002
`define META_TYPE_INST_ORIGIN 'h000000000003
`define META_CONST_DISPATCH_RAH 'h000000000000
`define META_CONST_DISPATCH_UART 'h000000000001
`define ELTWISE_ADD 0
`define ELTWISE_SUB 1
`define ELTWISE_MULT 2
`define INST_SIZE_BITS 256
`define META_WIDTH_BITS 48
`define RAH_APP_ID 1
`define META_APP_ID 2
`define CONV_TYPE_REGULAR 0
`define CONV_TYPE_DW 1
`define CONV_TYPE_PW 2

`define ZerothStartAddress 31:0
`define ZerothStartAddress_WIDTH 32
`define ZerothEndAddress 63:32
`define ZerothEndAddress_WIDTH 32