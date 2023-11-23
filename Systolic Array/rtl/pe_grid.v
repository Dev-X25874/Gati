/*
    Array of NxM processing elememts in systolic array
*/
module pe_grid #(
    parameter ROWS = 9,
    parameter COLS = 3
)(
    input i_clk,
    input i_sel, 
    input [(ROWS * 9) - 1:0] i_west_data, 
     input [(COLS * 32) - 1:0] i_north_data, 
    output [(COLS -1) : 0] o_sel, 
    output [(COLS * 32) - 1:0] o_data_32,
    output [(ROWS * 9) - 1:0] o_data_8
);
    
   genvar i, j; 
    generate 
        for (i = 0; i < ROWS ; i = i + 1) begin: PE_EL_ROWS
            for (j = 0; j < COLS ; j = j + 1) begin: PE_EL_COLS
        
            wire [32:0] out_data_32;
            wire [8:0] out_data_8 ;
            wire sel;
            
                if (i == 0 && j == 0) begin
                    pe pe_block(.i_clk(i_clk),
                                .i_sel(i_sel),
                                .i_west(i_west_data[((ROWS - i) * 9) - 1 -: 9]),
                                .w_p_sum(i_north_data[((COLS - j) * 32) - 1 -: 32]),
                                .o_sel(sel),
                                .o_data(out_data_32),
                                .data8(out_data_8)
                            );     
                end else if(i == ROWS - 1 && j == 0) begin
                     pe pe_block(.i_clk(i_clk),
                                .i_sel(PE_EL_ROWS[i-1].PE_EL_COLS[j].sel),
                                .i_west(i_west_data[((ROWS - i) * 9) - 1 -: 9]),
                                .w_p_sum(PE_EL_ROWS[i-1].PE_EL_COLS[j].out_data_32),
                                .o_sel(o_sel[j]),
                                .o_data(o_data_32[(COLS - j) * 32 - 1 -: 32]),
                                .data8(out_data_8)
                            );
                end else if (j == 0) begin
                    pe pe_block(.i_clk(i_clk),
                                .i_sel(PE_EL_ROWS[i-1].PE_EL_COLS[j].sel),
                                .i_west(i_west_data[((ROWS - i) * 9) - 1 -: 9]),
                                .w_p_sum(PE_EL_ROWS[i-1].PE_EL_COLS[j].out_data_32),
                                .o_sel(sel),
                                .o_data(out_data_32),
                                .data8(out_data_8)
                            );
                end else if (i == 0 && j == COLS - 1) begin
                    pe pe_block(.i_clk(i_clk),
                                .i_sel(i_sel),
                                .i_west(PE_EL_ROWS[i].PE_EL_COLS[j-1].out_data_8),
                                .w_p_sum(i_north_data[((COLS - j) * 32) - 1 -: 32]),
                                .o_sel(sel),
                                .o_data(out_data_32),
                                .data8(o_data_8[(ROWS - i) * 9 - 1 -: 9])
                            );
                end else if (i == 0) begin
                    pe pe_block(.i_clk(i_clk),
                                .i_sel(i_sel),
                                .i_west(PE_EL_ROWS[i].PE_EL_COLS[j-1].out_data_8),
                                .w_p_sum(i_north_data[((COLS - j) * 32) - 1 -: 32]),
                                .o_sel(sel),
                                .o_data(out_data_32),
                                .data8(out_data_8)
                            );
                end else if ((i == ROWS - 1) && (j == COLS - 1)) begin
                    pe pe_block(.i_clk(i_clk),
                                .i_sel(PE_EL_ROWS[i-1].PE_EL_COLS[j].sel),
                                .i_west(PE_EL_ROWS[i].PE_EL_COLS[j-1].out_data_8),
                                .w_p_sum(PE_EL_ROWS[i-1].PE_EL_COLS[j].out_data_32),
                                .o_sel(o_sel[j]),
                                .o_data(o_data_32[(COLS - j) * 32 - 1 -: 32]),
                                .data8(o_data_8[(ROWS - i) * 9 - 1 -: 9])
                            );
                end else if (j == COLS - 1) begin 
                    pe pe_block(.i_clk(i_clk),
                                .i_sel(PE_EL_ROWS[i-1].PE_EL_COLS[j].sel),
                                .i_west(PE_EL_ROWS[i].PE_EL_COLS[j-1].out_data_8),
                                .w_p_sum(PE_EL_ROWS[i-1].PE_EL_COLS[j].out_data_32),
                                .o_sel(sel),
                                .o_data(out_data_32),
                                .data8(o_data_8[(ROWS - i) * 9 - 1 -: 9])
                            );
                end else if (i == ROWS - 1) begin
                    pe pe_block(.i_clk(i_clk),
                                .i_sel(PE_EL_ROWS[i-1].PE_EL_COLS[j].sel),
                                .i_west(PE_EL_ROWS[i].PE_EL_COLS[j-1].out_data_8),
                                .w_p_sum(PE_EL_ROWS[i-1].PE_EL_COLS[j].out_data_32),
                                .o_sel(o_sel[j]),
                                .o_data(o_data_32[(COLS - j) * 32 - 1 -: 32]),
                                .data8(out_data_8)
                            );
                end else begin
                    pe pe_block(.i_clk(i_clk),
                                .i_sel(PE_EL_ROWS[i-1].PE_EL_COLS[j].sel),
                                .i_west(PE_EL_ROWS[i].PE_EL_COLS[j-1].out_data_8),
                                .w_p_sum(PE_EL_ROWS[i-1].PE_EL_COLS[j].out_data_32),
                                .o_sel(sel),
                                .o_data(out_data_32),
                                .data8(out_data_8)
                            );
                end
            end
        end 
    endgenerate
    

endmodule

//Logic for a single processing block element 
module pe (
    input i_clk,
    input i_sel,
    input [8:0] i_west,
    input [31:0] w_p_sum,
    output o_sel,
    output [31:0] o_data,
    output reg [8:0] data8 = 0
);
    wire [31:0] mux_in_1;
    wire [31:0] mux_in_2;
    
    always @(posedge i_clk) begin 
        data8 <= i_west; 
    end 
	//Include operations done on weights and data in a PE block     
    demux_wb 
    dmx_wb (.dmx_clk(i_clk),
            .i_sel(i_sel),
            .d_north(w_p_sum),
            .d_west(i_west[7:0]),
            .o_sel(o_sel),
            .mux_d1(mux_in_1),
            .mux_d2(mux_in_2)
        );
	//Selects whether we need to give weights or processed data as output of a PE block        
    mux 
    multiplexer(
    .i_clk(i_clk),
    .i_sel(i_sel),
    .i_data1(mux_in_1),
    .i_data2(mux_in_2),
    .o_data(o_data)
);
endmodule

/* 
    Loads weights and does operation on data and weights according to the select line's value
*/
module demux_wb(
    input dmx_clk,
    input i_sel,
    input [31:0] d_north,
    input [7:0] d_west,
    output o_sel,
    output [31:0] mux_d1,
    output [31:0] mux_d2
);


    reg [7:0] wb = 0;
    wire [31:0] o_dmx2;
    wire [7:0] o_dmx1;
    wire [31:0] i_sum1;
    
    assign o_dmx1 = d_north[7:0];
    assign o_dmx2 = (~i_sel) ? d_north : 0;
    assign o_sel = i_sel;
    //product
    assign i_sum1 = d_west * wb;
    
    //sum
    assign mux_d2 = i_sum1 + o_dmx2;
    
    assign mux_d1 = wb;

    //demultiplexer
    always @(posedge dmx_clk) begin
        if(i_sel ) begin 
            wb <= o_dmx1;
        end
        else begin
            wb <= wb;
        end
    end 
    
endmodule

/* 
    Selects the output of PE block depending upon the select line's value.
*/
module mux (
    input i_clk,
    input i_sel,
    input [31:0] i_data1,
    input [31:0] i_data2,
    output reg [31:0] o_data = 0
);
    
always @(posedge i_clk) begin
    if (i_sel)
        o_data <= i_data1;
    else
        o_data <= i_data2;
end

endmodule
