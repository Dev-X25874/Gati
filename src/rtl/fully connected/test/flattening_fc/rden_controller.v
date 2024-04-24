/*
    Assert read enable of weight fifo array to 
    load image and weight simultaneously into PE grid.
*/
module rden_controller#(
    parameter COL = 16,
    parameter ROW = 1,
    parameter W_FC_CNT = 15,
    parameter W_ADDR = 8,
    parameter RAM_DEPTH = (1 << W_ADDR)
)(
    input i_clk,
    input i_rst,
    input i_trigger,
    input i_sel1,
    input [COL-1 : 0] i_north_empty,
    input [(COL * (W_ADDR + 1))-1 : 0] i_north_occ,
    input [W_FC_CNT-1 : 0] i_img_dim,
    output [COL-1 : 0] o_north_rden
);

// wire [W_ADDR : 0] image_dim;
// assign image_dim = i_img_dim[W_ADDR : 0];

reg [W_ADDR:0] depth;
always @(*) begin
    depth <= RAM_DEPTH;
end

// wire w_trigger;
// one_cycle one_pulse (
//     .a(i_trigger),
//     .rst(i_rst),
//     .clk(i_clk),
//     .b(w_trigger)
// );

reg [COL-1 : 0] north_rden = 0;
reg [1:0] state = 0;
reg [3:0] dbg_cnt = 0;
reg r_start = 0;
reg [12:0] counter = 0;

// always @(posedge i_clk)begin
//     if(w_trigger)
//         r_start <= 1'b1;
// end
assign o_north_rden = north_rden;

always @(posedge i_clk)begin
    if(i_rst)begin
        north_rden <= 0;
        state <= 0;
    end else begin
            case (state)
                0:begin
                    // if(r_start & (i_sel1 == 0))begin
                        if(i_trigger & (i_sel1 == 0))begin
                        if((i_north_empty == 0))begin
                            if((i_north_occ >= {COL{depth >> 2}}))begin
                                // if((i_north_occ >= {COL{9'd128}}))begin
                                north_rden <= {COL{1'b1}};
                                counter <= counter + 1;
                                state <= 1;
                            end
                        end
                    end
                end 

                1: begin
                    if(((counter == i_img_dim)) || ((i_north_occ == 0)))begin
                        north_rden <= 0;
                        counter <= 0;
                        state <= 0;
                        dbg_cnt <= dbg_cnt + 1;
                    end else begin
                        counter <= counter + 1;
                        north_rden <= {COL{1'b1}};
                    end
                end
                default: state <= 0;
            endcase
    end
end

endmodule