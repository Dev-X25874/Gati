module internal_north_rden#(
    parameter COL = 4,
    parameter W_ADDR = 8,
    parameter ROW = 9
)(
    input i_clk,
    input i_rst,
    input i_start,
    input i_done,
    input i_layer_done,
    input i_sel_1,
    input [COL-1 : 0] i_fifo_empty,
    input [(COL * (W_ADDR + 1))-1 : 0] i_fifo_occupants,
    output [COL-1 : 0] o_fifo_read_enable,
    output o_sel
);

localparam S_ROW = ROW[8:0];

reg [2:0] state = 0;
reg [4:0] counter = 0;
reg sel = 1;
reg [COL-1 : 0] rden = 0;

wire w_start;
one_cycle start_pulse (
    .a(i_start),
    .rst(i_rst),
    .clk(i_clk),
    .b(w_start)
);

assign o_fifo_read_enable = rden;
assign o_sel = sel;

always @(posedge i_clk) begin
    if(i_rst)begin
        state <= 0;
        rden <= 0;
        sel <= 1;
    end else begin
        case (state)
            0:begin
                if(w_start)begin
                    state <= 1;
                    rden <= 0;
                    sel <= 1'b1;
                end
            end 

            1: begin
                if(i_sel_1)begin
                    if((i_fifo_empty == 0) && (i_fifo_occupants >= {COL{S_ROW}}))begin
                        rden <= {COL{1'b1}};
                        state <= 2;
                    end
                end
            end

            2: begin
                if(counter == ROW-1)begin
                    state <= 3;
                    counter <= 0;
                    rden <= 0;
                    sel <= sel;
                end else begin
                    counter <= counter + 1;
                end
            end

            3: begin
                if(i_done)begin
                    state <= 4;
                    sel <= ~sel;
                end
            end

            4: begin
                if(i_layer_done)begin
                    state <= 0;
                    sel <= 1'b1;
                end else begin
                    state <= 1;
                    sel <= sel;
                end
            end

            default: state <= 0;
        endcase
    end
end

    
endmodule


// //Load weights from internal north fifo array into pe grid
// module internal_north_rden#(
//    parameter COL = 1,
//    parameter ROW = 9,
//    parameter W_ADDR = 8,
//    parameter W_DATA = 8
// ) (
//    input i_clk,
//    input i_rst,
//    input i_trigger,
//    input i_sel1,
//    input [COL-1:0] i_fifo_empty,
//    output [COL-1:0] o_fifo_read_enable,
//    input [((W_ADDR + 1) * COL)-1 : 0] i_fifo_occupants,
//    output o_sel2
// );
// localparam S_ROW = ROW[8:0];
// wire w_trigger;

// one_cycle one_pulse (
//     .a(i_trigger),
//     .rst(i_rst),
//     .clk(i_clk),
//     .b(w_trigger)
// );

// reg [COL-1:0] rden = 0;
// reg [2:0] state = 0;
// reg sel = 0;
// reg sel2 = 1;
// reg [($clog2(COL * 32)) : 0] counter = 0;
// reg [((W_ADDR+1) * COL) -1 : 0] replicated_value = 0;

// assign o_fifo_read_enable = rden;
// assign o_sel2 = sel2;

// //Occupants of each fifo for all columns should be atleast equal to the number of rows
// always @(*)begin
//     replicated_value <= {COL{S_ROW}};
// end

// always @(posedge i_clk)begin
//     if(i_rst)begin
//         rden <= 0;
//         state <= 0;
//         counter <= 0;
//         sel2 <= 0;
//     end else begin
//         case(state)
//             0: begin
//                 if(w_trigger & i_sel1)begin
//                     sel2 <= ~sel2;
//                     state <= 1;
//                 end
//             end

//             1: begin
//                 // if(w_trigger & i_sel1) begin
//                     if(i_fifo_empty == 0)begin
//                         if(i_fifo_occupants >= replicated_value) begin
//                             rden <= {COL{1'd1}}; 
//                             state <= 2;
//                             // sel2 <= ~sel2;
//                         end
//                     end
//                 // end 
//             end    

//             2: begin
//                 if(counter == (ROW-1))begin
//                     rden <= 0;
//                     counter <= 0;
//                     sel2 <= sel2;
//                     state <= 1;
//                 end 
//                 else 
//                 begin
//                     counter <= counter + 1;
//                 end
//             end

//             default : begin
//                 state <= 0;
//             end
//         endcase
//     end
// end
// endmodule