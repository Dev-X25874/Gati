`timescale 1ns / 1ps
module sync_fifo_valid_tb ();

reg clk = 0;
reg rstn = 0;
reg rd_en = 0;
reg wr_en = 0;
reg [7:0] tempdata = 0;
reg [7:0] buf_in = 0;

wire buf_full;
wire dv;
wire buf_empty;
wire [7:0] buf_out;
wire [7:0] fifo_counter;

    fifo_valid 
    dut(.clk(clk),
        .rst_n (rstn),
        .data_in(buf_in),
        .we(wr_en),
        .re(rd_en),
        .data_out(buf_out),
        .occupants(fifo_counter),
        .empty(buf_empty),
        .full(buf_full),
        .data_valid(dv)
        );
         
always #5 clk <= ~clk;

initial begin
    #9 clk<= 1;
    #10  buf_in <= 8'd10;
    #10 wr_en <= 1'b1;
    #10 rd_en <= 1'b1;
    #10  buf_in <= 8'd20;
    #10  buf_in <= 8'd30;
    #10  buf_in <= 8'd40;
    #10  buf_in <= 8'd50;
    #10  buf_in <= 8'd60;
    #10  buf_in <= 8'd70;
    #10  buf_in <= 8'd80;
    
end
endmodule
