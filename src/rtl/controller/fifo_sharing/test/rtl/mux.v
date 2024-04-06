module mux#(
    parameter W_ADDR = 9,
    parameter COL = 32,
    parameter N_SA = 8,     //number of SA engines
    parameter SA_COL = 8,   //columns in each SA engine
    parameter FC_COL = 32,  //columns in FC engine
    parameter N_BRAM_BYTES = 32     //number of BRAM burst bytes
)(
    input i_clk,
    input i_rst,
    input [3:0] i_opcode,
    input i_sel_sa_rden_ctrl,
    input [COL-1 : 0] i_weight_ff_array_empty,
    input [(COL * (W_ADDR + 1))-1 : 0] i_weight_ff_array_occupants,
    output [((FC_COL * (W_ADDR + 1)))-1 : 0] o_fc_occupants,
    output [FC_COL-1 : 0] o_fc_empty,
    output [(N_SA * SA_COL)-1 : 0] o_sa_empty,
    output [((W_ADDR + 1) * (N_SA * SA_COL))-1 : 0] o_sa_occupants,
    output o_sel1
);

reg [FC_COL-1 : 0] r_fc_empty = 0;
reg [(FC_COL * (W_ADDR + 1))-1 : 0] r_fc_occ = 0;
reg [(N_SA * SA_COL)-1 : 0] r_sa_empty = 0;
reg [((W_ADDR + 1) * (N_SA * SA_COL))-1 : 0] r_sa_occ = 0;

assign o_sa_occupants = r_sa_occ;
assign o_sa_empty = r_sa_empty;
assign o_fc_empty = r_fc_empty;
assign o_fc_occupants = r_fc_occ;

wire o_sel1;
sel_gen select1_gen(
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_opcode(i_opcode),
    .o_sel1(o_sel1)
);

always @(posedge i_clk)begin
    if(i_rst)begin
        r_sa_occ <= 0;
        r_sa_empty <= 0;
        r_fc_empty <= 0;
        r_fc_occ <= 0; 
    end else begin
        case (o_sel1)
            1'b0:begin      //Fully Connected layer
               r_fc_empty <=  i_weight_ff_array_empty;
               r_fc_occ <= i_weight_ff_array_occupants;
            end
            1'b1:begin      //Convolution layer
                if((N_SA * SA_COL) < N_BRAM_BYTES) begin
                    case (i_sel_sa_rden_ctrl)
                        1'b0: begin     //First half of weight fifo array (starting from MSB)
                            r_sa_empty <= i_weight_ff_array_empty[(COL-1) -: (N_SA * SA_COL)];
                            r_sa_occ <= i_weight_ff_array_occupants[(COL * (W_ADDR + 1))-1 -: (N_SA * (SA_COL * (W_ADDR + 1)))];
                        end
                        1'b1: begin     //Second half of weight fifo array
                            r_sa_empty <= i_weight_ff_array_empty[(COL - (N_SA * SA_COL))-1 -: (N_SA * SA_COL)];
                            r_sa_occ <= i_weight_ff_array_occupants[((COL * (W_ADDR + 1)) - (N_SA * SA_COL))-1 -: (N_SA * (SA_COL * (W_ADDR + 1)))];
                        end
                    endcase
                end else begin
                    r_sa_occ <= i_weight_ff_array_occupants;
                    r_sa_empty <= i_weight_ff_array_empty;
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
module sel_gen(
    input i_clk,
    input i_rst,
    input [3:0] i_opcode,   //TODO: Width of opcode signal?
    output o_sel1
);

reg sel1 = 0;   //Either send weight fifo data into SA or FC
assign o_sel1 = sel1;
always @(posedge i_clk)begin
    if(i_rst)begin
        sel1 <= 0;
    end else begin
        if(i_opcode == 4'b1111)         //For convolution layer
            sel1 <= 1'b1;
        else if(i_opcode == 4'b0000)    //For fully connected layer
            sel1 <= 1'b0;
    end
end
    
endmodule