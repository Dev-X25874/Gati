module sa_tb();

parameter COL = 3;
parameter ROW = 9;

parameter TOTAL_BYTES = COL * ROW;

reg clk = 0; 
reg enb = 0; 
reg sel = 1; 
reg [71:0] west_data_in = 0;

//data
reg [(TOTAL_BYTES * 8) - 1:0] d_matrix = {
                                            8'h09, 8'h02, 8'h08,
                                            8'h04, 8'h07, 8'h07,
                                            8'h05, 8'h09, 8'h00,
                                            8'h03, 8'h01, 8'h05,
                                            8'h06, 8'h04, 8'h05,
                                            8'h06, 8'h06, 8'h00,
                                            8'h07, 8'h08, 8'h06,
                                            8'h07, 8'h03, 8'h01,
                                            8'h0, 8'h03, 8'h02
                                            };

//weights
reg [(TOTAL_BYTES * 32) -1 : 0] w_matrix = {
                                             32'h04, 32'h06, 32'h03,            
                                             32'h05, 32'h03, 32'h09,
                                             32'h00, 32'h05, 32'h02,
                                             32'h03, 32'h09, 32'h07,
                                             32'h09, 32'h09, 32'h00,
                                             32'h02, 32'h02, 32'h01,
                                             32'h07, 32'h05, 32'h09, 
                                             32'h09, 32'h03, 32'h00,
                                             32'h03, 32'h04, 32'h02 
                                             };

reg [95:0] north_data = 0;


wire [COL-1:0] sel_out; 
wire [31:0] south_data_out; 
wire [7:0] east_data_out; 

wire [71:0] data_to_be_passed;

pe_grid #(.ROWS (ROW),
            .COLS (COL)
)   top_design (.i_clk(clk),
                .i_enable(enb),
                .i_sel(sel), 
                .i_west_data({west_data_in[(ROWS * 8) - 1 -: 8], data_to_be_passed[((ROWS - 1) * 8) - 1 -: 8]}), 
              //  .i_north_data({north_data_0, north_data_1}), 
                .i_north_data(north_data), 
                .o_sel(sel_out), 
                .o_data_32(south_data_out),
                .o_data_8(east_data_out)
            );

always #5 clk <= ~clk;

initial begin
	$dumpfile("dump.vcd");
	$dumpvars;
	clk <= 1'b1; 
	enb <= 1'b1;
	sel <= 1; 
end 

reg [3:0] state = 0;
reg [3:0] cnt = 0;
reg i_enb = 0;

genvar i, j;

generate
    for (j = 0; j < COL; j = j + 1) begin: FC
        weight_register #(.SIZE(32)) dr (
            .i_enb(i_enb),
            .clk(clk),  
            .data_out(north_data[(COL - j) * 32 - 1 -: 32]),
            .matrix(w_matrix[(TOTAL_BYTES - ((cnt - 1) * COL) + j) * 32 - 1 -: 32]) 
        );
    end
    
endgenerate

generate
    for (i = 0; i < ROW; i = i + 1) begin: FR
        for (j = 0; j < i; j = j + 1) begin: FC
            wire [7:0] data_out_reg;
//            if (i == 0 && j == 0) begin
//                data_register dr2 (
//                    .i_enb(i_enb),
//                    .clk(clk),
//                    .data_out(data_to_be_passed[(ROW - i) * 8 - 1 -: 8]), 
//                    .d_matrix(west_data_in[(ROW - i) * 8 - 1 -: 8])
//                );
            if (j == i - 1) begin
                data_register dr2 (
                    .i_enb(i_enb),
                    .clk(clk),
                    .data_out(data_to_be_passed[(ROW - i) * 8 - 1 -: 8]),
                    .d_matrix(j == 0 ? west_data_in[(ROW - i) * 8 - 1 -: 8] : FC[j-1].data_out_reg)
                );
            end else if (j == 0) begin
                data_register dr2 (
                    .i_enb(i_enb),
                    .clk(clk),
                    .data_out(data_out_reg),
                    .d_matrix(west_data_in[(ROW - i) * 8 - 1 -: 8])
                );
            end else begin
                data_register dr2 (
                    .i_enb(i_enb),
                    .clk(clk),
                    .data_out(data_out_reg),
                    .d_matrix(FC[j-1].data_out_reg)
                );
            end
        end
    end
endgenerate

generate
    for (i = 0; i < ROW; i = i + 1) begin: DR
        weight_register #(.SIZE(8)) dr (
            .i_enb(i_enb),
            .clk(clk),  
            .data_out(west_data_in[(ROW - i) * 8 - 1 -: 8]),
            .matrix(d_matrix[(TOTAL_BYTES - ((cnt - 1) * ROW) + i) * 8 - 1 -: 8]) 
        );
    end
endgenerate

always @(posedge clk) begin
    case (state)
        0: begin
            cnt <= 0;
            state <= 1;
        end
        
        1: begin
            if (cnt == ROW) begin
                cnt <= 0;
                state <= 2;
                i_enb <= 0;
            end else begin
                cnt <= cnt + 1;
                i_enb <= 1;
            end
        end
        
        default: begin
            state <= 0;
        end
    endcase
end


endmodule

module weight_register #(
    parameter SIZE = 32
)(
    input i_enb,
    input clk,
    output reg [SIZE-1:0] data_out = 0,
    input [SIZE-1:0] matrix
);

always @(posedge clk) begin
    if (i_enb) begin
        data_out <= matrix;
    end
end

endmodule

module data_register (
    input clk,
    input i_enb,
    output reg [7:0] data_out = 0,
    input [7:0] d_matrix
);

always @(posedge clk) begin
    if (i_enb)
        data_out <= d_matrix;
end

endmodule
