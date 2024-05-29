`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2023 10:24:48
// Design Name: 
// Module Name: fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 8,
    parameter RAM_DEPTH = 1 << ADDR_WIDTH)(
                   
    input                           wr_clk,
    input                           rd_clk,
    input                           we,
    input                           re,
    input [DATA_WIDTH-1:0]          data_in,
    output [DATA_WIDTH-1:0]         data_out,
    output                          full_flag,
    output                          empty_flag,
    output [ADDR_WIDTH-1:0]         occupants

  
);
    reg [DATA_WIDTH-1:0]  mem [RAM_DEPTH-1:0];
    reg [ADDR_WIDTH-1:0]        rptr = 0;  //[$clog2(DEPTH)-1:0] 
    reg [ADDR_WIDTH-1:0]        wptr = 0;
    reg [DATA_WIDTH-1:0]        r_data_out = 0; 
    integer i;

    initial begin
        for (i = 0; i < RAM_DEPTH; i = i + 1) begin
            mem[i] = 0;
        end
    end

    
    always @(posedge wr_clk) begin
        if (we & !full_flag) begin
            mem[wptr] <= data_in;
            wptr <= wptr + 1;
        end  
    end 
    always @(posedge rd_clk) begin
        if (re & !empty_flag) begin
            r_data_out <= mem[rptr];
            rptr <= rptr + 1;
        end  
    end

    assign full_flag = (rptr-1 == wptr);
    assign empty_flag = (wptr == rptr);
    assign occupants = wptr - rptr;
    assign data_out = r_data_out;   
endmodule



