`include "arch_param.vh"

`ifndef portid_vh

`define MIPI_Wr 0
`define Config 1
`define Weight 2
`define Bias 3
`define Image 4

`ifdef FC
    `ifdef BIAS_FC
        `define FullyConn 5
        `define Acc 6
        `define FCBias 8
        `define MIPI_Rd 9
    `else
        `define FullyConn 5
        `define Acc 6
        `define MIPI_Rd 8
    `endif //BIAS_FC
`else
    `ifdef BIAS_FC
        `define Acc 5
        `define FCBias 7
        `define MIPI_Rd 8
    `else
        `define Acc 5
        `define MIPI_Rd 7
    `endif //BIAS_FC
`endif //FC

`define OPWrite (`Acc + 1)
`define LeftOperand (`MIPI_Rd + 1)
`define RightOperand (`LeftOperand + 1)

`ifdef TRANSPOSE
`define ReshapeTranspose (`RightOperand + 1)
`endif
`endif //portid_vh
