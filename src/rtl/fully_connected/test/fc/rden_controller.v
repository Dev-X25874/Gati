/*
Assert read enable of image and weight fifo array to 
load them together into PE grid.
*/
module rden_controller#(
    parameter COL = 4,
    parameter ROW = 1,
    parameter W_IMG_DIM = 15,
    parameter WEIGHT_FF_ADDR = 8,
    parameter IMAGE_FF_ADDR = 8
)(
    input i_clk,
    input i_rstn,
    input i_trigger,
    input [COL-1 : 0] i_weight_ff_array_empty,
    input [ROW-1 : 0] i_image_ff_array_empty,
    input [(COL * (WEIGHT_FF_ADDR + 1))-1 : 0] i_weight_ff_array_occ,
    input [(ROW * (IMAGE_FF_ADDR + 1))-1 : 0] i_image_ff_array_occ,
    input [W_IMG_DIM-1 : 0] i_img_dim,
    output [COL-1 : 0] o_weight_ff_array_rden,
    output [ROW-1 : 0] o_image_ff_array_rden
);

wire [WEIGHT_FF_ADDR : 0] image_dim_weight_ff;
assign image_dim_weight_ff = i_img_dim[WEIGHT_FF_ADDR : 0];

wire [IMAGE_FF_ADDR : 0] image_dim_img_ff;
assign image_dim_img_ff = i_img_dim[IMAGE_FF_ADDR : 0];

wire w_trigger;
pulse_gen one_pulse_generator(
    .a(i_trigger),
    .i_rstn(i_rstn),
    .clk(i_clk),
    .b(w_trigger)
);

reg [COL-1 : 0] weight_ff_array_rden = 0;
reg [ROW-1 : 0] img_ff_array_rden = 0;
reg [1:0] state = 0;
reg r_start = 0;
reg [$clog2(W_IMG_DIM)-1 : 0] counter = 0;

always @(posedge i_clk)begin
if(w_trigger)
r_start <= 1'b1;
end
assign o_weight_ff_array_rden = weight_ff_array_rden;
assign o_image_ff_array_rden = img_ff_array_rden;

always @(posedge i_clk)begin
    if(~i_rstn)begin
        weight_ff_array_rden <= 0;
        img_ff_array_rden <= 0;
        state <= 0;
    end else begin
        case (state)
        0:begin
            if(r_start)begin
                if((i_weight_ff_array_empty == 0) && (i_image_ff_array_empty == 0))begin
                    //there must be atleast 'image_dimension' number of occupants in each array before reading it's data
                    if((i_weight_ff_array_occ >= {COL{image_dim_weight_ff}}) && (i_image_ff_array_occ >= {ROW{image_dim_img_ff}}))begin
                        weight_ff_array_rden <= {COL{1'b1}};
                        img_ff_array_rden <= {ROW{1'b1}};
                        counter <= counter + 1;
                        state <= 1;
                    end
                end
            end
        end 

        1: begin
            /*  Weights and image from fifo will be read till it either loads all 'image_dimension' 
                number of occupants or if any fifo gets empty   */
            if(((counter == i_img_dim)) || ((i_weight_ff_array_occ == 0) && (i_image_ff_array_occ == 0)))begin
                weight_ff_array_rden <= 0;
                img_ff_array_rden <= 0;
                counter <= 0;
                state <= 0;
            end else begin
                counter <= counter + 1;
            end
        end

        default: state <= 0;
        endcase
    end
end

endmodule