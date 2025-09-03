`include "arch_param.vh"

`ifndef portid_vh
`ifdef FC
    `ifdef BIAS_FC
        `define MIPI_Wr 0
        `define Config 1
        `define Weight 2
        `define Bias 3
        `define Image 4
        `define FullyConn 5
        `define Acc 6
        `define OPWrite 7
        `define FCBias 8
        `define MIPI_Rd 9
        `define LeftOperand 10
        `define RightOperand 11
        `define ReshapeTranspose 12
    `else
        `define MIPI_Wr 0
        `define Config 1
        `define Weight 2
        `define Bias 3
        `define Image 4
        `define FullyConn 5
        `define Acc 6
        `define OPWrite 7
        `define MIPI_Rd 8
        `define LeftOperand 9
        `define RightOperand 10
        `define ReshapeTranspose 11
    `endif //BIAS_FC
`else
    `ifdef BIAS_FC
        `define MIPI_Wr 0
        `define Config 1
        `define Weight 2
        `define Bias 3
        `define Image 4
        `define Acc 5
        `define OPWrite 6
        `define FCBias 7
        `define MIPI_Rd 8
        `define LeftOperand 9
        `define RightOperand 10
        `define ReshapeTranspose 11
    `else
        `define MIPI_Wr 0
        `define Config 1
        `define Weight 2
        `define Bias 3
        `define Image 4
        `define Acc 5
        `define OPWrite 6
        `define MIPI_Rd 7
        `define LeftOperand 8
        `define RightOperand 9
        `define ReshapeTranspose 10
    `endif //BIAS_FC
`endif //FC
`endif //portid_vh
