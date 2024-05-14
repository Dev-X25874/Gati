//`include "sync_fifo_config.v"
module occupants_controller #(parameter N=8, DEPTH=512)(
    input clkin,
    input image_done,
    input image_done_2,
    input fifo_read,
    input [7:0]burst_length,
    input [7:0]burst_length_2,
    output [N*($clog2(DEPTH)+1)-1:0]occupants
  );
  synchronous_fifo #(.DEPTH(512),.DATA_WIDTH(32)) test1(
                     .clk(clkin),
                     .rst_n(1'b1),
                     .w_en(write_fifo),
                     .r_en(fifo_read),
                     //.burst_len(burst_length),
                     .data_in(32'd1),
                     .data_out(),
                     .full(),
                     .empty(),
                     .occupants(occupants[9:0]),
                     .ten_trigg(),
                     .not_empty()
                   );
  synchronous_fifo #(.DEPTH(512),.DATA_WIDTH(32)) test2(
                     .clk(clkin),
                     .rst_n(1'b1),
                     .w_en(write_fifo),
                     .r_en(fifo_read),
                     //.burst_len(burst_length),
                     .data_in(32'd1),
                     .data_out(),
                     .full(),
                     .empty(),
                     .occupants(occupants[19:10]),
                     .ten_trigg(),
                     .not_empty()
                   );
  synchronous_fifo #(.DEPTH(512),.DATA_WIDTH(32)) test3(
                     .clk(clkin),
                     .rst_n(1'b1),
                     .w_en(write_fifo),
                     .r_en(fifo_read),
                     //.burst_len(burst_length),
                     .data_in(32'd1),
                     .data_out(),
                     .full(),
                     .empty(),
                     .occupants(occupants[29:20]),
                     .ten_trigg(),
                     .not_empty()
                   );
  synchronous_fifo #(.DEPTH(512), .DATA_WIDTH(32)) test4(
                     .clk(clkin),
                     .rst_n(1'b1),
                     .w_en(write_fifo),
                     .r_en(fifo_read),
                     //.burst_len(burst_length),
                     .data_in(32'd1),
                     .data_out(),
                     .full(),
                     .empty(),
                     .occupants(occupants[39:30]),
                     .ten_trigg(),
                     .not_empty()
                   );
  synchronous_fifo #(.DEPTH(512),.DATA_WIDTH(32)) test5(
                     .clk(clkin),
                     .rst_n(1'b1),
                     .w_en(write_fifo),
                     .r_en(fifo_read),
                     //.burst_len(burst_length),
                     .data_in(32'd1),
                     .data_out(),
                     .full(),
                     .empty(),
                     .occupants(occupants[49:40]),
                     .ten_trigg(),
                     .not_empty()
                   );
  synchronous_fifo #(.DEPTH(512),.DATA_WIDTH(32)) test6(
                     .clk(clkin),
                     .rst_n(1'b1),
                     .w_en(write_fifo),
                     .r_en(fifo_read),
                     //.burst_len(burst_length),
                     .data_in(32'd1),
                     .data_out(),
                     .full(),
                     .empty(),
                     .occupants(occupants[59:50]),
                     .ten_trigg(),
                     .not_empty()
                   );
  synchronous_fifo #(.DEPTH(512),.DATA_WIDTH(32)) test7(
                     .clk(clkin),
                     .rst_n(1'b1),
                     .w_en(write_fifo),
                     .r_en(fifo_read),
                     //.burst_len(burst_length),
                     .data_in(32'd1),
                     .data_out(),
                     .full(),
                     .empty(),
                     .occupants(occupants[69:60]),
                     .ten_trigg(),
                     .not_empty()
                   );
  synchronous_fifo #(.DEPTH(512),.DATA_WIDTH(32)) test8(
                     .clk(clkin),
                     .rst_n(1'b1),
                     .w_en(write_fifo),
                     .r_en(fifo_read),
                     //.burst_len(burst_length),
                     .data_in(32'd1),
                     .data_out(),
                     .full(),
                     .empty(),
                     .occupants(occupants[79:70]),
                     .ten_trigg(),
                     .not_empty()
                   );
  reg [3:0]state=0;
  //reg [19:0]counter=5632;
  reg write_fifo;
  always @(posedge clkin)
  begin
    case(state)
      4'd0:
      begin
        if(~image_done||(~image_done_2))
        begin
          write_fifo<=1;
          state<=0;
        end
        else if(image_done)
        begin
          write_fifo<=0;
          state<=2;
        end
        else if(image_done_2)begin
          write_fifo<=0;
          state<=3;
        end
        if(occupants[79:70]>511)begin
          state<=1;
        end
      end
      4'd1:begin
        if(occupants[79:70]<500)begin
          state<=0;
        end
      end
      4'd2:begin
        if(occupants[79:70]<=(burst_length+1))begin
          state<=0;
        end
      end
      4'd3:begin
        if(occupants[79:70]<=(burst_length_2+1))begin
          state<=0;
        end
      end
    endcase
  end
endmodule
