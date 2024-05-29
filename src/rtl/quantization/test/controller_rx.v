module controller_rx #( parameter N = 2,
                            parameter DATA_WIDTH = 18,
                            parameter SHIFT_WIDTH = 18,
                            parameter UART_WIDTH = 8)(
    input                               clk,
    input [UART_WIDTH-1:0]              data_in,
    input                               i_valid,
    output [(N*DATA_WIDTH)-1:0]         o_data,
    output [(N*DATA_WIDTH)-1:0]         o_data_bias,
    output [(N*DATA_WIDTH)-1:0]         o_data_scale,
    output [N-1:0]                      o_valid,
    output [(N*SHIFT_WIDTH-1):0]        o_bit_shift

);

    reg [$clog2(N*DATA_WIDTH):0]    r_counter = N*12;
    reg [N-1:0]                     r_o_valid;
    reg [(N*12*UART_WIDTH)-1:0]     r_data_out;       //24 because we can't receive 18 bits from uart so 3 bytes 
    reg [2:0]                       p_state;
    
    assign o_valid = r_o_valid;
    // assign data_out_a = { r_data_out[89:72],r_data_out[41:24]};
    // assign data_out_b = { r_data_out[65:48],r_data_out[17:0]};
//    assign data_out_a = { r_data_out[95:72],r_data_out[47:24]};
//    assign data_out_b = { r_data_out[71:48],r_data_out[24:0]};
/*
genvar i;
generate
    for (i = 0; i < N*2; i = i + 1) begin
        if ((i % 2) == 1) begin
            assign data_out_a[((i-1)/2)*DATA_WIDTH +: 18] = r_data_out[i*24 +: 18];
        end else begin
            assign data_out_b[(i/2)*DATA_WIDTH +: 18] = r_data_out[i*24 +: 18];
        end
    end
endgenerate
*/
    localparam O_DATA_BITS = UART_WIDTH*3;
genvar i;
generate
    for (i = 0; i < N*4; i = i + 1) begin
        if ((i % 4) == 0) begin
            assign o_data[(i/4)*DATA_WIDTH +: DATA_WIDTH] = r_data_out[i*O_DATA_BITS +: DATA_WIDTH];
        end else if ((i % 4) == 1) begin 
            assign o_data_bias[((i-1)/4)*DATA_WIDTH +: DATA_WIDTH] = r_data_out[i*O_DATA_BITS +: DATA_WIDTH]; 
        end else if ((i % 4) == 2) begin
            assign o_data_scale[((i-2)/4)*DATA_WIDTH +: DATA_WIDTH] = r_data_out[i*O_DATA_BITS +: DATA_WIDTH]; 
        end else if ((i % 4) == 3) begin
            assign o_bit_shift[((i-3)/4)*SHIFT_WIDTH +: SHIFT_WIDTH] = r_data_out[i*O_DATA_BITS +: SHIFT_WIDTH];
        end
    end
endgenerate


always @(posedge clk) begin
    case (p_state) 
    0 : begin
        if (i_valid) begin
            p_state <= 1;
            r_data_out[(r_counter*8)-1 -: 8] <= data_in;
            r_o_valid <= {N{1'b0}};
        end else begin
            p_state <= 0;
        end
    end
    1 : begin   
        if (r_counter > 1) begin
            r_counter <= r_counter - 1;
            p_state <= 0;
        end else if (r_counter == 1)begin
            r_data_out[(r_counter*8)-1 -: 8] <= data_in;
            r_counter <= N*12;
            p_state <= 2;
            r_o_valid <= {N{1'b1}};
        end
    end
    2 : begin
        r_o_valid <= {N{1'b0}};
        p_state <= 0;
        end
    endcase
end
   
    
endmodule