module im2col_tb ();


localparam KERNEL_SIZE = 3;
localparam LOWER_BOUND = 1;
localparam UPPER_BOUND = 224;
localparam STRIDE = 3;
localparam W_ADDR = 8;
localparam W_DATA = 8;
localparam DATA_WIDTH = 8;


reg clk_in;
reg rstn;
reg stall_on;
reg i_im2col_start;
reg o_valid ;
reg [(KERNEL_SIZE*KERNEL_SIZE)-1:0] valid_sq;




wire dv;
wire [DATA_WIDTH-1:0] byte;
wire ren;
wire [DATA_WIDTH-1:0] rx_data;
wire valid_buff;
wire [DATA_WIDTH-1:0] mat_size;
wire mat_valid;
wire datavalid;
wire [3:0] zero_pad;
wire [1:0] zero_padded;
wire [DATA_WIDTH-1:0] data;
wire [$clog2(STRIDE):0]stride;
wire emptyflag;
wire i_im2col_start_index;
wire [2:0] w_ksize;


top_im2col #(.KERNEL_SIZE(KERNEL_SIZE), .DATA_WIDTH(DATA_WIDTH), .LOWER_BOUND(LOWER_BOUND), .UPPER_BOUND(UPPER_BOUND), .STRIDE(STRIDE)) top_dut(
.i_clk(clk_in),
.rstn(rstn),
.stall_on(stall_on),
.valid_mat_size(mat_valid),
.i_start_im2col_index(i_im2col_start_index),
//.i_valid_data(datavalid),
//.i_data(data),
.zero_pad(zero_pad),
.zero_padded(zero_padded),
.i_mat_size(mat_size),
.valid_sq(valid_sq),
.ksize(w_ksize),
//.o_valid(o_valid),
.stride(stride),
//.valid_sq_data_o(o_data),
.o_valid_buff(valid_buff)
);

always #10 clk_in = ~clk_in;

initial begin

    $dumpfile("im2col.vcd");
    $dumpvars();

     clk_in = 1'b0;
     rstn   = 1'b0;
     stall_on = 1'b1;
     i_im2col_start_index = 1'b0;
    #20;


    rstn = 1'b1; 
    stall_on = 1'b0;
    mat_valid = 1;
    zero_pad = 4'b0000;
    zero_padded = 2'b0;
    mat_size   =  ;
    w_ksize   = KERNEL_SIZE;
    stride  = STRIDE;

    #15 ;

    i_im2col_start_index = 1'b1;



    









end 


endmodule 
