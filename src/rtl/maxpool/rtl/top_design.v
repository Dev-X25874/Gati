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
    top_design  #(.N_SA(N_SA),
    .DATA_IN(DATA_IN),
    .IMG_WIDTH(IMG_WIDTH)) t1 ( 
      .clk(clk),
      .data_in(data_in[(DATA_IN*(N_SA -i)) -1 -:DATA_IN]),
      .rst(rst),  
      .enable(maxpool_enable),
      .datavalid(datavalid[i]),
      .IW(IW),
      .maxvalue_o(maxvalue_o[(DATA_IN*(N_SA-i)) -1 -:DATA_IN]),
      .datavalid_o(datavalid_o[i])
      );
	end
endgenerate 
endmodule



module top_design #(.DATA_IN(DATA_IN), .IMG_WIDTH(IMG_WIDTH), .N_SA(N_SA)) (
    input clk,
    input [DATA_IN -1 : 0] data_in,
    input rst,
    input enable,
    input datavalid,
    input [IMG_WIDTH - 1 : 0] IW, //it depends on the input dimension of the image width
    output [DATA_IN - 1 : 0] maxvalue_o,
    output datavalid_o
);
wire re;    
wire [DATA_IN : 0] demux1_o1;
wire [DATA_IN : 0] demux1_o2;
wire [DATA_IN : 0] maxpool_o;
wire [DATA_IN : 0] demux2_o1;
wire [DATA_IN : 0] demux2_o2;
wire ne;
wire [DATA_IN - 1 : 0] fifo1_out;
wire [DATA_IN - 1 : 0] fifo2_out;
wire selectline1;
wire selectline2;
wire data_valid1;
wire data_valid2;
wire [DATA_IN : 0] maxvalue;
wire empty1;
wire empty2;

counter1 #(.IMG_WIDTH(IMG_WIDTH)) c1(
  .clk(clk),
  .rst(rst),
  .datavalid(datavalid),
  .sel(selectline1),
  .dynamic_threshold(IW)
);

demux1 #(.DATA_IN(DATA_IN)) dut0(
  .clk(clk),
  .din(data_in),
  .sel(selectline1),
  .datavalid(datavalid),
  .a(),
  .b(demux1_o2),
  .c(demux1_o1)
);

maxpool #(.DATA_IN(DATA_IN)) dut1(
  .clk(clk),
  .datavalid(demux1_o2[DATA_IN]), 
  .dina(demux1_o1[DATA_IN - 1 : 0]),
  .dinb(demux1_o2[DATA_IN - 1 : 0]),
  .temp(maxpool_o)
);

counter2 #(.IMG_WIDTH(IMG_WIDTH)) c2(
  .clk(clk),
  .rst(rst),
  .datavalid(maxpool_o[DATA_IN]),
  .sel(selectline2),
  .dynamic_threshold(IW)
);

demux2 #(.DATA_IN(DATA_IN)) dut2(
  .data_in(maxpool_o[DATA_IN - 1 : 0]),
  .clk(clk),
  .rst(rst),
  .datavalid(maxpool_o[DATA_IN]),
  .sel(selectline2),
  .fifo1(demux2_o1),
  .fifo2(demux2_o2)
);

fifo_valid #(.DATA_WIDTH(DATA_IN), .ADDR_WIDTH(9)) dut3(
  .clk(clk),
  .rst_n(rst),
  .we(demux2_o1[DATA_IN]),
  .re(re),
  .data_in(demux2_o1[DATA_IN - 1 : 0]),
  .occupants(),
  .full(),
  .empty(empty1),
  .data_out(fifo1_out),
  .data_valid(data_valid1)
);


fifo_valid #(.DATA_WIDTH(DATA_IN), .ADDR_WIDTH(9)) dut4(
  .clk(clk),
  .rst_n(rst),
  .we(demux2_o2[DATA_IN]),
  .re(re),
  .data_in(demux2_o2[DATA_IN - 1 : 0]),
  .occupants(),
  .full(),
  .empty(empty2),
  .data_out(fifo2_out),
  .data_valid(data_valid2)
);

maxpool #(.DATA_IN(DATA_IN)) dut5(
  .clk(clk),
  .datavalid(data_valid1&data_valid2),
  .dina(fifo1_out),
  .dinb(fifo2_out),
  .temp(maxvalue)
);

assign re = ((~empty1) & (~empty2));

assign maxvalue_o =(enable==1)? maxvalue[DATA_IN - 1 : 0] : data_in ;
assign datavalid_o = (enable==1)?maxvalue[DATA_IN]:datavalid;

endmodule