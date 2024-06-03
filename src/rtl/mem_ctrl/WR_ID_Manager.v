module WR_ID_Manager #(
  parameter NUM_PORTS_SEL = 4,
  parameter ID_WIDTH = 8 
) (
    input clk,
    input rst,
    input [ID_WIDTH-1:0] aid,
    input valid,
    input atype,
    input wready, 
    input wlast ,
    output reg wready_out = 0,
    input [ID_WIDTH-1:0] wid, // Write controller ID
    output reg w_en_ack = 0 ,
    output reg [NUM_PORTS_SEL-1 :0] select = 0 ,
    output reg ack = 0 
);

// Define states for FSM using local parameter as it is use only for this design 
localparam IDLE = 2'b00;
localparam STORE_ID = 2'b01;
localparam WAIT_DATAEND = 2'b10 ;

reg [1:0] state = 0 ; // FSM state register
//reg [4:0] count_wr = 0 ;
//reg [7:0] stored_id = 0; // Store the ID when wready is high for the first time



always @(posedge clk) begin
    if (!rst) begin
        state <= IDLE;
        select <= 0  ;
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
                    select <=0 ;
                end
                else begin 
                    select <= 0 ;
                    w_en_ack <= 0 ;
                    state <= IDLE ;
                end 
            end
            STORE_ID: begin
              if (wready) begin
                    if ( wid == aid) begin 
                       select [wid] <= 1'b1 ;
                        w_en_ack <= 0 ;
                         ack <= 1'b1 ;
                        state <= WAIT_DATAEND;
                     end
                end  
                else begin 
                    select  <= select ;
                    ack  <= 0 ;
                    state <= STORE_ID ;
                end
            end
            

          WAIT_DATAEND : begin 

                if (wlast) begin 
                    select  <= 0 ;
                    ack <= 0 ;
                    w_en_ack <= 1'b1 ;
                    state <= IDLE ; 
                 end 
             
                
                else begin
                    select  <= select ;
                    ack <= 0 ;
                    w_en_ack <= 0 ;
                    state <= WAIT_DATAEND ;
                end
            end 
        endcase
    end
end  

always @(*) begin
     wready_out <= wready;
end 

 
endmodule
