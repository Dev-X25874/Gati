module top_master_slave #(parameter op_code_width = 4, 
            parameter CNT = (data_in/data_out),
            parameter data_in = 256,
            parameter data_out = 8) (
                input [(data_in)-1 : 0] din,
                input start,
                input clk,
                input [(op_code_width)-1 : 0] op_code,
                input ready,
                output [179:0] dout_final
            );
top_master top_master(
    .din(),
    .start(),
    .clk(),
    .op_code(),
    .ready_in(),
    .dout(),
    .sel(),
    .write(),
    .done()  
);

OP_CONV OP_CONV(
    .din(),
    .sel(),
    .write(),
    .done(),
    .clk(),
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
    .valid(),
    .ready(),
    .dout()
);

OP_FC OP_FC(
    .din(),
    .sel(),
    .write(),
    .done(),
    .clk(),
    .valid(),
    .ready(),
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
    .dout()
);

OP_Outputblock OP_Outputblock(
    .din(),
    .sel(),
    .write(),
    .done(),
    .clk(),
    .valid(),
    .ready(),
    .opcode(),
    .accumulantaddr(),
    .outputaddr(),
    .channelItr(),
    .kernelItr(),
    .imagedim(),
    .dout()
);

OP_Tailblock OP_Tailblock(
    .din(),
    .sel(),
    .write(),
    .done(),
    .clk(),
    .ready(),
    .valid(),
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
    .dout()
);



endmodule