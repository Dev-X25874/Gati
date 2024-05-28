module Mem_read_ctrl #(
    parameter AXI_DATA_WIDTH = 256,
    parameter N_FIFO = 32
) (
    input clk,
    input rst,
    input select, //from DRAM ctrler (RD_ID mger)

    input i_data_valid,
    input i_data_last,
    input [AXI_DATA_WIDTH -1 : 0] i_dram_data,

    output reg [AXI_DATA_WIDTH -1 : 0] o_dram_data,
    output reg [N_FIFO - 1 : 0] o_dram_fifo_wren,
    output reg o_data_last
);
    always@(posedge clk) begin
        if(!rst) begin
            o_dram_data <= 0;
            o_dram_fifo_wren <= 0;
        end
        else begin
            if(select==1) begin
                if(i_data_valid) begin
                    o_dram_fifo_wren <= {N_FIFO{1'b1}};
                    o_dram_data      <= i_dram_data;
                end
                else begin
                    o_dram_fifo_wren <= {N_FIFO{1'b0}};
                    o_dram_data      <= o_dram_data;
                end
            end
            else begin
                o_dram_fifo_wren <= {N_FIFO{1'b0}};
                o_dram_data      <= o_dram_data;
            end
        end
    end

    always@(posedge clk) o_data_last <= i_data_last;
endmodule