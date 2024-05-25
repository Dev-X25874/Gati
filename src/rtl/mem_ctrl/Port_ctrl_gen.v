///////////////////////////////////////////////////////////////////////////////////////////////////
 
module Port_ctrl_gen #(
    parameter NUM_PORTS = 4,
    parameter PORT_ID = {4'b0000, 4'b0001, 4'b0010, 4'b0011},
    parameter ADDRESS_WIDTH = 32,
    parameter IN_ADDR = 8 ,
    parameter COMBINED_DATA_WIDTH = 41,
    parameter BURST_LENGTH_WIDTH = 4,
    parameter PORT_ID_WIDTH = 4
) (
    input    clk,
    input    rst, 
    input [NUM_PORTS-1:0]       valid,        
    input [NUM_PORTS-1:0]       last,         
    input [(NUM_PORTS * 8)-1:0] in_address,   
    input [(NUM_PORTS * 4)-1:0] in_burst_len, 
    input [NUM_PORTS-1:0]       in_enable_rw, 
    output [NUM_PORTS-1 : 0] o_valid,
    output [(41 * NUM_PORTS)-1 : 0] combined_out
);

  // Generate block to instantiate multiple instances of Port_controller
  genvar i;
  generate
    for (i = 0; i < NUM_PORTS; i = i + 1) begin
      Port_controller #(
        .PORT_ID_VALUE (PORT_ID[(4 * (NUM_PORTS - i))-1 -: 4]) ,
        .ADDR_SEGMENTS (4),
        .ADDRESS_WIDTH (ADDRESS_WIDTH),
        .IN_ADDR (IN_ADDR) ,
        .COMBINED_DATA_WIDTH (COMBINED_DATA_WIDTH),
        .BURST_LENGTH_WIDTH (BURST_LENGTH_WIDTH),
        .PORT_ID_WIDTH (PORT_ID_WIDTH)
      ) Port_controller_inst (
        .clk(clk),
        .rst(rst),
        .valid(valid[i]),  
        .last (last[i]), 
        .in_address(in_address[(8 * (NUM_PORTS - i))-1 -: 8]),        
        .in_enable_rw(in_enable_rw[i]),           
        .in_burst_len(in_burst_len[(4 * (NUM_PORTS - i))- 1 -: 4]),
        .o_valid (o_valid[i]),
        .combined_out (combined_out [(41 * (NUM_PORTS - i))-1 -: 41])
      );
    end
  endgenerate
  
endmodule


///////////////////////////////////////////////////////////////////////////////////////////////////////////////


