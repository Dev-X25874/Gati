module controller_data_out #( parameter N = 3,
                              parameter DATA_WIDTH = 32)(
    input           clk,
    input [(N*DATA_WIDTH)-1:0]    data_in,
    input [N-1:0]         i_valid,
    output [7:0]   data_out,
    output          o_valid,
    input           trans_done
);

    reg [3:0]        r_counter = 4*N;
    reg            r_o_valid;
    reg [2:0]      p_state;
    reg [7:0]       r_data_out;
    assign o_valid = r_o_valid;
    assign data_out = r_data_out;
    
always @(posedge clk) begin
    case (p_state) 
    0 : begin
        if (i_valid) begin
            p_state <= 1;
        end else begin
            p_state <= 0;
        end
            r_o_valid <= 1'b0;
    end
    1 : begin
            r_o_valid <= 1'b1;
            p_state <= 2;
            r_data_out <= data_in[(r_counter*8)-1 -: 8];
        end
  
    2 : begin  
        if (trans_done == 1) begin
            if (r_counter > 1) begin
                r_counter <= r_counter - 1;
                p_state <= 1;
            end else if (r_counter == 1)begin
                r_counter <= N*4;
                p_state <= 0;
            end
            end else begin
                r_o_valid <= 1'b0;
            end
        end
    endcase
end


endmodule



