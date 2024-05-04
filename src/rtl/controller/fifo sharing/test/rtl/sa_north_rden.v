/*
    Read enable controller of SA block.
    Note: This controller is included here just for checking 
    the functionality of fifo sharing controller, 
    should be avoided while integration.
*/
/*
module sa_weight_ff_rden#(
    parameter COL_SA = 4,
    parameter W_ADDR = 8,
    parameter ROW = 9,
    parameter N_SA = 4,
    parameter N_BRAM_BYTES = 32
)(
    input i_clk,
    input i_rst,
    input i_start,
    input i_done,
    input i_layer_done,
    input [(N_SA * COL_SA)-1 : 0] i_weight_ff_empty,
    input [(N_SA * (COL_SA * (W_ADDR+1)))-1 : 0] i_weight_ff_occupants,
    output [(N_SA * COL_SA)-1  :0] o_weight_ff_read_en,
    output [N_SA-1 : 0] o_sel
);

genvar i;
generate
    for(i = 0; i < N_SA; i = i + 1)begin
        sa_north_rden#(
            .COL(COL_SA),
            .W_ADDR(W_ADDR),
            .ROW(ROW),
            .N_SA(N_SA),
            .N_BRAM_BYTES(N_BRAM_BYTES)
        )weight_fifo_array_rden_controller(
            .i_clk(i_clk),
            .i_rst(i_rst),
            .i_start(i_start),
            .i_done(i_done),
            .i_layer_done(i_layer_done),
            .i_fifo_empty(i_weight_ff_empty[(COL_SA * (N_SA - i))-1 -: COL_SA]),
            .i_fifo_occupants(i_weight_ff_occupants[((COL_SA * (W_ADDR + 1)) * (N_SA - i))-1 -: (COL_SA * (W_ADDR + 1))]),
            .o_fifo_read_enable(o_weight_ff_read_en[(COL_SA * (N_SA - i))-1 -: (COL_SA)]),
            .o_sel(o_sel[i])
        );

    end
endgenerate
    
endmodule

module sa_north_rden#(
    parameter COL = 4,
    parameter W_ADDR = 8,
    parameter ROW = 9,
    parameter N_SA = 4,
    parameter N_BRAM_BYTES = 32
)(
    input i_clk,
    input i_rst,
    input i_start,
    input i_done,
    input i_layer_done,
    input [COL-1 : 0] i_fifo_empty,
    input [(COL * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output [COL-1 : 0] o_fifo_read_enable,
    output o_sel
);

localparam S_ROW = ROW[8:0];

reg [2:0] state = 0;
reg [4:0] counter = 0;
reg sel = 1;
reg [COL-1 : 0] rden = 0;

wire w_start;
one_cycle start_pulse (
    .a(i_start),
    .rst(i_rst),
    .clk(i_clk),
    .b(w_start)
);

assign o_fifo_read_enable = rden;
assign o_sel = sel;

always @(posedge i_clk) begin
    if(i_rst)begin
        state <= 0;
        rden <= 0;
        sel <= 1;
    end else begin
        case (state)
            0: begin
                if(w_start)begin
                    state <= 1;
                    rden <= 0;
                    sel <= 1'b1;
                end
            end 

            1: begin
                if((i_fifo_empty == 0) && (i_fifo_occupants >= {COL{S_ROW}}))begin
                    rden <= {COL{1'b1}};
                    state <= 2;
                end
            end

            2: begin
                if(counter == ROW-1)begin
                    state <= 3;
                    counter <= 0;
                    rden <= 0;
                    sel <= sel;
                    read_img <= 1'b1;
                end else begin
                    counter <= counter + 1;
                end
            end

            3: begin
                if(i_done)begin
                    read_img <= 1'b0;
                   if((COL * N_SA) < N_BRAM_BYTES)
                        sel <= ~sel;
                    else
                        sel <= sel;
                    state <= 4;
                end
            end

            4: begin
                if(i_layer_done)begin
                    state <= 0;
                    sel <= 1'b1;
                end else begin
                    state <= 1;
                    sel <= sel;
                end
            end

            default: state <= 0;
        endcase
    end
end

    
endmodule
*/