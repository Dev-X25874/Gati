module fifo_sharing_weight_wren_ctrl#(
    parameter SA_OPCODE = 0,
    parameter FC_OPCODE = 4,
    parameter OPCODE_WIDTH = 4,
    parameter N_SA  	= 4,
    parameter COL_SA    = 4,
    parameter COL_FC    = 32,
    parameter DRAM_BW   = 32,
    parameter DATA_WIDTH = 8
) (
    input i_clk,
    input rst,
    input [OPCODE_WIDTH-1 : 0] opcode,
    input valid_inst_CONV_FC,

    input [DRAM_BW-1 : 0] i_datavalid_dram_weight,
    input [DRAM_BW*DATA_WIDTH - 1 : 0] i_dram_weight,

    output reg [COL-1 : 0] weight_fifo_wren,
    output reg [COL*DATA_WIDTH - 1 : 0] o_dram_weight
);

localparam COL = ((N_SA * COL_SA) > COL_FC) ? (N_SA * COL_SA) : COL_FC;
reg [OPCODE_WIDTH-1:0] r_opcode;

always@(posedge i_clk) begin
    if (valid_inst_CONV_FC) begin
        r_opcode <= opcode;
    end
end

reg sel; //select line for selecting CONV and FC modes
always@(posedge i_clk) begin
    if(!rst)
        sel <= 1'b0;
    else begin
        if(r_opcode==SA_OPCODE) sel <= 1'b1;
        else if(r_opcode==FC_OPCODE) sel <= 1'b0;
    end
end

/* based on sel line and COL generate sel_dmux to select the 
    write continuoulsy or alternatively
*/

//wire switch;
//assign switch = ((N_SA*COL_SA)<=DRAM_BW)? 0 : 1;

localparam switch = ((N_SA*COL_SA)<=DRAM_BW)? 0 : 1;
reg sel_dmux;

//reg [COL-1:0] weight_fifo_wren;

wire datavalid_dram_weight = &(i_datavalid_dram_weight);
always@(posedge i_clk) begin
    if(!rst) begin
        sel_dmux <= 1'b0;
    end
    else begin
        case (sel)
            1'b0: begin //FC Mode
                if(switch==1) begin
                    sel_dmux <= 0; //Todo: 1(or 0) check it, write has to be done continuously in only one part of the fifo
                end
                else begin
                    sel_dmux <= 0; //Discarded if switch = 0 
                end
            end
            1'b1: begin //CONV Mode
                if(switch==1) begin
                    if(datavalid_dram_weight)
                        sel_dmux <= ~sel_dmux;
                    else
                        sel_dmux <= sel_dmux;
                end
                else begin
                    sel_dmux <= 0; //Discraded if switch = 0
                end
            end 
        endcase
    end
end


generate
    if(switch==1) begin
        always @(posedge i_clk) 
        begin
        if(!rst) begin
            weight_fifo_wren <= 0;
        end
        else begin
            if(datavalid_dram_weight) 
            begin
                if(~sel_dmux) begin
                    weight_fifo_wren <= {{(COL-DRAM_BW){1'b1}},{DRAM_BW{1'b0}}};
                    o_dram_weight[(COL*DATA_WIDTH)-1 -:(COL-DRAM_BW)*DATA_WIDTH]    <= i_dram_weight;
                end
                else begin
                    weight_fifo_wren <= {{(COL-DRAM_BW){1'b0}},{DRAM_BW{1'b1}}};
                    o_dram_weight[((COL-DRAM_BW)*DATA_WIDTH)-1 -:(COL-DRAM_BW)*DATA_WIDTH]    <= i_dram_weight;
                end
            end
            else begin
                weight_fifo_wren <= {COL{1'b0}};
                o_dram_weight    <= o_dram_weight;
            end
        end
        end
    end

    else begin
       always@(posedge i_clk) begin
       if(!rst) begin
        weight_fifo_wren <= 0;
       end
       else begin
        if(datavalid_dram_weight) begin
            weight_fifo_wren <= {COL{1'b1}};
            o_dram_weight    <= i_dram_weight;
        end
        else begin
            weight_fifo_wren <= {COL{1'b0}};
            o_dram_weight    <= o_dram_weight;
        end
       end
       end 
    end
endgenerate

/*
always @(posedge i_clk) begin
    if(switch) begin
        if(datavalid_dram_weight) begin
            if(sel_dmux) begin
                weight_fifo_wren <= {{(COL-DRAM_BW){1'b1}},{DRAM_BW{1'b0}}};
                o_dram_weight[((COL*DATA_WIDTH)-1) -:(DRAM_BW)*DATA_WIDTH] <= i_dram_weight;
            end
            else begin
                weight_fifo_wren <= {{(COL-DRAM_BW){1'b0}},{DRAM_BW{1'b1}}};
                o_dram_weight[((COL-DRAM_BW)*DATA_WIDTH)-1 :(DRAM_BW)*DATA_WIDTH]    <= i_dram_weight;
            end
        end else begin
            weight_fifo_wren <= {COL{1'b0}};
            o_dram_weight    <= o_dram_weight;
        end
    end
    else begin
        if(datavalid_dram_weight) begin
            weight_fifo_wren <= {COL{1'b1}};
            o_dram_weight    <= i_dram_weight;
        end
        else begin
            weight_fifo_wren <= {COL{1'b0}};
            o_dram_weight    <= o_dram_weight;
        end
    end
end
*/

endmodule
