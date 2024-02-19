/*               rx_controller_fifo_data Module  
- This module gives control signals for a single FIFO with 20 bits of data and 
32 FIFOs.
- It serially fills data to one FIFO after another, until all 32 FIFOs are 
filled.   
*/



module rx_controller_fifo_data #(
    parameter                           DATA_WIDTH = 20,
    parameter                           FIFO_NO = 32,
    parameter                           N = 8,
    parameter                           FIFO_DEPTH = 256
)(
    input                               i_trig_fifo,
    input                               clk,
    input [DATA_WIDTH-1:0]              i_fifo_data,
    input                               fifo_empty_flag,
    output                              rd_en,
    output [DATA_WIDTH-1:0]             o_data,
    output [FIFO_NO-1:0]                wr_en_ctrl,
    output                              flag_adder

);


    reg                                 r_rd_en;
    reg [FIFO_NO-1:0]                   r_wr_en;
    reg [FIFO_NO-1:0]                   r1_wr_en;
    reg [DATA_WIDTH-1:0]                r_o_data;
    reg [3:0]                           p_state = 0;
    reg [$clog2(FIFO_DEPTH):0]          r_counter = 0;
    reg [$clog2(FIFO_NO):0]             r_counter_fifo = 0;
    reg                                 r_flag_adder;

    // genvar i;   

    // generate
    //     for (i = 32; i >= 1; i = i - 1) begin: WR_EN_GEN
    //         wire wr_en;
    //         wire data_out;
    //         if (i == 32) begin
    //             assign wr_en = (r_counter_fifo == 32) ? {r_wr_en,31'd0} : 32'b0;
    //         end else if (i == 1) begin
    //             assign wr_en_ctrl = (r_counter_fifo == 1) 
    //                         ? {{(FIFO_NO-1){0}}, r_wr_en} : WR_EN_GEN[i+1].wr_en; 
    //         end else begin
    //             assign wr_en = (r_counter_fifo == i) 
    //                         ? {32-i'd0, r_wr_en, i-1'd0} : WR_EN_GEN[i+1].wr_en;
    //         end
    //     end
    // endgenerate


// {FIFO_NO-1{0}} = 31'd0
    // genvar i;  

    // assign o_data = (r_counter_fifo == 1) 
    //                         ? {(FIFO_DEPTH*DATA_WIDTH-DATA_WIDTH){0}} 

    // generate
    //     for (i = 32; i >= 1; i = i - 1) begin: WR_DATA_GEN
    //         wire wr_en;
    //         wire data_out;
    //         if (i == 32) begin
    //             assign wr_en = (r_counter_fifo == 32) ? {r_wr_en,31'd0} : 32'd0;
    //             assig data_out = (r_counter_fifo == 32) ? {r_o_data,620'd0} : 640'd0;
    //         end else if (i == 1) begin
    //             assign o_data = (r_counter_fifo == 1) 
    //                         ? {620'd0,r_o_data} : WR_DATA_GEN[i+1].data_out;
    //             assign wr_en_ctrl = (r_counter_fifo == 1) 
    //                         ? {{(FIFO_NO-1){0}}, r_wr_en} : WR_DATA_GEN[i+1].wr_en; 
    //         end else begin
    //             assign wr_en = (r_counter_fifo == i) 
    //                         ? {32-i'd0, r_wr_en, i-1'd0} : WR_DATA_GEN[i+1].wr_en;
    //             assign data_out = (r_counter_fifo == i)
    //                         ? {{(640-i)*DATA_WIDTH}{0},r_o_data,{(i-20)*DATA_WIDTH}{0}} : WR_DATA_GEN[i+1].data_out;
    //         end
    //     end
    // endgenerate
    
    
    assign o_data = r_o_data;

    assign flag_adder = r_flag_adder;

    assign rd_en = r_rd_en;
/*    assign wr_en_ctrl = (r_counter_fifo == 0) ? {r_wr_en, 31'd0} :
(r_counter_fifo == 1) ? {31'd0, r_wr_en} :
(r_counter_fifo == 2) ? {30'd0, r_wr_en, 1'd0} :
(r_counter_fifo == 3) ? {29'd0, r_wr_en, 2'd0} :
(r_counter_fifo == 4) ? {28'd0, r_wr_en, 3'd0} :
(r_counter_fifo == 5) ? {27'd0, r_wr_en, 4'd0} :
(r_counter_fifo == 6) ? {26'd0, r_wr_en, 5'd0} :
(r_counter_fifo == 7) ? {25'd0, r_wr_en, 6'd0} :
(r_counter_fifo == 8) ? {24'd0, r_wr_en, 7'd0} :
(r_counter_fifo == 9) ? {23'd0, r_wr_en, 8'd0} :
(r_counter_fifo == 10) ? {22'd0, r_wr_en, 9'd0} :
(r_counter_fifo == 11) ? {21'd0, r_wr_en, 10'd0} :
(r_counter_fifo == 12) ? {20'd0, r_wr_en, 11'd0} :
(r_counter_fifo == 13) ? {19'd0, r_wr_en, 12'd0} :
(r_counter_fifo == 14) ? {18'd0, r_wr_en, 13'd0} :
(r_counter_fifo == 15) ? {17'd0, r_wr_en, 14'd0} :
(r_counter_fifo == 16) ? {16'd0, r_wr_en, 15'd0} :
(r_counter_fifo == 17) ? {15'd0, r_wr_en, 16'd0} :
(r_counter_fifo == 18) ? {14'd0, r_wr_en, 17'd0} :
(r_counter_fifo == 19) ? {13'd0, r_wr_en, 18'd0} :
(r_counter_fifo == 20) ? {12'd0, r_wr_en, 19'd0} :
(r_counter_fifo == 21) ? {11'd0, r_wr_en, 20'd0} :
(r_counter_fifo == 22) ? {10'd0, r_wr_en, 21'd0} :
(r_counter_fifo == 23) ? {9'd0, r_wr_en, 22'd0} :
(r_counter_fifo == 24) ? {8'd0, r_wr_en, 23'd0} :
(r_counter_fifo == 25) ? {7'd0, r_wr_en, 24'd0} :
(r_counter_fifo == 26) ? {6'd0, r_wr_en, 25'd0} :
(r_counter_fifo == 27) ? {5'd0, r_wr_en, 26'd0} :
(r_counter_fifo == 28) ? {4'd0, r_wr_en, 27'd0} :
(r_counter_fifo == 29) ? {3'd0, r_wr_en, 28'd0} :
(r_counter_fifo == 30) ? {2'd0, r_wr_en, 29'd0} :
(r_counter_fifo == 31) ? {1'd0, r_wr_en, 30'd0} :
(r_counter_fifo == 32) ? {r_wr_en, 31'd0} :
32'd0;
*/
assign wr_en_ctrl = r1_wr_en << r_counter_fifo;

always @(posedge clk) begin
    r1_wr_en <= r_wr_en; 
end

always @(posedge clk) begin
    case(p_state)
        0 : begin
            r_flag_adder <= 0;
            if(i_trig_fifo) begin
                p_state <= 1;
            end else begin
                p_state <= 0;
            end
        end

        1 : begin
        if (!fifo_empty_flag) begin
            if (r_counter_fifo < FIFO_NO) begin
                p_state <= 1;
                if (r_counter < FIFO_DEPTH) begin
                    r_counter <= r_counter + 1;
                    r_rd_en <= 1;
                    r_o_data <= i_fifo_data;
                    r_wr_en <= 1;
                end else begin
                    r_counter <= 1;
                    r_counter_fifo <= r_counter_fifo + 1;
                end
            end else begin
                p_state <= 2;
                r_counter_fifo <= 0;
                r_rd_en <= 0;
                r_wr_en <= 0;
            end
        end else begin
            p_state <= 2;
            r_rd_en <= 0;
            r_wr_en <= 0;
            
        end
        end
        
        2 : begin
            r_flag_adder <= 1;
            p_state <= 0;
            r_rd_en <= 0;
            r_wr_en <= 0;
        end

    endcase
end 

endmodule 