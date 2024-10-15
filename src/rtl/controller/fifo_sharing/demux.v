/*
    Based on the opcode signal coming from instructions,
    this demux switches between SA and FC to load weights into
    either of them at a time.
*/
module demux#(
    parameter WEIGHT_FF_DEPTH = 512,
    parameter COL = 32,
    parameter N_SA = 8,             //number of SA engines
    parameter COL_SA = 8,           //columns in each SA engine
    parameter COL_FC = 32,          //columns in FC engine
    parameter N_DRAM_BYTES = 32,    //number of DRAM burst bytes
    parameter SA_OPCODE = 0,
    parameter FC_OPCODE = 4,
    parameter W_DATA = 8,
    parameter W_OPCODE = 4          //width of opcode
)(
    input i_clk,
    input i_rstn,
    input [W_OPCODE-1:0] i_opcode,
    input i_sel_sa_rden_ctrl,
    input [(COL * W_DATA)-1 : 0] i_weight_ff_array_data,
    input [COL-1 : 0] i_weight_ff_array_empty,
    input [COL-1 : 0] i_weight_ff_array_almost_empty,
    input [COL-1 : 0] i_weight_ff_array_dv,
    input [(COL * (WEIGHT_FF_ADDR + 1))-1 : 0] i_weight_ff_array_occupants,
    output [((COL_FC * (WEIGHT_FF_ADDR + 1)))-1 : 0] o_fc_occupants,
    output [(COL_FC * W_DATA)-1 : 0] o_fc_data,
    output [COL_FC-1 : 0] o_fc_empty,
    output [COL_FC-1 : 0] o_fc_almost_empty,
    output [COL_FC-1 : 0] o_fc_dv,
    output [(COL_SA * N_SA)-1 : 0] o_sa_dv,
    output [(N_SA * COL_SA)-1 : 0] o_sa_empty,
    output [(N_SA * COL_SA * W_DATA)-1 : 0] o_sa_data,
    output [((WEIGHT_FF_ADDR + 1) * (N_SA * COL_SA))-1 : 0] o_sa_occupants,
    output demux_sel
);

localparam WEIGHT_FF_ADDR = $clog2(WEIGHT_FF_DEPTH);

reg [COL_FC-1 : 0] r_fc_empty = 0;
reg [COL_FC-1 : 0] r_fc_almost_empty = 0;
reg [(COL_FC * (WEIGHT_FF_ADDR + 1))-1 : 0] r_fc_occ = 0;
reg [(N_SA * COL_SA)-1 : 0] r_sa_empty = 0;
reg [((WEIGHT_FF_ADDR + 1) * (N_SA * COL_SA))-1 : 0] r_sa_occ = 0;
reg [(COL_FC * W_DATA)-1 : 0] r_fc_data = 0;
reg [(N_SA * COL_SA * W_DATA)-1 : 0] r_sa_data = 0;
reg [COL_FC-1 : 0] r_fc_dv = 0;
reg [(N_SA * COL_SA)-1 : 0] r_sa_dv = 0;

assign o_sa_occupants = r_sa_occ;
assign o_sa_empty = r_sa_empty;
assign o_fc_empty = r_fc_empty;
assign o_fc_almost_empty = r_fc_almost_empty;
assign o_fc_occupants = r_fc_occ;
assign o_sa_data = r_sa_data;
assign o_fc_data = r_fc_data;
assign o_fc_dv = r_fc_dv;
assign o_sa_dv = r_sa_dv;

wire demux_sel;
sel_gen#(
    .SA_OPCODE(SA_OPCODE),
    .FC_OPCODE(FC_OPCODE),
    .W_OPCODE(W_OPCODE)
)select1_gen(
    .i_clk(i_clk),
    .i_rstn(i_rstn),
    .i_opcode(i_opcode),
    .demux_sel(demux_sel)
);
/*
always @(posedge i_clk)begin
    if(~i_rstn)begin
        r_sa_occ <= 0;
        r_sa_empty <= 0;
        r_fc_empty <= 0;
        r_fc_occ <= 0;
        r_fc_data <= 0;
        r_sa_data <= 0; 
        r_sa_dv <= 0;
        r_fc_dv <= 0;
    end else begin
        case (demux_sel)
            1'b0:begin      //Fully Connected layer
            r_fc_empty <=  i_weight_ff_array_empty;
            r_fc_occ <= i_weight_ff_array_occupants;
            r_fc_data <= i_weight_ff_array_data[(COL * W_DATA)-1 : ((COL - COL_FC) * W_DATA)];
            r_fc_dv <= i_weight_ff_array_dv;
            end

            1'b1:begin      //Convolution layer
                
                    When the total number of columns across all SA engines is less than the number DRAM bytes,
                    the weights are loaded from the first half of the weight fifo array,
                    and then the remaining fifo weights are loaded at the next request that comes from the SA engines.
                    Until SA continues to send read enable to the weight fifo array,
                    this toggling between the two sides of the weights fifo array will continue in the same manner.
                
                if((N_SA * COL_SA) < N_DRAM_BYTES)begin
                    case (i_sel_sa_rden_ctrl)
                    1'b1: begin     //First half of weight fifo array (starting from MSB)
                        r_sa_empty <= i_weight_ff_array_empty[(COL-1) -: (N_SA * COL_SA)];
                        r_sa_occ <= i_weight_ff_array_occupants[(COL * (WEIGHT_FF_ADDR + 1))-1 -: (N_SA * (COL_SA * (WEIGHT_FF_ADDR + 1)))];
                        r_sa_data <= i_weight_ff_array_data[(COL * W_DATA)-1 -: (N_SA * (COL_SA * W_DATA))];
                        r_sa_dv <= i_weight_ff_array_dv[(COL-1) -: (N_SA * COL_SA)];
                    end
                    1'b0: begin     //Second half of weight fifo array
                        r_sa_empty <= i_weight_ff_array_empty[(COL - (N_SA * COL_SA))-1 -: (N_SA * COL_SA)];
                        // r_sa_occ <= i_weight_ff_array_occupants[((COL * (WEIGHT_FF_ADDR + 1)) - (N_SA * COL_SA))-1 -: (N_SA * (COL_SA * (WEIGHT_FF_ADDR + 1)))];
                        r_sa_occ <= i_weight_ff_array_occupants[((COL-(N_SA*COL_SA))*(WEIGHT_FF_ADDR+1))-1 -: (N_SA * (COL_SA * (WEIGHT_FF_ADDR + 1)))];
                        // r_sa_data <= i_weight_ff_array_data[((COL * W_DATA) - (N_SA * COL_SA))-1 -: (N_SA * (COL_SA * W_DATA))];
                        r_sa_data <= i_weight_ff_array_data[((COL-(N_SA*COL_SA))*W_DATA)-1 -: (N_SA * (COL_SA * W_DATA))];
                        r_sa_dv <= i_weight_ff_array_dv[(COL - (N_SA * COL_SA))-1 -: (N_SA * COL_SA)];
                    end
                    endcase
                end 
                
                    Else,there won't be any toggling in weight fifo array.
                    And weights will be loaded together into each column of every SA engine.
                
                else begin
                    r_sa_occ <= i_weight_ff_array_occupants;
                    r_sa_empty <= i_weight_ff_array_empty;
                    r_sa_data <= i_weight_ff_array_data;
                    r_sa_dv <= i_weight_ff_array_dv;
                end
            end 
        endcase
    end
end
*/
always @(*)begin
    if(~i_rstn)begin
        r_sa_occ = 0;
        r_sa_empty = 0;
        r_fc_empty = 0;
        r_fc_almost_empty = 0;
        r_fc_occ = 0;
        r_fc_data = 0;
        r_sa_data = 0; 
        r_sa_dv = 0;
        r_fc_dv = 0;
    end else begin
        case (demux_sel)
            1'b0:begin      //Fully Connected layer
            r_fc_empty =  i_weight_ff_array_empty;
            r_fc_almost_empty = i_weight_ff_array_almost_empty;
            r_fc_occ = i_weight_ff_array_occupants;
            r_fc_data = i_weight_ff_array_data[(COL * W_DATA)-1 : ((COL - COL_FC) * W_DATA)];
            r_fc_dv = i_weight_ff_array_dv;

            r_sa_occ = 0;
            r_sa_empty = {(N_SA * COL_SA){1'b1}};
            r_sa_data = 0; 
            r_sa_dv = 0;
            end

            1'b1:begin      //Convolution layer
                /*
                    When the total number of columns across all SA engines is less than the number DRAM bytes,
                    the weights are loaded from the first half of the weight fifo array,
                    and then the remaining fifo weights are loaded at the next request that comes from the SA engines.
                    Until SA continues to send read enable to the weight fifo array,
                    this toggling between the two sides of the weights fifo array will continue in the same manner.
                */
                r_fc_empty = {COL_FC{1'b1}};
                r_fc_almost_empty = 0;
                r_fc_occ = 0;
                r_fc_data = 0;
                r_fc_dv = 0;
                if((N_SA * COL_SA) < N_DRAM_BYTES)begin
                    case (i_sel_sa_rden_ctrl)
                    1'b1: begin     //First half of weight fifo array (starting from MSB)
                        r_sa_empty = i_weight_ff_array_empty[(COL-1) -: (N_SA * COL_SA)];
                        r_sa_occ = i_weight_ff_array_occupants[(COL * (WEIGHT_FF_ADDR + 1))-1 -: (N_SA * (COL_SA * (WEIGHT_FF_ADDR + 1)))];
                        r_sa_data = i_weight_ff_array_data[(COL * W_DATA)-1 -: (N_SA * (COL_SA * W_DATA))];
                        r_sa_dv = i_weight_ff_array_dv[(COL-1) -: (N_SA * COL_SA)];
                    end
                    1'b0: begin     //Second half of weight fifo array
                        r_sa_empty = i_weight_ff_array_empty[(COL - (N_SA * COL_SA))-1 -: (N_SA * COL_SA)];
                        // r_sa_occ <= i_weight_ff_array_occupants[((COL * (WEIGHT_FF_ADDR + 1)) - (N_SA * COL_SA))-1 -: (N_SA * (COL_SA * (WEIGHT_FF_ADDR + 1)))];
                        r_sa_occ = i_weight_ff_array_occupants[((COL-(N_SA*COL_SA))*(WEIGHT_FF_ADDR+1))-1 -: (N_SA * (COL_SA * (WEIGHT_FF_ADDR + 1)))];
                        // r_sa_data <= i_weight_ff_array_data[((COL * W_DATA) - (N_SA * COL_SA))-1 -: (N_SA * (COL_SA * W_DATA))];
                        r_sa_data = i_weight_ff_array_data[((COL-(N_SA*COL_SA))*W_DATA)-1 -: (N_SA * (COL_SA * W_DATA))];
                        r_sa_dv = i_weight_ff_array_dv[(COL - (N_SA * COL_SA))-1 -: (N_SA * COL_SA)];
                    end
                    endcase
                end 
                /*
                    Else,there won't be any toggling in weight fifo array.
                    And weights will be loaded together into each column of every SA engine.
                */
                else begin
                    r_sa_occ = i_weight_ff_array_occupants;
                    r_sa_empty = i_weight_ff_array_empty;
                    r_sa_data = i_weight_ff_array_data;
                    r_sa_dv = i_weight_ff_array_dv;
                end
            end 
        endcase
    end
end

endmodule

/*
    Generates select signal value for mux which handles
    whether to load weights into SA or FC block
*/
module sel_gen#(
    parameter SA_OPCODE = 0,
    parameter FC_OPCODE = 4,
    parameter W_OPCODE = 4
)(
    input i_clk,
    input i_rstn,
    input [W_OPCODE-1:0] i_opcode,
    output demux_sel
);

reg sel = 0;    //select signal for demux
assign demux_sel = sel;
always @(posedge i_clk)begin
    if(~i_rstn)begin
        sel <= 0;
    end else begin
        if(i_opcode == SA_OPCODE)         //For convolution layer
            sel <= 1'b1;
        else if(i_opcode == FC_OPCODE)    //For fully connected layer
            sel <= 1'b0;
    end
end
    
endmodule
