module WR_ID_Manager #(
  parameter NUM_PORTS = 4
) (
    input clk,
    input rst,
    input [7:0] aid,
    input valid,
    input atype,
    input wready,   ///// it is input in the ddr axi side so can i use the 
    input wlast ,
    input [7:0] wid, // Write controller ID
    output reg w_en_ack = 0 ,
    output reg [NUM_PORTS-1 :0] select = 0 ,
   // output reg [7:0] status_reg = 0 ,
    output reg ack = 0 
);

// Define states for FSM using local parameter as it is use only for this design 
localparam IDLE = 2'b00;
localparam STORE_ID = 2'b01;
localparam WAIT_WLAST = 2'b10 ;

reg [1:0] state = 0 ; // FSM state register
//reg [7:0] stored_id = 0; // Store the ID when wready is high for the first time



always @(posedge clk) begin
    if (!rst) begin
        state <= IDLE;
        select <= 4'b0000 ;
     //   status_reg <= 8'h00; 
        ack <= 0 ;
        w_en_ack <= 0 ;
        
    end 
    
    else begin
        // FSM state transitions
        case(state)
            IDLE: begin
                if (valid && atype) begin
                    w_en_ack <= 0 ;
                    state <= STORE_ID;
                     ack <= 0 ;
                    select <= 4'b0000 ;
                end
                else begin 
                    select <= 4'b0000 ;
                    w_en_ack <= 0 ;
                    state <= IDLE ;
                end 
            end
            STORE_ID: begin
                if (wready) begin
                    if ( wid == aid) begin 
                       select <= 1<< wid ;
                        w_en_ack <= 0 ;
                         ack <= 1'b1 ;
                       // status_reg <= wid;
                        state <= WAIT_WLAST;
                     end
                end  
                else begin 
                    select  <= select ;
                    ack  <= 0 ;
                    state <= STORE_ID ;
                end
            end
            
            WAIT_WLAST : begin 
                if (wlast) begin 
                    select  <= select ;
                    ack <= 0 ;
                    w_en_ack <= 1'b1 ;
                    state <= IDLE ; 
                 end 
             
                
                else begin
                    select  <= select ;
                    ack <= 0 ;
                    w_en_ack <= 0 ;
                    state <= WAIT_WLAST ;
                end
            end 
        endcase
    end
end    
 
endmodule