.. code::

	`define OP_CONV 'h00
	`define CONV_Opcode 3:0
	`define CONV_Opcode_WIDTH 4
	`define CONV_IW 13:4
	`define CONV_IW_WIDTH 10
	`define CONV_IH 23:14
	`define CONV_IH_WIDTH 10
	`define CONV_OW 33:24
	`define CONV_OW_WIDTH 10
	`define CONV_OH 43:34
	`define CONV_OH_WIDTH 10
	`define CONV_IC 53:44
	`define CONV_IC_WIDTH 10
	`define CONV_KN 63:54
	`define CONV_KN_WIDTH 10
	`define CONV_KW 67:64
	`define CONV_KW_WIDTH 4
	`define CONV_KH 71:68
	`define CONV_KH_WIDTH 4
	`define CONV_Stride 75:72
	`define CONV_Stride_WIDTH 4
	`define CONV_Pad 78:76
	`define CONV_Pad_WIDTH 3
	`define CONV_PadSides 82:79
	`define CONV_PadSides_WIDTH 4
	`define CONV_ImageStartAddress 114:83
	`define CONV_ImageStartAddress_WIDTH 32
	`define CONV_ImageEndAddress 146:115
	`define CONV_ImageEndAddress_WIDTH 32
	`define CONV_WeightStartAddress 178:147
	`define CONV_WeightStartAddress_WIDTH 32
	`define CONV_WeightEndAddress 210:179
	`define CONV_WeightEndAddress_WIDTH 32

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
	`define FC_Flatten 60:60
	`define FC_Flatten_WIDTH 1
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
	`define FC_Vec2MatCols 224:209
	`define FC_Vec2MatCols_WIDTH 16

	`define OP_OutputBlock 'h02
	`define OutputBlock_Opcode 3:0
	`define OutputBlock_Opcode_WIDTH 4
	`define OutputBlock_AccumulantAddr 35:4
	`define OutputBlock_AccumulantAddr_WIDTH 32
	`define OutputBlock_OutputAddr 67:36
	`define OutputBlock_OutputAddr_WIDTH 32
	`define OutputBlock_ChannelItr 79:68
	`define OutputBlock_ChannelItr_WIDTH 12
	`define OutputBlock_KernelItr 91:80
	`define OutputBlock_KernelItr_WIDTH 12
	`define OutputBlock_ImageDimOutput 107:92
	`define OutputBlock_ImageDimOutput_WIDTH 16
	`define OutputBlock_ImageDimAcc 123:108
	`define OutputBlock_ImageDimAcc_WIDTH 16
	`define OutputBlock_AccEn 124:124
	`define OutputBlock_AccEn_WIDTH 1
	`define OutputBlock_DispatchEn 125:125
	`define OutputBlock_DispatchEn_WIDTH 1
	`define OutputBlock_DispatchID 157:126
	`define OutputBlock_DispatchID_WIDTH 32
	`define OutputBlock_OnChipAcc 158:158
	`define OutputBlock_OnChipAcc_WIDTH 1

	`define OP_START 'hf
	`define START_Opcode 3:0
	`define START_Opcode_WIDTH 4
	`define START_LayerNumber 15:4
	`define START_LayerNumber_WIDTH 12
	`define START_TotalLayers 27:16
	`define START_TotalLayers_WIDTH 12

	`define OP_TailBlock 'h01
	`define TailBlock_Opcode 3:0
	`define TailBlock_Opcode_WIDTH 4
	`define TailBlock_BNEn 4:4
	`define TailBlock_BNEn_WIDTH 1
	`define TailBlock_BNChannels 14:5
	`define TailBlock_BNChannels_WIDTH 10
	`define TailBlock_BNStartAddress 46:15
	`define TailBlock_BNStartAddress_WIDTH 32
	`define TailBlock_BNEndAddress 78:47
	`define TailBlock_BNEndAddress_WIDTH 32
	`define TailBlock_ActEn 79:79
	`define TailBlock_ActEn_WIDTH 1
	`define TailBlock_ActType 83:80
	`define TailBlock_ActType_WIDTH 4
	`define TailBlock_ActParam 91:84
	`define TailBlock_ActParam_WIDTH 8
	`define TailBlock_QuantEn 92:92
	`define TailBlock_QuantEn_WIDTH 1
	`define TailBlock_QuantScale 108:93
	`define TailBlock_QuantScale_WIDTH 16
	`define TailBlock_QuantShift 113:109
	`define TailBlock_QuantShift_WIDTH 5
	`define TailBlock_PoolEn 114:114
	`define TailBlock_PoolEn_WIDTH 1
	`define TailBlock_PoolType 117:115
	`define TailBlock_PoolType_WIDTH 3
	`define TailBlock_PoolWidth 127:118
	`define TailBlock_PoolWidth_WIDTH 10
	`define TailBlock_PoolHeight 137:128
	`define TailBlock_PoolHeight_WIDTH 10
	`define TailBlock_PoolStride 141:138
	`define TailBlock_PoolStride_WIDTH 4
	`define TailBlock_PoolPadding 145:142
	`define TailBlock_PoolPadding_WIDTH 4
	`define TailBlock_PoolCeil 146:146
	`define TailBlock_PoolCeil_WIDTH 1
	`define TailBlock_PoolModCount 150:147
	`define TailBlock_PoolModCount_WIDTH 4
	`define TailBlock_PoolPadSides 154:151
	`define TailBlock_PoolPadSides_WIDTH 4
	`define TailBlock_BiasEn 155:155
	`define TailBlock_BiasEn_WIDTH 1
	`define TailBlock_BiasWidth 163:156
	`define TailBlock_BiasWidth_WIDTH 8
	`define TailBlock_BiasStartAddress 195:164
	`define TailBlock_BiasStartAddress_WIDTH 32
	`define TailBlock_BiasEndAddress 227:196
	`define TailBlock_BiasEndAddress_WIDTH 32

	`define ACT_RELU 'h00
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
	`define META_TYPE_RESET 'h00000000
	`define META_TYPE_DISPATCH 'h00000001
	`define META_TYPE_PAYLOAD_SIZE 'h00000002
	`define META_CONST_DISPATCH_RAH 'h00000000
	`define META_CONST_DISPATCH_UART 'h00000001

	`define ZerothStartAddress 31:0
	`define ZerothStartAddress_WIDTH 32
	`define ZerothEndAddress 63:32
	`define ZerothEndAddress_WIDTH 32

.. code::

	#define OP_CONV 0x00
	#define CONV_Opcode_LOW 0
	#define CONV_Opcode_HIGH 3
	#define CONV_Opcode_COUNT 4
	#define CONV_IW_LOW 4
	#define CONV_IW_HIGH 13
	#define CONV_IW_COUNT 10
	#define CONV_IH_LOW 14
	#define CONV_IH_HIGH 23
	#define CONV_IH_COUNT 10
	#define CONV_OW_LOW 24
	#define CONV_OW_HIGH 33
	#define CONV_OW_COUNT 10
	#define CONV_OH_LOW 34
	#define CONV_OH_HIGH 43
	#define CONV_OH_COUNT 10
	#define CONV_IC_LOW 44
	#define CONV_IC_HIGH 53
	#define CONV_IC_COUNT 10
	#define CONV_KN_LOW 54
	#define CONV_KN_HIGH 63
	#define CONV_KN_COUNT 10
	#define CONV_KW_LOW 64
	#define CONV_KW_HIGH 67
	#define CONV_KW_COUNT 4
	#define CONV_KH_LOW 68
	#define CONV_KH_HIGH 71
	#define CONV_KH_COUNT 4
	#define CONV_Stride_LOW 72
	#define CONV_Stride_HIGH 75
	#define CONV_Stride_COUNT 4
	#define CONV_Pad_LOW 76
	#define CONV_Pad_HIGH 78
	#define CONV_Pad_COUNT 3
	#define CONV_PadSides_LOW 79
	#define CONV_PadSides_HIGH 82
	#define CONV_PadSides_COUNT 4
	#define CONV_ImageStartAddress_LOW 83
	#define CONV_ImageStartAddress_HIGH 114
	#define CONV_ImageStartAddress_COUNT 32
	#define CONV_ImageEndAddress_LOW 115
	#define CONV_ImageEndAddress_HIGH 146
	#define CONV_ImageEndAddress_COUNT 32
	#define CONV_WeightStartAddress_LOW 147
	#define CONV_WeightStartAddress_HIGH 178
	#define CONV_WeightStartAddress_COUNT 32
	#define CONV_WeightEndAddress_LOW 179
	#define CONV_WeightEndAddress_HIGH 210
	#define CONV_WeightEndAddress_COUNT 32

	#define OP_FC 0x03
	#define FC_Opcode_LOW 0
	#define FC_Opcode_HIGH 3
	#define FC_Opcode_COUNT 4
	#define FC_WeightRows_LOW 4
	#define FC_WeightRows_HIGH 19
	#define FC_WeightRows_COUNT 16
	#define FC_WeightCols_LOW 20
	#define FC_WeightCols_HIGH 35
	#define FC_WeightCols_COUNT 16
	#define FC_InputRows_LOW 36
	#define FC_InputRows_HIGH 51
	#define FC_InputRows_COUNT 16
	#define FC_DropoutConstant_LOW 52
	#define FC_DropoutConstant_HIGH 59
	#define FC_DropoutConstant_COUNT 8
	#define FC_Flatten_LOW 60
	#define FC_Flatten_HIGH 60
	#define FC_Flatten_COUNT 1
	#define FC_ImageDim_LOW 61
	#define FC_ImageDim_HIGH 80
	#define FC_ImageDim_COUNT 20
	#define FC_ImageStartAddress_LOW 81
	#define FC_ImageStartAddress_HIGH 112
	#define FC_ImageStartAddress_COUNT 32
	#define FC_ImageEndAddr_LOW 113
	#define FC_ImageEndAddr_HIGH 144
	#define FC_ImageEndAddr_COUNT 32
	#define FC_WeightStartAddress_LOW 145
	#define FC_WeightStartAddress_HIGH 176
	#define FC_WeightStartAddress_COUNT 32
	#define FC_WeightEndAddress_LOW 177
	#define FC_WeightEndAddress_HIGH 208
	#define FC_WeightEndAddress_COUNT 32
	#define FC_Vec2MatCols_LOW 209
	#define FC_Vec2MatCols_HIGH 224
	#define FC_Vec2MatCols_COUNT 16

	#define OP_OutputBlock 0x02
	#define OutputBlock_Opcode_LOW 0
	#define OutputBlock_Opcode_HIGH 3
	#define OutputBlock_Opcode_COUNT 4
	#define OutputBlock_AccumulantAddr_LOW 4
	#define OutputBlock_AccumulantAddr_HIGH 35
	#define OutputBlock_AccumulantAddr_COUNT 32
	#define OutputBlock_OutputAddr_LOW 36
	#define OutputBlock_OutputAddr_HIGH 67
	#define OutputBlock_OutputAddr_COUNT 32
	#define OutputBlock_ChannelItr_LOW 68
	#define OutputBlock_ChannelItr_HIGH 79
	#define OutputBlock_ChannelItr_COUNT 12
	#define OutputBlock_KernelItr_LOW 80
	#define OutputBlock_KernelItr_HIGH 91
	#define OutputBlock_KernelItr_COUNT 12
	#define OutputBlock_ImageDimOutput_LOW 92
	#define OutputBlock_ImageDimOutput_HIGH 107
	#define OutputBlock_ImageDimOutput_COUNT 16
	#define OutputBlock_ImageDimAcc_LOW 108
	#define OutputBlock_ImageDimAcc_HIGH 123
	#define OutputBlock_ImageDimAcc_COUNT 16
	#define OutputBlock_AccEn_LOW 124
	#define OutputBlock_AccEn_HIGH 124
	#define OutputBlock_AccEn_COUNT 1
	#define OutputBlock_DispatchEn_LOW 125
	#define OutputBlock_DispatchEn_HIGH 125
	#define OutputBlock_DispatchEn_COUNT 1
	#define OutputBlock_DispatchID_LOW 126
	#define OutputBlock_DispatchID_HIGH 157
	#define OutputBlock_DispatchID_COUNT 32
	#define OutputBlock_OnChipAcc_LOW 158
	#define OutputBlock_OnChipAcc_HIGH 158
	#define OutputBlock_OnChipAcc_COUNT 1

	#define OP_START 0xf
	#define START_Opcode_LOW 0
	#define START_Opcode_HIGH 3
	#define START_Opcode_COUNT 4
	#define START_LayerNumber_LOW 4
	#define START_LayerNumber_HIGH 15
	#define START_LayerNumber_COUNT 12
	#define START_TotalLayers_LOW 16
	#define START_TotalLayers_HIGH 27
	#define START_TotalLayers_COUNT 12

	#define OP_TailBlock 0x01
	#define TailBlock_Opcode_LOW 0
	#define TailBlock_Opcode_HIGH 3
	#define TailBlock_Opcode_COUNT 4
	#define TailBlock_BNEn_LOW 4
	#define TailBlock_BNEn_HIGH 4
	#define TailBlock_BNEn_COUNT 1
	#define TailBlock_BNChannels_LOW 5
	#define TailBlock_BNChannels_HIGH 14
	#define TailBlock_BNChannels_COUNT 10
	#define TailBlock_BNStartAddress_LOW 15
	#define TailBlock_BNStartAddress_HIGH 46
	#define TailBlock_BNStartAddress_COUNT 32
	#define TailBlock_BNEndAddress_LOW 47
	#define TailBlock_BNEndAddress_HIGH 78
	#define TailBlock_BNEndAddress_COUNT 32
	#define TailBlock_ActEn_LOW 79
	#define TailBlock_ActEn_HIGH 79
	#define TailBlock_ActEn_COUNT 1
	#define TailBlock_ActType_LOW 80
	#define TailBlock_ActType_HIGH 83
	#define TailBlock_ActType_COUNT 4
	#define TailBlock_ActParam_LOW 84
	#define TailBlock_ActParam_HIGH 91
	#define TailBlock_ActParam_COUNT 8
	#define TailBlock_QuantEn_LOW 92
	#define TailBlock_QuantEn_HIGH 92
	#define TailBlock_QuantEn_COUNT 1
	#define TailBlock_QuantScale_LOW 93
	#define TailBlock_QuantScale_HIGH 108
	#define TailBlock_QuantScale_COUNT 16
	#define TailBlock_QuantShift_LOW 109
	#define TailBlock_QuantShift_HIGH 113
	#define TailBlock_QuantShift_COUNT 5
	#define TailBlock_PoolEn_LOW 114
	#define TailBlock_PoolEn_HIGH 114
	#define TailBlock_PoolEn_COUNT 1
	#define TailBlock_PoolType_LOW 115
	#define TailBlock_PoolType_HIGH 117
	#define TailBlock_PoolType_COUNT 3
	#define TailBlock_PoolWidth_LOW 118
	#define TailBlock_PoolWidth_HIGH 127
	#define TailBlock_PoolWidth_COUNT 10
	#define TailBlock_PoolHeight_LOW 128
	#define TailBlock_PoolHeight_HIGH 137
	#define TailBlock_PoolHeight_COUNT 10
	#define TailBlock_PoolStride_LOW 138
	#define TailBlock_PoolStride_HIGH 141
	#define TailBlock_PoolStride_COUNT 4
	#define TailBlock_PoolPadding_LOW 142
	#define TailBlock_PoolPadding_HIGH 145
	#define TailBlock_PoolPadding_COUNT 4
	#define TailBlock_PoolCeil_LOW 146
	#define TailBlock_PoolCeil_HIGH 146
	#define TailBlock_PoolCeil_COUNT 1
	#define TailBlock_PoolModCount_LOW 147
	#define TailBlock_PoolModCount_HIGH 150
	#define TailBlock_PoolModCount_COUNT 4
	#define TailBlock_PoolPadSides_LOW 151
	#define TailBlock_PoolPadSides_HIGH 154
	#define TailBlock_PoolPadSides_COUNT 4
	#define TailBlock_BiasEn_LOW 155
	#define TailBlock_BiasEn_HIGH 155
	#define TailBlock_BiasEn_COUNT 1
	#define TailBlock_BiasWidth_LOW 156
	#define TailBlock_BiasWidth_HIGH 163
	#define TailBlock_BiasWidth_COUNT 8
	#define TailBlock_BiasStartAddress_LOW 164
	#define TailBlock_BiasStartAddress_HIGH 195
	#define TailBlock_BiasStartAddress_COUNT 32
	#define TailBlock_BiasEndAddress_LOW 196
	#define TailBlock_BiasEndAddress_HIGH 227
	#define TailBlock_BiasEndAddress_COUNT 32

	#define ACT_RELU 0x00
	#define POOL_MAX 0x00
	#define POOL_AVERAGE 0x01
	#define POOL_GLOBAL_AVG 0x02
	#define WORD_SIZE 32
	#define ACC_SIZE 32
	#define GATI_INST_ORG 0
	#define DWP_HEADER_BYTES 12
	#define DWP_PACKET_SZ 4
	#define DWP_SOP 0xffffffff
	#define DWP_SOP_INDEX 0
	#define DWP_DS_INDEX 1
	#define DWP_ADDR_INDEX 2
	#define META_SOP 0xffffffffffff
	#define META_TYPE_RESET 0x00000000
	#define META_TYPE_DISPATCH 0x00000001
	#define META_TYPE_PAYLOAD_SIZE 0x00000002
	#define META_CONST_DISPATCH_RAH 0x00000000
	#define META_CONST_DISPATCH_UART 0x00000001

	#define ZerothStartAddress_LOW 0
	#define ZerothStartAddress_HIGH 31
	#define ZerothStartAddress_COUNT 32
	#define ZerothEndAddress_LOW 32
	#define ZerothEndAddress_HIGH 63
	#define ZerothEndAddress_COUNT 32

  struct Table {
    std::map<std::string, int> tbl;
    std::vector<std::string> order;
  };
  void print_table(const Table &tbl);
	inline Table get_conv_table(const std::bitset<INST_SIZE_BITS>& inst) {
		Table tbl;
		tbl.tbl.insert({"Opcode", bitset_range_get<CONV_Opcode_COUNT, INST_SIZE_BITS>(inst, CONV_Opcode_LOW, CONV_Opcode_HIGH)});
		tbl.order.push_back("Opcode");
		tbl.tbl.insert({"IW", bitset_range_get<CONV_IW_COUNT, INST_SIZE_BITS>(inst, CONV_IW_LOW, CONV_IW_HIGH)});
		tbl.order.push_back("IW");
		tbl.tbl.insert({"IH", bitset_range_get<CONV_IH_COUNT, INST_SIZE_BITS>(inst, CONV_IH_LOW, CONV_IH_HIGH)});
		tbl.order.push_back("IH");
		tbl.tbl.insert({"OW", bitset_range_get<CONV_OW_COUNT, INST_SIZE_BITS>(inst, CONV_OW_LOW, CONV_OW_HIGH)});
		tbl.order.push_back("OW");
		tbl.tbl.insert({"OH", bitset_range_get<CONV_OH_COUNT, INST_SIZE_BITS>(inst, CONV_OH_LOW, CONV_OH_HIGH)});
		tbl.order.push_back("OH");
		tbl.tbl.insert({"IC", bitset_range_get<CONV_IC_COUNT, INST_SIZE_BITS>(inst, CONV_IC_LOW, CONV_IC_HIGH)});
		tbl.order.push_back("IC");
		tbl.tbl.insert({"KN", bitset_range_get<CONV_KN_COUNT, INST_SIZE_BITS>(inst, CONV_KN_LOW, CONV_KN_HIGH)});
		tbl.order.push_back("KN");
		tbl.tbl.insert({"KW", bitset_range_get<CONV_KW_COUNT, INST_SIZE_BITS>(inst, CONV_KW_LOW, CONV_KW_HIGH)});
		tbl.order.push_back("KW");
		tbl.tbl.insert({"KH", bitset_range_get<CONV_KH_COUNT, INST_SIZE_BITS>(inst, CONV_KH_LOW, CONV_KH_HIGH)});
		tbl.order.push_back("KH");
		tbl.tbl.insert({"Stride", bitset_range_get<CONV_Stride_COUNT, INST_SIZE_BITS>(inst, CONV_Stride_LOW, CONV_Stride_HIGH)});
		tbl.order.push_back("Stride");
		tbl.tbl.insert({"Pad", bitset_range_get<CONV_Pad_COUNT, INST_SIZE_BITS>(inst, CONV_Pad_LOW, CONV_Pad_HIGH)});
		tbl.order.push_back("Pad");
		tbl.tbl.insert({"PadSides", bitset_range_get<CONV_PadSides_COUNT, INST_SIZE_BITS>(inst, CONV_PadSides_LOW, CONV_PadSides_HIGH)});
		tbl.order.push_back("PadSides");
		tbl.tbl.insert({"ImageStartAddress", bitset_range_get<CONV_ImageStartAddress_COUNT, INST_SIZE_BITS>(inst, CONV_ImageStartAddress_LOW, CONV_ImageStartAddress_HIGH)});
		tbl.order.push_back("ImageStartAddress");
		tbl.tbl.insert({"ImageEndAddress", bitset_range_get<CONV_ImageEndAddress_COUNT, INST_SIZE_BITS>(inst, CONV_ImageEndAddress_LOW, CONV_ImageEndAddress_HIGH)});
		tbl.order.push_back("ImageEndAddress");
		tbl.tbl.insert({"WeightStartAddress", bitset_range_get<CONV_WeightStartAddress_COUNT, INST_SIZE_BITS>(inst, CONV_WeightStartAddress_LOW, CONV_WeightStartAddress_HIGH)});
		tbl.order.push_back("WeightStartAddress");
		tbl.tbl.insert({"WeightEndAddress", bitset_range_get<CONV_WeightEndAddress_COUNT, INST_SIZE_BITS>(inst, CONV_WeightEndAddress_LOW, CONV_WeightEndAddress_HIGH)});
		tbl.order.push_back("WeightEndAddress");
		return tbl;
	}
	inline void pretty_print_conv(const std::bitset<INST_SIZE_BITS>& inst) {
		auto tbl = get_conv_table(inst);
		print_table(tbl);
	}
	inline Table get_fc_table(const std::bitset<INST_SIZE_BITS>& inst) {
		Table tbl;
		tbl.tbl.insert({"Opcode", bitset_range_get<FC_Opcode_COUNT, INST_SIZE_BITS>(inst, FC_Opcode_LOW, FC_Opcode_HIGH)});
		tbl.order.push_back("Opcode");
		tbl.tbl.insert({"WeightRows", bitset_range_get<FC_WeightRows_COUNT, INST_SIZE_BITS>(inst, FC_WeightRows_LOW, FC_WeightRows_HIGH)});
		tbl.order.push_back("WeightRows");
		tbl.tbl.insert({"WeightCols", bitset_range_get<FC_WeightCols_COUNT, INST_SIZE_BITS>(inst, FC_WeightCols_LOW, FC_WeightCols_HIGH)});
		tbl.order.push_back("WeightCols");
		tbl.tbl.insert({"InputRows", bitset_range_get<FC_InputRows_COUNT, INST_SIZE_BITS>(inst, FC_InputRows_LOW, FC_InputRows_HIGH)});
		tbl.order.push_back("InputRows");
		tbl.tbl.insert({"DropoutConstant", bitset_range_get<FC_DropoutConstant_COUNT, INST_SIZE_BITS>(inst, FC_DropoutConstant_LOW, FC_DropoutConstant_HIGH)});
		tbl.order.push_back("DropoutConstant");
		tbl.tbl.insert({"Flatten", bitset_range_get<FC_Flatten_COUNT, INST_SIZE_BITS>(inst, FC_Flatten_LOW, FC_Flatten_HIGH)});
		tbl.order.push_back("Flatten");
		tbl.tbl.insert({"ImageDim", bitset_range_get<FC_ImageDim_COUNT, INST_SIZE_BITS>(inst, FC_ImageDim_LOW, FC_ImageDim_HIGH)});
		tbl.order.push_back("ImageDim");
		tbl.tbl.insert({"ImageStartAddress", bitset_range_get<FC_ImageStartAddress_COUNT, INST_SIZE_BITS>(inst, FC_ImageStartAddress_LOW, FC_ImageStartAddress_HIGH)});
		tbl.order.push_back("ImageStartAddress");
		tbl.tbl.insert({"ImageEndAddr", bitset_range_get<FC_ImageEndAddr_COUNT, INST_SIZE_BITS>(inst, FC_ImageEndAddr_LOW, FC_ImageEndAddr_HIGH)});
		tbl.order.push_back("ImageEndAddr");
		tbl.tbl.insert({"WeightStartAddress", bitset_range_get<FC_WeightStartAddress_COUNT, INST_SIZE_BITS>(inst, FC_WeightStartAddress_LOW, FC_WeightStartAddress_HIGH)});
		tbl.order.push_back("WeightStartAddress");
		tbl.tbl.insert({"WeightEndAddress", bitset_range_get<FC_WeightEndAddress_COUNT, INST_SIZE_BITS>(inst, FC_WeightEndAddress_LOW, FC_WeightEndAddress_HIGH)});
		tbl.order.push_back("WeightEndAddress");
		tbl.tbl.insert({"Vec2MatCols", bitset_range_get<FC_Vec2MatCols_COUNT, INST_SIZE_BITS>(inst, FC_Vec2MatCols_LOW, FC_Vec2MatCols_HIGH)});
		tbl.order.push_back("Vec2MatCols");
		return tbl;
	}
	inline void pretty_print_fc(const std::bitset<INST_SIZE_BITS>& inst) {
		auto tbl = get_fc_table(inst);
		print_table(tbl);
	}
	inline Table get_outputblock_table(const std::bitset<INST_SIZE_BITS>& inst) {
		Table tbl;
		tbl.tbl.insert({"Opcode", bitset_range_get<OutputBlock_Opcode_COUNT, INST_SIZE_BITS>(inst, OutputBlock_Opcode_LOW, OutputBlock_Opcode_HIGH)});
		tbl.order.push_back("Opcode");
		tbl.tbl.insert({"AccumulantAddr", bitset_range_get<OutputBlock_AccumulantAddr_COUNT, INST_SIZE_BITS>(inst, OutputBlock_AccumulantAddr_LOW, OutputBlock_AccumulantAddr_HIGH)});
		tbl.order.push_back("AccumulantAddr");
		tbl.tbl.insert({"OutputAddr", bitset_range_get<OutputBlock_OutputAddr_COUNT, INST_SIZE_BITS>(inst, OutputBlock_OutputAddr_LOW, OutputBlock_OutputAddr_HIGH)});
		tbl.order.push_back("OutputAddr");
		tbl.tbl.insert({"ChannelItr", bitset_range_get<OutputBlock_ChannelItr_COUNT, INST_SIZE_BITS>(inst, OutputBlock_ChannelItr_LOW, OutputBlock_ChannelItr_HIGH)});
		tbl.order.push_back("ChannelItr");
		tbl.tbl.insert({"KernelItr", bitset_range_get<OutputBlock_KernelItr_COUNT, INST_SIZE_BITS>(inst, OutputBlock_KernelItr_LOW, OutputBlock_KernelItr_HIGH)});
		tbl.order.push_back("KernelItr");
		tbl.tbl.insert({"ImageDimOutput", bitset_range_get<OutputBlock_ImageDimOutput_COUNT, INST_SIZE_BITS>(inst, OutputBlock_ImageDimOutput_LOW, OutputBlock_ImageDimOutput_HIGH)});
		tbl.order.push_back("ImageDimOutput");
		tbl.tbl.insert({"ImageDimAcc", bitset_range_get<OutputBlock_ImageDimAcc_COUNT, INST_SIZE_BITS>(inst, OutputBlock_ImageDimAcc_LOW, OutputBlock_ImageDimAcc_HIGH)});
		tbl.order.push_back("ImageDimAcc");
		tbl.tbl.insert({"AccEn", bitset_range_get<OutputBlock_AccEn_COUNT, INST_SIZE_BITS>(inst, OutputBlock_AccEn_LOW, OutputBlock_AccEn_HIGH)});
		tbl.order.push_back("AccEn");
		tbl.tbl.insert({"DispatchEn", bitset_range_get<OutputBlock_DispatchEn_COUNT, INST_SIZE_BITS>(inst, OutputBlock_DispatchEn_LOW, OutputBlock_DispatchEn_HIGH)});
		tbl.order.push_back("DispatchEn");
		tbl.tbl.insert({"DispatchID", bitset_range_get<OutputBlock_DispatchID_COUNT, INST_SIZE_BITS>(inst, OutputBlock_DispatchID_LOW, OutputBlock_DispatchID_HIGH)});
		tbl.order.push_back("DispatchID");
		tbl.tbl.insert({"OnChipAcc", bitset_range_get<OutputBlock_OnChipAcc_COUNT, INST_SIZE_BITS>(inst, OutputBlock_OnChipAcc_LOW, OutputBlock_OnChipAcc_HIGH)});
		tbl.order.push_back("OnChipAcc");
		return tbl;
	}
	inline void pretty_print_outputblock(const std::bitset<INST_SIZE_BITS>& inst) {
		auto tbl = get_outputblock_table(inst);
		print_table(tbl);
	}
	inline Table get_start_table(const std::bitset<INST_SIZE_BITS>& inst) {
		Table tbl;
		tbl.tbl.insert({"Opcode", bitset_range_get<START_Opcode_COUNT, INST_SIZE_BITS>(inst, START_Opcode_LOW, START_Opcode_HIGH)});
		tbl.order.push_back("Opcode");
		tbl.tbl.insert({"LayerNumber", bitset_range_get<START_LayerNumber_COUNT, INST_SIZE_BITS>(inst, START_LayerNumber_LOW, START_LayerNumber_HIGH)});
		tbl.order.push_back("LayerNumber");
		tbl.tbl.insert({"TotalLayers", bitset_range_get<START_TotalLayers_COUNT, INST_SIZE_BITS>(inst, START_TotalLayers_LOW, START_TotalLayers_HIGH)});
		tbl.order.push_back("TotalLayers");
		return tbl;
	}
	inline void pretty_print_start(const std::bitset<INST_SIZE_BITS>& inst) {
		auto tbl = get_start_table(inst);
		print_table(tbl);
	}
	inline Table get_tailblock_table(const std::bitset<INST_SIZE_BITS>& inst) {
		Table tbl;
		tbl.tbl.insert({"Opcode", bitset_range_get<TailBlock_Opcode_COUNT, INST_SIZE_BITS>(inst, TailBlock_Opcode_LOW, TailBlock_Opcode_HIGH)});
		tbl.order.push_back("Opcode");
		tbl.tbl.insert({"BNEn", bitset_range_get<TailBlock_BNEn_COUNT, INST_SIZE_BITS>(inst, TailBlock_BNEn_LOW, TailBlock_BNEn_HIGH)});
		tbl.order.push_back("BNEn");
		tbl.tbl.insert({"BNChannels", bitset_range_get<TailBlock_BNChannels_COUNT, INST_SIZE_BITS>(inst, TailBlock_BNChannels_LOW, TailBlock_BNChannels_HIGH)});
		tbl.order.push_back("BNChannels");
		tbl.tbl.insert({"BNStartAddress", bitset_range_get<TailBlock_BNStartAddress_COUNT, INST_SIZE_BITS>(inst, TailBlock_BNStartAddress_LOW, TailBlock_BNStartAddress_HIGH)});
		tbl.order.push_back("BNStartAddress");
		tbl.tbl.insert({"BNEndAddress", bitset_range_get<TailBlock_BNEndAddress_COUNT, INST_SIZE_BITS>(inst, TailBlock_BNEndAddress_LOW, TailBlock_BNEndAddress_HIGH)});
		tbl.order.push_back("BNEndAddress");
		tbl.tbl.insert({"ActEn", bitset_range_get<TailBlock_ActEn_COUNT, INST_SIZE_BITS>(inst, TailBlock_ActEn_LOW, TailBlock_ActEn_HIGH)});
		tbl.order.push_back("ActEn");
		tbl.tbl.insert({"ActType", bitset_range_get<TailBlock_ActType_COUNT, INST_SIZE_BITS>(inst, TailBlock_ActType_LOW, TailBlock_ActType_HIGH)});
		tbl.order.push_back("ActType");
		tbl.tbl.insert({"ActParam", bitset_range_get<TailBlock_ActParam_COUNT, INST_SIZE_BITS>(inst, TailBlock_ActParam_LOW, TailBlock_ActParam_HIGH)});
		tbl.order.push_back("ActParam");
		tbl.tbl.insert({"QuantEn", bitset_range_get<TailBlock_QuantEn_COUNT, INST_SIZE_BITS>(inst, TailBlock_QuantEn_LOW, TailBlock_QuantEn_HIGH)});
		tbl.order.push_back("QuantEn");
		tbl.tbl.insert({"QuantScale", bitset_range_get<TailBlock_QuantScale_COUNT, INST_SIZE_BITS>(inst, TailBlock_QuantScale_LOW, TailBlock_QuantScale_HIGH)});
		tbl.order.push_back("QuantScale");
		tbl.tbl.insert({"QuantShift", bitset_range_get<TailBlock_QuantShift_COUNT, INST_SIZE_BITS>(inst, TailBlock_QuantShift_LOW, TailBlock_QuantShift_HIGH)});
		tbl.order.push_back("QuantShift");
		tbl.tbl.insert({"PoolEn", bitset_range_get<TailBlock_PoolEn_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolEn_LOW, TailBlock_PoolEn_HIGH)});
		tbl.order.push_back("PoolEn");
		tbl.tbl.insert({"PoolType", bitset_range_get<TailBlock_PoolType_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolType_LOW, TailBlock_PoolType_HIGH)});
		tbl.order.push_back("PoolType");
		tbl.tbl.insert({"PoolWidth", bitset_range_get<TailBlock_PoolWidth_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolWidth_LOW, TailBlock_PoolWidth_HIGH)});
		tbl.order.push_back("PoolWidth");
		tbl.tbl.insert({"PoolHeight", bitset_range_get<TailBlock_PoolHeight_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolHeight_LOW, TailBlock_PoolHeight_HIGH)});
		tbl.order.push_back("PoolHeight");
		tbl.tbl.insert({"PoolStride", bitset_range_get<TailBlock_PoolStride_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolStride_LOW, TailBlock_PoolStride_HIGH)});
		tbl.order.push_back("PoolStride");
		tbl.tbl.insert({"PoolPadding", bitset_range_get<TailBlock_PoolPadding_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolPadding_LOW, TailBlock_PoolPadding_HIGH)});
		tbl.order.push_back("PoolPadding");
		tbl.tbl.insert({"PoolCeil", bitset_range_get<TailBlock_PoolCeil_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolCeil_LOW, TailBlock_PoolCeil_HIGH)});
		tbl.order.push_back("PoolCeil");
		tbl.tbl.insert({"PoolModCount", bitset_range_get<TailBlock_PoolModCount_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolModCount_LOW, TailBlock_PoolModCount_HIGH)});
		tbl.order.push_back("PoolModCount");
		tbl.tbl.insert({"PoolPadSides", bitset_range_get<TailBlock_PoolPadSides_COUNT, INST_SIZE_BITS>(inst, TailBlock_PoolPadSides_LOW, TailBlock_PoolPadSides_HIGH)});
		tbl.order.push_back("PoolPadSides");
		tbl.tbl.insert({"BiasEn", bitset_range_get<TailBlock_BiasEn_COUNT, INST_SIZE_BITS>(inst, TailBlock_BiasEn_LOW, TailBlock_BiasEn_HIGH)});
		tbl.order.push_back("BiasEn");
		tbl.tbl.insert({"BiasWidth", bitset_range_get<TailBlock_BiasWidth_COUNT, INST_SIZE_BITS>(inst, TailBlock_BiasWidth_LOW, TailBlock_BiasWidth_HIGH)});
		tbl.order.push_back("BiasWidth");
		tbl.tbl.insert({"BiasStartAddress", bitset_range_get<TailBlock_BiasStartAddress_COUNT, INST_SIZE_BITS>(inst, TailBlock_BiasStartAddress_LOW, TailBlock_BiasStartAddress_HIGH)});
		tbl.order.push_back("BiasStartAddress");
		tbl.tbl.insert({"BiasEndAddress", bitset_range_get<TailBlock_BiasEndAddress_COUNT, INST_SIZE_BITS>(inst, TailBlock_BiasEndAddress_LOW, TailBlock_BiasEndAddress_HIGH)});
		tbl.order.push_back("BiasEndAddress");
		return tbl;
	}
	inline void pretty_print_tailblock(const std::bitset<INST_SIZE_BITS>& inst) {
		auto tbl = get_tailblock_table(inst);
		print_table(tbl);
	}
