module Test_data_ctrl_1 (
    input clk,
    input rst,
    output  [7:0] addr,
    output reg last = 0,
    output reg [3:0] blen_in = 0,
    output reg valid = 0,
    output reg r_w_en = 0
);

reg [1:0] state = 2'b00;
reg [36:0] mem [4:0];
reg [2:0] count_addr = 0;
reg [2:0] count_data = 0;
reg [31:0] r_addr = 0;
reg [7:0] temp_r_addr_1 = 0;

localparam IDLE = 2'b00;
localparam DIVIDE_DATA = 2'b01;
localparam COUNT_DATA = 2'b10;
localparam STOP = 2'b11;

assign addr = temp_r_addr_1 ;

initial begin
    $readmemb("Data_test_1.mem", mem);
end

always @(posedge clk ) begin
    if (!rst) begin
        state <= IDLE;
        count_data <= 0;
        count_addr <= 0;
        valid <= 0;
        last <= 0;
    end else begin
        case (state)
            IDLE: begin
                state <= DIVIDE_DATA;
            end
            DIVIDE_DATA: begin
                valid <= 1'b1 ;
                last <= 0;
                blen_in <= mem[count_data][35:32];
                r_w_en <= mem[count_data][36];
                r_addr = mem[count_data][31:0];
                if (count_addr < 4) begin 
                    state <= DIVIDE_DATA ;
                    temp_r_addr_1 <= r_addr [8*(4-count_addr)-1 -: 8];
                    count_addr <= count_addr + 1 ;
                end 
                
                else begin 
                    state <= COUNT_DATA ;
                    valid <= 0 ;
                    last <= 1'b1 ;
                    count_addr <= 0 ;
                end 
            end
            COUNT_DATA: begin
                if (count_data < 5) begin
                    count_data <= count_data + 1;
                    state <= IDLE;
                    last <= 0;
                end else begin
                    count_data <= 0;
                    state <= STOP;
                end
            end
            STOP: begin
                state <= STOP;
                count_data <= 0;
                count_addr <= 0;
                valid <= 0;
                last <= 0;
            end
        endcase
    end
end

endmodule
