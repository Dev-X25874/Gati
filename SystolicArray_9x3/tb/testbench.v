`timescale 1ns / 1ps
module testbench();
    
    parameter ROW = 9;
    parameter COL = 3;
    parameter TOTAL_BYTES = ROW * COL;
    parameter W_DATA = 8;
    parameter W_ADDR = 9;
    parameter RAM_DEPTH = 1 << W_ADDR;
    
    reg clk = 0;
    reg sel1 = 0; 
    reg sel2 = 0; 
    reg [7:0] data_in = 0; 

    wire [(COL * W_DATA)-1 : 0] o_north_data;
    wire [(ROW * W_DATA) -1 : 0] o_east_data;
    
    reg [ROW-1:0] west_rden = 0;
    wire [ROW-1:0] west_empty;
    wire [ROW-1:0] west_full;
    reg trigger1 = 0;
    reg trigger2 = 0;
    wire out_sel;
    wire [7:0] out_data;
    wire [7:0] out_w_ps;
    
    reg [COL-1:0] north_rden = 0;
    wire [COL-1:0] north_empty;
    wire [COL-1:0] north_full;
    
    top_module_design#(
        .ROW(ROW),
        .COL(COL),
        .W_DATA(W_DATA),
        .W_ADDR(W_ADDR),
        .RAM_DEPTH(RAM_DEPTH),
        .TOTAL_BYTES(TOTAL_BYTES)
    )dut(
        .i_clk(clk),
        .i_sel_1(sel1),
        .i_sel_2(sel2),
        .i_trigger_1(trigger1),
        .i_trigger_2(trigger2),
        .data_in(data_in),
        .col_data_out(out_w_ps),
        .row_data_out(out_data),
        .sel_out(out_sel)
    );
    always #5 clk <= ~clk;
    
    initial begin 
        clk <= 1;
        
        #100 sel1 <= 1;
        sel2 <= 0;
        
        #10 data_in <= 8'd4;
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd3;
        
        
        #10 data_in <= 8'd5;  
        #10 data_in <= 8'd3;
        #10 data_in <= 8'd9; 
        
        #10 data_in <= 8'd0;
        #10 data_in <= 8'd5;
        #10 data_in <= 8'd2;
        
        #10 data_in <= 8'd3;
        #10 data_in <= 8'd9;
        #10 data_in <= 8'd7;
        
        #10 data_in <= 8'd9;
        #10 data_in <= 8'd9;
        #10 data_in <= 8'd0;
        
        #10 data_in <= 8'd2;
        #10 data_in <= 8'd2;
        #10 data_in <= 8'd1;
        
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd5;
        #10 data_in <= 8'd9;
        
        #10 data_in <= 8'd9;
        #10 data_in <= 8'd3;
        #10 data_in <= 8'd0;
        
        #10 data_in <= 8'd3;
        #10 data_in <= 8'd4;
        #10 data_in <= 8'd2; 
        
        #10 data_in <= 8'd0;
        #10 data_in <= 8'd0;
        #10 data_in <= 8'd0;
        
        
        #10 sel1<= 0; 
        #50 trigger1 <= 1'b1;
        #30 trigger1 <= 1'b0;
        
        #70  data_in <= 8'd0;
        sel2 <= 1'b1;
   
        #10 data_in <= 8'd9;
        #10 data_in <= 8'd4;
        #10 data_in <= 8'd5;
        #10 data_in <= 8'd3;  
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd0;
        
        #10 data_in <= 8'd2;
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd9;
        #10 data_in <= 8'd1;  
        #10 data_in <= 8'd4;
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd8;
        #10 data_in <= 8'd3;
        #10 data_in <= 8'd3;
        
        #10 data_in <= 8'd8;
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd0;
        #10 data_in <= 8'd5;  
        #10 data_in <= 8'd5;
        #10 data_in <= 8'd0;
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd1;
        #10 data_in <= 8'd2;
        
        #10 data_in <= 8'd9;
        #10 data_in <= 8'd4;
        #10 data_in <= 8'd5;
        #10 data_in <= 8'd3;  
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd0;
        
        #10 data_in <= 8'd2;
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd9;
        #10 data_in <= 8'd1;  
        #10 data_in <= 8'd4;
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd8;
        #10 data_in <= 8'd3;
        #10 data_in <= 8'd3;
        
        #10 data_in <= 8'd8;
        #10 data_in <= 8'd7;
        #10 data_in <= 8'd0;
        #10 data_in <= 8'd5;  
        #10 data_in <= 8'd5;
        #10 data_in <= 8'd0;
        #10 data_in <= 8'd6;
        #10 data_in <= 8'd1;
        #10 data_in <= 8'd2;
        
        #10 data_in <= 8'd90;
        #10 data_in <= 8'd40;
        #10 data_in <= 8'd50;
        #10 data_in <= 8'd30;  
        #10 data_in <= 8'd60;
        #10 data_in <= 8'd60;
        #10 data_in <= 8'd70;
        #10 data_in <= 8'd70;
        #10 data_in <= 8'd00;
        
        #10 data_in <= 8'd20;
        #10 data_in <= 8'd70;
        #10 data_in <= 8'd90;
        #10 data_in <= 8'd10;  
        #10 data_in <= 8'd40;
        #10 data_in <= 8'd60;
        #10 data_in <= 8'd80;
        #10 data_in <= 8'd30;
        #10 data_in <= 8'd30;
        
        #10 data_in <= 8'd80;
        #10 data_in <= 8'd70;
        #10 data_in <= 8'd00;
        #10 data_in <= 8'd50;  
        #10 data_in <= 8'd50;
        #10 data_in <= 8'd00;
        #10 data_in <= 8'd60;
        #10 data_in <= 8'd10;
        #10 data_in <= 8'd20;                
        
        #10 sel2 <= 1'b0;
        
        #10 trigger2 <= 1'b1;

        end   
    
    
endmodule

