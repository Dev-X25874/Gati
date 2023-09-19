/*
    Array of fifo that stores output of all the rows of systolic array
    simultaneously.
*/
module o_row_fifo_array#(
    parameter ROW = 9,
    parameter COL = 3,
    parameter W_DATA = 8
)(  input i_clk,
    input [(ROW * 9) -1 : 0] i_data,
    input [ROW-1:0] i_read_enable,
    output [W_DATA -1 : 0] o_data_1,
    output [W_DATA -1 : 0] o_data_2,
    output [W_DATA -1 : 0] o_data_3,
    output [W_DATA -1 : 0] o_data_4,
    output [W_DATA -1 : 0] o_data_5,
    output [W_DATA -1 : 0] o_data_6,
    output [W_DATA -1 : 0] o_data_7,
    output [W_DATA -1 : 0] o_data_8,
    output [W_DATA -1 : 0] o_data_9,
    output [ROW-1:0] o_empty,
    output dv1,
    output dv2,
    output dv3,
    output dv4,
    output dv5,
    output dv6,
    output dv7,
    output dv8,
    output dv9
);
    
wire [W_DATA-1 :0] i_data1;
wire [W_DATA-1 :0] i_data2;
wire [W_DATA-1 :0] i_data3;
wire [W_DATA-1 :0] i_data4;
wire [W_DATA-1 :0] i_data5;
wire [W_DATA-1 :0] i_data6;
wire [W_DATA-1 :0] i_data7;
wire [W_DATA-1 :0] i_data8;
wire [W_DATA-1 :0] i_data9;

wire wren1;
wire wren2;
wire wren3;
wire wren4;
wire wren5;
wire wren6;
wire wren7;
wire wren8;
wire wren9;

assign i_data1 = i_data[79:72];
assign i_data2 = i_data[70:63];
assign i_data3 = i_data[61:54];
assign i_data4 = i_data[52:45];
assign i_data5 = i_data[43:36];
assign i_data6 = i_data[34:27];
assign i_data7 = i_data[25:18];
assign i_data8 = i_data[16:9]; 
assign i_data9 = i_data[7:0];  


 assign wren1 = i_data[80];
 assign wren2 = i_data[71];
 assign wren3 = i_data[62];
 assign wren4 = i_data[53];
 assign wren5 = i_data[44];
 assign wren6 = i_data[35];
 assign wren7 = i_data[26];
 assign wren8 = i_data[17];
 assign wren9 = i_data[8];
 
wire empty1;
wire empty2;    
wire empty3;
wire empty4;
wire empty5;
wire empty6;
wire empty7;
wire empty8;
wire empty9;

assign o_empty = {empty1, empty2, empty3,
                  empty4, empty5, empty6,
                  empty7, empty8, empty9};

 
 genvar i;
 generate
    for(i = 0 ; i < ROW; i = i +1)begin : ROW_DATA_OUT        
        if(i == 0) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data1),
                .we(wren1),
                .re(i_read_enable[0]),
                .data_out(o_data_1),
                .occupants(),
                .empty(empty1),
                .full(),
                .data_valid(dv1)
            );
        end
        
        else if(i == 1) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data2),
                .we(wren2),
                .re(i_read_enable[1]),
                .data_out(o_data_2),
                .occupants(),
                .empty(empty2),
                .full(),
                .data_valid(dv2)
            );                
        end
        
        else if(i == 2) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data3),
                .we(wren3),
                .re(i_read_enable[2]),
                .data_out(o_data_3),
                .occupants(),
                .empty(empty3),
                .full(),
                .data_valid(dv3)
            );            
        end
        
        else if (i == 3) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data4),
                .we(wren4),
                .re(i_read_enable[3]),
                .data_out(o_data_4),
                .occupants(),
                .empty(empty4),
                .full(),
                .data_valid(dv4)
            );            
        end
        
        else if(i == 4) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data5),
                .we(wren5),
                .re(i_read_enable[4]),
                .data_out(o_data_5),
                .occupants(),
                .empty(empty5),
                .full(),
                .data_valid(dv5)
            );                
        end
        
        else if(i == 5) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data6),
                .we(wren6),
                .re(i_read_enable[5]),
                .data_out(o_data_6),
                .occupants(),
                .empty(empty6),
                .full(),
                .data_valid(dv6)
            );            
        end
        
        else if(i == 6) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data7),
                .we(wren7),
                .re(i_read_enable[6]),
                .data_out(o_data_7),
                .occupants(),
                .empty(empty7),
                .full(),
                .data_valid(dv7)
            );                
        end
        
        else if( i == 7) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data8),
                .we(wren8),
                .re(i_read_enable[7]),
                .data_out(o_data_8),
                .occupants(),
                .empty(empty8),
                .full(),
                .data_valid(dv8)
            );            
        end
        
        else if (i == 8) begin
            fifo_valid 
            fifo_inst (
                .clk (i_clk),
                .rst_n (1'b1),
                .data_in (i_data9),
                .we(wren9),
                .re(i_read_enable[8]),
                .data_out(o_data_9),
                .occupants(),
                .empty(empty9),
                .full(),
                .data_valid(dv9)
            );            
        end
    end       
 endgenerate
endmodule