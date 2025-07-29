module generalized_pool #(
parameter N_SA = 8,
parameter DATA_WIDTH = 8,
parameter POOL_HEIGHT = 4, // width of kernal height
parameter POOL_WIDTH = 4, // width of kernal width
parameter POOLING_TYPE_WIDTH = 3,
parameter POOLSTRIDE_WIDTH = 4,
parameter POOLPADDING_WIDTH = 4,
parameter POOLCEIL_WIDTH = 1,
parameter POOLMODCOUNT_WIDTH = 4,
parameter POOLPADSIDES_WIDTH = 4,
parameter POOL_SCALE_WIDTH = 8,
parameter POOL_SHIFT_WIDTH = 4,
parameter OH_WIDTH = 10,
parameter ADDR_WIDTH = 5,
parameter OW_WIDTH = 10)
(
  input clk,
  input [N_SA*DATA_WIDTH-1:0] din, // data_in,
  input rst_n, //rst
  input ENABLE, //maxpool_enable,
  input [N_SA -1:0] datavalid_in, //datavalid,
  input [(POOLING_TYPE_WIDTH - 1) : 0] PoolType,  // Type of pooling (Max/Avg)
  input [(POOLSTRIDE_WIDTH - 1) : 0]PoolStride,
  input [(POOL_WIDTH - 1) : 0] PoolWidth,            // Width of the pooling kernel
  input [(POOL_HEIGHT - 1) : 0] PoolHeight,          // Height of the pooling kernel
  input [(POOLPADDING_WIDTH - 1) : 0] PoolPadding,
  input [(POOLCEIL_WIDTH - 1) : 0] PoolCeil,
  input [(POOLMODCOUNT_WIDTH - 1) : 0] PoolModCount,
  input [(POOLPADSIDES_WIDTH - 1) : 0] PoolPadSides,
  input [(POOL_SCALE_WIDTH - 1) : 0] PoolScale, // Scale factor for average pool
  input [(POOL_SHIFT_WIDTH - 1) : 0] PoolShift, // Shift value for average pool
  input [(OH_WIDTH + OW_WIDTH - 1) : 0] PoolimageSize,
  input [(OH_WIDTH - 1) : 0] OH, // Output Height of the image //input [IMG_WIDTH-1:0] IW,
  input [(OW_WIDTH - 1) : 0] OW, // Output Width of the image //input [IMG_WIDTH-1:0] IW,
  output [N_SA*DATA_WIDTH-1:0] dout,
  output [N_SA -1:0] done,
  output [N_SA -1:0] datavalid_out
  );
  
  genvar i;
  generate
    for(i=0;i<N_SA;i=i+1)begin

      top_max # (
    .DATA_WIDTH(DATA_WIDTH),
    .POOL_HEIGHT(POOL_HEIGHT),
    .POOL_WIDTH(POOL_WIDTH),
    .POOLING_TYPE_WIDTH(POOLING_TYPE_WIDTH),
    .POOLSTRIDE_WIDTH(POOLSTRIDE_WIDTH),
    .POOLPADDING_WIDTH(POOLPADDING_WIDTH),
    .POOLCEIL_WIDTH(POOLCEIL_WIDTH),
    .POOLMODCOUNT_WIDTH(POOLMODCOUNT_WIDTH),
    .POOLPADSIDES_WIDTH(POOLPADSIDES_WIDTH),
    .POOL_SCALE_WIDTH(POOL_SCALE_WIDTH),
    .POOL_SHIFT_WIDTH(POOL_SHIFT_WIDTH),
    .OH_WIDTH(OH_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .OW_WIDTH(OW_WIDTH)
  )
  top_max_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .din(din[(DATA_WIDTH*(N_SA -i)) -1 -:DATA_WIDTH]),
    .datavalid_in(datavalid_in[i]),
    .PoolType(PoolType),
    .PoolStride(PoolStride),
    .PoolWidth(PoolWidth),
    .PoolHeight(PoolHeight),
    .PoolPadding(PoolPadding),
    .PoolCeil(PoolCeil),
    .PoolModCount(PoolModCount),
    .PoolPadSides(PoolPadSides),
    .PoolScale(PoolScale),
    .PoolShift(PoolShift),
    .PoolimageSize(PoolimageSize),
    .OH(OH),
    .OW(OW),
    .dout(dout[(DATA_WIDTH*(N_SA-i)) -1 -:DATA_WIDTH]),
    .done(done[i]),
    .datavalid_out(datavalid_out[i])
  );
	end
endgenerate 
endmodule