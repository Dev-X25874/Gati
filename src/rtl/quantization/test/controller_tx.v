module controller_tx #( parameter N = 2,
                              parameter OUT_DATA_WIDTH = 8,
                              parameter UART_WIDTH = 8)(
    input                           clk,
    input [(N*OUT_DATA_WIDTH)-1:0]   data_in,
    input [N-1:0]                   i_valid,
    output [UART_WIDTH-1:0]         data_out,
    output                          o_valid,
    input                           trans_done
);

    reg [3:0]       r_counter = N;
    reg             r_o_valid;
    reg [2:0]       p_state;
    reg [UART_WIDTH-1:0]       r_data_out;
    assign o_valid = r_o_valid;
    assign data_out = r_data_out;
    
//    wire [79:0]    w_data_in;
 //   assign w_data_in = {{4{1'b0}},data_in[71:36],{4{1'b0}},data_in[35:0]};
    
/*genvar i;
generate 
for ( i = 0; i < N; i = i + 1) begin
    assign w_data_in[i*40 +: 40] = {{4{1'b0}},data_in [i*2*DATA_WIDTH +: 2*DATA_WIDTH]};

end
endgenerate     
 */   
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
                r_counter <= N;
                p_state <= 0;
            end
            end else begin
                r_o_valid <= 1'b0;
            end
        end
    endcase
end

endmodule



