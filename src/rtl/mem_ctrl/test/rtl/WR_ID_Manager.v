///////////////////////////////////////////////////////////////////////////////
module WR_ID_Manager #(
  parameter NUM_PORTS = 4
) (
    input clk,
    input rst,
    input valid,
    input [7:0] id_in,
    input atype,
    input wready,   ///// it is input in the ddr axi side so can i use the 
    input wlast ,
    input [7:0] wid, // Write controller ID
    output reg [NUM_PORTS-1 :0] select = 0 ,
    output reg [7:0] status_reg = 0 ,
    output reg ack = 0 
);

// Define states for FSM using local parameter as it is use only for this design 
localparam IDLE = 2'b00;
localparam STORE_ID = 2'b01;
localparam WAIT_WLAST = 2'b10 ;

reg [1:0] state = 0 ; // FSM state register
reg [7:0] id_reg = 0; // Register to store the ID when valid and atype are high
reg [7:0] stored_id = 0; // Store the ID when wready is high for the first time

// Default assignments
//assign status_reg = 8'h00;
//assign ack = 1'b0;

always @(posedge clk) begin
    if (!rst) begin
        state <= IDLE;
        id_reg <= 8'h00;
        stored_id <= 8'h00; 
        
    end 
    
    else begin
        // FSM state transitions
        case(state)
            IDLE: begin
                if (valid && atype) begin
                    id_reg <= id_in ;
                    state <= STORE_ID;
                end
                else 
                    state <= IDLE ;
            end
            STORE_ID: begin
                if (wready) begin
                    stored_id <= wid;
                    state <= WAIT_WLAST;
                end  
                else  
                    state <= STORE_ID ;
            end
            
            WAIT_WLAST : begin 
                if (wlast) begin 
                        state <= IDLE ; 
                 end 
                end 
                
                else begin 
                    state <= WAIT_WLAST ;
                end 
        endcase
    end
end    
 
    always @ (posedge clk) begin 
        if (!rst) begin 
            select <= 4'b0000 ;
            ack <= 0 ;
        end 
        
        else  begin
            if (stored_id == wid && wready) begin 
                select[stored_id] <= 1'b1 ;
                status_reg <= wid ;
                ack <= 1'b1 ;
            end 
            
            else begin
                select <= select ;
                ack <= ack ; 
            end 
       end     
    end

endmodule

/////////////////////////////////////////////////////////////////////////////////////////////////////////
