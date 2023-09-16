`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Maxpooling
// Module Name: maxpooling_pipelined
// Project Name: CNN Acceleration - GATI
// Description: This is the sub block where the maximum element of each region is computed 
//////////////////////////////////////////////////////////////////////////////////


module maxpooling_pipelined(
  input         clk, 
  input[7:0]    feature_map_inp,//Input
  input         flag_read, //Select line for address mux in top
  output[7:0]   downsampled_out //Output
    );
    
  reg       flag_maxpool = 0;
  reg [7:0] reg_0 = 0;
  reg [7:0] reg_1 = 0;
  reg [7:0] reg_2 = 0;
  reg [7:0] reg_3 = 0;
  reg [7:0] temp_1 =0;
  reg [7:0] temp_2 =0;
    
  reg[1:0]  p_state =0 ; 
  parameter CHECKFLAG_AND_REGISTERDATA1=2'b00;
  parameter REGISTER_DATA2=2'b01;
  parameter REGISTER_DATA3=2'b10;
  parameter REGISERDATA4_AND_CHECKFLAG=2'b11;
  
  reg [7:0] max_val=0;
  assign downsampled_out=max_val;
  reg [7:0] prev_max=0;
    
    
  //Maxpooing computation  
always @(posedge clk) begin
  if (flag_maxpool) begin
    if (reg_0>reg_1) begin
      temp_1<=reg_0; 
    end else begin
      temp_1<=reg_1;
    end 
     
   if (reg_2>reg_3) begin
     temp_2<=reg_2; 
   end else begin
     temp_2<=reg_3;
   end 
 end else begin
      max_val<=prev_max;
   end
 end 
     
always @ (posedge clk) begin
  if (temp_1>temp_2) begin
    max_val<=temp_1; 
  end else begin
    max_val<=temp_2; 
  end
end   
    
  //Implementation of FSM for registering the data   
always @(posedge clk) begin
  prev_max <= max_val;
case (p_state)      
  CHECKFLAG_AND_REGISTERDATA1 : begin
    if(flag_read==1 ) begin
      flag_maxpool <= 0;
      p_state <=REGISTER_DATA2 ;
      reg_0 <= feature_map_inp;
    end 
  end
            
  REGISTER_DATA2: begin
    reg_1 <= feature_map_inp;
    p_state <= REGISTER_DATA3;
  end
  
  REGISTER_DATA3: begin
    reg_2 <= feature_map_inp;
    p_state <= REGISERDATA4_AND_CHECKFLAG;
  end
  
  REGISERDATA4_AND_CHECKFLAG: begin
    reg_3 <= feature_map_inp;
    p_state <= CHECKFLAG_AND_REGISTERDATA1;
    flag_maxpool <= 1;
  end
  
  default: begin
    p_state <= CHECKFLAG_AND_REGISTERDATA1;
  end
 endcase
 end

endmodule    
    
    

