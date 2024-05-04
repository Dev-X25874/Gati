/*
    Generate uart transmitter N_SA times,
    output of each engine is received by each tranmsitter in fifo
*/
module uart_tx#(
    parameter W_DATA = 8,
    parameter N_SA = 4
)(  
    input i_clk,
    input i_rst,
    input [N_SA-1 : 0] i_tx_dv,
    input [(N_SA * W_DATA)-1 : 0] i_tx_byte,
    output [N_SA-1 : 0] o_tx_done,
    output [N_SA-1 : 0] o_tx_serial
);
  
genvar i;
generate
    for (i = 0; i < N_SA; i = i + 1) begin
        tx#(
            .CLKS_PER_BIT(50)
        )transmitter(
            .i_Rst(i_rst),
            .i_Clock(i_clk),
            .i_TX_DV(i_tx_dv[i]),
            .i_TX_Byte(i_tx_byte[((W_DATA * (N_SA - i)) -1) -: W_DATA]),
            .o_TX_Active(),
            .o_TX_Serial(o_tx_serial[i]),
            .o_TX_Done(o_tx_done[i])
		);
    end
endgenerate
endmodule

module tx 
  #(parameter CLKS_PER_BIT = 10416)
  (
   input       i_Rst,
   input       i_Clock,
   input       i_TX_DV,
   input [7:0] i_TX_Byte, 
   output reg  o_TX_Active,
   output reg  o_TX_Serial,
   output reg  o_TX_Done
   );
 
  localparam IDLE         = 2'b00;
  localparam TX_START_BIT = 2'b01;
  localparam TX_DATA_BITS = 2'b10;
  localparam TX_STOP_BIT  = 2'b11;
  
  reg [2:0] r_SM_Main;
  reg [13:0] r_Clock_Count;
  reg [2:0] r_Bit_Index;
  reg [7:0] r_TX_Data;


  // Purpose: Control TX state machine
  always @(posedge i_Clock or posedge i_Rst)
  begin
    if (i_Rst)
    begin
      r_SM_Main <= 3'b000;
    end
    else
    begin

      o_TX_Done <= 1'b0;

      case (r_SM_Main)
      IDLE :
        begin
          o_TX_Serial   <= 1'b1;         // Drive Line High for Idle
          r_Clock_Count <= 0;
          r_Bit_Index   <= 0;
          
          if (i_TX_DV == 1'b1)
          begin
            o_TX_Active <= 1'b1;
            r_TX_Data   <= i_TX_Byte;
            r_SM_Main   <= TX_START_BIT;
          end
          else
            r_SM_Main <= IDLE;
        end // case: IDLE
      
      
      // Send out Start Bit. Start bit = 0
      TX_START_BIT :
        begin
          o_TX_Serial <= 1'b0;
          
          // Wait CLKS_PER_BIT-1 clock cycles for start bit to finish
          if (r_Clock_Count < CLKS_PER_BIT-1)
          begin
            r_Clock_Count <= r_Clock_Count + 1'b1;
            r_SM_Main     <= TX_START_BIT;
          end
          else
          begin
            r_Clock_Count <= 0;
            r_SM_Main     <= TX_DATA_BITS;
          end
        end // case: TX_START_BIT
      
      
      // Wait CLKS_PER_BIT-1 clock cycles for data bits to finish         
      TX_DATA_BITS :
        begin
          o_TX_Serial <= r_TX_Data[r_Bit_Index];
          
          if (r_Clock_Count < CLKS_PER_BIT-1)
          begin
            r_Clock_Count <= r_Clock_Count + 1'b1;
            r_SM_Main     <= TX_DATA_BITS;
          end
          else
          begin
            r_Clock_Count <= 0;
            
            // Check if we have sent out all bits
            if (r_Bit_Index < 7)
            begin
              r_Bit_Index <= r_Bit_Index + 1'b1;
              r_SM_Main   <= TX_DATA_BITS;
            end
            else
            begin
              r_Bit_Index <= 0;
              r_SM_Main   <= TX_STOP_BIT;
            end
          end 
        end // case: TX_DATA_BITS
      
      
      // Send out Stop bit.  Stop bit = 1
      TX_STOP_BIT :
        begin
          o_TX_Serial <= 1'b1;
          
          // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
          if (r_Clock_Count < CLKS_PER_BIT-1)
          begin
            r_Clock_Count <= r_Clock_Count + 1'b1;
            r_SM_Main     <= TX_STOP_BIT;
          end
          else
          begin
            o_TX_Done     <= 1'b1;
            r_Clock_Count <= 0;
            r_SM_Main     <= IDLE;
            o_TX_Active   <= 1'b0;
          end 
        end // case: TX_STOP_BIT      
      
      default :
        r_SM_Main <= IDLE;
      
    endcase
    end // else: !if(~i_Rst_L)
  end // always @ (posedge i_Clock or negedge i_Rst_L)

  
endmodule