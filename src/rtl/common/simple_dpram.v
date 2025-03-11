module simple_dpram #(
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter OUT_REG = 1
)
(
    input clk,
    input we,
    input re,
    input [W_ADDR-1:0] waddr,
    input [W_ADDR-1:0] raddr,
    input [W_DATA-1:0] wdata_a,
    output [W_DATA-1:0] rdata_b
);

    reg [W_DATA-1:0] ram [2**W_ADDR-1:0];
    reg [W_DATA-1:0] reg_rdata, reg_rdata_delayed;
    
    always @(posedge clk) begin
        if (we) ram[waddr] <= wdata_a;
    end
    
    always @(posedge clk) begin
        if (re) reg_rdata <= ram[raddr];
    end

    generate 
        if(OUT_REG) begin
            always @(posedge clk) begin
                reg_rdata_delayed <= reg_rdata;
            end
            assign rdata_b = reg_rdata_delayed;
        end
        else begin
            assign rdata_b = reg_rdata;
        end
    endgenerate

endmodule