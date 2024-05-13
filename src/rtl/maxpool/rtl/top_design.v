module maxpool_gen #(parameter N_SA = 8,
                    parameter DATA_IN = 8,
                    parameter IMG_WIDTH = 10)
                    (
                      input clk,
                      input [N_SA*DATA_IN-1:0] data_in,
                      input rst,
                      input maxpool_enable,
                      input [N_SA -1:0]datavalid,
                      input [IMG_WIDTH-1:0] IW,
                      output [N_SA*DATA_IN-1:0] maxvalue_o,
                      output [N_SA -1:0] datavalid_o
                    );
                  
genvar i;
generate 
  for(i=0;i<N_SA;i=i+1)begin
    top_design t1 ( 
      .clk(clk),
      .data_in(data_in[(DATA_IN*(N_SA -i)) -1 -:DATA_IN]),
      .rst(rst),  
      .enable(maxpool_enable),
      .datavalid(datavalid[i]),
      .IW(IW),
      .maxvalue_o(maxvalue_o[(DATA_IN*(N_SA-i)) -1 -:DATA_IN]),
      .datavalid_o(datavalid_o[i]));
	end
endgenerate 
endmodule



module top_design(
    input clk,
    input [7:0] data_in,
    input rst,
    input enable,
    input datavalid,
    input [IMG_WIDTH-1:0] IW, //it depends on the input dimension of the image width
    output [7:0] maxvalue_o,
    output datavalid_o
);
wire re;    
wire [8:0] demux1_o1;
wire [8:0] demux1_o2;
wire [8:0] maxpool_o;
wire [8:0] demux2_o1;
wire [8:0] demux2_o2;
wire ne;
wire [7:0] fifo1_out;
wire [7:0] fifo2_out;
wire selectline1;
wire selectline2;
wire data_valid1;
wire data_valid2;
wire [8:0] maxvalue;
wire empty1;
wire empty2;

counter1 c1(
  .clk(clk),
  .rst(rst),
  .datavalid(datavalid),
  .sel(selectline1),
  .dynamic_threshold(IW)
);

demux1 dut0(
  .clk(clk),
  .din(data_in),
  .sel(selectline1),
  .datavalid(datavalid),
  .a(),
  .b(demux1_o2),
  .c(demux1_o1)
);

maxpool dut1(
  .clk(clk),
  .datavalid(demux1_o2[8]), 
  .dina(demux1_o1[7:0]),
  .dinb(demux1_o2[7:0]),
  .temp(maxpool_o)
);

counter2 c2(
  .clk(clk),
  .rst(rst),
  .datavalid(maxpool_o[8]),
  .sel(selectline2),
  .dynamic_threshold(IW)
);

demux2 dut2(
  .data_in(maxpool_o[7:0]),
  .clk(clk),
  .rst(rst),
  .datavalid(maxpool_o[8]),
  .sel(selectline2),
  .fifo1(demux2_o1),
  .fifo2(demux2_o2)
);

fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) dut3(
  .clk(clk),
  .rst_n(rst),
  .we(demux2_o1[8]),
  .re(re),
  .data_in(demux2_o1[7:0]),
  .occupants(),
  .full(),
  .empty(empty1),
  .data_out(fifo1_out),
  .data_valid(data_valid1)
);


fifo_valid #(.DATA_WIDTH(8), .ADDR_WIDTH(9)) dut4(
  .clk(clk),
  .rst_n(rst),
  .we(demux2_o2[8]),
  .re(re),
  .data_in(demux2_o2[7:0]),
  .occupants(),
  .full(),
  .empty(empty2),
  .data_out(fifo2_out),
  .data_valid(data_valid2)
);

maxpool dut5(
  .clk(clk),
  .datavalid(data_valid1&data_valid2),
  .dina(fifo1_out),
  .dinb(fifo2_out),
  .temp(maxvalue)
);

assign re = ((~empty1) & (~empty2));

assign maxvalue_o =(enable==1)? maxvalue[7:0] : data_in ;
assign datavalid_o = (enable==1)?maxvalue[8]:datavalid;

endmodule