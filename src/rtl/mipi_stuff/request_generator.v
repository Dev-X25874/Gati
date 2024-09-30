module request_generator #(
    parameter ADDR_W = 32,
    parameter DATA_SIZE = 20,
    parameter ID = 10)
    (
        input  clk,
        input  rst,
        input  [(ADDR_W+DATA_SIZE+ID)-1:0] i_combined,
        input  req_ready, // comes from memory request controller
        input  mipi_ready, //comes from mipi formatter
        input  empty,
        input  fifo_valid,
        output o_rd_en,
        output [ADDR_W-1:0] o_addr,
        output [DATA_SIZE-1:0] o_data_size, //goes to mipi formatter
        output [ID-1:0] o_id, //goes to mipi formatter
        output o_valid_req // goes to both request controller and mipi formatter
    );

    reg [ADDR_W-1:0] r_addr = 0;
    reg [DATA_SIZE-1:0] r_data_size = 0;
    reg [ID-1:0] r_id = 0;
    reg r_valid_req;
    reg r_rd_en;
    reg state = 0;

    assign o_addr = r_addr;
    assign o_data_size = r_data_size;
    assign o_id = r_id;
    assign o_valid_req = r_valid_req;
    assign o_rd_en = r_rd_en;

    always @ (posedge clk) begin
        if(!rst) begin
            r_addr <= 0;
            r_data_size <= 0;
            r_id <= 0;
            r_valid_req <= 0;
            state <= 0;
        end

        else begin
            case(state)
            0: begin
                r_valid_req <= 0;
                if(!empty && mipi_ready && req_ready) begin
                    r_rd_en <= 1;
                    state <= 1;
                end
                else begin
                    state <= 0;
                    r_rd_en <= 0;
                end
            end

            1:begin
                if(fifo_valid) begin 
                    r_valid_req <= 1;
                    r_rd_en <= 0;
                    r_addr <= i_combined[(ADDR_W+DATA_SIZE+ID)-1 -:ADDR_W];
                    r_data_size <= i_combined[(DATA_SIZE+ID)-1 -:DATA_SIZE];
                    r_id <= i_combined[ID-1:0];
                    state <= 0;
                end
                else begin
                    r_rd_en <= r_rd_en;
                    state <= 1;
                end
            end
            endcase
        end
    end
endmodule



