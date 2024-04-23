module controller_concate #(parameter BURST_LENGTH = 10, parameter OCCUPANCY = 40, parameter AXI_DATA_BYTES = 32) (
    input [7:0] din,
    input rx_valid,
    input clk,
    output reg [31:0] start_addr = 0,
    output reg [31:0] stop_addr = 0,
    output [11:0] kernelitr,
    output reg config_start = 0,
    output reg valid_start_addr = 0,
    output reg valid_stop_addr = 0,
    output reg valid_kernelitr = 0
);

reg [2:0] state = 0;
reg [4:0] count_start_addr = 0;
reg [4:0] count_krnl_itr = 0;
reg [4:0] count_stp_addr = 0;
reg enable = 0;
reg [15:0] r_kernelitr = 0;
assign kernelitr = r_kernelitr[11:0];

always @(posedge clk) begin
    case(state)
    0: begin
        config_start <= 0;
        start_addr <= 0;
        stop_addr <= 0;
        valid_start_addr <= 0;
        valid_stop_addr <= 0;
        valid_kernelitr <= 0;
        state <= 1;
    end
    1: begin
        if(rx_valid)  begin
            config_start <= din[0];
            state <= 2;
        end
        else begin
            config_start <= 0;
            state <= 1;
        end
    end
    2: begin
        if(rx_valid) begin
            if(count_start_addr < 3) begin
                start_addr[32-(count_start_addr*8)-1 -:8] <= din;
                count_start_addr <= count_start_addr + 1;
                valid_start_addr <= 0;
                enable <= 0;
                state <= 2;
            end
            else begin
                start_addr[32-(count_start_addr*8)-1 -:8] <= din;
                count_start_addr <= 0;
                valid_start_addr <= 1;
                enable <= 1;
                state <= 3;
            end
        end
        else begin
            start_addr <= start_addr;
            count_start_addr <= count_start_addr;
            state <= 2;
            enable <= 0;
            valid_start_addr <= 0;
        end
    end
    3: begin
        if(rx_valid) begin
            if(count_krnl_itr < 1) begin
                r_kernelitr[16-(count_krnl_itr*8)-1 -:8] <= din;
                count_krnl_itr <= count_krnl_itr + 1;
                valid_kernelitr <= 0;
                state <= 3;
            end
            else begin
                r_kernelitr[16-(count_krnl_itr*8)-1 -:8] <= din;
                count_krnl_itr <= 0;
                valid_kernelitr <= 1;
                state <= 4;
            end
        end
        else begin
            r_kernelitr <= r_kernelitr;
            count_krnl_itr <= count_krnl_itr;
            valid_kernelitr <= 0;
            state <= 3;
        end
    end
    4: begin
        if(rx_valid) begin
            if(enable) begin
                stop_addr <= ((start_addr + (((BURST_LENGTH + 1) << $clog2(AXI_DATA_BYTES)) * 15)));
                state <= 5;
            end
            else begin
               stop_addr <= 0; 
               state <= 4;
            end
        end
        else begin
            stop_addr <= stop_addr;
            state <= 4;
        end
            /*if(count_stp_addr < 3) begin
                stop_addr[32-(count_stp_addr*8)-1 -:8] <= din;
                count_stp_addr <= count_stp_addr + 1;
                valid_stop_addr <= 0;
                state <= 4;
            end
            else begin
                stop_addr[32-(count_stp_addr*8)-1 -:8] <= din;
                count_stp_addr <= 0;
                valid_stop_addr <= 1;
                state <= 5;
            end
        end
        else begin
            stop_addr <= stop_addr;
            count_stp_addr <= count_stp_addr;
            state <= 4;
            valid_stop_addr <= 0;
        end*/
    end
    5: begin
        if(rx_valid) begin
            stop_addr <= stop_addr;
            valid_stop_addr <= 1;
            count_stp_addr <= 0;
            state <= 0;
        end
    end
    endcase
end

endmodule