module CONTROLLER_CONCATE(
    input clk,
    input [7:0] din,
    input rx_valid,
    output [19:0] dout,
    output reg valid = 0
);

reg [3:0] counter_rx = 0;
reg [3:0] count_concate = 0;
reg [23:0] r_dout = 0;
assign dout = r_dout[19:0];

always @(posedge clk) begin
    if(counter_rx < 15) begin
        if(rx_valid) begin
            if(count_concate < 2) begin
                r_dout[24-(count_concate*8)-1 -:8] <= din;
                count_concate <= count_concate + 1;
                counter_rx <= counter_rx + 1;
                valid <= 0;
            end
            else begin
                count_concate <= 0;
                r_dout[24-(count_concate*8)-1 -:8] <= din;
                valid <= 1;
            end
        end 
        else begin
            r_dout <= r_dout;
            counter_rx <= counter_rx;
            count_concate <= count_concate;
            valid <= 0;
        end
    end 
    else begin
        r_dout  <= 0;
        counter_rx <= 0;
        count_concate <= 0;
        valid <= 0;
    end  
end
endmodule
