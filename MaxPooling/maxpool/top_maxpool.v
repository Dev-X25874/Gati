`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Maxpooling
// Module Name: top_maxpool
// Project Name: CNN Acceleration
// Target Devices: 
// Tool Versions: 
// Description: Max pooling is a downsampling technique in neural networks used to reduce spatial dimensions of 
//              feature maps. 
//              It partitions input data into non-overlapping regions and selects the maximum value from each region,
//              effectively preserving essential features while reducing computational complexity and preventing 
//              overfitting.
// 
//////////////////////////////////////////////////////////////////////////////////


module top_maxpool(
  input         i_clk, 
  input         i_write_en, // write or read enable(0--> write, 1--> read) 
  input         i_cs,       // chip select is like an enable signal, if cs--> 0 then neither write nor read 
  input [7:0]   i_data,     // incoming data from the testbench to be written to register 
  input [5:0]   i_addr,     // address from the testbench
  output [7:0]  o_data,     // output gives the max of the 4 elements
  input         i_flag
);
  wire [7:0]    mem_mux;
  wire [7:0]    wire_data;
  wire [5:0]    rd_addr;
  wire          cs_mux;
  wire          w_cs;
  wire          w_wr_en;
  wire          wr_en_mux;
    //Instantiation of Single Port Memory
single_port_memory memory_mod(
  .clk        (i_clk),
  .wr_en      (wr_en_mux), 
  .cs         (cs_mux),    
  .addr       (mem_mux), 
  .w_data     (i_data),    
  .r_data     (wire_data)       
);    
    //Instantiation of address generator
address_gen address_generator_mod(
  .flag       (i_flag),  
  .ag_cs      (w_cs),  
  .ag_wr_en   (w_wr_en),  
  .addr_gen   (rd_addr), 
  .clk        (i_clk)
);
    
    //INstantiation of maxpooling
maxpooling_pipelined maxpooling_mod(
  .clk              (i_clk),  
  .feature_map_inp  (wire_data),  
  .flag_read        (i_flag),  
  .downsampled_out  (o_data)
);
  //Multiplexer for the selection of address between the testbench(while writing) and address generator(while reading)    
  assign mem_mux =  i_flag ? rd_addr : i_addr;  
  //Multiplexer for the selection of chip select between the testbench(while writing) and address generator(while reading)  
  assign cs_mux  =  i_flag ?  w_cs : i_cs; 
  //Multiplexer for the selection of read/write enable between the testbench(while writing) and address generator(while reading)   
  assign wr_en_mux  =  i_flag ? w_wr_en : i_write_en;   
    
    
endmodule
