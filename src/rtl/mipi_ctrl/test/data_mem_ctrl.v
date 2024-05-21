module data_mem_ctrl (
    input clk,
    input rst,
    input i_trigger,
    output reg [31:0] data = 0,
    output reg valid = 0
);

reg [1:0] state = 2'b00;
reg [31:0] mem [127:0];
reg [7:0] count_data = 0;

localparam IDLE = 2'b00;
localparam DIVIDE_DATA = 2'b01;
localparam COUNT_DATA = 2'b10;
localparam STOP = 2'b11;


initial begin
    $readmemh("data.mem", mem);
end

always @(posedge clk ) begin
    if (!rst) begin
        state <= IDLE;
        count_data <= 0;
        valid <= 0;
    end else begin
        case (state)
            IDLE: begin
                if(i_trigger)begin
                    state <= DIVIDE_DATA;
                    valid <= 0;
                end
            end
            DIVIDE_DATA: begin
                data <= mem[count_data];
                valid <= 1;
                if (count_data < 128) begin
                    count_data <= count_data + 1;
                    state <= DIVIDE_DATA;
                    valid <= 1;
                end else begin
                    count_data <= 0;
                    valid <= 0;
                    state <= STOP;
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