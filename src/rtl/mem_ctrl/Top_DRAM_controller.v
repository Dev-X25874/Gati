module Top_DRAM_controller #(
    parameter   SYS_CLK_PERIOD    = 32'd100_000_000 ,             //System Clock Period
    parameter   NUM_PORTS = 10,                                    // number of ports
    parameter   BURST_LENGTH_WIDTH = 8,                           // burst length
    parameter   ADDRESS_WIDTH = 32,                               // address width                 
    parameter   IN_ADDR = 8,                                      // input address width of port controller
    parameter   PORT_ID = {4'b0000, 4'b0001, 4'b0010, 4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111, 4'b1000, 4'b1001},   // only use for port controller 
    parameter   POINTER_COUNT = 10,                               // fifo depth
    parameter   RAM_DEPTH = (1 << POINTER_COUNT),                 // fifo depth
    parameter   PORT_ID_WIDTH = 4,                                // ID width before the arbiter module [port controller, fifo, arbiter and request manager]
    parameter   ID_WIDTH = 8,                                     // ID width after the arbiter module
    parameter   AXI_ID_BLEN_CON = 8 ,                             // burst length width for AXI
    parameter   AXI_DATA_WIDTH      = 256 ,                       // Axi data width 
    parameter   AXI_BYTE_NUMBER     = AXI_DATA_WIDTH/8  ,                                  
    parameter   ADW_C               = AXI_DATA_WIDTH    ,
    parameter   ABN_C               = AXI_BYTE_NUMBER   
) (
    input clk,
    input c_81_clk,
	input   [ 1:0]  PllLocked ,
    input rst ,                                            // active low
    
    //DDR Controner Control Signal
    output      DdrCtrl_CFG_RST_N     ,                        //(O)[Control]DDR Controner Reset(Low Active)     
    output      DdrCtrl_CFG_SEQ_RST   ,                       //(O)[Control]DDR Controner Sequencer Reset 
    output      DdrCtrl_CFG_SEQ_START ,                       //(O)[Control]DDR Controner Sequencer Start 
    input [NUM_PORTS-1:0] port_ctrl_i_valid ,                           // valid signal for port controller
    input [(NUM_PORTS * 8)-1:0] port_ctrl_i_address,                   // 8 bit of address for port controller generator 
    input [(NUM_PORTS * BURST_LENGTH_WIDTH)-1:0] port_ctrl_i_BLEN,     // 4 bit of burst length for port controller (NUM_PORTS is use for generating the port controller)
    input [NUM_PORTS-1:0] port_ctrl_i_rw_enable ,                          // read/ write enable pin for port controller generator module
    input [NUM_PORTS-1:0] port_ctrl_i_last ,         
    
    output reg [AXI_DATA_WIDTH-1 :0 ] axi_read_o_delay_data ,         // delay for read data
    output         rd_r_last ,                                    // delay of read axi last signal
    output         rd_r_valid ,                                   // delay of read axi valid signal
    output         wr_id_o_wready ,                               // delauy of wready signal
    output [BURST_LENGTH_WIDTH-1:0] wr_axi_blen ,                 // write axi burst length
    input         wr_axi_valid,                                   // write valid signal for axi write data
    input         wr_axi_last ,                                   // last signal for indicating the last data of write 
    input [AXI_DATA_WIDTH-1:0] wr_axi_data ,                     // write data for AXI
    output [NUM_PORTS-1:0] select_wr ,                            // select signal for selecting the write port
    output [NUM_PORTS-1:0] select_rd ,                            // select signal for selecting the read port
    output                 DdrInitDone, //Indicates the user that DDR initialization is done and data transfer can begin
    
////DDR controller Axi signals /////////////    
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
    output              bready  
); 
localparam DATA_WIDTH = ADDRESS_WIDTH + BURST_LENGTH_WIDTH + PORT_ID_WIDTH + 1;
localparam BIN_WIDTH = $clog2(NUM_PORTS-1);

//reg  [AXI_DATA_WIDTH-1 :0 ] axi_read_o_delay_data = 0 ;
wire [(NUM_PORTS * DATA_WIDTH)-1:0] port_ctrl_req_out ;       // request out is combine the output of meta data 
wire [NUM_PORTS-1:0] fifo_empty_out;               
wire [NUM_PORTS-1:0] port_ctrl_o_valid, fifo_rd_en ;
wire [(NUM_PORTS*DATA_WIDTH)-1 : 0]  fifo_o_data ;            // output of fifo
wire [NUM_PORTS-1:0] fifo_rd_o_valid ;                        // fifo read valid
wire r_en_ack, w_en_ack ;                                     // acknowledge pin for read and write - use in en_pin logic [wr_id_manager, rd_id_manager]
wire [AXI_ID_BLEN_CON-1:0 ] axi_id, rd_blen ;
wire axi_wr_start, axi_rd_start ;                             // starting the read or write operation in axi - DDR
wire [AXI_DATA_WIDTH-1 :0 ] axi_read_o_data ;

wire [ADDRESS_WIDTH-1:0]  RR_o_addr;                          // output address from RR module 
wire [BURST_LENGTH_WIDTH-1:0] RR_o_blen;                      // output burst length from RR module
wire [PORT_ID_WIDTH-1:0] RR_o_port_id;                        // output port id from RR module
wire RR_o_rw ;                                                // output read or write enable from RR module
wire RR_o_valid_req ;

Port_ctrl_gen #(
    .NUM_PORTS(NUM_PORTS),
    .ADDRESS_WIDTH (ADDRESS_WIDTH),
    .IN_ADDR (IN_ADDR) ,
    .PORT_ID (PORT_ID) ,
    .COMBINED_DATA_WIDTH (DATA_WIDTH),
    .BURST_LENGTH_WIDTH (BURST_LENGTH_WIDTH),
    .PORT_ID_WIDTH (PORT_ID_WIDTH)
) 
port_ctrl_gen_inst(
    .clk (clk),
	.c_81_clk(c_81_clk),
    .rst(Axi0Rst_N), 
    .valid(port_ctrl_i_valid),        
    .last (port_ctrl_i_last),       
    .o_valid (port_ctrl_o_valid),  
    .in_address (port_ctrl_i_address),    //[I] address (8 bit)
    .in_burst_len (port_ctrl_i_BLEN),     //[I]burst length (4 bit)
    .in_enable_rw(port_ctrl_i_rw_enable),    // [I]read/write enable  (1 bit)
    .combined_out (port_ctrl_req_out)  // combine the meta data pass to the synchronous fifo (41 bit - as of now i am testing only four ports that is why it becomes 41 bits)
);


Req_Queue_gen #(
    .NUM_QUEUE(NUM_PORTS),
    .DATA_WIDTH (DATA_WIDTH),
    .ADDR_WIDTH (POINTER_COUNT), 
    .RAM_DEPTH (RAM_DEPTH)
) 
Req_Queue_gen_inst(
    .clk (clk),
	.c_81_clk(c_81_clk),
    .rst (Axi0Rst_N), 
    .empty_flag (fifo_empty_out),
    .rd_en (fifo_rd_en),
    .Wr_en (port_ctrl_o_valid),
    .data_in (port_ctrl_req_out),
    .data_out (fifo_o_data),  //  output [255:0] w_data_out1 ,
    .rd_out (fifo_rd_o_valid)
    
);

RR_ARB  #(
    .N (NUM_PORTS),
    .NUM_PORTS (NUM_PORTS),
    .PORT_ID_WIDTH (PORT_ID_WIDTH) ,
    .ADDRESS_WIDTH (ADDRESS_WIDTH),
    .BIN_WIDTH (BIN_WIDTH),
    .BURST_LENGTH_WIDTH (BURST_LENGTH_WIDTH) ,
    .DATA_WIDTH (DATA_WIDTH)
)
RR_ARB_inst(
	.rst_an (Axi0Rst_N),
	.clk (clk),
	.req (~fifo_empty_out),              // request 
	.grant_out (),                       // grant
    .en_pin (RR_en_pin),                   // enable pin is depend on the read|write acknowlege pin come from ID manager  
    .rd_sel_binary (),
    .req_out (fifo_rd_en),
    .in_data_div (fifo_o_data),        // input of meta data
    .o_addr_div (RR_o_addr),          // address - 32 bits
    .o_burst_div (RR_o_blen),        // burst length - 4 bits
    .o_port_div (RR_o_port_id),          // port id - 4 bits
    .o_rw_div (RR_o_rw),             // read/write enable - 1 bit
    .r_valid (fifo_rd_o_valid),       // valid read signal from fifo
    .valid_req (RR_o_valid_req)         // valid signal for request from request manager 
);


localparam EXT = ID_WIDTH - PORT_ID_WIDTH ;
reg RR_en_pin;
assign rd_blen = RR_o_blen ;
assign wr_axi_blen = RR_o_blen ;
assign axi_id = {{EXT{1'b0}}, RR_o_port_id} ;
assign axi_wr_start = RR_o_rw & RR_o_valid_req ;    // read/write enable pin and valid request signal come from request manager and arbiter module to enable the DDR RAM Write operation 
assign axi_rd_start = !RR_o_rw & RR_o_valid_req ;   //  read/write enable pin and valid request signal come from request manager and arbiter module to enable the DDR RAM read operation 

///////////////////////////////////////////////////////////////////////////////////
  reg [7:0] PowerOnResetCnt = 8'h0  ; //Power On Reset Counter
  reg [2:0] ResetShiftReg   = 3'h0  ; //Reset Shift Regist
  wire      DdrResetCtrl            ; //DDR Controller Reset Control
  assign DdrResetCtrl = ~rst ;
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
    .RamRdStart (axi_rd_start) ,    // start read operation 
    .RamRdData (axi_read_o_data) ,     // [o] output read data
    .CfgRdAddr (RR_o_addr) ,   // read address - 32 bits
    .CfgRdBLen (rd_blen),          // read burst length - 8 bits
    .w_ctrl_valid  (wr_axi_valid),  // (I) write valid
    .w_ctrl_last (wr_axi_last),     // (I) write last    
    .RamWrStart (axi_wr_start),         // (I) write start operation 
    .axi_wr_id(axi_id) ,             // (I) write id - 8 bit
    .axi_rd_id (axi_id) ,            // (I) read id - 8 bit
    .RamWrData (wr_axi_data),       // (I) write data - 256 bits
    .CfgWrAddr (RR_o_addr) ,       // (I) write address - 32 bits
    .CfgWrBlen (wr_axi_blen),           // (I) write burst length - 8 bits 
///// axi signal connected wirh DDR controller //////
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

WR_ID_Manager #(
    .NUM_PORTS_SEL (NUM_PORTS),
    .ID_WIDTH (ID_WIDTH)
) 
ID_MANAGER_inst(
    .clk (clk),
    .rst(Axi0Rst_N),
    .aid ( aid ),     // aid (I) from DDR
    .valid (avalid),  // (I) from DDR
    .atype (atype),   // (I) from DDR 
    .wready (wready),   // (I) from DDR
    .wready_out (wr_id_o_wready),  // delayed of Wready 
    .wlast (wlast) ,     // (I) from the external port which gives the write data here from (external any write port-DDR-this port) 
    .wid (wid),       // Write controller ID 
    .w_en_ack(w_en_ack) ,   // (O) which is use for en_pin in arbiter 
    .select (select_wr),    // (O) select pin - for selecting the external write port according to id
    .ack() 
);


RD_ID_Manager #(
    .ID_WIDTH (ID_WIDTH),
    .NUM_PORTS_SEL (NUM_PORTS)
)
ID_manager_rd_inst (
    .clk (clk),
    .rst (Axi0Rst_N),
    .valid (avalid),      // (I) from DDR
    .id_rd_in (aid),      // (I) from DDR
    .atype (atype),       // (I) from DDR
    .rvalid (rvalid),     // (I) from DDR
    .rlast (rlast),       // (I) from DDR
    .rid (rid),           // (I) from DDR
    .r_en_ack (r_en_ack), // (O) read acknowlege pin use in en_pin logic 
    .select_rd (select_rd), // (o) select (the size is depending on the number of ports)
    .rd_r_valid (rd_r_valid), // delayed signal of valid
    .rd_r_last(rd_r_last),   // delayed signal of last 
    .ack_rd () 
);


/////// delay logic for read axi data //////
always @ (posedge clk) begin 
    axi_read_o_delay_data <= rdata ;
end 

reg flag;
always@(posedge clk) begin
    if(!Axi0Rst_N) flag <= 0;
    else begin
        if(fifo_rd_en!=0) flag <= 1;
        else if(w_en_ack|r_en_ack) flag <= 0;
        // else flag <= 1;
    end
end
////// this logic is use in arbiter module ///////
always@(*) begin
    if(!Axi0Rst_N) RR_en_pin = 1;
    else begin
        if(fifo_rd_en!=0) RR_en_pin = 0;
        else if (w_en_ack|r_en_ack) RR_en_pin = 1;
        else if ((fifo_rd_en == 0) && ~flag) RR_en_pin = 1;
        else RR_en_pin = 0;
    end

end
endmodule 
