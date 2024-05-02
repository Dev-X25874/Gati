module dram_controller(
    input clkin,
    //input [255:0]instruction_data,
    //input instruction_valid,
    input [31:0]i_acc_address,
    input [31:0]i_op_start,
    input [11:0]i_channel_itr,
    input [11:0]i_kernel_itr,
    input [15:0]i_imag_dim,
    input slave_valid,
    input [79:0]occupants,
    input memory_acknowledgement,
    output reg [31:0]acc_address,
    output reg [31:0] op_start_add1,
    output reg acc_address_valid,
    output reg op_valid_1,
    output reg memory_request,
    output [10:0]o_burst_length,
    output o_image_done,//only for testing
    output reg fifo_read
  );

  reg [11:0]channel_itr=0;
  reg [11:0]kernel_itr=0;
  reg [11:0]AXI_DATA_BYTES=32;
  reg [15:0]imag_dim=0;
  reg [15:0]imag_dim_init=0;
  reg [31:0]acc_address_init=0;
  reg [4:0]case_1_output=0;
  reg [4:0]case_2_acc=0;
  reg [4:0]case_2_output=0;
  reg [4:0]imag_dim_case=0;
  reg flag=1;
  reg image_done=0;

  reg [9:0]kernel_count=0;
  reg [9:0]channel_count=0;
  reg [9:0]offset_acc=0;
  reg [9:0]offset_op=0;
  reg [3:0]top_state=0;

  //reg [31:0]acc_address=0;
  reg [10:0]burst_length=16;
  always@(posedge clkin)
  begin
    //acc_address_valid<=0;//keeping it for later
    case(top_state)
      4'd0:
      begin
        kernel_count<=0;
        channel_count<=0;
        acc_address_valid<=0;
        op_valid_1<=0;
        fifo_read<=0;

        if(slave_valid)
        begin
          //if(instruction_data[3:0]==3)
          //begin
            acc_address_init <=i_acc_address;
            op_start_add1 <=i_op_start;
            channel_itr <=i_channel_itr;
            kernel_itr <=i_kernel_itr;
            imag_dim_init<=i_imag_dim;
            top_state<=4'd1;
          //end
        end
      end
      4'd1:
      begin
        imag_dim<=imag_dim_init;
        top_state<=4'd2;
      end
      4'd2:
      begin
        if(channel_itr<2)
        begin
          if(kernel_count<=(kernel_itr-1))
          begin
            case(case_1_output)
              5'd0:
              begin
                burst_length<=16;
                fifo_read<=0;
                if(~image_done)
                begin
                  if((occupants[9:0]>=16)&&(occupants[19:10]>=16)&&(occupants[79:70]>=16)&&(occupants[29:20]>=16)&&(occupants[39:30]>=16)&&(occupants[49:40]>=16)&&(occupants[59:50]>=16)&&(occupants[69:60]>=16))
                  begin
                    case_1_output<=5;
                  end
                  else
                  begin
                    case_1_output<=0;
                  end
                end
                else
                begin
                  case_1_output<=2;
                end
              end
              5'd5:
              begin
                case_1_output<=1;
              end
              5'd1:
              begin
                op_start_add1<=op_start_add1+offset_op;
                imag_dim<=imag_dim-128; //imag_dim<=imag_dim-8;
                case_1_output<=4;
                memory_request<=1;
                fifo_read<=1;
              end
              5'd2:
              begin
                burst_length<=imag_dim>>1;
                case_1_output<=6;
              end
              5'd6:
              begin
                case_1_output<=3;
              end
              5'd3:
              begin
                kernel_count<=kernel_count+1;
                case_1_output<=4;
                op_start_add1<=op_start_add1+offset_op;
                memory_request<=1;
                fifo_read<=1;

              end
              5'd4:
              begin
                memory_request<=0;
                fifo_read<=0;
                if(memory_acknowledgement)
                begin
                  case_1_output<=0;
                  op_valid_1<=1;
                end
                else
                begin
                  case_1_output<=4;
                end

              end
            endcase
          end
          else if(kernel_count>(kernel_itr-1))
          begin
            top_state<=4'd0;
          end
        end
        else
        begin
          if(kernel_count<=(kernel_itr-1))
          begin
            if(channel_count<(channel_itr-1))
            begin
              op_valid_1<=0;
              case_2_output<=0;
              case(case_2_acc)
                5'd0:
                begin
                  burst_length<=16;
                  if(~image_done)
                  begin
                    if((occupants[9:0]>=16)&&(occupants[19:10]>=16)&&(occupants[79:70]>=16)&&(occupants[29:20]>=16)&&(occupants[39:30]>=16)&&(occupants[49:40]>=16)&&(occupants[59:50]>=16)&&(occupants[69:60]>=16))
                    begin
                      case_2_acc<=5;
                    end
                    else
                    begin
                      case_2_acc<=0;
                    end
                  end
                  else
                  begin
                    case_2_acc<=2;
                  end
                  acc_address_valid<=0;
                end
                5'd5:begin
                  case_2_acc<=1;
                end
                5'd1:
                begin
                  if((channel_count==0)&&flag)
                  begin
                    acc_address<=acc_address_init;
                    flag<=0;
                  end
                  else
                  begin
                    acc_address<=acc_address+offset_acc;
                  end
                  case_2_acc<=4;
                  memory_request<=1;
                  fifo_read<=1;
                  acc_address_valid<=1;
                  imag_dim<=imag_dim-32;
                end
                5'd2:
                begin
                  burst_length<=imag_dim>>1;
                  case_2_acc<=6;
                end
                5'd6:begin
                  case_2_acc<=3;
                end
                5'd3:
                begin
                  acc_address<=acc_address+offset_acc>>1;
                  channel_count<=channel_count+1;
                  memory_request<=1;
                  fifo_read<=1;
                  acc_address_valid<=1;
                  case_2_acc<=4;
                  flag<=1;
                end

                5'd4:
                begin
                  memory_request<=0;
                  acc_address_valid<=0;
                  fifo_read<=0;
                  if(memory_acknowledgement)
                  begin
                    case_2_acc<=0;
                    //acc_address_valid<=1;
                  end
                  else
                  begin
                    case_2_acc<=4;
                  end
                end
              endcase
            end
            else if(channel_count==(channel_itr-1))
            begin
              case_2_acc<=0;
              acc_address_valid<=0;
              case(case_2_output)
                5'd0:
                begin
                  burst_length<=16;
                  op_valid_1<=0;
                  if(~image_done)
                  begin
                    if((occupants[9:0]>=16)&&(occupants[19:10]>=16)&&(occupants[79:70]>=16)&&(occupants[29:20]>=16)&&(occupants[39:30]>=16)&&(occupants[49:40]>=16)&&(occupants[59:50]>=16)&&(occupants[69:60]>=16))
                    begin
                      case_2_output<=5;
                    end
                    else
                    begin
                      case_2_output<=0;
                    end
                  end
                  else
                  begin
                    case_2_output<=2;
                  end
                end
                5'd5:begin
                  case_2_output<=1;
                end
                5'd1:
                begin
                  op_start_add1<=op_start_add1+offset_op;
                  case_2_output<=4;
                  memory_request<=1;
                  fifo_read<=1;
                  imag_dim<=imag_dim-128;
                end
                5'd2:
                begin
                  burst_length<=imag_dim>>1;
                  case_2_output<=6;
                end
                5'd6:begin
                  case_2_output<=3;
                end
                5'd3:
                begin
                  channel_count<=0;
                  memory_request<=1;
                  fifo_read<=1;
                  kernel_count<=kernel_count+1;
                  op_start_add1<=op_start_add1+offset_op;
                  op_valid_1<=1;
                  case_2_output<=4;
                end
                5'd4:
                begin
                  memory_request<=0;
                  fifo_read<=0;
                  if(memory_acknowledgement)
                  begin
                    case_2_output<=0;
                    op_valid_1<=1;
                  end
                end
              endcase
            end
          end
          else
          begin
            top_state<=0;
            op_valid_1<=0;
            case_2_output<=0;
            fifo_read<=0;
            memory_request<=0;
            acc_address_valid<=0;
          end
        end
        case(imag_dim_case)
          5'd0:
          begin
            if((case_1_output!=0)||(case_2_output!=0)) //for op address imagdim -8
            begin
              if(imag_dim<128)
              begin
                image_done<=1;
                if((case_1_output==2)||(case_2_output==2))
                begin
                  imag_dim_case<=1;
                end
              end
            end
            else
            begin
              if(imag_dim<32)
              begin
                image_done<=1;
                if((case_2_acc==2)||(case_2_output==2))
                begin
                  imag_dim_case<=1;
                end
              end
            end
          end
          5'd1:
          begin
            image_done<=0;
            imag_dim_case<=0;
            imag_dim<=imag_dim_init;
          end
        endcase

      end
    endcase
    offset_acc<=(burst_length<<$clog2(AXI_DATA_BYTES));
    offset_op<=(burst_length<<$clog2(AXI_DATA_BYTES));
  end
  assign o_burst_length=burst_length;
  assign o_image_done=image_done;
endmodule
