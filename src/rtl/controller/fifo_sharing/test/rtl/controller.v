module controller (
    input i_clk,
    input i_rst,
    input [3:0] i_opcode,
    // input i_layer_iteration, //1 -> Conv done, 0 -> Conv incomplete
    output o_sel1
    // output o_sel2
);

reg sel1 = 0;   //Either send 32 fifo data into SA or FC
// reg sel2 = 0;   //Which set of 16 fifo to be accessed by SA block, if 0-> set1, 1 -> set2
assign o_sel1 = sel1;
// assign o_sel2 = sel2;
always @(posedge i_clk)begin
    if(i_rst)begin
        sel1 <= 0;
        // sel2 <= 0;    
    end else begin
        if(i_opcode == 4'b1111)begin    //For convolution layer
            sel1 <= 1'b1;
            // if(i_layer_iteration)begin  //Convolution done for this layer
            //     sel2 <= ~sel2;
            // end else begin
            //     sel2 <= sel2;
            // end
        end
        else if (i_opcode == 4'b0000)begin  //For fully connected layer
            sel1 <= 1'b0;
        end
    end
end
    
endmodule