/*
    Controls write enable signal of bram array
*/
module bram_wren_ctrl#(
    parameter N_FIFO = 32,
    parameter W_DATA = 8,
    parameter W_ADDR = 9
)(
    input clk,
    input rst,
    input start,
    input data_valid,
    input [14:0] image_dim,
    input [(N_FIFO * W_DATA)-1 : 0] i_data,
    output write_done,
    output [N_FIFO-1 : 0] write_enable,
    output [(N_FIFO * W_DATA)-1 : 0] o_data,
    output [(N_FIFO * (W_ADDR + 1))-1 : 0] o_addr
);

reg [6:0] counter = 0;
reg [1:0] state = 0;
reg w_done = 0;
reg [N_FIFO-1 : 0] wren = 0;
reg [(N_FIFO * W_DATA)-1 : 0] data = 0;
reg [(N_FIFO * (W_ADDR + 1))-1 : 0] addr = 0;
assign write_done = w_done;
assign write_enable = wren;
assign o_data = data;
assign o_addr = addr;

wire w_start;
one_pulse start_pulse(
    .a(start),
    .rst(rst),
    .clk(clk),
    .b(w_start)
);

always @(posedge clk) begin
    if(rst)begin
        data <= 0;
        w_done <= 0;
        wren <= 0;
    end else begin
        case (state)
            0:begin
                w_done <= 0;
                if(w_start)begin
                    state <= 1;
                end
            end

            1: begin
                if(data_valid)begin
                   if(counter == (image_dim >> 5))begin
                        state <= 0;
                        counter <= 0;
                        addr <= 0;
                        wren <= {N_FIFO{1'b0}};
                        w_done <= 1'b1;
                        data <= 0;
                   end else begin
                        data <= i_data;
                        counter <= counter + 1;
                        wren <= {N_FIFO{1'b1}};
                        addr <= addr + 1;
                   end
                end
            end
            default: state <= 0;
        endcase
    end
end

endmodule