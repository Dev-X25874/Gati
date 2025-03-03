/*
    Receives read enable signal from weight fifo array controller present in SA and FC.
    Further, this mux decides whether to send read enable signal of SA or FC into weight fifo array.
*/
module rden_mux#(
    parameter COL = 16,
    parameter COL_FC = 32,
    parameter N_SA = 4,
    parameter ROW = 9,
    parameter COL_SA = 4,
    parameter N_DRAM_BYTES = 32
)(
    input i_clk,
    input i_rstn,
    input i_done,
    input [(N_DRAM_BYTES/COL_SA)-1 : 0] i_fc_rden,
    input [(N_SA)-1 : 0] i_sa_rden,
    input i_sel_1,
    output o_sel,
    output [COL-1 : 0] o_north_rden
);

reg [COL-1 : 0] north_rden = 0;
wire [COL-1 : 0] conv_north_rden;
wire [COL-1 : 0] fc_north_rden;
assign fc_north_rden = {i_fc_rden,{(COL-(N_DRAM_BYTES/COL_SA)){1'b0}}};
assign o_sel = sel_count;
assign o_north_rden = (i_sel_1)? (((N_SA * COL_SA) < N_DRAM_BYTES)?conv_north_rden:north_rden):fc_north_rden;
localparam SHIFTS = N_DRAM_BYTES/(N_SA*COL_SA);
reg [$clog2(SHIFTS)-1:0] sel_count = 0;
reg [$clog2(ROW)-1:0] row_counter = 0;
reg state = 0;
/*
always @(posedge i_clk)begin
    if(~i_rstn)begin
        north_rden <= 0;
    end else begin
        case (i_sel_1)
            1'b0:begin  //Fully connected layer
                north_rden <= i_fc_rden;
            end
            1'b1: begin //Convolution layer
                if((N_SA * COL_SA) < N_DRAM_BYTES)begin
                    case (i_sel_2)
                        1'b1:begin  //First half of weight fifo array (starting from MSB)
                            north_rden <= {i_sa_rden, {(COL_SA * N_SA){1'b0}}};
                        end
                        1'b0: begin //Second half of weight fifo array
                            north_rden <= {{(COL_SA * N_SA){1'b0}}, i_sa_rden};
                        end 
                    endcase
                end else begin
                    north_rden <= i_sa_rden;
                end
            end
        endcase
    end
end
*/
always @(posedge i_clk)begin
    if(~i_rstn)begin
        north_rden <= 0;
        sel_count <= 0;
        row_counter <= 0;
        state <= 0;
    end else begin
        case (i_sel_1)
            1'b0:begin  //Fully connected layer
                north_rden <= i_fc_rden;
            end
            1'b1: begin //Convolution layer
                if((N_SA * COL_SA) < N_DRAM_BYTES)begin
                    case (state)
                        1'b0: begin
                            if(&i_sa_rden) begin
                                if(sel_count == SHIFTS - 1) begin
                                    if(row_counter == ROW - 1) begin
                                        row_counter <= 0;
                                        sel_count <= sel_count;
                                        state <= 1;
                                    end
                                    else begin
                                        row_counter <= row_counter + 1;
                                        sel_count <= sel_count + 1;
                                        state <= 0;
                                    end
                                end
                                else begin
                                    if(row_counter == ROW - 1) begin
                                        row_counter <= 0;
                                        sel_count <= sel_count;
                                        state <= 1;
                                    end
                                    else begin
                                        row_counter <= row_counter + 1;
                                        sel_count <= sel_count + 1;
                                        state <= 0;
                                    end
                                end
                            end
                            else begin
                                sel_count <= sel_count;
                                row_counter <= row_counter;
                                state <= 0;
                            end
                        end

                        1'b1: begin
                            if(i_done) begin
                                sel_count <= sel_count + 1;
                                state <= 0;
                            end
                            else begin
                                sel_count <= sel_count;
                                state <= 1;
                            end
                        end
                    endcase
                end else begin
                    north_rden <= i_sa_rden;
                end
            end
        endcase
    end
end

Dmux_param # (
    .NUM_PORTS(SHIFTS),
    .DATA_WIDTH(N_SA),
    .COL_SA(1)
  )
  Dmux_param_inst (
    .i_din(i_sa_rden),
    .i_datavalid(),
    .i_sel(sel_count),
    .o_dout(conv_north_rden),
    .o_datavalid()
  );

endmodule
