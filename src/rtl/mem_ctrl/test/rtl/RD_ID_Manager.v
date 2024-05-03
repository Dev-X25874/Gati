module RD_ID_Manager (
    input clk,
    input rst,
    input valid,
    input [7:0] id_rd_in,
    input atype,
    input rvalid,
    input rlast,
    input [7:0] rid,
    output reg r_en_ack = 0,
    output reg [3:0] select_rd = 4'b0000,
  //  output reg [7:0] status_rd_reg = 8'h00,
    output reg ack_rd = 0 
);

// FIFO parameters
parameter FIFO_DEPTH = 4; 
localparam IDLE = 2'b00 ;
localparam STORED_RD_ID = 2'b01 ;

reg [1:0] state = 0 ;
// FIFO storage and pointers
//reg [7:0] fifo[FIFO_DEPTH-1 :0];
reg [2:0] rd_ptr = 3'b000;
reg [2:0] wr_ptr = 3'b000;
reg [7:0] stored_rd_id = 0 ;
reg [7:0] current_sent = 0 ;

// Default assignments
//assign status_rd_reg = fifo[rd_ptr];
//assign ack_rd = 1'b0;

// Write operation
always @(posedge clk) begin 

    if (!rst) begin 
        wr_ptr <= 0 ;
        rd_ptr <= 0 ;
        r_en_ack <= 0 ;
        state <= IDLE ;
    end 
    
    else  begin 
        case (state) 
            IDLE : begin 
                
               if (valid && !atype) begin
                    r_en_ack <= 0 ;
                    current_sent <= id_rd_in ;
                    state <= STORED_RD_ID ;
                  /*  wr_ptr <= (wr_ptr == FIFO_DEPTH - 1) ? 3'b000 : wr_ptr + 1;
                    fifo[wr_ptr] <= id_rd_in;
                   
                    state <= STORED_RD_ID ;*/
                end 
                
                else begin
                    r_en_ack <= 0 ;
                    current_sent <= current_sent ;
                    state <= IDLE ;
               end 
            end 
            
            STORED_RD_ID : begin 
                if (rvalid ) begin 
                    stored_rd_id <= rid;
                    r_en_ack <= 1'b1 ;
                   // status_rd_reg = fifo[rd_ptr] ;
                   // rd_ptr <= (rd_ptr == FIFO_DEPTH - 1) ? 3'b000 : rd_ptr + 1 ;
                    state <= IDLE ;
                end 
                
                else  begin
                    stored_rd_id <= stored_rd_id;
                    r_en_ack <= 0 ;
                    state <= STORED_RD_ID ;
                end
            end 
        endcase
    end
end 

always @ (posedge clk) begin 
    if (!rst) begin 
        select_rd <=4'b0000 ;
        ack_rd <= 1'b0 ;
    end
    else begin 
        if ((current_sent == rid) && rvalid)  begin
         //   select_rd <= 1 << status_rd_reg ;
            select_rd <= 1 << current_sent ;
            ack_rd <= 1'b1 ;
        end 
        
        else if ((current_sent == rid) && rvalid && rlast ) begin 
            select_rd  <= 0;
            ack_rd <= 0 ;
        end 
        
        else begin 
            select_rd <= select_rd ;
            ack_rd <= ack_rd ;
        end 
    end 
end 
endmodule
