module dispatch_flag_check #(
    parameter ADDR_W = 32,
    parameter DATA_SIZE = 20,
    parameter ID = 10)
    (
        input  clk,
        input  rst,
        input  [ADDR_W-1:0] i_addr,
        input  [DATA_SIZE-1:0] i_data_size,
        input  [ID-1:0] i_id,
        input  dispatch_cpu,//comes from instruction
        input  layer_done, //comes from config block
        input  i_start,     
        /*output [ADDR_W-1:0] o_addr,
        output [DATA_SIZE-1:0] o_data_size,
        output [ID-1:0] o_id*/
        output [(ADDR_W+DATA_SIZE+ID)-1:0] o_combined,
        output reg r_valid
    );

    /*reg [ADDR_W-1:0] r_addr = 0;
    reg [DATA_SIZE-1:0] r_data_size = 0;
    reg [ID-1:0] r_id = 0;*/
    reg [(ADDR_W+DATA_SIZE+ID)-1:0] r_combined;
    reg [1:0] state = 0;

    /*assign o_addr = r_addr;
    assign o_data_size = r_data_size;
    assign o_id = r_id;*/
    assign o_combined = r_combined;

    always @ (posedge clk) begin
        if(!rst) begin
           /* r_addr <= 0;
            r_data_size <= 0;
            r_id <= 0;*/
            r_valid <= 0;
            r_combined <= 0;
            state <= 0;
        end
        
        else begin
            case(state)
            0:begin
                if(i_start) begin
                    state <= 1;
                    r_valid <= 0;
                end
                else begin
                    state <= 0;
                    r_valid <= 0;
                end
            end

            1:begin
                if(dispatch_cpu) begin
                    state <= 2;
                    r_valid <= 0;
                end
                else begin
                    state <= 1;
                    r_valid <= 0;
                end
            end

            2:begin
                if(layer_done) begin
                    state <= 3;
                end
                else begin
                    state <= 2;
                end
            end

            3:begin
                r_combined <= {i_addr,i_data_size,i_id};
                state <= 0;
                r_valid <= 1;
            end
            endcase
        end
    end
endmodule