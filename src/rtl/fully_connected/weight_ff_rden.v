//Asserts read enable signal of weight fifo array.
module weight_ff_rden#(
    parameter COL = 16,
    parameter ROW = 1,
    parameter W_IMG_DIM = 15,
    parameter WEIGHT_FF_DEPTH = 512,
    parameter W_KERNAL_CNT = 10
)(
    input i_clk,
    input i_rstn,
    input i_trigger,                            
    input i_sel_mux,
    input [W_KERNAL_CNT-1 : 0] i_kernal_count,
    input i_accumulator_valid,
    input i_north_empty,
    input i_north_almost_empty,
    input [(COL * (WEIGHT_FF_ADDR + 1))-1 : 0] i_north_occ,
    input [W_IMG_DIM-1 : 0] i_img_dim,
    output o_north_rden
);

localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);

// wire [WEIGHT_FF_ADDR : 0] image_dim;
// assign image_dim = i_img_dim[WEIGHT_FF_ADDR : 0];

reg w_trigger;
/*
pulse_gen one_pulse (
    .a(i_trigger),
    .i_rstn(i_rstn),
    .clk(i_clk),
    .b(w_trigger)
);
*/
reg north_rden = 0;
reg [1:0] state = 0;
reg [3:0] dbg_cnt = 0;
reg r_start = 0;
reg [(W_IMG_DIM)-1 : 0] counter = 0;

reg [W_KERNAL_CNT-1 : 0] r_kernal_count, kernal_counter;

always @(posedge i_clk)begin
    r_kernal_count<=i_kernal_count;
    w_trigger <= i_trigger;
    // if(w_trigger)
    //     r_start <= 1'b1;
    // else
    //     r_start <= 1'b0;
end
assign o_north_rden = north_rden;

always @(posedge i_clk)begin
    if(~i_rstn)begin
        north_rden <= 0;
        state <= 0;
    end else begin
            case (state)
                0:begin
                    if(w_trigger & (~i_sel_mux))begin
                        state <= 1;
                        // if((&(i_north_almost_empty)) && (&(north_rden)))begin
                        //     north_rden <= 0;
                        //     counter <= counter;
                        //     state <= 0;
                        // end
                        // else if((i_north_empty == 0))begin
                        //     // if((i_north_occ >= {COL{image_dim}}))begin
                        //     north_rden <= {COL{1'b1}};
                        //     counter <= counter + 1;
                        //     state <= 1;
                        // // end
                        // end
                    end
                end 

                1: begin
                    if(kernal_counter < r_kernal_count) begin
                        if(counter == i_img_dim)begin
                            north_rden <= 0;
                            counter <= 0;
                            state <= 2;
                            // dbg_cnt <= dbg_cnt + 1;
                        end else begin
                            if((i_north_almost_empty) && (&(north_rden)))begin
                                north_rden <= 0;
                                counter <= counter;
                                state <= 1;
                            end
                            else if(i_north_empty==0) begin
                                north_rden <= {{1'b1}};
                                counter <= counter + 1;
                                state <= 1;
                            end                        
                        end
                    end
                    else begin
                        kernal_counter <= 0;
                        state <= 0; 
                    end
                end

                2: begin
                    if(i_accumulator_valid)begin
                        kernal_counter <= kernal_counter + 1;
                        state <= 1;
                    end
                end
                default: state <= 0;
            endcase
    end
end

endmodule
