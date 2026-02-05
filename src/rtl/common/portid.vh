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

`ifdef ELTWISE 
`define LeftOperand (`MIPI_Rd + 1)
`define RightOperand (`LeftOperand + 1)

`ifdef CONCAT
    `ifdef TRANSPOSE
    `define ReshapeTranspose (`RightOperand + 1)
    `define Concat (`ReshapeTranspose + 1) 
    `else
    `define Concat (`RightOperand + 1)
    `endif
`else
    `ifdef TRANSPOSE
    `define ReshapeTranspose (`RightOperand + 1)
    `endif
`endif // CONCAT

`else 

`ifdef CONCAT
    `ifdef TRANSPOSE
    `define ReshapeTranspose (`MIPI_Rd + 1)
    `define Concat (`ReshapeTranspose + 1) 
    `else
    `define Concat (`MIPI_Rd + 1)
    `endif
`else
    `ifdef TRANSPOSE
    `define ReshapeTranspose (`MIPI_Rd + 1)
    `endif
`endif // CONCAT
`endif

`endif //portid_vh
