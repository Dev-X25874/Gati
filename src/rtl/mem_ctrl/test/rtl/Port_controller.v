/////////////////////////////////////////////////////////////////////////////////////////////////

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
  
  output reg         o_valid = 0,
  output  [31:0]  out_address,   // 32-bit output address
  output  [3:0]   out_burst_len, // 4-bit output burst length
  output          out_enable_rw, // Read/Write enable output
  output  [3:0]   port_id,
  output reg [40 : 0 ] combined_out = 0
);

  reg [31:0] address_reg = 0;
  reg [3:0]  burst_len_reg = 0;
  reg        enable_rw_reg = 0;
  reg [3:0]  port_id_reg = 0;
  reg [2:0]  address_transmit_counter = 0;
  reg [7:0]  addr_segment[ADDR_SEGMENTS-1:0];
 
  always @ (posedge clk ) begin
    if (!rst) begin
      address_reg <= 32'b0;
      burst_len_reg <= 4'b0;
      enable_rw_reg <= 1'b0;
      port_id_reg <= PORT_ID_VALUE;
      address_transmit_counter <= 0;
      o_valid <= 0;
      combined_out <= 0 ;
    end
    else begin
      if (valid && address_transmit_counter < ADDR_SEGMENTS) begin
        addr_segment[address_transmit_counter] <= in_address;
        address_transmit_counter <= address_transmit_counter + 1;
        address_reg <= 0 ;
        combined_out <= 0 ;
       // o_valid <= 1 ;
      end
      
      if (valid) begin
        //if (last) begin
        address_reg <= {addr_segment[0], addr_segment[1], addr_segment[2], addr_segment[3]};
      //  combined_out <= {address_reg, burst_len_reg, port_id_reg, enable_rw_reg} ;
        burst_len_reg <= in_burst_len;
        enable_rw_reg <= in_enable_rw;
        port_id_reg <= PORT_ID_VALUE;
     //   combined_out <= 0;
       // o_valid <= 1;
        //end 
      end
      
      if (valid == 0 || last && address_transmit_counter == ADDR_SEGMENTS ) begin
        address_transmit_counter <= 0;
        //o_valid <= 1 ;
        if (last) begin
            o_valid <= 1 ;
            combined_out <= {address_reg, burst_len_reg, port_id_reg, enable_rw_reg} ;
            
        end
        else begin 
            o_valid <= 0;
            combined_out <= combined_out;
        end
      end 
    end
  end

  assign out_address = address_reg;
  assign out_burst_len = burst_len_reg;
  assign out_enable_rw = enable_rw_reg;
  assign port_id = port_id_reg;

endmodule


/*
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
  
  output reg         o_valid = 0,
  output  [31:0]  out_address,   // 32-bit output address
  output  [3:0]   out_burst_len, // 4-bit output burst length
  output          out_enable_rw, // Read/Write enable output
  output  [3:0]   port_id
);

  reg [31:0] address_reg = 0;
  reg [3:0]  burst_len_reg = 0;
  reg        enable_rw_reg = 0;
  reg [3:0]  port_id_reg = 0;
  reg [2:0]  address_transmit_counter = 0;
  reg [7:0]  addr_segment[ADDR_SEGMENTS-1:0];
 
  always @ (posedge clk ) begin
    if (!rst) begin
      address_reg <= 32'b0;
      burst_len_reg <= 4'b0;
      enable_rw_reg <= 1'b0;
      port_id_reg <= PORT_ID_VALUE;
      address_transmit_counter <= 0;
     // o_valid <= 0;
    end
    else begin
      if (valid && address_transmit_counter < ADDR_SEGMENTS) begin
        addr_segment[address_transmit_counter] <= in_address;
        address_transmit_counter <= address_transmit_counter + 1;
       // o_valid <= 1 ;
      end
      else  begin
      //  address_transmit_counter <= 0; 
        if (last && address_transmit_counter == ADDR_SEGMENTS && valid) begin
        address_reg <= {addr_segment[3], addr_segment[2], addr_segment[1], addr_segment[0]};
        burst_len_reg <= in_burst_len;
        enable_rw_reg <= in_enable_rw;
        port_id_reg <= PORT_ID_VALUE;
       // o_valid <= 0;
      end
    end 
    end
  end

  always @ (posedge clk) begin 
    if (valid == 1) 
        o_valid <= 1'b1 ;
    else 
        o_valid <= 0 ; 
  end 
  
  
  assign out_address = address_reg;
  assign out_burst_len = burst_len_reg;
  assign out_enable_rw = enable_rw_reg;
  assign port_id = port_id_reg;

endmodule*/




/*module Port_controller #(
  parameter ADDR_SEGMENTS = 4 ,
  parameter PORT_ID_VALUE = 4'b0000 
) (
  input              clk,          // Clock signal
  input              rst,          // Reset signal  
  input              valid,        // Valid signal
  input              last,         // Last signal  
  input      [7:0]   in_address,   // 8-bit input address
  input      [3:0]   in_burst_len, // 4-bit input burst length
  input              in_enable_rw, // Read/Write enable input
  
  output  reg        o_valid ,
  output  [31:0]  out_address,  // 32-bit output address
  output  [3:0]   out_burst_len,// 4-bit output burst length
  output          out_enable_rw,  // Read/Write enable output
  output  [3:0]   port_id
);
  reg [31:0] address_reg = 0;
  reg [3:0]  burst_len_reg = 0;
  reg        enable_rw_reg = 0;
  reg [3:0]  port_id_reg = 0;
  reg [2:0]  address_transmit_counter = 0;
  
  // Address slicing
  reg [7:0] addr_segment[ADDR_SEGMENTS-1:0];
 
  
  always @ (posedge clk ) begin
    if (!rst) begin
      address_reg <= 32'b0;
      burst_len_reg <= 4'b0;
      enable_rw_reg <= 1'b0;
      o_valid <= 0;
      address_transmit_counter <= 0;

    end
    else if (valid && address_transmit_counter < ADDR_SEGMENTS) begin
      addr_segment[address_transmit_counter] <= in_address;
      address_transmit_counter <= address_transmit_counter + 1;
      o_valid <= 1'b1 ;
      
      if (address_transmit_counter == ADDR_SEGMENTS && last) begin
        address_transmit_counter <= 0;
        o_valid <= 1'b1 ;
      end
    end
    
    if (valid && address_transmit_counter == 0) begin
        address_reg <= {addr_segment[3], addr_segment[2], addr_segment[1], addr_segment[0]};
        o_valid <= 1'b1 ;
        burst_len_reg <= in_burst_len;
        enable_rw_reg <= in_enable_rw;
        port_id_reg <= PORT_ID_VALUE;
      
    end
    else begin 
        if (valid == 1) 
            o_valid <= 1 ;
        else 
            o_valid <= 0 ;
    end 
   // else 
       // o_valid <= 0;
  end

assign out_address = address_reg ;
assign out_burst_len = burst_len_reg ;
assign out_enable_rw = enable_rw_reg ;
assign port_id = port_id_reg;

endmodule*/
  //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
module inputconvert #(
  parameter ADDR_WIDTH = 32,
  parameter BURST_LENGTH_WIDTH = 4,
  parameter PORT_ID_WIDTH = 4
)(
  input clk,
  input rst,
  input  [ADDR_WIDTH-1:0] address,
  input  [BURST_LENGTH_WIDTH-1:0] burst_length,
  input  [PORT_ID_WIDTH-1:0] i_port,
  input  rw_in,

  output [(ADDR_WIDTH+BURST_LENGTH_WIDTH+PORT_ID_WIDTH+1)-1:0] combined_input
);

reg [ADDR_WIDTH-1 :0] add_reg = 0;
reg [BURST_LENGTH_WIDTH-1 :0 ] blen_reg = 0;
reg [PORT_ID_WIDTH-1 :0] port_reg = 0;
reg rw_reg = 0;
    
  always @ (posedge clk) begin 
    if (!rst) begin 
        add_reg <= 0 ;
        blen_reg <= 0;
        port_reg <= 0 ;
        rw_reg <= 0 ;
    end 
    
    else begin 
        add_reg <= address ;
        blen_reg <= burst_length ;
        port_reg <= i_port ;
        rw_reg <= rw_in ;
    end 
 end 
 
  assign combined_input = {add_reg , blen_reg, port_reg , rw_reg };

endmodule*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


/*module Port_controller #(
  parameter ADDR_SEGMENTS = 4 ,
  parameter PORT_ID_VALUE = 4'b0000 
) (
  input              clk,          // Clock signal
  input              rst,          // Reset signal  
  input              valid,        // Valid signal
  input              last,         // Last signal  
  input      [7:0]   in_address,   // 8-bit input address
  input      [3:0]   in_burst_len, // 4-bit input burst length
  input              in_enable_rw, // Read/Write enable input
  output reg      o_valid ,
  output  [31:0]  out_address,  // 32-bit output address
  output  [3:0]   out_burst_len,// 4-bit output burst length
  output          out_enable_rw,  // Read/Write enable output
  output  [3:0]   port_id
);
  reg [31:0] address_reg = 0;
  reg [3:0]  burst_len_reg = 0;
  reg        enable_rw_reg = 0;
  reg [3:0]  port_id_reg = 0;
  
  // Address slicing
  reg [7:0] addr_segment[ADDR_SEGMENTS-1:0];
 
   genvar i;
   generate
    for (i = 0; i < ADDR_SEGMENTS; i = i + 1) begin 
     always @* begin
        if (valid == 1'b1) begin
            addr_segment[i] = in_address[i*8 +: 8]  ;             // [(i+1)*8-1 -: 8];      //
       end
      end
    end
  endgenerate
  
  always @ (posedge clk ) begin
    if (!rst) begin
      address_reg <= 32'b0;
      burst_len_reg <= 4'b0;
      enable_rw_reg <= 1'b0;
      o_valid <= 1'b0 ;

    end
    else begin
      // Update internal registers on positive edge of clock when valid signal is asserted
      if (valid  && last) begin         
        // Concatenate the address segments to form the 32-bit address
        address_reg <= {addr_segment[3], addr_segment[2], addr_segment[1], addr_segment[0]};
        
      //  if (last == 1) begin 
        o_valid <= 1'b1 ; 
        burst_len_reg <= in_burst_len;
        enable_rw_reg <= in_enable_rw;
        port_id_reg <= PORT_ID_VALUE;
      // end 
      end
    end
  end

assign out_address = address_reg ;
assign out_burst_len = burst_len_reg ;
assign out_enable_rw = enable_rw_reg ;
assign port_id = port_id_reg;

endmodule*/