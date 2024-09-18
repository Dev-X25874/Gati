`timescale 1ns / 1ps
////////////////////////////////////////////////////////////////////////////////

// Design Name: Im2col
// Module Name: Index to co-ordinate conversion
// Project Name: CNN Acceleration
// Description: The first sub-block of im2col where,
//              -- The input data will be getting its respective coordinate(i.e.
//                 rows and column) 
// Revision 1 --> 12-10-2023 -- The code had few bugs like --  
//                           -- The coordinate wasn't starting from (0,0) i.e. 
//                              (row,column) 
//                           -- The coordinate also wasn't ending at (224,224) 
//                              i.e. (row,column)
//                           -- The bit size during initialization was made 
//                              correct
//                           -- The comparison logic was fixed 
// Revision 2 --> 21-11-2023 -- Additional comments were added
////////////////////////////////////////////////////////////////////////////////


module index_to_coordinate # (parameter UPPER_BOUND = 28,
                              parameter DATA_WIDTH = 8,
                              parameter LOWER_BOUND = 1
                                         
) 
(
    input                                   valid_mat_size,
//    output                                  o_start_im2col_ctrl,
    input                                   i_start_im2col_index,
    input                                   i_valid_data,
    input 									stall_on,
	input                                   clk,
    input [DATA_WIDTH-1:0]                  i_data,
    input                                   rstn,
    input [$clog2(UPPER_BOUND)-1:0]         mat_size,
    input                                   zero_pad,
    output                                  o_valid_buff,
    output                                  o_valid_data,
    output                                 reg  im2col_done,
	 output [$clog2(UPPER_BOUND)-1:0]        row,
    output [$clog2(UPPER_BOUND)-1:0]        col,
    output [$clog2(UPPER_BOUND)-1:0]        o_mat_size,
    output [DATA_WIDTH-1:0]                 o_data
);

    reg [$clog2(UPPER_BOUND)-1:0]           curr_row = LOWER_BOUND;
    reg [$clog2(UPPER_BOUND)-1:0]           curr_col = LOWER_BOUND;
    reg [2:0]                               p_state = 0;
    wire                                    w_valid_data;
    reg                                     r_start_im2col = 0;
    wire                                    w_start_im2col;

    assign row = curr_row;
    assign col = curr_col;
//##############################################################################  
/* - Start the row and column counter (row,col) with (1,1)
   - Increment the column counter by one till 224th column is reached.
   - If column counter reaches to maximum then reset the column counter and 
     increment row counter by one
   - Repeat the above process till both row and column counters reach maximum 
   (i.e., (row,col)=(224,224))*/
//############################################################################## 
	reg                                   r_valid_mat_size;
    reg                                   r_i_start_im2col_index;
    reg                                   r_i_valid_data;
    reg [DATA_WIDTH-1:0]                  r_i_data;
    reg [$clog2(UPPER_BOUND)-1:0]         r_mat_size;
    reg                                   r_zero_pad;



	always @(posedge clk) begin 

	r_valid_mat_size<=valid_mat_size;
	r_i_start_im2col_index<=i_start_im2col_index;
	r_i_valid_data<=i_valid_data;
	r_i_data<=i_data;
	r_mat_size<=mat_size;
	r_zero_pad<=zero_pad;
	end

    always @(posedge clk) begin
        if(!rstn) begin
            curr_col <= 0;
            curr_row <= 0;
        end 
        else begin
            if(~stall_on) begin
                if (r_start_im2col | r_i_valid_data) begin
                    if (curr_row == o_mat_size && curr_col == o_mat_size) begin
                        curr_row <= LOWER_BOUND;
                        curr_col <= LOWER_BOUND;
                    end
                    else if (curr_col == o_mat_size) begin 
                        curr_col <= LOWER_BOUND;       /*curr_col is assigned to 0 if the curr_col exceeds the UPPER_BOUND */
                        curr_row <= curr_row + 1;      /* meanwhile the curr_row is incremented and goes to the next row*/
                    end else if (curr_col >= 1 && curr_col <= o_mat_size) begin
                        curr_col <= curr_col + 1;       /*curr_col is incremented and goes to the next col */
                        curr_row <= curr_row;
                    end 
                    else begin
                        curr_row <= LOWER_BOUND;
                        curr_col <= LOWER_BOUND;
                    end     
                end 
                else begin
                    curr_row <= curr_row;
                    curr_col <= curr_col;
                end
            end
        end
	end
   
	reg flag=0;
    always @(posedge clk) begin
        if (r_i_start_im2col_index) begin
            r_start_im2col <= 1'b1;
		    flag<=1;  
	    end
	    else if (curr_row == o_mat_size && curr_col == o_mat_size) begin
		  if(flag) begin 
		  	im2col_done<=1;
			flag<=0;
		  end
          r_start_im2col <= 1'b0;
		  end
	    else begin 
			im2col_done<=0;
        end
    end
    
    assign o_valid_buff = r_start_im2col? (r_zero_pad ? ((((curr_row == 1)&&(curr_col == 1)) 
            | ((curr_row == o_mat_size)&&(curr_col == o_mat_size)) 
            | (curr_row == o_mat_size)|(curr_row == 1) 
            | (curr_col == o_mat_size - 1) 
            | (curr_col == o_mat_size)
			| ((curr_row==0)&&(curr_col==0))) ? 0 : 1) : 1):0;
    
    

    assign  {o_valid_data,o_data} = r_start_im2col? (r_zero_pad ? (((curr_row == LOWER_BOUND) 
            && (curr_col>=LOWER_BOUND) && (curr_col<=o_mat_size)) ?{1'd1,8'd0} :
            ((curr_row == o_mat_size) && (curr_col>=LOWER_BOUND) && (curr_col<=o_mat_size)) ? {1'd1,8'd0} :
            ((curr_col == LOWER_BOUND) && (curr_row>=LOWER_BOUND) && (curr_row<=o_mat_size)) ? {1'd1,8'd0} :
            ((curr_col == o_mat_size) && (curr_row>=LOWER_BOUND) && (curr_row<=o_mat_size)) ? {1'd1,8'd0} : 
            {r_i_valid_data,r_i_data}) : {r_i_valid_data,r_i_data}) : {r_i_valid_data,r_i_data};              

    assign o_mat_size = r_start_im2col? (r_valid_mat_size ?(r_zero_pad ? r_mat_size + 2 : r_mat_size) : 0) : 0; 

//	always @ (posedge clk) begin 
//	    im2col_done <= (curr_col == o_mat_size && curr_row == o_mat_size)? 1'b1 : 1'b0;
//	end

endmodule



