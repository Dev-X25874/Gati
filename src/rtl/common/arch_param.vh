 // arch_param.vh

`define N_SA 4
`define COL_SA 4
`define ROW 9

// Arch. Parameters for Im2Col
// Caution: Change these parameters with atmost care
/*  
    These are dependent on the maximum dim of Input image,
    say, 224*224, 300*300, 320*320, 416*416 etc.

    IM2COL_BOUND_GEN_WIDTH is the Data width of bound generation registers
    Select this parameter as round(log2(Max i/p dim)) to nearest multiple of
    2 power. 
    Ex: 1. max i/p dim = 224, IM2COL_BOUND_GEN_WIDTH = 8
        2. max i/p dim = 300, IM2COL_BOUND_GEN_WIDTH = 16
    
    N_MOD_STAGES is the parameter to have appropriate number fo stages required
    to compute 'mod' operation for handling stride in Im2Col block. This depends
    on the max i/p dim. N_MOD_STAGES = round(log2(Max i/p dim)) to nearest integer.
    Ex: 1. max i/p dim = 224, N_MOD_STAGES = 8
        2. max i/p dim = 300, N_MOD_STAGES = 9 
*/
`define IM2COL_BOUND_GEN_WIDTH 16
`define N_MOD_STAGES 9

// For using Leaky ReLU
//`define GEN_LEAKY_RELU

// Macros for Debugging
// Comment these if not required
// To monitor Layer wise compute cycles

`define MONITOR_LAYER_CYCLES

// To monitor stall cycles of SA (psum_stall, sa_stall, im2col_stall)
`define MONITOR_STALL_CYLES
