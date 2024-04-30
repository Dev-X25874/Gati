
module request_controller_accumulator_tb;

  // Parameters
  localparam  BURST_LENGTH = 15;
  localparam  OCCUPANCY = 40;
  localparam  AXI_DATA_BYTES = 32;

  //Ports
  reg [31:0] start_addr;
  reg [31:0] stop_addr;
  reg  config_start;
  reg  fifo_status;
  reg  clk;
  reg  enable;
  wire reg [7:0] addr_out;
  wire  wr_enable;
  wire  valid;
  wire [$clog2(AXI_DATA_BYTES) : 0] burst_length;

  request_controller_accumulator # (
    .BURST_LENGTH(BURST_LENGTH),
    .OCCUPANCY(OCCUPANCY),
    .AXI_DATA_BYTES(AXI_DATA_BYTES)
  )
  request_controller_accumulator_inst (
    .start_addr(start_addr),
    .stop_addr(stop_addr),
    .config_start(config_start),
    .fifo_status(fifo_status),
    .clk(clk),
    .enable(enable),
    .addr_out(addr_out),
    .wr_enable(wr_enable),
    .valid(valid),
    .burst_length(burst_length)
  );

  initial begin
    start_addr = 0;
    stop_addr = 0;
    config_start = 0;
    fifo_status = 0;
    clk = 0;
    enable = 0;
  end

always #5  clk = ~clk ;

initial begin
    $dumpfile("req_con_accumulator.vcd");
    $dumpvars(0,request_controller_accumulator_tb);
    enable = 1;
    config_start = 1;
    fifo_status = 1;
    start_addr = 32'h0000_0000;
    stop_addr = 32'h0000_1F96;
    #1000;
    $finish; 
end

endmodule