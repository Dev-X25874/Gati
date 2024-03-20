module Req_Queue (
  input          clk,          
  input          rst,         
  input  [31:0]  in_address,     // 32-bit input address
  input  [3:0]   in_port_id,     // 4-bit input port ID
  input  [3:0]   in_burst_len,   // 4-bit input burst length
  input          in_enable_rw,   // Read/Write enable input
  
  output  [31:0] out_addr,        // 32-bit output address
  output  [3:0]  out_port_id,        // 4-bit output port ID
  output  [3:0]  BLEN,      // 4-bit output burst length
  output         enable_rw,      // Read/Write enable output
  output reg     empty_flag         // Empty flag indicating if the queue is empty
);

  parameter QUEUE_DEPTH = 8;  // Define the depth of the queue
  
  reg [31:0] address_queue   [QUEUE_DEPTH-1:0] = 0;
  reg [3:0]  port_id_queue   [QUEUE_DEPTH-1:0] = 0;
  reg [3:0]  burst_len_queue [QUEUE_DEPTH-1:0] = 0;
  reg        enable_rw_queue [QUEUE_DEPTH-1:0] = 0;
  
  reg [2:0]  write_ptr = 0;   // Pointer to write into the queue
  reg [2:0]  read_ptr = 0;    // Pointer to read from the queue
  reg [2:0]  count = 0;        // Number of elements in the queue
  
  always @ (posedge clk) begin
    if (!rst) begin
      write_ptr <= 0;
      read_ptr <= 0;
      count <= 0;
      empty_flag <= 1'b1;
    end
    else begin
    
      // Write data into the queue if enable_rw is asserted and queue is not full
      if (in_enable_rw && count < QUEUE_DEPTH) begin
        address_queue[write_ptr] <= in_address;
        port_id_queue[write_ptr] <= in_port_id;
        burst_len_queue[write_ptr] <= in_burst_len;
        enable_rw_queue[write_ptr] <= in_enable_rw;
        
        write_ptr <= write_ptr + 1;
        count <= count + 1;
        empty_flag <= 1'b0;
      end
      
      // Read data from the queue if not empty
      if (count > 0) begin
        out_addr <= address_queue[read_ptr];
        out_port_id <= port_id_queue[read_ptr];
        BLEN <= burst_len_queue[read_ptr];
        enable_rw <= enable_rw_queue[read_ptr];
        
        read_ptr <= read_ptr + 1;
        count <= count - 1;
        
        if (count == 1'b0)
          empty_flag <= 1'b1;
      end
    end
  end

endmodule

