module controller_request_receiver #(parameter BURST_LENGTH = 10, parameter OCCUPANCY = 40, parameter AXI_DATA_BYTES = 32) (
    input valid_in, //[$clog2(AXI_DATA_BYTES) : 0] burst_length,
    input clk,
    output reg valid_out = 0
  );

  reg r_burst_length = 0;
  reg [1:0] state = 0;

  always @(posedge clk)
  begin
    //case(state)
    // 0: begin
    //     valid <= 0;
    //     r_burst_length <= burst_length[0];
    //     state <= 1;
    // end
    //1: begin
    if(valid_in) //(burst_length[1] == 1)
    begin
      valid_out <= 1;
      state <= 0;
    end
    else
    begin
      valid_out <= 0;
      state <= 1;
    end
    //end
    //endcase
  end

endmodule
