module Top_element_wise#(
    parameter DATA_WIDTH            = 8,
    parameter ELTWISE_TYPE_WIDTH    = 4,
    parameter N                     = 4,
    parameter FIFO_NO               = 8,
    parameter W_ADDR                = 9,
    parameter DATA_WIDTH_OB         = 32,

    parameter ELTWISE_IW_WIDTH      = 10, // Width of the input width;
    parameter ELTWISE_IH_WIDTH      = 10, // Width of the input height;
    parameter ELTWISE_IC_WIDTH      = 10 // Width of the output width;
)
(
    input clkin,
    input rst,
    input EltWise_op_en,
    input [FIFO_NO-1:0]LeftOperand_wr_en,
    input [FIFO_NO-1:0]RightOperand_wr_en,
    input [ELTWISE_IW_WIDTH-1:0]EltWise_IW,
    input [ELTWISE_IH_WIDTH-1:0]EltWise_IH,
    input [ELTWISE_IC_WIDTH-1:0]EltWise_IC,
    input [(DATA_WIDTH*FIFO_NO*N)-1:0]LeftOperand_data_in,
    input [(DATA_WIDTH*FIFO_NO*N)-1:0]RightOperand_data_in,
    input [ELTWISE_TYPE_WIDTH-1:0]EltWise_type,
    output [(DATA_WIDTH_OB*N)-1:0]EltWise_data_out,
    output [N-1:0]EltWise_data_out_valid,
    output [((W_ADDR+1)*FIFO_NO)-1:0]LeftOperand_fifo_occupants,
    output [((W_ADDR+1)*FIFO_NO)-1:0]RightOperand_fifo_occupants,
    output EW_done,
    input op_fifo_empty
);
wire [(DATA_WIDTH*FIFO_NO*N)-1:0] LeftOperand_data_in_reordered,RightOperand_data_in_reordered;
wire [(DATA_WIDTH*FIFO_NO*N)-1:0] LeftOperand_data_out,RightOperand_data_out;
wire [FIFO_NO-1:0] LeftOperand_empty_flag,RightOperand_empty_flag;
wire [FIFO_NO-1:0] LeftOperand_full,RightOperand_full;
wire [FIFO_NO-1:0] LeftOperand_valid_fifo,RightOperand_valid_fifo;
wire [(DATA_WIDTH*N)-1:0] LeftOperand_fifo_data_out,RightOperand_fifo_data_out;
wire [FIFO_NO-1:0] element_rd_en;
wire data_valid;

conv_output_reorder_EW #(
    .W_DATA(DATA_WIDTH),
    .N_BYTES(N*FIFO_NO),
    .N(N),
    .FIFO_NO(FIFO_NO)
) reorder_LeftOperand (
    .i_data(LeftOperand_data_in),
    .o_data(LeftOperand_data_in_reordered)
);
conv_output_reorder_EW #(
    .W_DATA(DATA_WIDTH),
    .N_BYTES(N*FIFO_NO),
    .N(N),
    .FIFO_NO(FIFO_NO)
) reorder_RightOperand (
    .i_data(RightOperand_data_in),
    .o_data(RightOperand_data_in_reordered)
);
dram_fifo #(
    .DIMENSION(FIFO_NO),
    .W_DATA(DATA_WIDTH*N),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(1 << W_ADDR),
    .OUTPUT_REG(0)

) fifo_LeftOperand (
    .i_clk(clkin),
    .i_rst(rst),
    .i_data(LeftOperand_data_in_reordered),
    .i_read_enable(element_rd_en),
    .i_write_enable(LeftOperand_wr_en),
    .o_data(LeftOperand_data_out),
    .o_fifo_empty(LeftOperand_empty_flag),
    .o_fifo_full(LeftOperand_full),
    .o_fifo_dv(LeftOperand_valid_fifo),
    .o_occupants(LeftOperand_fifo_occupants)
);
dram_fifo #(.DIMENSION(FIFO_NO),
    .W_DATA(DATA_WIDTH*N),
    .W_ADDR(W_ADDR),
    .RAM_DEPTH(1 << W_ADDR),
    .OUTPUT_REG(0)

) fifo_RightOperand (
    .i_clk(clkin),
    .i_rst(rst),
    .i_data(RightOperand_data_in_reordered),
    .i_read_enable(element_rd_en),
    .i_write_enable(RightOperand_wr_en),
    .o_data(RightOperand_data_out),
    .o_fifo_empty(RightOperand_empty_flag),
    .o_fifo_full(RightOperand_full),
    .o_fifo_dv(RightOperand_valid_fifo),
    .o_occupants(RightOperand_fifo_occupants)
);

EltWise_controller #(
    .DATA_WIDTH(DATA_WIDTH),  
    .N(N),           
    .FIFO_NO(FIFO_NO),
    .ELTWISE_IW_WIDTH(ELTWISE_IW_WIDTH),
    .ELTWISE_IH_WIDTH(ELTWISE_IH_WIDTH),
    .ELTWISE_IC_WIDTH(ELTWISE_IC_WIDTH)       
)EltWise_controller(
    .clkin(clkin),
    .rst(rst),
    .EltWise_op_en(EltWise_op_en),
    .LeftOperand_data_out(LeftOperand_data_out),
    .RightOperand_data_out(RightOperand_data_out),
    .LeftOperand_valid_fifo(LeftOperand_valid_fifo),
    .RightOperand_valid_fifo(RightOperand_valid_fifo),
    .element_rd_en(element_rd_en),
    .EltWise_IW(EltWise_IW),
    .EltWise_IH(EltWise_IH),    
    .EltWise_IC(EltWise_IC),
    .LeftOperand_empty_flag(LeftOperand_empty_flag),
    .RightOperand_empty_flag(RightOperand_empty_flag),
    .LeftOperand_fifo_data_out(LeftOperand_fifo_data_out),
    .RightOperand_fifo_data_out(RightOperand_fifo_data_out),
    .EW_done(EW_done),
    .data_valid(data_valid),
    .op_fifo_empty(op_fifo_empty)
);
genvar i;
generate
    for(i=0;i<N;i=i+1)begin
        element_wise_op #(
            .DATA_WIDTH(DATA_WIDTH),
            .ELTWISE_TYPE_WIDTH(ELTWISE_TYPE_WIDTH),
            .DATA_WIDTH_OB(DATA_WIDTH_OB)
        ) ew_op (
            .clkin(clkin),
            .LeftOperand(LeftOperand_fifo_data_out[((i+1)*DATA_WIDTH)-1 -:DATA_WIDTH]),
            .RightOperand(RightOperand_fifo_data_out[((i+1)*DATA_WIDTH)-1 -:DATA_WIDTH]),
            .data_valid(data_valid),
            .EltWise_type(EltWise_type),
            .EltWise_out(EltWise_data_out[((i+1)*DATA_WIDTH_OB)-1 -: DATA_WIDTH_OB]),
            .EltWise_valid(EltWise_data_out_valid[i]) 
        );
    end
endgenerate
endmodule