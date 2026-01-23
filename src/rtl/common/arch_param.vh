 // arch_param.vh
`include "gen_hardware.vh" 

/*
    These are Systolic array architecture related parameter by changing these the corresponding sa arch can be generated currently supported arch are 
                     
                    NSA      | 4 | 8 | 16 |
                    COL_SA   | 4 | 8 | 1  |
                    ROW      | 9 | 9 | 16 |

    If any value other then these three arch is passed to parameters the rtl would not synthesize.
*/

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

    STRIDE is the parameter that define the max stride for which the im2col engine will be generated thus if it 4 then it can only handle the stride 4 in input beyond which the system will break thus this can be changes based on the max input stride and should not be kept unnecessary  large thus to reduce the resource usages. 
*/

// `define IM2COL_BOUND_GEN_WIDTH 16
// `define N_MOD_STAGES 10
`define STRIDE 4

/*
Hardware Generation Options:

1. ELTWISE_SIGMOID_TANH - For Generating Sigmoid/Tanh Eltwise operation
2. GEN_LEAKY_RELU       - For Generating Leaky ReLU functionality in the relu activation block. DO NOT GENERATE IN CASE OF 16 1 16.
3. MEGA_POOL            - For Generating Maxpool as a mega block. DO NOT GENERATE IN CASE OF 16 1 16. 
4. GLOBAL_POOL          - For Generating Global Average Pool. DO NOT GENERATE IF USING MINI POOL.
5. FC                   - For Generating FC 
6. POOL                 - For Generating MINI POOL in Tail block
7. BIAS_FC              - For Generating BIAS_FC addition 
8. TRANSPOSE            - For Generating Reshape-Transpose hardware
9. CONCAT               - For Generating CONCAT hardware

*/

// For Generating Sigmoid/Tanh Eltwise operation
//`define ELTWISE_SIGMOID_TANH

// For Generating Leaky ReLU functionality in the relu activation block 
// DO NOT GENERATE IN CASE OF 16 1 16
//`define GEN_LEAKY_RELU

// For Generating Maxpool as a mega block
// DO NOT GENERATE IN CASE OF 16 1 16 
//`define MEGA_POOL

// For Generating Global Average Pool
// DO NOT GENERATE IF USING MINI POOL
// `define GLOBAL_POOL

// For Generating FC 
//`define FC   

// For Generating Mini Pool in Tail block
// `define POOL   

// For Generating for BIAS_FC add 
//`define BIAS_FC  

// For Generating Reshape-Transpose operation

// `define TRANSPOSE 

// To generate CONCAT hardware
//`define CONCAT 

// Macros for Debugging
/* These should be remained commented until the GATI need's to be synthesized in the debug mode to reduce the resources used and thus reduce the critical timings 
*/

// To monitor Layer wise compute cycles

//`define MONITOR_LAYER_CYCLES

// To monitor stall cycles of SA (psum_stall, sa_stall, im2col_stall)\

//`define MONITOR_STALL_CYLES
