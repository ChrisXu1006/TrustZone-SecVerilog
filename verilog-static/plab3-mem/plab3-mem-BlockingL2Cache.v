//=========================================================================
// Alternative Blocking Cache
//=========================================================================

`ifndef PLAB3_MEM_BLOCKING_L2_CACHE_V
`define PLAB3_MEM_BLOCKING_L2_CACHE_V

`include "vc-mem-msgs.v"
`include "plab3-mem-BlockingL2CacheCtrl.v"
`include "plab3-mem-BlockingL2CacheDpath.v"


module plab3_mem_BlockingL2Cache
#(
  parameter mode = 0,					   // 0 for instruction, 1 for data

  parameter p_mem_nbytes = 256,            // Cache size in bytes
  parameter p_num_banks  = 0,              // Total number of cache banks

  // opaque field from the cache and memory side
  parameter p_opaque_nbits = 8,

  // local parameters not meant to be set from outside
  parameter dbw          = 128,             // Short name for data bitwidth
  parameter abw          = 32,             // Short name for addr bitwidth
  parameter clw          = 128,            // Short name for cacheline bitwidth

  parameter o = p_opaque_nbits
)
(
  input                                         clk,
  input                                         reset,

  // Cache Request

  input [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0]  cachereq_msg,
  input                                         cachereq_val,
  output                                        cachereq_rdy,

  // Cache Response

  output [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]    cacheresp_msg,
  output                                        cacheresp_val,
  input                                         cacheresp_rdy,

  // Memory Request

  output [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0] memreq_msg,
  output                                        memreq_val,
  input                                         memreq_rdy,

  // Imply Insecure memory request
  input											insecure,

  // Memory Response

  input [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]     memresp_msg,
  input                                         memresp_val,
  output                                        memresp_rdy
);

  // calculate the index shift amount based on number of banks

  localparam c_idx_shamt = $clog2( p_num_banks );

  //----------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------

  // control signals (ctrl->dpath)
  wire [1:0]									amo_sel;
  wire                                         	cachereq_en;
  wire                                         	memresp_en;
  wire                                         	is_refill;
  wire                                         	tag_array_0_wen;
  wire                                         	tag_array_0_ren;
  wire                                         	tag_array_1_wen;
  wire                                         	tag_array_1_ren;
  wire                                         	way_sel;
  wire                                         	data_array_wen;
  wire                                         	data_array_ren;
  wire [clw/8-1:0]                             	data_array_wben;
  wire                                         	read_data_reg_en;
  wire                                         	read_tag_reg_en;
  wire [$clog2(clw/dbw)-1:0]                   	read_byte_sel;
  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0] memreq_type;
  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0] cacheresp_type;


  // status signals (dpath->ctrl)
  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,clw)-1:0] cachereq_type;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,clw)-1:0] cachereq_addr;
  wire                                             tag_match_0;
  wire                                             tag_match_1;

  //----------------------------------------------------------------------
  // Control
  //----------------------------------------------------------------------

  plab3_mem_BlockingL2CacheCtrl
  #(
    .size                   (p_mem_nbytes),
    .p_idx_shamt            (c_idx_shamt),
    .p_opaque_nbits         (p_opaque_nbits),
	.dbw					(dbw)
  )
  ctrl
  (
   .clk               (clk),
   .reset             (reset),

   // Cache Request

   .cachereq_val      (cachereq_val),
   .cachereq_rdy      (cachereq_rdy),

   // Cache Response

   .cacheresp_val     (cacheresp_val),
   .cacheresp_rdy     (cacheresp_rdy),

   // Memory Request

   .memreq_val        (memreq_val),
   .memreq_rdy        (memreq_rdy),

   // Memory Response

   .insecure		  (insecure),

   .memresp_val       (memresp_val),
   .memresp_rdy       (memresp_rdy),

   // control signals (ctrl->dpath)
   .amo_sel           (amo_sel),
   .cachereq_en       (cachereq_en),
   .memresp_en        (memresp_en),
   .is_refill         (is_refill),
   .tag_array_0_wen   (tag_array_0_wen),
   .tag_array_0_ren   (tag_array_0_ren),
   .tag_array_1_wen   (tag_array_1_wen),
   .tag_array_1_ren   (tag_array_1_ren),
   .way_sel           (way_sel),
   .data_array_wen    (data_array_wen),
   .data_array_ren    (data_array_ren),
   .data_array_wben   (data_array_wben),
   .read_data_reg_en  (read_data_reg_en),
   .read_tag_reg_en   (read_tag_reg_en),
   .read_byte_sel     (read_byte_sel),
   .memreq_type       (memreq_type),
   .cacheresp_type    (cacheresp_type),

   // status signals  (dpath->ctrl)
   .cachereq_type     (cachereq_type),
   .cachereq_addr     (cachereq_addr),
   .tag_match_0       (tag_match_0),
   .tag_match_1       (tag_match_1)
  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  plab3_mem_BlockingL2CacheDpath
  #(
    .size                   (p_mem_nbytes),
    .p_idx_shamt            (c_idx_shamt),
    .p_opaque_nbits         (p_opaque_nbits),
	.dbw					(dbw)
  )
  dpath
  (
   .clk               (clk),
   .reset             (reset),

   // Cache Request

   .cachereq_msg      (cachereq_msg),

   // Cache Response

   .cacheresp_msg     (cacheresp_msg),

   // Memory Request

   .memreq_msg        (memreq_msg),

   // Memory Response

   .insecure		  (insecure),
   .memresp_msg       (memresp_msg),

   // control signals (ctrl->dpath)
   .amo_sel           (amo_sel),
   .cachereq_en       (cachereq_en),
   .memresp_en        (memresp_en),
   .is_refill         (is_refill),
   .tag_array_0_wen   (tag_array_0_wen),
   .tag_array_0_ren   (tag_array_0_ren),
   .tag_array_1_wen   (tag_array_1_wen),
   .tag_array_1_ren   (tag_array_1_ren),
   .way_sel           (way_sel),
   .data_array_wen    (data_array_wen),
   .data_array_ren    (data_array_ren),
   .data_array_wben   (data_array_wben),
   .read_data_reg_en  (read_data_reg_en),
   .read_tag_reg_en   (read_tag_reg_en),
   .read_byte_sel     (read_byte_sel),
   .memreq_type       (memreq_type),
   .cacheresp_type    (cacheresp_type),

   // status signals  (dpath->ctrl)
   .cachereq_type     (cachereq_type),
   .cachereq_addr     (cachereq_addr),
   .tag_match_0       (tag_match_0),
   .tag_match_1       (tag_match_1)
  );


  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------
  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    case ( ctrl.state_reg )

      ctrl.STATE_IDLE:                  vc_trace_str( trace, "(I )" );
      ctrl.STATE_TAG_CHECK:             vc_trace_str( trace, "(TC)" );
      ctrl.STATE_READ_DATA_ACCESS:      vc_trace_str( trace, "(RD)" );
      ctrl.STATE_WRITE_DATA_ACCESS:     vc_trace_str( trace, "(WD)" );
      ctrl.STATE_AMO_READ_DATA_ACCESS:  vc_trace_str( trace, "(AR)" );
      ctrl.STATE_AMO_WRITE_DATA_ACCESS: vc_trace_str( trace, "(AW)" );
      ctrl.STATE_INIT_DATA_ACCESS:      vc_trace_str( trace, "(IN)" );
      ctrl.STATE_REFILL_REQUEST:        vc_trace_str( trace, "(RR)" );
      ctrl.STATE_REFILL_WAIT:           vc_trace_str( trace, "(RW)" );
      ctrl.STATE_REFILL_UPDATE:         vc_trace_str( trace, "(RU)" );
      ctrl.STATE_EVICT_PREPARE:         vc_trace_str( trace, "(EP)" );
      ctrl.STATE_EVICT_REQUEST:         vc_trace_str( trace, "(ER)" );
      ctrl.STATE_EVICT_WAIT:            vc_trace_str( trace, "(EW)" );
      ctrl.STATE_WAIT:                  vc_trace_str( trace, "(W )" );
      default:                          vc_trace_str( trace, "(? )" );

    endcase

  end
  endtask

endmodule

`endif
