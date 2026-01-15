`include "../common/instructions.vh"
`include "../common/arch_param.vh"

module Tail_done_gen#(
    parameter N = 4,
    parameter I_ACC_SIZE_WIDTH = 16,
    parameter I_OP_SIZE_WIDTH =16,
    parameter OPCODE_WIDTH = 4
)
(
    input i_clk,
    input rst,
    input [OPCODE_WIDTH-1:0]opcode,
    input [N -1:0] datavalid_acc,
    input [N -1:0] datavalid_pool,
    input quant_en, 
    input [I_ACC_SIZE_WIDTH-1:0] img_dim_Acc,
    input [I_OP_SIZE_WIDTH-1:0] img_dim_Op,

    output Tail_done
);

localparam I_SIZE_WIDTH = (I_ACC_SIZE_WIDTH > I_OP_SIZE_WIDTH) ? I_ACC_SIZE_WIDTH : I_OP_SIZE_WIDTH;

reg [I_SIZE_WIDTH-1:0] data_count;
//assign data_count = (pool_en==0)? img_dim_Acc : img_dim_Op;

reg [I_SIZE_WIDTH : 0] counter;
reg state;
reg r_tail_done;


always @(posedge i_clk) begin
    case (opcode)
        `OP_CONV: begin
            if (~quant_en) begin
        	    data_count<=img_dim_Acc;
        	end
        	else begin 
        	    data_count<=img_dim_Op;
        	end
        end
        `ifdef MEGA_POOL
        `OP_POOL: begin
            data_count<=img_dim_Op;
        end
        `endif
        `OP_FC: begin
            data_count<=img_dim_Op;
        end
        `OP_EltWise: begin
            data_count<=img_dim_Op;
        end
    endcase
end
always@(posedge i_clk) begin
    if(!rst) begin
        r_tail_done <= 0;
        counter <= 0;
        state <= 0;
    end
    else begin
        case(state)
            0:begin
                r_tail_done <= 1'b0;
                if((datavalid_acc=={N{1'b1}})  || (datavalid_pool=={N{1'b1}})) begin
                    state <= 1;
                    counter <= counter;
                end
                else begin
                    state <= 0;
                    counter <= counter;
                end
            end
            1: begin
                if(counter == (data_count-1)) begin
                    counter     <= 0;
                    state       <= 0;
                    r_tail_done <= 1'b1;
                end
                else if((datavalid_acc=={N{1'b1}}) || (datavalid_pool=={N{1'b1}})) begin
                    counter     <= counter + 1;
                    state       <= 1;
                    r_tail_done <= 1'b0;
                end
                else begin
                    counter     <= counter;
                    state       <= 1;
                    r_tail_done <= 1'b0;
                end
            end
        endcase
        
    end
end

assign Tail_done = r_tail_done;

endmodule
