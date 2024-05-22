module Top_mem_ctrl #(
    parameter   TCo_C             = 100             ,
    parameter   SYS_CLK_PERIOD    = 32'd100_000_000 , //System Clock Period
    parameter NUM_PORTS = 4,        // number of ports
    parameter NUM_QUEUE = 4,        
    parameter DATA_WIDTH = 41,      // data width from port controller outputs [port id, address, burst length, read/write enable]
    parameter ADDR_WIDTH = 32,     
    parameter BURST_LENGTH_WIDTH = 4,   // burst length
    parameter ADDRESS_WIDTH = 32,     //  // address width
    parameter BURST_WIDTH = 4,
    parameter POINTER_COUNT = 10,     
    parameter RAM_DEPTH = (1 << POINTER_COUNT),
    parameter BIN_WIDTH = $clog2(NUM_PORTS-1),
    parameter PORT_ID_WIDTH = 4,
    parameter AXI_ID_BLEN_CON = 8 ,
    parameter  AXI_DATA_WIDTH      = 256 ,
    parameter  AXI_BYTE_NUMBER     = AXI_DATA_WIDTH/8  ,                                  
    parameter  ADW_C               = AXI_DATA_WIDTH    ,
    parameter  ABN_C               = AXI_BYTE_NUMBER   
) (
    input clk,
    input t_in,
    input   [ 1:0]  PllLocked ,
    
    //DDR Controner Control Signal
    output      DdrCtrl_CFG_RST_N     ,     //(O)[Control]DDR Controner Reset(Low Active)     
    output      DdrCtrl_CFG_SEQ_RST   ,    //(O)[Control]DDR Controner Sequencer Reset 
    output      DdrCtrl_CFG_SEQ_START ,    //(O)[Control]DDR Controner Sequencer Start 
    
    output [(NUM_PORTS*32)-1 : 0] o_addr,
    output [(NUM_PORTS*4)-1:0] o_BLEN ,
    output [(NUM_PORTS*4)-1:0] i_port_id,
    output [NUM_PORTS-1:0] enable_in,
    output [BIN_WIDTH-1:0] rd_sel_binary,
   
    output  [      7:0] aid     ,
    output  [     31:0] aaddr   , 
    output  [      7:0] alen    , 
    output  [      2:0] asize   , 
    output  [      1:0] aburst  , 
    output  [      1:0] alock   , 
    output              avalid  , 
    input               aready  , 
    output              atype   ,
    output  [      7:0] wid     , 
    output  [ABN_C-1:0] wstrb   , 
    output              wlast   , 
    output              wvalid  , 
    input               wready  , 
    output  [ADW_C-1:0] wdata   , 
    input   [      7:0] rid     , 
    input               rlast   , 
    input               rvalid  , 
    output              rready  , 
    input   [      1:0] rresp   , 
    input   [ADW_C-1:0] rdata   , 
    input   [      7:0] bid     , 
    input               bvalid  , 
    output              bready  ,
    output [255:0] r_data_out_1 ,
    output         rd_r_last ,
    output         data_valid 
   // output [255:0] r_data_out_2 
 
);

always@(*) begin    
if(t_in == 0)  rst <= 1;
else rst  <= 0 ;
end
 
/*wire t_in_inv ;
assign t_in_inv = ~t_in ;
one_pulse
one_pulse_inst(
    .a(t_in),
    .clk(clk),
    .b(trigger)
);*/

//assign rst = ~trigger ;
//wire trigger ;
reg rst = 0 ;
wire [NUM_PORTS-1:0] i_valid ;
wire [(NUM_PORTS * 8)-1:0] in_address;
wire [(NUM_PORTS * 4)-1:0] in_BLEN;
wire [NUM_PORTS-1:0] i_enable ;
wire [NUM_PORTS-1:0] i_last ;
wire [(NUM_PORTS * DATA_WIDTH)-1:0] combined_out ;
wire [NUM_PORTS-1:0] e_flag;
wire [NUM_PORTS-1:0] o_valid, r_en ;
wire [(NUM_PORTS*DATA_WIDTH)-1 : 0]  div_out_data ;
wire [NUM_PORTS-1:0] rd_out_en ;
//wire en_pin ;
wire r_en_ack, w_en_ack ;
wire [AXI_DATA_WIDTH-1 :0 ] ram_data ;
wire [AXI_ID_BLEN_CON-1:0 ] id_in, blen ;
wire wr_start, rd_start ;
wire [3:0] select_wr ;
//wire w_sel_1 , w_sel_2 ;
wire [3:0] select_rd ;
wire r_sel_1 , r_sel_2 ;
//wire valid_ctrl_1,valid_ctrl_2 , last_ctrl_2, last_ctrl_1 ;
wire [255:0] wdata_ctrl_1, wdata_ctrl_2 ;
wire wr_axi_valid, wr_axi_last ;
wire [255:0] wr_axi_data ;
wire [ADDR_WIDTH-1:0]  o_addr_div;
wire [BURST_LENGTH_WIDTH-1:0] o_burst_div;
wire [PORT_ID_WIDTH-1:0] o_port_div;
wire o_rw_div ;
wire o_valid_req ;
//reg [255:0] r_data_out_2 = 0  ;

Top_test_data_ctrl # (
    .NUM_PORTS (NUM_PORTS) 
) 
Test_data_inst (  
    .clk (clk),
    .rst (Axi0Rst_N),
    .out_valid (i_valid),
    .out_test_addr (in_address),
    .out_BLEN (in_BLEN),
    .out_enable (i_enable),
    .out_last (i_last) 
);


Port_ctrl_gen #(
    .NUM_PORTS(NUM_PORTS)
) 
port_ctrl_gen_inst(
    .clk (clk),
    .rst(Axi0Rst_N), 
    .valid(i_valid),        
    .last (i_last),       
    .o_valid (o_valid),  
    .in_address (in_address),   
    .in_burst_len (in_BLEN), 
    .in_enable_rw(i_enable),   
    .out_address (o_addr),  
    .out_burst_len (o_BLEN),
    .out_enable_rw (enable_in),
    .port_id (i_port_id),
    .combined_out (combined_out)

);

Req_Queue_gen #(
    .NUM_QUEUE(NUM_QUEUE),
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (POINTER_COUNT), 
    .RAM_DEPTH (RAM_DEPTH)
) 
Req_Queue_gen_inst(
    .clk (clk),
    .rst (Axi0Rst_N), 
    .empty_flag (e_flag),
    .rd_en (r_en),
    .Wr_en (o_valid),
    .data_in (combined_out),
    .data_out (div_out_data),  //  output [255:0] w_data_out1 ,
    .rd_out (rd_out_en)
    
);

RR_ARB  #(
    .N (NUM_PORTS),
    .NUM_PORTS (NUM_PORTS),
    .PORT_ID_WIDTH (PORT_ID_WIDTH) ,
    .ADDRESS_WIDTH (ADDR_WIDTH),
    .BIN_WIDTH (BIN_WIDTH),
    .BURST_LENGTH_WIDTH (BURST_LENGTH_WIDTH) ,
    .DATA_WIDTH (DATA_WIDTH)
)
RR_ARB_inst(
	.rst_an (Axi0Rst_N),
	.clk (clk),
	.req (~e_flag),
	.grant_out (o_grant),
    .en_pin (en_pin),
    .rd_sel_binary (rd_sel_binary),
    .req_out (r_en),
    .in_data_div (div_out_data),
    .o_addr_div (o_addr_div),
    .o_burst_div (o_burst_div), 
    .o_port_div (o_port_div),
    .o_rw_div (o_rw_div),
    .r_valid (rd_out_en),
    .valid_req (o_valid_req)
);


reg en_pin;
//assign en_pin = (w_en_ack | r_en_ack) ;
assign blen = {4'b0, o_burst_div} ;
assign blen_wr = {4'b0, o_burst_div} ;
assign id_in = {4'b0, o_port_div} ;
assign wr_start = o_rw_div & o_valid_req ;
assign rd_start = !o_rw_div & o_valid_req ;
wire [7:0] blen_wr ;

///////////////////////////////////////////////////////////////////////////////////
  reg [7:0] PowerOnResetCnt = 8'h0  ; //Power On Reset Counter
  reg [2:0] ResetShiftReg   = 3'h0  ; //Reset Shift Regist
  wire      DdrResetCtrl            ; //DDR Controller Reset Control
  assign DdrResetCtrl = ~rst  ;
  always @( posedge clk) if (&PllLocked)    
  begin
    PowerOnResetCnt <=  PowerOnResetCnt + {7'h0,(~&PowerOnResetCnt)};
  end
  
  always @( posedge clk)  
  begin
    ResetShiftReg[2] <=  ResetShiftReg[1] ;
    ResetShiftReg[1] <=   ResetShiftReg[0] ;
    ResetShiftReg[0] <= (&PowerOnResetCnt) & (~DdrResetCtrl);
  end    
  
  /////////////////////////////////////////////////////////
  //DDR Reset   
  wire  DdrInitDone   ;  //DDR Initial Done status
  
  ddr_reset_sequencer 
  # (
      .FREQ (SYS_CLK_PERIOD / 1_000_000)
    )
  U0_DDR_Reset
  (
    .ddr_rstn_i         ( ResetShiftReg[2]      ), // main user DDR reset, active low
    .clk                ( clk                ), // user clock
    /* Connect these three signals to DDR reset interface */
    .ddr_rstn           ( DdrCtrl_CFG_RST_N          ), // Master Reset
    .ddr_cfg_seq_rst    ( DdrCtrl_CFG_SEQ_RST   ), // Sequencer Reset
    .ddr_cfg_seq_start  ( DdrCtrl_CFG_SEQ_START ), // Sequencer Start
    /* optional status monitor for user logic */
    .ddr_init_done		  (    DdrInitDone  )  // Done status
  );
  
  /////////////////////////////////////////////////////////
  reg   [2:0] SysClkResetReg = 3'h0;    //System Clock Reset Register
  
  always @( posedge clk)  
  begin
    SysClkResetReg[2] <=  SysClkResetReg[1] ;
    SysClkResetReg[1] <=  SysClkResetReg[0] ;
    SysClkResetReg[0] <= (~DdrResetCtrl) & DdrInitDone;
  end
    
  wire    Reset_N  = SysClkResetReg[2]; //System Reset (Low Active)
    
  /////////////////////////////////////////////////////////
  reg   [2:0] Axi0ResetReg = 3'h0;    //System Clock Reset Register
  
  always @( posedge clk)  
  begin
    Axi0ResetReg[2] <=   Axi0ResetReg[1] ;
    Axi0ResetReg[1] <=  Axi0ResetReg[0] ;
    Axi0ResetReg[0] <=  (~DdrResetCtrl) & DdrInitDone;
  end
    
  wire    Axi0Rst_N  ;
 assign Axi0Rst_N = Axi0ResetReg[2]; //System Reset (Low Active)
    
  /////////////////////////////////////////////////////////
  reg   [2:0] Axi1ResetReg = 3'h0;    //System Clock Reset Register
   
  always @( posedge clk)  
  begin
    Axi1ResetReg[2] <=   Axi1ResetReg[1] ;
    Axi1ResetReg[1] <=  Axi1ResetReg[0] ;
    Axi1ResetReg[0] <=  (~DdrResetCtrl) & DdrInitDone;
  end
    
  wire    Axi1Rst_N  = Axi1ResetReg[2]; //System Reset (Low Active)

Top_Axi #(
    .AXI_DATA_WIDTH (AXI_DATA_WIDTH),
    .AXI_BYTE_NUMBER (AXI_BYTE_NUMBER) ,                                  
    .ADW_C (ADW_C) ,
    .ABN_C (ABN_C)   
)
NATIVE_AXI_inst(  
    .SysClk (clk),
    .rst(Axi0Rst_N),
    .RamRdStart (rd_start) ,
    .RamRdData (ram_data) ,
    .CfgRdAddr (o_addr_div) ,
    .CfgRdBLen (blen),
    .w_ctrl_valid  (wr_axi_valid),
    .w_ctrl_last (wr_axi_last),
    
    .RamWrStart (wr_start),
    .axi_wr_id(id_in) ,
    .axi_rd_id (id_in) ,
    .RamWrData (wr_axi_data),
    .CfgWrAddr (o_addr_div) ,
    .CfgWrBlen (blen_wr),
    .aid    (aid)     ,
    .aaddr  (aaddr)   , 
    .alen   (alen)    , 
    .asize  (asize)   , 
    .aburst (aburst)  , 
    .alock  (alock)   , 
    .avalid (avalid)  , 
    .aready (aready)  , 
    .atype  (atype)   ,
    .wid    (wid)     , 
    .wstrb  (wstrb)   , 
    .wlast  (wlast)   , 
    .wvalid (wvalid)  , 
    .wready (wready)  , 
    .wdata  (wdata)   , 
    .rid    (rid)     , 
    .rlast  (rlast)   , 
    .rvalid (rvalid)  , 
    .rready (rready)  , 
    .rresp  (rresp)   , 
    .rdata  (rdata)   , 
    .bid    (bid)     , 
    .bvalid (bvalid)  , 
    .bready (bready) 

);

assign w_sel_1 = select_wr[0] |  select_wr[2];
assign w_sel_2 = select_wr[1] | select_wr[3] ;
wire w_sel_1  ;
wire w_sel_2  ;
wire wready_out ;


Mem_ctrl_wr # (
.AXI_DATA_WIDTH (AXI_DATA_WIDTH)
)
Mem_ctrl_wr_1(
    .clk (clk),
    .rst (Axi0Rst_N),
    .select (w_sel_1),
    .wready_w (wready_out),
    .wvalid_w (valid_ctrl_1),
    .wlast_w (last_ctrl_1),
    .in_Addr (o_addr_div),
  //  .wdata_out (wdata_ctrl_1),
    .DdrWrData (wdata_ctrl_1),
    .BLEN_w (blen_wr)
) ;

Mem_ctrl_wr #(
.AXI_DATA_WIDTH(AXI_DATA_WIDTH)
)
Mem_ctrl_wr_2 (
    .clk (clk),
    .rst (Axi0Rst_N),
    .select (w_sel_2),
    .wready_w (wready_out),
    .wvalid_w (valid_ctrl_2),
    .wlast_w (last_ctrl_2),
    .in_Addr (o_addr_div),
  //  .wdata_out (wdata_ctrl_2),
    .DdrWrData (wdata_ctrl_2),
    .BLEN_w (blen_wr)
 ) ;
 
 MUX_WR_SEL 
 Mux_inst(
    .clk(clk),
    .rst (Axi0Rst_N), 
    .w_valid_1 (valid_ctrl_1),
    .w_valid_2 (valid_ctrl_2),
    .w_last1 (last_ctrl_1),
    .w_last2 (last_ctrl_2),
    .sel_in1 (w_sel_1), 
    .sel_in2 (w_sel_2),
    .data_in1 (wdata_ctrl_1),
    .data_in2 (wdata_ctrl_2),
    .w_valid_out (wr_axi_valid),
    .w_last_out (wr_axi_last),
    .w_odata_sel (wr_axi_data)
);



WR_ID_Manager #(
  .NUM_PORTS (NUM_PORTS)
) 
ID_MANAGER_inst(
    .clk (clk),
    .rst(Axi0Rst_N),
    .aid ( aid ),
    .valid (avalid),
    .atype (atype),
    //.WBlen (blen_wr) ,
    .wready (wready),   ///// it is input in the ddr axi side so can i use the 
    .wready_out (wready_out),
    .wlast (wlast) ,
    .wid (wid),       // Write controller ID
    .w_en_ack(w_en_ack) ,
    .select (select_wr),
    .ack() 
);


assign r_sel_1 = select_rd[2] | select_rd[1];
assign r_sel_2 = select_rd[3] | select_rd[0] ;
wire rd_r_valid ;
RD_ID_Manager
ID_manager_rd_inst (
    .clk (clk),
    .rst (Axi0Rst_N),
    .valid (avalid),
    .id_rd_in (aid),
    .atype (atype),
    .rvalid (rvalid),
    .rlast (rlast),
    .rid (rid),
    .r_en_ack (r_en_ack),
    .select_rd (select_rd),
    .rd_r_valid (rd_r_valid),
    .rd_r_last(rd_r_last),
    .ack_rd () 
);

Mem_Rd_ctrl
Mem_Rd_inst_1 (
    .clk (clk),
    .rst (Axi0Rst_N),
    .select_rd (r_sel_1),
    .rvalid_rd (rd_r_valid) ,
    .rlast_rd (rd_r_last),
    .rdata_in (rdata),
    .data_valid (data_valid) ,
    .rdata_out (r_data_out_1)
) ;         

/*Mem_Rd_ctrl
Mem_Rd_ctrl_inst2 (
    .clk (clk),
    .rst (rst),
    .select_rd (r_sel_2),
    .rvalid_rd (rvalid) ,
    .rlast_rd (rlast),
    .rdata_in (ram_data),
    .rdata_out (r_data_out_2)
) ;*/

always@(*) begin
    if(!Axi0Rst_N) en_pin <= 1;
    else begin
        if(r_en!=0) en_pin <= 0;
        else if (w_en_ack|r_en_ack) en_pin <=1;
    end

end
endmodule 