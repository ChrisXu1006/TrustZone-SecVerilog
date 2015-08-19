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
  input                                         {L} clk,
  input                                         {L} reset,

  input                                         {L} domain,
  // Cache Request

  input [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0]  {Data domain} cachereq_msg,
  input                                         {Ctrl domain} cachereq_val,
  output                                        {Ctrl domain} cachereq_rdy,

  // Cache Response

  output [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]    {Data domain} cacheresp_msg,
  output                                        {Ctrl domain} cacheresp_val,
  input                                         {Ctrl domain} cacheresp_rdy,

  // Memory Request

  output [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0] {Data domain} memreq_msg,
  output                                        {Ctrl domain} memreq_val,
  input                                         {Ctrl domain} memreq_rdy,

  // Imply Insecure memory request
  input											{Ctrl domain} insecure,

  // Memory Response

  input [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]     {Data domain} memresp_msg,
  input                                         {Ctrl domain} memresp_val,
  output                                        {Ctrl domain} memresp_rdy
);

  // calculate the index shift amount based on number of banks

  localparam c_idx_shamt = $clog2( p_num_banks );

  //----------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------

  // control signals (ctrl->dpath)
  wire [1:0]									{Ctrl domain} amo_sel;
  wire                                         	{Ctrl domain} cachereq_en;
  wire                                         	{Ctrl domain} memresp_en;
  wire                                         	{Ctrl domain} is_refill;
  wire                                         	{Ctrl domain} tag_array_0_wen;
  wire                                         	{Ctrl domain} tag_array_0_ren;
  wire                                         	{Ctrl domain} tag_array_1_wen;
  wire                                         	{Ctrl domain} tag_array_1_ren;
  wire                                         	{Ctrl domain} way_sel;
  wire                                         	{Ctrl domain} data_array_wen;
  wire                                         	{Ctrl domain} data_array_ren;
  wire [clw/8-1:0]                             	{Ctrl domain} data_array_wben;
  wire                                         	{Ctrl domain} read_data_reg_en;
  wire                                         	{Ctrl domain} read_tag_reg_en;
  wire [$clog2(clw/dbw)-1:0]                   	{Ctrl domain} read_byte_sel;
  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0] {Ctrl domain} memreq_type;
  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0] {Ctrl domain} cacheresp_type;


  // status signals (dpath->ctrl)
  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,clw)-1:0] {Ctrl domain} cachereq_type;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,clw)-1:0] {Ctrl domain} cachereq_addr;
  wire                                             {Ctrl domain} tag_match_0;
  wire                                             {Ctrl domain} tag_match_1;

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

   .domain            (domain),

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

   .domain            (domain),
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

endmodule

`endif
