module WR_ID_Manager #(
  parameter NUM_PORTS_SEL = 4,
  parameter ID_WIDTH = 8 ,
  parameter PORT_ID_WIDTH = 4,
  parameter BURST_LEN_WIDTH = 8
) (
    input clk,
    input rst,
    input [ID_WIDTH-1:0] aid,
    input [BURST_LEN_WIDTH-1:0] wr_blen,
    input valid,
    input atype,
    input wready, 
    input wlast ,
    output reg wready_out = 0,
    input [ID_WIDTH-1:0] wid, // Write controller ID
    output w_en_ack,
    output reg [NUM_PORTS_SEL-1 :0] select = 0 ,
    output reg ack = 0 
);

// Define states for FSM using local parameter as it is use only for this design 
localparam IDLE = 2'b00;
localparam STORE_ID = 2'b01;
localparam WAIT_DATAEND = 2'b10 ;

reg [1:0] state = 0 ; // FSM state register
reg [BURST_LEN_WIDTH:0] count_wr = 0 ;
//reg [7:0] stored_id = 0; // Store the ID when wready is high for the first time

reg w_en_ack_reg;

always @(posedge clk) begin
    if (!rst) begin
        state <= IDLE;
        select <= 0  ;
        ack <= 0 ;
        count_wr <= 0 ;
        w_en_ack_reg <= 0;
    end 
    
    else begin
        // FSM state transitions
        case(state)
            IDLE: begin
                if (valid && atype) begin
                    state <= STORE_ID;
                    w_en_ack_reg <= 0 ;
                    select <=0 ;
                    count_wr <= 0;
                end
                else begin
                    select <= 0 ;
                    w_en_ack_reg <= 0 ;
                    state <= IDLE ;
                    count_wr <= 0;
                end 
            end
            STORE_ID: begin
              if (wready) begin
                if (wid == aid) begin 
                    select[wid[PORT_ID_WIDTH-1:0]] <= 1'b1 ;
                    w_en_ack_reg <= 0 ;
                    ack <= 1'b1 ;
                    if(wr_blen>15) begin
                        count_wr <= wr_blen - 8;
                    end
                    state <= WAIT_DATAEND;
                end
                end  
                else begin 
                    select  <= select ;
                    ack  <= 0 ;
                    w_en_ack_reg <= 0;
                    state <= STORE_ID ;
                end
            end            

            WAIT_DATAEND : begin 
                // if(count_wr==0) begin
                //     count_wr <= 0;
                //     w_en_ack_reg <= 1;
                // end
                // else begin
                //     if(wready) count_wr <= count_wr-1;
                // end

                if (wlast) begin 
                    select  <= 0 ;
                    ack <= 0 ;
                    w_en_ack_reg <= 1'b1 ;
                    state <= IDLE ; 
                end 
             
                else begin
                    select  <= select ;
                    ack <= 0 ;
                    w_en_ack_reg <= 0 ;
                    state <= WAIT_DATAEND ;
                end
            end 
        endcase
    end
end  

always @(*) begin
    wready_out = wready;
end 

assign w_en_ack = w_en_ack_reg;

/*
pulse_gen one_pulse_inst
(
    .clk(clk),
    .i_rstn(rst),
    .a(w_en_ack_reg),
    .b(w_en_ack)
);
*/ 
endmodule
