//=========================================================================
// Alternative Blocking Cache
//=========================================================================

`ifndef PLAB3_MEM_BLOCKING_L1_CACHE_V
`define PLAB3_MEM_BLOCKING_L1_CACHE_V

`include "vc-mem-msgs.v"
`include "plab3-mem-BlockingL1CacheCtrl.v"
`include "plab3-mem-BlockingL1CacheDpath.v"


module plab3_mem_BlockingL1Cache
#(
  parameter p_mem_nbytes = 256,            // Cache size in bytes
  parameter p_num_banks  = 0,              // Total number of cache banks

  // opaque field from the cache and memory side
  parameter p_opaque_nbits = 8,

  // local parameters not meant to be set from outside
  parameter dbw          = 32,             // Short name for data bitwidth
  parameter abw          = 32,             // Short name for addr bitwidth
  parameter clw          = 128,            // Short name for cacheline bitwidth

  parameter o = p_opaque_nbits
)
(
  input                                         {L} clk,
  input                                         {L} reset,

  // Cache Request

  input [`VC_MEM_REQ_MSG_NBITS(o,abw,dbw)-1:0]  {Data cachereq_domain} cachereq_msg,
  input                                         {Ctrl cachereq_domain} cachereq_val,
  output                                        {Ctrl cachereq_domain} cachereq_rdy,
  input											{L} cachereq_domain,

  // Cache Response

  output [`VC_MEM_RESP_MSG_NBITS(o,dbw)-1:0]    {Data cacheresp_domain} cacheresp_msg,
  output                                        {Ctrl cacheresp_domain} cacheresp_val,
  input                                         {Ctrl cacheresp_domain} cacheresp_rdy,
  output										{L} cacheresp_domain,

  // Memory Request

  output [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0] {Data memreq_domain} memreq_msg,
  output                                        {Ctrl memreq_domain} memreq_val,
  input                                         {Ctrl memreq_domain} memreq_rdy,
  output										{L} memreq_domain,

  // Memory Response

  input											{Ctrl memresp_domain} fail,

  input [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]     {Data memresp_domain} memresp_msg,
  input                                         {Ctrl memresp_domain} memresp_val,
  output                                        {Ctrl memresp_domain} memresp_rdy,
  input											{L} memresp_domain
);

  // calculate the index shift amount based on number of banks

  localparam c_idx_shamt = $clog2( p_num_banks );

  //----------------------------------------------------------------------
  // Wires
  //----------------------------------------------------------------------

  // control signals (ctrl->dpath)
  wire [1:0]									{Ctrl cachereq_nsbit} amo_sel;
  wire                                         	{Ctrl cachereq_nsbit} cachereq_en;
  wire                                         	{Ctrl cachereq_nsbit} memresp_en;
  wire                                         	{Ctrl cachereq_nsbit} is_refill;
  wire                                         	{Ctrl cachereq_nsbit} tag_array_0_wen;
  wire                                         	{Ctrl cachereq_nsbit} tag_array_0_ren;
  wire                                         	{Ctrl cachereq_nsbit} tag_array_1_wen;
  wire                                         	{Ctrl cachereq_nsbit} tag_array_1_ren;
  wire											{Ctrl cachereq_nsbit} nsb_array_0_wen;
  wire											{Ctrl cachereq_nsbit} nsb_array_0_ren;
  wire											{Ctrl cachereq_nsbit} nsb_array_1_wen;
  wire											{Ctrl cachereq_nsbit} nsb_array_1_ren;
  wire                                         	{Ctrl cachereq_nsbit} way_sel;
  wire                                         	{Ctrl cachereq_nsbit} data_array_wen;
  wire                                         	{Ctrl cachereq_nsbit} data_array_ren;
  wire [clw/8-1:0]                             	{Ctrl cachereq_nsbit} data_array_wben;
  wire                                         	{Ctrl cachereq_nsbit} read_data_reg_en;
  wire                                         	{Ctrl cachereq_nsbit} read_tag_reg_en;
  wire [$clog2(clw/dbw)-1:0]                   	{Ctrl cachereq_nsbit} read_byte_sel;
  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0] {Ctrl memreq_domain}  memreq_type;
  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(o,dbw)-1:0] {Ctrl cacheresp_domain} cacheresp_type;
  wire											{Ctrl cachereq_nsbit} secure_mask;


  // status signals (dpath->ctrl)
  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0] {Ctrl cachereq_nsbit} cachereq_type;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] {Ctrl cachereq_nsbit} cachereq_addr;
  wire											   {L} cachereq_nsbit;
  wire                                             {Ctrl cachereq_nsbit} tag_match_0;
  wire                                             {Ctrl cachereq_nsbit} tag_match_1;
  wire											   {L} nsb_match_0;
  wire											   {L} nsb_match_1;

  //----------------------------------------------------------------------
  // Control
  //----------------------------------------------------------------------

  plab3_mem_BlockingL1CacheCtrl
  #(
    .size                   (p_mem_nbytes),
    .p_idx_shamt            (c_idx_shamt),
    .p_opaque_nbits         (p_opaque_nbits)
  )
  ctrl
  (
   .clk               (clk),
   .reset             (reset),

   // Cache Request

   .cachereq_val      (cachereq_val),
   .cachereq_rdy      (cachereq_rdy),
   .cachereq_domain   (cachereq_domain),

   // Cache Response

   .cacheresp_val     (cacheresp_val),
   .cacheresp_rdy     (cacheresp_rdy),
   .cacheresp_domain  (cacheresp_domain),

   // Memory Request

   .memreq_val        (memreq_val),
   .memreq_rdy        (memreq_rdy),
   .memreq_domain     (memreq_domain),

   // Memory Response

   .fail			  (fail),

	
   .memresp_val       (memresp_val),
   .memresp_rdy       (memresp_rdy),
   .memresp_domain    (memresp_domain),

   // control signals (ctrl->dpath)
   .amo_sel           (amo_sel),
   .cachereq_en       (cachereq_en),
   .memresp_en        (memresp_en),
   .is_refill         (is_refill),
   .tag_array_0_wen   (tag_array_0_wen),
   .tag_array_0_ren   (tag_array_0_ren),
   .tag_array_1_wen   (tag_array_1_wen),
   .tag_array_1_ren   (tag_array_1_ren),
   .nsb_array_0_wen	  (nsb_array_0_wen),
   .nsb_array_0_ren	  (nsb_array_0_ren),
   .nsb_array_1_wen	  (nsb_array_1_wen),
   .nsb_array_1_ren	  (nsb_array_1_ren),
   .way_sel           (way_sel),
   .data_array_wen    (data_array_wen),
   .data_array_ren    (data_array_ren),
   .data_array_wben   (data_array_wben),
   .read_data_reg_en  (read_data_reg_en),
   .read_tag_reg_en   (read_tag_reg_en),
   .read_byte_sel     (read_byte_sel),
   .memreq_type       (memreq_type),
   .cacheresp_type    (cacheresp_type),
   .secure_mask		  (secure_mask),

   // status signals  (dpath->ctrl)
   .cachereq_type     (cachereq_type),
   .cachereq_addr     (cachereq_addr),
   .cachereq_nsbit	  (cachereq_nsbit),
   .tag_match_0       (tag_match_0),
   .tag_match_1       (tag_match_1),
   .nsb_match_0		  (nsb_match_0),
   .nsb_match_1		  (nsb_match_1)
  );

  //----------------------------------------------------------------------
  // Datapath
  //----------------------------------------------------------------------

  plab3_mem_BlockingL1CacheDpath
  #(
    .size                   (p_mem_nbytes),
    .p_idx_shamt            (c_idx_shamt),
    .p_opaque_nbits         (p_opaque_nbits)
  )
  dpath
  (
   .clk               (clk),
   .reset             (reset),

   // Cache Request

   .cachereq_msg      (cachereq_msg),
   .cachereq_domain	  (cachereq_domain),

   // Cache Response

   .cacheresp_msg     (cacheresp_msg),
   .cacheresp_domain  (cacheresp_domain),

   // Memory Request

   .memreq_msg        (memreq_msg),
   .memreq_domain	  (memreq_domain),

   // Memory Response

   .memresp_msg       (memresp_msg),
   .memresp_domain	  (memresp_domain),

   // control signals (ctrl->dpath)
   .amo_sel           (amo_sel),
   .cachereq_en       (cachereq_en),
   .memresp_en        (memresp_en),
   .is_refill         (is_refill),
   .tag_array_0_wen   (tag_array_0_wen),
   .tag_array_0_ren   (tag_array_0_ren),
   .tag_array_1_wen   (tag_array_1_wen),
   .tag_array_1_ren   (tag_array_1_ren),
   .nsb_array_0_wen   (nsb_array_0_wen),
   .nsb_array_0_ren   (nsb_array_0_ren),
   .nsb_array_1_wen   (nsb_array_1_wen),
   .nsb_array_1_ren   (nsb_array_1_ren),
   .way_sel           (way_sel),
   .data_array_wen    (data_array_wen),
   .data_array_ren    (data_array_ren),
   .data_array_wben   (data_array_wben),
   .read_data_reg_en  (read_data_reg_en),
   .read_tag_reg_en   (read_tag_reg_en),
   .read_byte_sel     (read_byte_sel),
   .memreq_type       (memreq_type),
   .cacheresp_type    (cacheresp_type),
   .secure_mask		  (secure_mask),

   // status signals  (dpath->ctrl)
   .cachereq_type     (cachereq_type),
   .cachereq_addr     (cachereq_addr),
   .cachereq_nsbit	  (cachereq_nsbit),
   .tag_match_0       (tag_match_0),
   .tag_match_1       (tag_match_1),
   .nsb_match_0		  (nsb_match_0),
   .nsb_match_1		  (nsb_match_1)
  );

endmodule

`endif
