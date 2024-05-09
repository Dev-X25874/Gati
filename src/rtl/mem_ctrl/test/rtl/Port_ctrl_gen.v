///////////////////////////////////////////////////////////////////////////////////////////////////
 
module Port_ctrl_gen #(
    parameter NUM_PORTS = 4,
    parameter PORT_ID = {4'b0000, 4'b0001, 4'b0010, 4'b0011}
) (
    input    clk,
    input    rst, 
    input [NUM_PORTS-1:0]       valid,        
    input [NUM_PORTS-1:0]       last,         
    input [(NUM_PORTS * 8)-1:0] in_address,   
    input [(NUM_PORTS * 4)-1:0] in_burst_len, 
    input [NUM_PORTS-1:0]       in_enable_rw, 
  
    output [(NUM_PORTS * 32)-1:0] out_address,  
    output [NUM_PORTS-1 : 0] o_valid,
    output [(NUM_PORTS * 4)-1:0] out_burst_len,
    output [NUM_PORTS-1:0] out_enable_rw,
    output [(NUM_PORTS * 4)-1:0] port_id,
    output [(41 * NUM_PORTS)-1 : 0] combined_out
);

  // Generate block to instantiate multiple instances of Port_controller
  genvar i;
  generate
    for (i = 0; i < NUM_PORTS; i = i + 1) begin
      Port_controller #(
        .PORT_ID_VALUE (PORT_ID[(4 * (NUM_PORTS - i))-1 -: 4]) ,
        .ADDR_SEGMENTS (4)
      ) Port_controller_inst (
        .clk(clk),
        .rst(rst),
        .valid(valid[i]),  
        .last (last[i]), 
        .in_address(in_address[(8 * (NUM_PORTS - i))-1 -: 8]),        
      //  .in_enable_rw(in_enable_rw[NUM_PORTS-1-i]),           
        .in_enable_rw(in_enable_rw[i]),           
        .in_burst_len(in_burst_len[(4 * (NUM_PORTS - i))- 1 -: 4]),
        .o_valid (o_valid[i]),
        .out_address (out_address [(32 * (NUM_PORTS - i))-1 -: 32]),
        .out_burst_len (out_burst_len [(4 * (NUM_PORTS - i))-1 -: 4]),
      //  .out_enable_rw (out_enable_rw[NUM_PORTS-1-i]) ,
        .out_enable_rw (out_enable_rw[i]) ,
        .port_id (port_id[(4 * (NUM_PORTS - i))-1 -: 4]),
        .combined_out (combined_out [(41 * (NUM_PORTS - i))-1 -: 41])
      );
    end
  endgenerate
  

    //  assign combined_out = {out_address, out_burst_len, out_enable_rw, out_enable_rw};

endmodule
