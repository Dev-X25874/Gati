module shift_reg_row #(
    parameter ROW = 9
)(
    input i_clk,
    input i_enable,
    output [ROW-1:0] o_data 
);
    
reg [ROW-1:0] counter = 0;
reg [ROW-1:0] data = 0;
reg [ROW-1:0] data_out = 0;

//always @(posedge i_clk)begin
//    data_out <= data;
//end

assign o_data = data;

always @(posedge i_clk) begin
    if(i_enable) begin
        if (counter == ROW - 1)
            counter <= 0;
        else
            counter <= counter + 1;
            
        data[counter] <= 1;
        
        if (counter == 0)
            data[ROW - 1] <= 0;
        else
            data[counter - 1] <= 0;
    end else begin
        counter <= 0;
        data <= 0;
    end
end
    
endmodule


//module shift_reg_row#(
//    parameter ROW = 9
//)(
//    input i_clk,
//    input i_enable,
//    output [ROW-1:0] o_data 
//);

//reg [ROW-1:0] counter = 0;
//reg [ROW-1:0] data = 0;
//reg [ROW-1:0] data_out = 0;

//assign o_data = data;

//always @(posedge i_clk) begin
//    if(i_enable) begin
//        if (counter == ROW -1)
//            counter <= 0;
//        else
//            counter <= counter + 1;
        
//        data[counter] <= ~data;
       
//        if(ROW > 1) begin
//            if (counter == 0)
//                data[ROW - 1] <= 0;
//            else
//                data[counter - 1] <= 0;
//        end            
//    end else begin
//        counter <= 0;
//        data <= 0;
//    end
//end

//endmodule



//module shift_reg_row#(
//    parameter COL = 1,
//    parameter ROW = 9
//)(
//    input i_clk,
//    input i_enable,
//    output [ROW-1:0] o_write_enable
//);

//reg [ROW-1 : 0] wren = 0;
//reg [7:0] state = 0;
//reg [($clog2(ROW))-1:0] row_counter = 0;
//reg [($clog2(COL))-1 : 0] col_counter = 0;

//assign o_write_enable = wren;

//always @(posedge i_clk)begin
//    if(i_enable)begin
//        if(col_counter == COL)begin
//            wren <= 0;
//            col_counter <= 0;
//        end else begin
//            wren <= ~wren;
//            col_counter <= col_counter + 1;
//        end
//    end else begin
//        wren <= 0;
//        col_counter <= 0;
//    end
//end

//always @(posedge i_clk)begin
//    case(state)
//        0: begin
//            wren <= 0;
//            col_counter <= 0;
//            row_counter <= 0;
//            if(i_enable) begin
//                state <= 1;
//            end
//        end
        
//        1: begin
//            if(col_counter == COL)begin
//                wren <= 0;
//                state <= 0;
//            end else begin
//                wren <= ~wren;
//                col_counter <= col_counter + 1;
//            end
//        end
        
        
////        2: begin
////            if(row_counter == ROW) begin
////                state <= 1;
////                wren <= 0;
////                col_counter <= col_counter + 1;
////            end else begin
////                wren <= ~wren;
////                row_counter <= row_counter + 1;
////            end
////        end
        
//        default : begin
//            state <= 0;
//        end
        
//    endcase
//end

//endmodule