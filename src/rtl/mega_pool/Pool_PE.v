`include "../common/arch_param.vh"


`ifdef MEGA_MAX
module Pool_PE_block#(
    parameter W_DATA = 8
)(
    input i_clk,
    input i_rstn,
    input i_mode,
    input [W_DATA :0] i_data1,
    input [W_DATA :0] i_data2,
    output [W_DATA :0] o_data
);

reg [W_DATA-1 : 0] r_o_data;
reg r_o_datavalid;

always @(posedge i_clk) begin
    if(~i_rstn)begin
        r_o_data <= 0;
        r_o_datavalid <= 0;
    end else begin
        r_o_datavalid <= (i_data1[W_DATA] & i_data2[W_DATA]);
        case(i_mode)
            0: begin
                r_o_data = ($signed(i_data1[W_DATA-1 : 0]) > $signed(i_data2[W_DATA-1 : 0]))? i_data1[W_DATA-1 : 0] : i_data2[W_DATA-1 : 0];
            end
            1: r_o_data <= $signed(i_data1[W_DATA-1 : 0]) + $signed(i_data2[W_DATA-1 : 0]);
        endcase
    end
end

assign o_data = {r_o_datavalid, r_o_data};

endmodule
`endif