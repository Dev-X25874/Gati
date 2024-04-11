module controller_concate(
    input [7:0] din,
    input rx_valid,
    input clk,
    output [31:0] start_addr,
    output [31:0] stop_addr,
    output [11:0] kernelitr,
    output config_start
);

always @(posedge clk) begin
    case(state)
    0: begin
        config_start <= 0;
        start_addr <= 0;
        stop_addr <= 0;
        kernelitr <= 0
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
                state <= 2;
            end
            else begin
                start_addr[32-(count_start_addr*8)-1 -:8] <= din;
                count_start_addr <= 0;
                state <= 3;
            end
        end
        else begin
            start_addr <= start_addr;
            count_start_addr <= count_start_addr;
            state <= 2;
        end
    end
    3: begin
        if(rx_valid) begin
            if(count_krnl_itr < 3) begin
                kernelitr[32-(count_krnl_itr*8)-1 -:8] <= din;
                count_krnl_itr <= count_krnl_itr + 1;
                state <= 3;
            end
            else begin
                kernelitr[32-(count_stp_addr*8)-1 -:8] <= din;
                count_stp_addr <= 0;
                state <= 4;
            end
        end
        else begin
            kernelitr <= kernelitr;
            count_krnl_itr <= count_krnl_itr;
            state <= 3;
        end
    end
    4: begin
        if(rx_valid) begin
            if(count_stp_addr < 3) begin
                stop_addr[32-(count_start_addr*8)-1 -:8] <= din;
                count_stp_addr <= count_stp_addr + 1;
                state <= 4;
            end
            else begin
                stop_addr[32-(count_stp_addr*8)-1 -:8] <= din;
                count_stp_addr <= 0;
                state <= 5;
            end
        end
        else begin
            stop_addr <= stop_addr;
            count_stp_addr <= count_stp_addr;
            state <= 4;
        end
    end
    endcase
end

endmodule