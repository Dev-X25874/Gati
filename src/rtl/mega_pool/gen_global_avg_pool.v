module global_avg_pool_gen #(
parameter N_SA = 8,
parameter DATA_WIDTH = 8,
parameter POOLING_TYPE_WIDTH = 3,
parameter POOL_SCALE_WIDTH = 8,
parameter POOL_SHIFT_WIDTH = 4,
parameter OH_WIDTH = 10,
parameter OW_WIDTH = 10)
(
  input clk,
  input [N_SA*DATA_WIDTH-1:0] din, // data_in,
  input rst_n, //rst
  input ENABLE, //maxpool_enable,
  input [N_SA -1:0] datavalid_in, //datavalid,
  input [(POOLING_TYPE_WIDTH - 1) : 0] PoolType,  // Type of pooling (Max/Avg)
  input [(POOL_SCALE_WIDTH - 1) : 0] PoolScale, // Scale factor for average pool
  input [(POOL_SHIFT_WIDTH - 1) : 0] PoolShift, // Shift value for average pool
  input [(OH_WIDTH + OW_WIDTH - 1) : 0] PoolimageSize,
  output [N_SA*DATA_WIDTH-1:0] dout,
  output [N_SA -1:0] datavalid_out
  );
  
  genvar i;
  generate
    for(i=0;i<N_SA;i=i+1)begin

    global_avg_pool # (
    .DATA_WIDTH(DATA_WIDTH),
    .POOLING_TYPE_WIDTH(POOLING_TYPE_WIDTH),
    .POOL_SCALE_WIDTH(POOL_SCALE_WIDTH),
    .POOL_SHIFT_WIDTH(POOL_SHIFT_WIDTH),
    .OH_WIDTH(OH_WIDTH),
    .OW_WIDTH(OW_WIDTH)
  )
  global_avg_pool_inst (
    .clk(clk),
    .rst_n(rst_n),
    .ENABLE(ENABLE),
    .din(din[(DATA_WIDTH*(N_SA -i)) -1 -:DATA_WIDTH]),
    .datavalid_in(datavalid_in[i]),
    .PoolType(PoolType),
    .PoolScale(PoolScale),
    .PoolShift(PoolShift),
    .PoolimageSize(PoolimageSize),
    .dout(dout[(DATA_WIDTH*(N_SA-i)) -1 -:DATA_WIDTH]),
    .datavalid_out(datavalid_out[i])
  );
	end
endgenerate 
endmodule