//Asserts read enable signal of weight fifo array.
module weight_ff_rden#(
    parameter COL = 16,
    parameter ROW = 1,
    parameter W_IMG_DIM = 15,
    parameter WEIGHT_FF_DEPTH = 512
)(
    input i_clk,
    input i_rstn,
    input i_trigger,                            
    input i_sel_mux,
    input [COL-1 : 0] i_north_empty,
    input [(COL * (WEIGHT_FF_ADDR + 1))-1 : 0] i_north_occ,
    input [W_IMG_DIM-1 : 0] i_img_dim,
    output [COL-1 : 0] o_north_rden
);

localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);

// wire [WEIGHT_FF_ADDR : 0] image_dim;
// assign image_dim = i_img_dim[WEIGHT_FF_ADDR : 0];

wire w_trigger;
pulse_gen one_pulse (
    .a(i_trigger),
    .i_rstn(i_rstn),
    .clk(i_clk),
    .b(w_trigger)
);

reg [COL-1 : 0] north_rden = 0;
reg [1:0] state = 0;
reg [3:0] dbg_cnt = 0;
reg r_start = 0;
reg [$clog2(W_IMG_DIM)-1 : 0] counter = 0;

always @(posedge i_clk)begin
    if(w_trigger)
        r_start <= 1'b1;
end
assign o_north_rden = north_rden;

always @(posedge i_clk)begin
    if(~i_rstn)begin
        north_rden <= 0;
        state <= 0;
    end else begin
            case (state)
                0:begin
                    if(r_start & (~i_sel_mux))begin
                        if((i_north_empty == 0))begin
                            // if((i_north_occ >= {COL{image_dim}}))begin
                            north_rden <= {COL{1'b1}};
                            counter <= counter + 1;
                            state <= 1;
                        // end
                        end
                    end
                end 

                1: begin
                    if(counter == i_img_dim)begin
                        north_rden <= 0;
                        counter <= 0;
                        state <= 0;
                        // dbg_cnt <= dbg_cnt + 1;
                    end else begin
                        if(i_north_occ == 0)begin
                            north_rden <= 0;
                            counter <= counter;
                            state <= 1;
                        end
                        else begin 
                            north_rden <= 0;
                            counter <= counter + 1;
                            state <= 1;
                        end                        
                    end
                end
                default: state <= 0;
            endcase
    end
end

endmodule