module mux#(
    parameter W_ADDR = 9,
    parameter COL = 32,
    parameter N_SA = 8,     //number of SA engines
    parameter COL_SA = 8,   //columns in each SA engine
    parameter COL_FC = 32,  //columns in FC engine
    parameter N_DRAM_BYTES = 32,     //number of BRAM burst bytes
    parameter SA_OPCODE = 0,
    parameter FC_OPCODE = 4
)(
    input i_clk,
    input i_rstn,
    input [3:0] i_opcode,
    input i_sel_sa_rden_ctrl,
    input [(COL * W_DATA)-1 : 0] i_weight_ff_array_data,
    input [COL-1 : 0] i_weight_ff_array_empty,
    input [COL-1 : 0] i_weight_ff_array_dv,
    input [(COL * (W_ADDR + 1))-1 : 0] i_weight_ff_array_occupants,
    output [((COL_FC * (W_ADDR + 1)))-1 : 0] o_fc_occupants,
    output [(COL_FC * W_DATA)-1 : 0] o_fc_data,
    output [COL_FC-1 : 0] o_fc_empty,
    output [COL_FC-1 : 0] o_fc_dv,
    output [(COL_SA * N_SA)-1 : 0] o_sa_dv,
    output [(N_SA * COL_SA)-1 : 0] o_sa_empty,
    output [(N_SA * COL_SA * W_DATA)-1 : 0] o_sa_data,
    output [((W_ADDR + 1) * (N_SA * COL_SA))-1 : 0] o_sa_occupants,
    output o_sel1
);

reg [COL_FC-1 : 0] r_fc_empty = 0;
reg [(COL_FC * (W_ADDR + 1))-1 : 0] r_fc_occ = 0;
reg [(N_SA * COL_SA)-1 : 0] r_sa_empty = 0;
reg [((W_ADDR + 1) * (N_SA * COL_SA))-1 : 0] r_sa_occ = 0;
reg [(COL_FC * W_DATA)-1 : 0] r_fc_data = 0;
reg [(N_SA * COL_SA * W_DATA)-1 : 0] r_sa_data = 0;
reg [COL_FC-1 : 0] r_fc_dv = 0;
reg [(N_SA * COL_SA)-1 : 0] r_sa_dv = 0;

assign o_sa_occupants = r_sa_occ;
assign o_sa_empty = r_sa_empty;
assign o_fc_empty = r_fc_empty;
assign o_fc_occupants = r_fc_occ;
assign o_sa_data = r_sa_data;
assign o_fc_data = r_fc_data;
assign o_fc_dv = r_fc_dv;
assign o_sa_dv = r_sa_dv;

wire o_sel1;
sel_gen#(
.SA_OPCODE(SA_OPCODE),
.FC_OPCODE(FC_OPCODE)
)select1_gen(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_opcode(i_opcode),
    .o_sel1(o_sel1)
);

always @(posedge i_clk)begin
    if(~i_rstn)begin
        r_sa_occ <= 0;
        r_sa_empty <= 0;
        r_fc_empty <= 0;
        r_fc_occ <= 0;
        r_fc_data <== 0;
        r_sa_data <= 0; 
        r_sa_dv <= 0;
        r_fc_dv < 0;
    end else begin
        case (o_sel1)
            1'b0:begin      //Fully Connected layer
               r_fc_empty <=  i_weight_ff_array_empty;
               r_fc_occ <= i_weight_ff_array_occupants;
               r_fc_data <= i_weight_ff_array_data;
               r_fc_dv <= i_weight_ff_array_dv;
            end
            1'b1:begin      //Convolution layer
                if((N_SA * COL_SA) < N_DRAM_BYTES) begin
                    case (i_sel_sa_rden_ctrl)
                        1'b0: begin     //First half of weight fifo array (starting from MSB)
                            r_sa_empty <= i_weight_ff_array_empty[(COL-1) -: (N_SA * COL_SA)];
                            r_sa_occ <= i_weight_ff_array_occupants[(COL * (W_ADDR + 1))-1 -: (N_SA * (COL_SA * (W_ADDR + 1)))];
                            r_sa_data <= i_weight_ff_array_data[(COL * W_DATA)-1 -: (N_SA * (COL_SA * W_DATA))];
                            r_sa_dv <= i_weight_ff_array_dv[(COL-1) -: (N_SA * COL_SA)];
                        end
                        1'b1: begin     //Second half of weight fifo array
                            r_sa_empty <= i_weight_ff_array_empty[(COL - (N_SA * COL_SA))-1 -: (N_SA * COL_SA)];
                            r_sa_occ <= i_weight_ff_array_occupants[((COL * (W_ADDR + 1)) - (N_SA * COL_SA))-1 -: (N_SA * (COL_SA * (W_ADDR + 1)))];
                            r_sa_data <= i_weight_ff_array_data[((COL * W_DATA) - (N_SA * COL_SA))-1 -: (N_SA * (COL_SA * W_DATA))];
                            r_sa_dv <= i_weight_ff_array_dv[(COL - (N_SA * COL_SA))-1 -: (N_SA * COL_SA)];
                        end
                    endcase
                end else begin
                    r_sa_occ <= i_weight_ff_array_occupants;
                    r_sa_empty <= i_weight_ff_array_empty;
                    r_sa_data <= i_weight_ff_array_data;
                    r_sa_dv <= i_weight_ff_array_dv;
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
        parameter FC_OPCODE = 4
)(
    input i_clk,
    input i_rst,
    input [3:0] i_opcode,
    output o_sel1
);

reg sel1 = 0;   //Either send weight fifo data into SA or FC
assign o_sel1 = sel1;
always @(posedge i_clk)begin
    if(i_rst)begin
        sel1 <= 0;
    end else begin
        //
        if(i_opcode == SA_OPCODE)         //For convolution layer
            sel1 <= 1'b1;
        else if(i_opcode == FC_OPCODE)    //For fully connected layer
            sel1 <= 1'b0;
    end
end
    
endmodule
