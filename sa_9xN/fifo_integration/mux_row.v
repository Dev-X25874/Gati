module mux_row #(
    parameter ROW = 9
) ( input [ROW-1:0] i_data1,
    input [ROW-1:0] i_data2,
    input [ROW-1:0] i_data3,
    input [ROW-1:0] i_data4,
    input [ROW-1:0] i_data5,
    input [ROW-1:0] i_data6,
    input [ROW-1:0] i_data7,
    input [ROW-1:0] i_data8,
    input [ROW-1:0] i_data9,
    input [ROW-1:0] i_data10,
    input [3:0] i_sel,
    output reg [ROW -1 : 0] o_data = 0
);
    always @(*)begin
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

            4: begin
                o_data <= i_data5;
            end

            5: begin
                o_data <= i_data6;
            end

            6: begin
                o_data <= i_data7;
            end

            7: begin
                o_data <= i_data8;
            end

            8: begin
                o_data <= i_data9;
            end

            9: begin
                o_data <= i_data10;
            end

            default: begin
                o_data <= 0;
            end
        endcase
    end

endmodule