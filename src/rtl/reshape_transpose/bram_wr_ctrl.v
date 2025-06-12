module bram_wr_ctrl #(
    parameter AXI_DATA_BYTES = 32,
    parameter N_BRAM = 32,
    parameter W_DATA = 8,
    parameter W_ADDR = 8,
    parameter ELEMENTS = 2,
    parameter SHFT_REG_X = 2,
    parameter COL_SA = 1,
    parameter W_CITER_CNT = 10,
    parameter SA = 16)

(
    input clk,
    input rst_n,
    input valid_in,
    input  [(W_ADDR*N_BRAM) - 1:0]                 rd_addr,
    input  [(AXI_DATA_BYTES * W_DATA) - 1 : 0] data_in,
    input  [(N_BRAM - 1) : 0]                  n_bram_rden,
    input  [(W_CITER_CNT - 1) : 0]             channel_itr_count,
    output reg rd_bram_start = 0,
    output [(AXI_DATA_BYTES * W_DATA) - 1 : 0] data_out
);

wire [(AXI_DATA_BYTES * W_DATA) - 1 : 0] data_in_fifo;
wire [(N_BRAM * W_ADDR)-1 : 0]             wr_addr;
reg  [(N_BRAM - 1) : 0]                  n_bram_wren = 0;
reg  [W_ADDR - 1:0]                          r_addr = 0;
reg  [W_DATA-1:0]                            counter = 0;
assign wr_addr = {N_BRAM{r_addr}};

localparam OFFSET = COL_SA;
localparam UPPER_LOOP = SHFT_REG_X;
localparam LOWER_LOOP = SA;

genvar i,j;
generate
    for(i = 0; i < UPPER_LOOP; i = i + 1) begin
        for (j = 0; j < LOWER_LOOP; j = j + 1) begin
            localparam k = i * LOWER_LOOP + j;
            assign data_in_fifo[(((W_DATA) * ((AXI_DATA_BYTES) - k)) - 1) -: W_DATA] = data_in[(((W_DATA) * ((AXI_DATA_BYTES - i) - (j * OFFSET * SHFT_REG_X))) - 1) -: W_DATA];
        end
    end
endgenerate

always @(posedge clk) begin
    if(!rst_n) begin
        n_bram_wren <= 0;
        r_addr <= 0;
        counter <= 0;
        rd_bram_start <= 0;
    end

    else begin
        if(valid_in) begin
            n_bram_wren <= 32'b1111_1111_1111_1111_1111_1111_1111_1111;
            if(counter < (channel_itr_count - 1)) begin
                r_addr <= r_addr + 1;
                rd_bram_start <= 0;
                counter <= counter + 1;
            end
            else begin
                r_addr <= r_addr + 1;
                rd_bram_start <= 1;
                counter <= 0;
            end
        end
        else begin
            n_bram_wren <= 32'b0000_0000_0000_0000_0000_0000_0000_0000;
            r_addr <= r_addr;
            rd_bram_start <= 0;
        end
    end
end

gen_bram #(.AXI_DATA_BYTES(AXI_DATA_BYTES),
           .W_DATA(W_DATA),
           .W_ADDR(W_ADDR),
           .N_BRAM(N_BRAM))
gen_bram(
    .clk(clk),
    .we(n_bram_wren),
    .re(n_bram_rden),
    .waddr(wr_addr),
    .raddr(rd_addr),
    .data_in(data_in_fifo),
    .data_out(data_out)
);

endmodule