`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: UART RECEIVER
// Module Name: uart_rx
// Project Name: 
//////////////////////////////////////////////////////////////////////////////////
//The system clock frequcny is = 100MHz;
//The Baud rate is = 115200 bps;
//wkt: clk frequency/divisor = baud rate 
//--> Accordingly                    100 * 10^6 / 115200 = 868.05 
//--> Round it off to                                    = 868 = CLKS_PER_BIT
//So the receiver takes 868 clock cycles to sample a single bit of the data, we will sample it
//at the middle of the bit width to get the intended data for sampling. And so the start bit 
//is run for CLKS_PER_BIT/2 no. of times.  

module uart_rx #(parameter CLKS_PER_BIT = 868)(
  input          clk,       
  input          i_data,          // The input for the rx is 1 bit
  output [7:0]   o_data,          // The output from the rx is a byte
  output         o_valid_data,    // The valid is asserted when the rx recieves all the 8 bits
  output         rx_busy          // It is busy until it hasn't receieved all the 8 bits
);
  reg [3:0]    r_index=0;         // Keeps track of bit count (0 to 7) to recieve 8 bits  
  reg [13:0]   r_counter=0;       // Keeps track of no. of counts rx has to wait to sample each bit
  reg [7:0]    r_o_data=0;        
  reg          r_valid_data=0;
  reg [1:0]    p_state=0;
  reg          r_rx_busy = 0;
  
  parameter    IDLE = 2'd0;
  parameter    START_BIT = 2'd1;
  parameter    DATA_BITS = 2'd2;
  parameter    STOP_BIT = 2'd3;
  
assign o_data = r_o_data;
assign o_valid_data = r_valid_data;
assign rx_busy = r_rx_busy;
always @(posedge clk) begin
  case (p_state)
    IDLE: begin
      r_valid_data <= 1'b0;
      r_counter <= 0;
      r_index <= 0;
    if (i_data == 1'b0) begin
        p_state <= START_BIT;
        r_rx_busy <= 1'b1;       
    end else begin
        p_state <= IDLE; 
    end
   end 
    START_BIT: begin
      if (r_counter == (CLKS_PER_BIT / 2)) begin
        if (i_data == 1'b0) begin
          r_counter <= 0;
          p_state <= DATA_BITS;
        end else begin 
          p_state <= IDLE;
        end
      end else begin
        r_counter <= r_counter + 1;
        p_state <= START_BIT;
      end     
    end
    DATA_BITS: begin
      if (r_counter == CLKS_PER_BIT) begin 
        r_counter <= 0;
        r_o_data[r_index] <= i_data;
        if (r_index < 7) begin
          r_index <= r_index + 1;
          p_state <= DATA_BITS;
        end else begin
          r_index <= 0;
          p_state <= STOP_BIT;
        end
      end else begin
        r_counter <= r_counter + 1;
        p_state <= DATA_BITS;    
      end
    end 
    STOP_BIT: begin
      if (r_counter == CLKS_PER_BIT) begin
        if (i_data == 1'b1) begin
          r_valid_data <= 1;
          r_counter <= 0;
        end
        r_rx_busy <= 1'b0;
        p_state <= IDLE;
      end else begin
        r_counter <= r_counter + 1;
        p_state <= STOP_BIT;
      end 
    end
  endcase   
end   
endmodule

