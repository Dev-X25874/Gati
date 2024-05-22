module axi_addr_generator#(
  parameter ADDR_WIDTH=32
)(
  input clkin,
  input i_rstn,
  input [ADDR_WIDTH-1:0]i_acc_address,
  input [ADDR_WIDTH-1:0]i_op_address,
  input i_acc_address_valid,
  input i_op_address_valid,
  input [7:0]i_acc_burst_len,
  input [7:0]i_op_burst_len,
  output reg[7:0]o_address,
  output reg o_valid,
  output reg [7:0]o_burst_len,
  output reg last,
  output o_read_write_req
);
reg [3:0]state=0;
reg [31:0]internal_address;
reg [7:0]counter=0;
reg [1:0] rw_state = 0;
reg rd_wr_req = 0;

assign o_read_write_req = rd_wr_req;

always @(posedge clkin)begin
if(~i_rstn)begin
  state <= 0;
  internal_address <= 0;
  counter <= 0;
  o_address <= 0;
  o_valid <= 0;
  o_burst_len <= 0;
  last <= 0;
  // rd_wr_req <= 0;
end else begin
  case(state)
  4'd0:
    begin
    if(i_acc_address_valid)begin
      state<=1;
      internal_address<=i_acc_address;
      o_burst_len<=i_acc_burst_len;
    end
    else if(i_op_address_valid)begin
      state<=1;
      internal_address<=i_op_address;
      o_burst_len<=i_op_burst_len;
    end
    else begin
      state<=0;
    end
    o_valid <= 0;
    // rd_wr_req <= 0;
  end

  4'd1:
  begin
    o_address<=internal_address[ADDR_WIDTH-counter-1-:8];
    counter<=counter+8;
    if(counter==0)begin
      o_valid<=1'b1;
      // rd_wr_req <= 1'b1;
    end
    else if(counter == 32)begin
      o_valid <= 1'b0;
      // rd_wr_req <= 1'b0;
    end
    if(counter<ADDR_WIDTH)begin
      state<=4'd1;
    end
    else begin
      state<=4'd0;
      counter<=0;
      // rd_wr_req <= 1'b0;
    end
    if(counter==24)begin
      last<=1'b1;
      // rd_wr_req <= 1'b0;
    end
    else begin
      last<=1'b0;
    end
  end
  endcase
end
end

always @(posedge clkin)begin
  if(~i_rstn)begin
    rd_wr_req <= 0;
  end else begin
    case (rw_state)
      0:begin
        if(state == 1 && counter == 0)begin
          rd_wr_req <= 1'b1;
          rw_state <= 1;
        end
      end
      1: begin
        rd_wr_req <= 1'b0;
        rw_state <= 0;
      end
      default: rw_state <= 0;
    endcase
  end
end
endmodule