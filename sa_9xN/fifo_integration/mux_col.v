module mux_col
#(parameter COL =3)
(
    input [COL -1:0] i_data1,
    input [COL -1:0] i_data2,
    input [COL -1:0] i_data3,
    input [COL -1:0] i_data4,
    input [1:0] i_sel,
    output reg [COL-1:0]o_data = 0
);


    always @(*) begin
        case(i_sel)
            0: begin
                o_data <= i_data1;
            end

            1: begin
                o_data <= i_data2;
            end

             2: begin
                o_data <= i_data3;
            end

             3: begin
                o_data <= i_data4;
            end
            default : begin
                o_data <= 0;
            end

        endcase 
    end

endmodule