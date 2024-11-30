module test_data_ctrl (
    input clk,
    input rst,
    output reg valid = 0,
    output reg [61:0] dout =0
    );

reg [1:0] state = 2'b00;
reg [61:0] mem [2:0];
reg [3:0] count_data = 0;

localparam IDLE = 2'b00;
//localparam DIVIDE_DATA = 2'b01;
localparam COUNT_DATA = 2'b10;
localparam STOP = 2'b11;


initial begin
    $readmemb("memory_file.mem", mem);
end

always @(posedge clk ) begin
    if (!rst) begin
        state <= IDLE;
        count_data <= 0;
        valid <= 0;
        dout <= 0;
    end else begin
        case (state)
            IDLE: begin
               valid <= 1'b0;
               count_data <= 0;
               state <= COUNT_DATA;
               end
            COUNT_DATA: begin
                valid <= 1'b1;
                if (count_data == 3) begin
                    count_data <= 0;
                    valid <= 0;
                    state <= STOP;
                end else begin
                    dout <= mem[count_data];
                    state <= COUNT_DATA;
                    count_data <= count_data + 1;
                end
                end
            STOP: begin
                state <= STOP;
                count_data <= 0;
                valid <= 0;
            end
        endcase
    end
end

endmodule