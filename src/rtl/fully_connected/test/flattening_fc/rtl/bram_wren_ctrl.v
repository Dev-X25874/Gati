/*
    Controls write enable signal of bram array
*/
module bram_wren_ctrl#(
    parameter N_BRAM = 8,
    parameter W_DATA = 8,
    parameter W_ADDR = 9,
    parameter N_BANK = 4,
    parameter W_KERNAL_CNT = 10,
    parameter W_IMG_BRAM_ADDR = 10
)(
    input clk,
    input rst,
    input start,
    input data_valid,
    input [W_KERNAL_CNT-1 : 0] i_kernal_counter,    //input from instruction
    input [W_KERNAL_CNT-1 : 0] kernal_counter,      //input from read enable controller
    input [W_IMG_BRAM_ADDR-1 : 0] i_addr_counter,
    input [((N_BANK * N_BRAM) * W_DATA)-1 : 0] i_data,
    output write_done,
    output [(N_BANK * N_BRAM)-1 : 0] write_enable,
    output [((N_BANK * N_BRAM) * W_DATA)-1 : 0] o_data,
    output [(N_BANK * (W_ADDR + 1))-1 : 0] o_waddr
);

reg [6:0] counter = 0;
reg [1:0] state = 0;
reg w_done = 0;
reg [(N_BANK * N_BRAM)-1 : 0] wren = 0;
reg [((N_BANK * N_BRAM) * W_DATA)-1 : 0] data = 0;
reg [W_ADDR : 0] waddr = 0;
assign write_done = w_done;
assign write_enable = wren;
assign o_data = data;
assign o_waddr = {N_BANK{waddr}};

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
        case (state)    //Note: Include start trigger while integrating this block
            0:begin
                if(data_valid)begin
                    data <= i_data;
                    counter <= counter + 1;
                    wren <= {(N_BANK * N_BRAM){1'b1}};
                    w_done <= 1'b0;
                    state <= 1;
                end
            end

            1: begin
                if(data_valid)begin
                    if(counter == i_addr_counter)begin
                         counter <= 0;
                         waddr <= 0;
                         wren <= {(N_BANK * N_BRAM){1'b0}};
                         w_done <= 1'b1;
                         data <= 0;
                         state <= 2;
                    end else begin
                         data <= i_data;
                         counter <= counter + 1;
                         wren <= {(N_BANK * N_BRAM){1'b1}};
                         waddr <= waddr + 1;
                         w_done <= 1'b0;
                    end
                end else begin
                    counter <= counter;
                    waddr <= waddr;
                    w_done <= 1'b0;
                    wren <= 0;
                    data <= data;
                end
            end

            2: begin
                if(kernal_counter == i_kernal_counter)  //32 weight are loaded at once into FC, so 4096/32 = 128
                    state <= 0;
            end
        endcase
    end
end

endmodule