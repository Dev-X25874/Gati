`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: UART Transmitter
// Module Name: uart_tx
// Description: 
// 
// 
//////////////////////////////////////////////////////////////////////////////////
// The clock frequency --> 100MHz 
// Baud rate           --> 115200
// clk frequency / baud rate --> 100*10^6 / 115200 --> 868 clks/bit 

module uart_tx #(parameter CLKS_PER_BITS = 868)( 
  input [7:0] i_data_byte, //The input to the tx is a byte 
  output      o_data_bit,  //The output from the tx is a bit sent out 8 times serially
  input       clk,
  output      o_done,      //Done is raised when it is done sending all the 8 bits
  input       i_valid,     //It starts converting a byte to bit when it gets a valid
  output      tx_busy      //Busy is high until it transmits one byte
);
  reg         r_tx_busy = 0;
  reg         r_o_data_bit = 1; 
  reg [13:0]  r_counter = 0;// Keeps track of no. of counts tx has to wait to send each bit based on baud rate
  reg [3:0]   r_index = 0;  // Keeps track of bit count (0 to 7) to transmit 8 bits
  reg [2:0]   p_state = 0;
  reg         r_o_done = 0;
  reg [7:0]   r_i_data = 0;
  parameter   IDLE = 2'd0;
  parameter   START_BIT = 2'd1;
  parameter   DATA_BITS = 2'd2;
  parameter   STOP_BIT = 2'd3;
  parameter   STOP_BIT_2 = 2'd4;
  
  assign o_done = r_o_done;
  assign o_data_bit = r_o_data_bit;
  
  always @(posedge clk) begin
    case (p_state)
      IDLE : begin
        r_o_done <= 0;
        r_index <= 0;
        r_counter <= 0;
        r_o_data_bit <= 1;
        if (i_valid == 1) begin
          p_state <= 5;
          r_tx_busy <= 1'b1;
          r_i_data <= i_data_byte;
        end
      end
      
      5: begin
        if(r_counter == CLKS_PER_BITS - 1) begin
          r_counter <= 0;
          p_state <= START_BIT;            
        end else begin
          r_counter <= r_counter + 1;
          r_o_data_bit <= 1'b1;
        end
      end
      
      START_BIT : begin
        if(r_counter == CLKS_PER_BITS - 1) begin
          r_counter <= 0;
          p_state <= DATA_BITS;            
        end else begin
          r_counter <= r_counter + 1;
          r_o_data_bit <= 1'b0;
        end
      end
      
      DATA_BITS : begin
        if (r_index < 8) begin
            if (r_counter == CLKS_PER_BITS - 1) begin
              r_counter <= 0;
              r_index <= r_index + 1;
            end
            else begin
              r_o_data_bit <= r_i_data [r_index];
              r_counter <= r_counter + 1;
            end 
        end else begin
            r_index <= 0;
            p_state <= STOP_BIT;
        end
      end
      STOP_BIT : begin
        if (r_counter == CLKS_PER_BITS - 1) begin
          r_counter <= 0;
          r_o_done <= 1;
          p_state <= IDLE;
          r_tx_busy <= 1'b0;
        end
        else begin
          r_o_data_bit <= 1'b1;
          r_counter <= r_counter + 1;      
        end
      end     
    endcase
  end 
  assign tx_busy = r_tx_busy;
     
endmodule
