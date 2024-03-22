
module Port_controller #(
  parameter ADDR_SEGMENTS = 4,
  parameter PORT_ID_VALUE = 4'b0000 
)(
  input              clk,          // Clock signal
  input              rst,          // Reset signal  
  input              valid,        // Valid signal
  input              last,         // Last signal  
  input      [7:0]   in_address,   // 8-bit input address
  input      [3:0]   in_burst_len, // 4-bit input burst length
  input              in_enable_rw, // Read/Write enable input
  
  output   reg     o_valid = 0,
  output  [31:0] out_address,   // 32-bit output address
  output  [3:0]  out_burst_len, // 4-bit output burst length
  output          out_enable_rw, // Read/Write enable output
  output   [3:0]  port_id,
  output reg [40:0]  combined_out = 0
);

  parameter IDLE = 2'b00;
  parameter TRANSMIT_ADDRESS = 2'b01;
  parameter WAIT_DATA = 2'b10 ;
  
  // Define state register
  reg [1:0] state = 0;
  
  // Registers for storing data
  reg [31:0] address_reg = 0;
  reg [3:0]  burst_len_reg = 0;
  reg        enable_rw_reg = 0;
  reg [3:0]  port_id_reg = 0;
  reg [2:0]  address_transmit_counter = 0;
  reg [7:0]  addr_segment [ADDR_SEGMENTS - 1:0];
  
  // Separate always block for handling address and valid signal
  always @(posedge clk) begin
    if (!rst) begin
      address_reg <= 0;
    //  address_transmit_counter <= 0;
      //o_valid <= 0;
    end 
    else begin
      if (valid)begin
        address_reg <= {address_reg[23:0],in_address};
      end
      
    end
  end
  
  // FSM
  always @(posedge clk) begin
    if (!rst) begin
      state <= IDLE;
      burst_len_reg <= 0;
      enable_rw_reg <= 0;
      port_id_reg <= PORT_ID_VALUE;
      combined_out <= 0;
    end 
    else begin 
      case (state)
        IDLE: begin 
          if (valid) begin
            state <= TRANSMIT_ADDRESS;
            burst_len_reg <= in_burst_len;
            enable_rw_reg <= in_enable_rw;
            o_valid <= 0 ;
          end
        end
        TRANSMIT_ADDRESS: begin 
          if (last) begin
            o_valid <= 1'b0 ;
            //combined_out <= {address_reg, burst_len_reg, port_id_reg, enable_rw_reg};
            state <= WAIT_DATA ;
          end
        end 
        
        WAIT_DATA : begin 
            o_valid <= 1'b1 ;
            combined_out <= {address_reg, burst_len_reg, port_id_reg, enable_rw_reg};
            state <= IDLE ;
        end
      endcase
    end
  end
  
  // Output assignments
  assign out_address = address_reg;
  assign out_burst_len = burst_len_reg;
  assign out_enable_rw = enable_rw_reg;
  assign port_id = port_id_reg;

endmodule