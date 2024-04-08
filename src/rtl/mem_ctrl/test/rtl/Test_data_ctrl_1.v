module Test_data_ctrl_1 (
    input clk,
    input rst,
    output  [7:0] addr_in_1,
    output reg last_1 = 0,
    output reg [3:0] blen_in_1 = 0,
    output reg valid_1 = 0,
    output reg r_w_en_1 = 0
);

reg [1:0] state = 2'b00;
reg [36:0] mem [5:0];
reg [2:0] count_addr = 0;
reg [2:0] count_data = 0;
reg [31:0] addr_1;
reg [7:0] temp_r_addr_2 = 0;

localparam IDLE = 2'b00;
localparam DIVIDE_DATA = 2'b01;
localparam COUNT_DATA = 2'b10;
localparam STOP = 2'b11;

assign addr_in_1 = temp_r_addr_2;

initial begin
    $readmemh("Data.mem", mem);
end

always @(posedge clk ) begin
    if (!rst) begin
        state <= IDLE;
        count_data <= 0;
        count_addr <= 0;
        valid_1 <= 0;
        last_1 <= 0;
    end else begin
        case (state)
            IDLE: begin
                
                state <= DIVIDE_DATA;
            end
            DIVIDE_DATA: begin
                last_1 <= 0;
                valid_1 <= 1'b1;
                blen_in_1 <= mem[count_data][35:32];
                r_w_en_1 <= mem[count_data][36:35];
                addr_1 <= mem[count_data][31:0];
                if (count_addr < 4) begin
                    temp_r_addr_2 <= addr_1[8*(4-count_addr)-1 -: 8];
                    count_addr <= count_addr + 1;
                end else begin
                    state <= COUNT_DATA;
                    valid_1 <= 0;
                    last_1 <= 1;
                    count_addr <= 0;
                end
            end
            COUNT_DATA: begin
                if (count_data < 5) begin
                    count_data <= count_data + 1;
                    state <= IDLE;
                    last_1 <= 0;
                end else begin
                    state <= STOP;
                end
            end
            STOP: begin
                state <= STOP;
                count_data <= 0;
                count_addr <= 0;
                valid_1 <= 0;
                last_1 <= 0;
            end
        endcase
    end
end

endmodule