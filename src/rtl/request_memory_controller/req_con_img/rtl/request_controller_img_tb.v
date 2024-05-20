module request_controller_img_tb;

  // Parameters
  localparam  burst_length_out = 15;
  localparam  occupancy_count = 40;
  localparam  AXI_DATA_BYTES = 32;

  //Ports
  reg [31:0] start_addr;
  reg [11:0] channelitr;
  reg [11:0] kernelitr;
  reg [31:0] stop_addr;
  reg  config_start;
  reg  fifo_status;
  reg  clk;
  wire reg [7:0] addr_out;
  wire  wr_enable;
  wire  valid;
  wire [$clog2(AXI_DATA_BYTES) : 0] burst_length;

  request_controller_img # (
    .burst_length_out(burst_length_out),
    .occupancy_count(occupancy_count),
    .AXI_DATA_BYTES(AXI_DATA_BYTES)
  )
  request_controller_img_inst (
    .start_addr(start_addr),
    .channelitr(channelitr),
    .kernelitr(kernelitr),
    .stop_addr(stop_addr),
    .config_start(config_start),
    .fifo_status(fifo_status),
    .clk(clk),
    .addr_out(addr_out),
    .wr_enable(wr_enable),
    .valid(valid),
    .burst_length(burst_length)
  );

initial begin
    start_addr = 0;
    channelitr = 0;
    kernelitr = 0;
    stop_addr = 0;
    config_start = 0;
    fifo_status = 0;
    clk = 0;
end  

always #5  clk = ~clk ;

initial begin
  $dumpfile("req_con_img.vcd");
  $dumpvars(0,request_controller_img_tb);
  fifo_status = 1;
  config_start = 1;
  start_addr = 32'd0;
  stop_addr = 32'd7163;
  kernelitr = 12'd2;
  #1000;
  $finish;  
end

endmodule