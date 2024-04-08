/*
    Write weights into one fifo at a time, send a write enable signal
    to the engine's north fifo array. Thus, the write enable signal 
    for each fifo in that array is created sequentially.
*/

module north_array_wren#(
    parameter COL = 4
)(
    input i_clk,
    input i_rst,
    input i_enb,
    output [COL-1 : 0] o_wren
);

reg [COL-1 : 0] wren = 0;
reg [COL-1 : 0] counter = 0;

assign o_wren = wren;

always @(posedge i_clk) begin
    if(i_rst)begin
        counter <= 0;
        wren <= 0;
    end else begin
        if(i_enb) begin
            if (counter == COL - 1)
                counter <= 0;
            else
                counter <= counter + 1;
                
            wren[counter] <= 1;
            
            if(COL > 1) begin
                if (counter == 0)
                    wren[COL - 1] <= 0;
                else
                    wren[counter - 1] <= 0;
            end
        end else begin
            counter <= 0;
            wren <= 0;
        end
    end
end
    
endmodule

// module north_array_wren#(
//     parameter COL = 4,
//     parameter N_SA = 1
// )(
//     input i_clk,
//     input i_rst,
//     input [N_SA-1 : 0] i_enb,
//     output [(N_SA * COL)-1 : 0] o_wren
// );
// genvar i;
// generate
//     for(i = 0; i < N_SA; i = i + 1)begin
//         reg [COL-1:0] counter = 0;
//         reg [COL-1:0] data = 0;

//         always @(posedge i_clk) begin
//             if(i_rst)begin
//                 counter <= 0;
//                 data <= 0;
//             end else begin
//                 if(i_enb[i]) begin
//                     if (counter == COL - 1)
//                         counter <= 0;
//                     else
//                         counter <= counter + 1;
                        
//                     data[counter] <= 1;
                    
//                     if(COL > 1) begin
//                         if (counter == 0)
//                             data[COL - 1] <= 0;
//                         else
//                             data[counter - 1] <= 0;
//                     end
//                 end else begin
//                     counter <= 0;
//                     data <= 0;
//                 end
//             end
//         end

//         assign o_wren = data[(COL * (N_SA - i))-1 -: COL];

//     end
// endgenerate
// endmodule