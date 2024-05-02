module last_ff_ctrl#(
    parameter W_ACC = 32,
    parameter COL = 32
)(
    input i_clk,
    input i_rst,
    input i_data_valid,
    input [(W_ACC * COL)-1 : 0] i_data,
    output [W_ACC-1 : 0] o_data,
    output o_ff_wren
);

reg [W_ACC-1 : 0] data = 0;
reg wren = 0;
reg [1:0] state = 0;
reg [$clog2(COL) : 0] cnt = 0;

assign o_data = data;
assign o_ff_wren = wren;

always @(posedge i_clk) begin
    if(i_rst)begin
        wren <= 0;
        data <= 0;
        state <= 0;
        cnt <= 0;
    end else begin
        case (state)
            0:begin
                if(i_data_valid)begin
                    state <= 1;
                end
            end 

            1: begin
                if(cnt == COL)begin
                    state <= 0;
                    wren <= 0;
                    cnt <= 0;
                    data <= 0;
                end else begin
                    data <= i_data[(((COL - cnt) * W_ACC)-1) -: W_ACC];
                    wren <= 1;
                    cnt <= cnt + 1;
                end
            end
            default: state <= 0;
        endcase
    end
end
    
endmodule