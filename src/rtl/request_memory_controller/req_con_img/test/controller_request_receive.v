module controller_request_receiver(
  input clk,
  input valid_in,
  output reg valid_out = 1
);

reg [1:0] state = 0;

always @(posedge clk) begin
  case(state)
  0: begin
    valid_out <= 1;
    state <= 1;
  end
  1: begin
    valid_out <= 0;
    state <= 2;
  end
  2: begin
    if(valid_in) begin
      valid_out <= 1;
      state <= 3;
    end
    else begin
      valid_out <= 0;
      state <= 2;
    end
  end
  3: begin
    valid_out <= valid_out;
    state <= 1;
  end
  endcase
end

endmodule