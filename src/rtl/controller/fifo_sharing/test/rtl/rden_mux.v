module rden_mux#(
    parameter COL = 4
)(
    input i_clk,
    input i_rst,
    input [COL-1 : 0] i_fc_rden,
    input [(COL/2)-1 : 0] i_sa_rden,
    input i_sel_1,
    input i_sel_2,
    output [COL-1 : 0] o_north_rden
);

reg [COL-1 : 0] north_rden = 0;
assign o_north_rden = north_rden;

always @(posedge i_clk)begin
    if(i_rst)begin
        north_rden <= 0;
    end else begin
        case (i_sel_1)  //TODO: ADD default state in all mux case statements
            1'b0:begin  //Fully connected layer
                north_rden <= i_fc_rden;
            end
            1'b1: begin //Convolution layer
                case (i_sel_2)
                    1'b0:begin  //32-17 fifo set
                        north_rden <= {i_sa_rden, 4'd0};
                    end
                    1'b1: begin //16-1 fifo set
                        north_rden <= {4'd0, i_sa_rden};
                    end 
                endcase
            end
        endcase
    end
end

endmodule