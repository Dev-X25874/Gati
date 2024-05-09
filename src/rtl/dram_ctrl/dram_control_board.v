module dram_controller#(parameter N = 8,
                          parameter  DEPTH=512 ,
                          parameter BURST_LENGTH = 15,
                          parameter BURST_LENGTH_2 =15,//For outputs
                          parameter BURST_LEN_WIDTH = 8,
                          parameter  NUMBER_ACC=2 ,
                          parameter NUMBER_OP=8,
                          //parameter NUM_SA = 4,
                          //parameter DATA_BUS_WIDTH = 256,
                          //parameter OUTPUT_WIDTH = 8,
                          //parameter ACC_WIDTH = 32,
                          parameter IMAG_DIM_OUTPUT = NUMBER_OP*(BURST_LENGTH_2+1),
                          parameter IMAG_DIM_ACC = NUMBER_ACC*(BURST_LENGTH+1),
                          parameter AXI_DATA_BYTES=32)
  (
    input clkin,
    //input [255:0]instruction_data,
    //input instruction_valid,
    input [31:0]i_acc_address,
    input [31:0]i_op_start,
    input [11:0]i_channel_itr,
    input [11:0]i_kernel_itr,
    input [15:0]i_imag_dim,
    input [15:0]i_imag_dim_2,
    input slave_valid,
    input [N*($clog2(DEPTH)+1)-1:0]occupants,
    //input memory_acknowledgement,
    input last,
    output reg [31:0]acc_address,
    output reg [31:0] op_start_add1,
    output reg acc_address_valid,
    output reg op_valid_1,
    output reg memory_request,
    output [7:0]o_burst_length,
    output [7:0]o_burst_length_2,
    output o_image_done,
    output o_image_done_2//only for testing
    //output reg fifo_read
  );

  reg [11:0]channel_itr=0;
  reg [11:0]kernel_itr=0;
  //reg [11:0]AXI_DATA_BYTES=32;
  reg [15:0]imag_dim=0;
  reg [15:0]imag_dim_2=0;
  reg [15:0]imag_dim_init=0;
  reg [15:0]imag_dim_init_2=0;
  reg [31:0]acc_address_init=0;
  reg [2:0]case_1_output=0;
  reg [2:0]case_2_acc=0;
  reg [2:0]case_2_output=0;
  reg [2:0]imag_dim_case=0;
  reg [2:0]imag_dim_case_2=0;
  reg flag=1;
  reg image_done=0;
  reg image_done_2=0;
  reg flag_2=0;
  reg flag_3=0;
  reg flag_4=1;

  reg [11:0]kernel_count=0;
  reg [11:0]channel_count=0;
  reg [9:0]offset_acc=0;
  reg [9:0]offset_op=0;
  reg [3:0]top_state=0;
  wire result_int;
  wire result_int_2;
  //reg [31:0]acc_address=0;
  reg [BURST_LEN_WIDTH-1:0]burst_length=BURST_LENGTH+1;
  reg [BURST_LEN_WIDTH-1:0]burst_length_2=BURST_LENGTH_2+1;


  /*  CompareFifoOccupants result_gen(
                          .occupants(occupants),
                          .result(result_int)
                        ); */

  assign result_int = (occupants>=({N{burst_length}}))?1:0;
  assign result_int_2 = (occupants>=({N{burst_length_2}}))?1:0;
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
        //fifo_read<=0;

        if(slave_valid)
        begin
          //if(instruction_data[3:0]==3)
          //begin
          acc_address_init <=i_acc_address;
          op_start_add1 <=i_op_start;
          channel_itr <=i_channel_itr;
          kernel_itr <=i_kernel_itr;
          imag_dim_init<=i_imag_dim;
          imag_dim_init_2<=i_imag_dim_2;
          top_state<=4'd1;
          //end
        end
      end
      4'd1:
      begin
        imag_dim<=imag_dim_init;
        imag_dim_2<=imag_dim_init_2;
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
                burst_length_2<=BURST_LENGTH_2+1;
                //fifo_read<=0;
                // image_done
                if(~image_done_2)
                begin
                  if(result_int)
                  begin
                    case_1_output<=1;//chnge to 1
                  end
                  else
                  begin
                    case_1_output<=0; //sme
                  end
                end
                else
                begin
                  case_1_output<=3; //3
                end
              end
              5'd1://1
              begin
                case_1_output<=2; //chnge to 2
              end
              5'd2: //2
              begin
                op_start_add1<=op_start_add1+offset_op;
                imag_dim_2<=imag_dim_2-IMAG_DIM_OUTPUT; //imag_dim<=imag_dim-8;
                case_1_output<=6; //6
                memory_request<=1;
                //fifo_read<=1;
              end
              5'd3: //3
              begin
                burst_length_2<=(imag_dim_2>>$clog2(NUMBER_OP));
                case_1_output<=4; //4
              end
              5'd4:  //4
              begin

                if(burst_length_2==0)
                begin
                  case_1_output<=0;
                end
                else
                  case_1_output<=5;
              end
              5'd5: //5
              begin
                kernel_count<=kernel_count+1;
                case_1_output<=6; //6
                op_start_add1<=op_start_add1+offset_op;
                memory_request<=1;
                //fifo_read<=1;

              end
              5'd6: //6
              begin
                memory_request<=0;
                //fifo_read<=0;
                if(last)
                begin
                  case_1_output<=0; //0
                  op_valid_1<=1;
                end
                else
                begin
                  case_1_output<=6; //6
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
                  burst_length<=BURST_LENGTH+1;
                  if(~image_done)
                  begin
                    if(result_int)
                    begin
                      case_2_acc<=1;//1
                    end
                    else
                    begin
                      case_2_acc<=0;//0
                    end
                  end
                  else
                  begin
                    case_2_acc<=3;//3
                  end
                  acc_address_valid<=0;
                end
                5'd1://1
                begin
                  case_2_acc<=2;

                end
                5'd2://2
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
                  case_2_acc<=6;
                  memory_request<=1;
                  //fifo_read<=1;
                  acc_address_valid<=1;
                  imag_dim<=imag_dim-IMAG_DIM_ACC;
                end
                5'd3://3
                begin
                  acc_address<=acc_address+offset_acc;
                  case_2_acc<=4;
                  memory_request<=1;
                  acc_address_valid<=1;
                end
                5'd4://4
                begin
                  burst_length<=(imag_dim>>$clog2(NUMBER_ACC));
                  case_2_acc<=5;
                  memory_request<=0;
                  acc_address_valid<=0;
                  //offset_acc<=((burst_length)<<$clog2(AXI_DATA_BYTES));

                end
                5'd5://5
                begin
                  if(burst_length==0)
                  begin
                    case_2_acc<=0;
                    channel_count<=channel_count+1;
                    flag<=1;
                    acc_address_valid<=0;
                  end
                  else
                  begin
                    if(last)
                    begin
                      acc_address<=acc_address+offset_acc;
                      memory_request<=1;
                      //fifo_read<=1;
                      acc_address_valid<=1;
                      case_2_acc<=6;
                      flag<=1;
                      flag_2<=1;
                    end
                  end
                end

                5'd6://6
                begin
                  memory_request<=0;
                  acc_address_valid<=0;
                  //fifo_read<=0;
                  if(last && flag_2)
                  begin
                    channel_count<=channel_count+1;
                    flag_2<=0;
                  end
                  if(last)
                  begin
                    case_2_acc<=0;
                    //acc_address_valid<=1;
                  end
                  else
                  begin
                    case_2_acc<=6;
                  end
                end
              endcase
            end
            else if(channel_count==(channel_itr-1))
            begin
              case_2_acc<=0;
              acc_address_valid<=0;//idk i removed this before but idk why
              case(case_2_output)
                5'd0:
                begin
                  burst_length_2<=BURST_LENGTH_2+1;
                  op_valid_1<=0;
                  if(~image_done_2)
                  begin
                    if(result_int_2)
                    begin
                      case_2_output<=1;
                    end
                    else
                    begin
                      case_2_output<=0;
                    end
                  end
                  else
                  begin
                    case_2_output<=3;
                    burst_length_2<=(imag_dim_2>>$clog2(NUMBER_OP));
                  end
                end
                5'd1://1
                begin
                  case_2_output<=2;
                  //offset_op<=((burst_length_2)<<$clog2(AXI_DATA_BYTES));
                end
                5'd2://2
                begin
                  if(flag_4)begin
                    op_start_add1<=op_start_add1;
                    flag_4<=0;
                  end
                  else begin
                  op_start_add1<=op_start_add1+offset_op;
                  end
                  case_2_output<=6;
                  memory_request<=1;
                  op_valid_1<=1;
                  //fifo_read<=1;
                  imag_dim_2<=imag_dim_2-IMAG_DIM_OUTPUT;
                end
                5'd3://3
                begin
                  if(burst_length_2==0)
                  begin
                    case_2_output<=0;
                    kernel_count<=kernel_count+1;
                    op_valid_1<=0;
                  end
                  //burst_length_2<=(imag_dim_2>>$clog2(NUMBER_OP));
                  if(flag_4)begin
                    op_start_add1<=op_start_add1;
                  end
                  else begin
                  op_start_add1<=op_start_add1+offset_op;
                  end
                  case_2_output<=4;
                  memory_request<=1;
                  op_valid_1<=1;
                end
                5'd4://4
                begin
                  case_2_output<=5;
                  memory_request<=0;
                  op_valid_1<=0;


                end
                5'd5://5
                begin
                    if(last)begin
                    case_2_output<=0;
                    kernel_count<=kernel_count+1;
                    channel_count<=0;
                    memory_request<=0;
                    op_valid_1<=0;
                    //offset_op<=((burst_length_2)<<$clog2(AXI_DATA_BYTES));
                    end
                end
                5'd6://6
                begin
                  memory_request<=0;
                  op_valid_1<=0;
                  //fifo_read<=0;
                  if(flag_3&&last)
                  begin
                    kernel_count<=kernel_count+1;
                    channel_count<=0;
                    flag_3<=0;
                  end
                  if(last)
                  begin
                    case_2_output<=0;
                  end
                  else
                  begin
                    case_2_output<=6;
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
            //fifo_read<=0;
            memory_request<=0;
            acc_address_valid<=0;
          end
        end
        case(imag_dim_case)
          5'd0:
          begin
            if(case_2_acc!=0)
            begin
              if(imag_dim<IMAG_DIM_ACC)
              begin
                image_done<=1;
                if(case_2_acc==3)
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
        case(imag_dim_case_2)
          5'd0:
          begin
            if((case_1_output!=0)||(case_2_output!=0)||(channel_count==channel_itr-2)) //for op address imagdim -8
            begin
              if(imag_dim_2<IMAG_DIM_OUTPUT)
              begin
                image_done_2<=1;
                if((case_1_output==3)||(case_2_output==3))
                begin
                  imag_dim_case_2<=1;
                end
              end
            end
          end
          5'd1:
          begin
            image_done_2<=0;
            imag_dim_case_2<=0;
            imag_dim_2<=imag_dim_init_2;
          end
        endcase
      end
    endcase
    offset_acc<=((burst_length)<<$clog2(AXI_DATA_BYTES));
    offset_op<=((burst_length_2)<<$clog2(AXI_DATA_BYTES));
  end
  assign o_burst_length=burst_length-1;
  assign o_burst_length_2=burst_length_2-1;
  assign o_image_done=image_done;
  assign o_image_done_2=image_done_2;
endmodule
