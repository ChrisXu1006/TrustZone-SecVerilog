//=========================================================================
// Alternative Blocking Cache Datapath
//=========================================================================

`ifndef PLAB3_MEM_BLOCKING_L2_CACHE_DPATH_V
`define PLAB3_MEM_BLOCKING_L2_CACHE_DPATH_V

`include "vc-mem-msgs.v"
`include "vc-arithmetic.v"
`include "vc-muxes.v"
`include "vc-regs.v"
`include "vc-srams.v"

module plab3_mem_BlockingL2CacheDpath
#(
  parameter size    = 256,            // Cache size in bytes

  parameter p_idx_shamt = 0,

  parameter p_opaque_nbits   = 8,

  // local parameters not meant to be set from outside
  parameter dbw     = 32,             // Short name for data bitwidth
  parameter abw     = 32,             // Short name for addr bitwidth
  parameter clw     = 128,            // Short name for cacheline bitwidth
  parameter nblocks = size*8/clw,     // Number of blocks in the cache
  parameter idw     = $clog2(nblocks),// Short name for index width

  parameter o = p_opaque_nbits
)
(
  input                                              {L} clk,
  input                                              {L} reset,

  input                                              {L} domain,
  // Cache Request

  input [`VC_MEM_REQ_MSG_NBITS(o,abw,dbw)-1:0]       {Data domain} cachereq_msg,

  // Cache Response

  output [`VC_MEM_RESP_MSG_NBITS(o,dbw)-1:0]         {Data domain} cacheresp_msg,

  // Memory Request

  output [`VC_MEM_REQ_MSG_NBITS(o,abw,clw)-1:0]      {Data domain} memreq_msg,

  // Memory Response

  input												 {Ctrl domain} insecure,
  input [`VC_MEM_RESP_MSG_NBITS(o,clw)-1:0]          {Data domain} memresp_msg,

  // control signals (ctrl->dpath)
  input [1:0]                                        {Ctrl domain} amo_sel,
  input                                              {Ctrl domain} cachereq_en,
  input                                              {Ctrl domain} memresp_en,
  input                                              {Ctrl domain} is_refill,
  input                                              {Ctrl domain} tag_array_0_wen,
  input                                              {Ctrl domain} tag_array_0_ren,
  input                                              {Ctrl domain} tag_array_1_wen,
  input                                              {Ctrl domain} tag_array_1_ren,
  input                                              {Ctrl domain} way_sel,
  input                                              {Ctrl domain} data_array_wen,
  input                                              {Ctrl domain} data_array_ren,
  // width of cacheline divided by number of bits per byte
  input [clw/8-1:0]                                  {Ctrl domain} data_array_wben,
  input                                              {Ctrl domain} read_data_reg_en,
  input                                              {Ctrl domain} read_tag_reg_en,
  input [$clog2(clw/dbw)-1:0]                        {Ctrl domain} read_byte_sel,
  input [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0]     {Ctrl domain} memreq_type,
  input [`VC_MEM_RESP_MSG_TYPE_NBITS(o,dbw)-1:0]     {Ctrl domain} cacheresp_type,

  // status signals (dpath->ctrl)
  output [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0] {Ctrl domain} cachereq_type,
  output [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] {Ctrl domain} cachereq_addr,
  output                                             {Ctrl domain} tag_match_0,
  output                                             {Ctrl domain} tag_match_1
);

  // Unpack cache request

  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0]   {Ctrl domain} cachereq_addr_out;
  wire [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)-1:0]   {Data domain} cachereq_data_out;
  wire [`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,abw,dbw)-1:0] {Ctrl domain} cachereq_opaque_out;
  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0]   {Ctrl domain} cachereq_type_out;
  wire [`VC_MEM_REQ_MSG_LEN_NBITS(o,abw,dbw)-1:0]    {Ctrl domain} cachereq_len_out;

  vc_MemReqMsgUnpack#(o,abw,dbw) cachereq_msg_unpack
  (
    .msg    (cachereq_msg),

    .type   (cachereq_type_out),
    .opaque (cachereq_opaque_out),
    .addr   (cachereq_addr_out),
    .len    (cachereq_len_out),
    .data   (cachereq_data_out)
  );

  // Unpack memory response

  wire [`VC_MEM_RESP_MSG_DATA_NBITS(o,clw)-1:0]      {Data domain} memresp_data_out;
  wire [`VC_MEM_RESP_MSG_OPAQUE_NBITS(o,clw)-1:0]    {Ctrl domain} memresp_opaque_out;
  wire [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0]      {Ctrl domain} memresp_type_out;
  wire [`VC_MEM_RESP_MSG_LEN_NBITS(o,clw)-1:0]       {Ctrl domain} memresp_len_out;

  vc_MemRespMsgUnpack#(o,clw) memresp_msg_unpack
  (
    .domain (domain),
    .msg    (memresp_msg),

    .opaque (memresp_opaque_out),
    .type   (memresp_type_out),
    .len    (memresp_len_out),
    .data   (memresp_data_out)
  );

  // Register the unpacked cachereq_msg

  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0]   {Ctrl domain} cachereq_addr_reg_out;
  wire [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)-1:0]   {Data domain} cachereq_data_reg_out;
  wire [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0]   {Ctrl domain} cachereq_type_reg_out;
  wire [`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,abw,dbw)-1:0] {Ctrl domain} cachereq_opaque_reg_out;

  vc_EnResetReg_Ctrl #(`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw), 0) cachereq_type_reg
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (cachereq_en),
    .d      (cachereq_type_out),
    .q      (cachereq_type_reg_out)
  );

  vc_EnResetReg_Ctrl #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw), 0) cachereq_addr_reg
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (cachereq_en),
    .d      (cachereq_addr_out),
    .q      (cachereq_addr_reg_out)
  );

  vc_EnResetReg_Ctrl #(`VC_MEM_REQ_MSG_OPAQUE_NBITS(o,abw,dbw), 0) cachereq_opaque_reg
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (cachereq_en),
    .d      (cachereq_opaque_out),
    .q      (cachereq_opaque_reg_out)
  );

  vc_EnResetReg #(`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw), 0) cachereq_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (cachereq_en),
    .d      (cachereq_data_out),
    .q      (cachereq_data_reg_out)
  );

  assign cachereq_type = cachereq_type_reg_out;
  assign cachereq_addr = cachereq_addr_reg_out;

  // Register the unpacked data from memresp_msg

  wire [clw-1:0]                                   {Data domain} memresp_data_reg_out;

  vc_EnResetReg #(clw, 0) memresp_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (memresp_en),
    .d      (memresp_data_out),
    .q      (memresp_data_reg_out)
  );

  // Generate cachereq write data which will be the data field or some
  // calculation with the read data for amos

  wire [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)-1:0] {Data domain} cachereq_write_data;
  wire [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)-1:0] {Data domain} read_byte_sel_mux_out;

  vc_Mux4 #(dbw) amo_sel_mux
  (
    .domain(domain),
    .in0  (cachereq_data_reg_out),
    .in1  (cachereq_data_reg_out + read_byte_sel_mux_out),
    .in2  (cachereq_data_reg_out & read_byte_sel_mux_out),
    .in3  (cachereq_data_reg_out | read_byte_sel_mux_out),
    .sel  (amo_sel),
    .out  (cachereq_write_data)
  );


  // Replicate cachereq_write_data

  wire [`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)*clw/dbw-1:0] {Data domain} cachereq_write_data_replicated;

  genvar i;
  generate
    for ( i = 0; i < clw/dbw; i = i + 1 ) begin
      assign cachereq_write_data_replicated[`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)*(i+1)-1:`VC_MEM_REQ_MSG_DATA_NBITS(o,abw,dbw)*i] = cachereq_write_data;
    end
  endgenerate

  // Refill mux

  wire [`VC_MEM_RESP_MSG_DATA_NBITS(o,clw)-1:0] {Data domain} refill_mux_out;

  vc_Mux2 #(clw) refill_mux
  (
    .domain(domain),
    .in0  (cachereq_write_data_replicated),
    .in1  (memresp_data_reg_out),
    .sel  (is_refill),
    .out  (refill_mux_out)
  );

  // Taking slices of the cache request address
  //     byte offset: 2 bits wide
  //     word offset: 2 bits wide
  //     index: $clog2(nblocks) - 1 bits wide
  //     nbits: width of tag = width of addr - $clog2(nblocks) - 4
  //     entries: 256*8/128 = 16
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4-1:0] {Ctrl domain} cachereq_tag;
  // Index is 3 bits to account for the way number
  wire [4:0]                                         {Ctrl domain} cachereq_idx;

  assign cachereq_tag = cachereq_addr_reg_out[`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:4];
  // -1 for way
  assign cachereq_idx = cachereq_addr_reg_out[4+p_idx_shamt +: 5];

  // Tag array
  wire                                             {L}             tag_array_0_domain;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] {Ctrl tag_array_0_domain} tag_array_0_out;

  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] {Ctrl domain} tag_array_0_read_out;
  assign tag_array_0_read_out = ( tag_array_0_domain == domain ) ? tag_array_0_out : 0;  

  vc_CombinationalSRAM_1rw_Ctrl #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw),nblocks/2) tag_array_0
  (
    .clk           (clk),
    .reset         (reset),
    .in_domain     (domain),
    .read_addr     (cachereq_idx),
    .read_data     (tag_array_0_out),
    .write_en      (tag_array_0_wen),
    .read_en       (tag_array_0_ren),
    .write_byte_en (4'b1111),
    .write_addr    (cachereq_idx),
    .write_data    ( { 4'h0, cachereq_tag } ),
    .out_domain    (tag_array_0_domain)
  );

  // Tag array 1
  wire                                             {L}             tag_array_1_domain;
  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] {Ctrl tag_array_1_domain} tag_array_1_out;

  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0] {Ctrl domain} tag_array_1_read_out;
  assign tag_array_1_read_out = ( tag_array_1_domain == domain ) ? tag_array_1_out : 0;

  vc_CombinationalSRAM_1rw_Ctrl #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw),nblocks/2) tag_array_1
  (
    .clk           (clk),
    .reset         (reset),
    .in_domain     (domain),
    .read_addr     (cachereq_idx),
    .read_data     (tag_array_1_out),
    .write_en      (tag_array_1_wen),
    .read_en       (tag_array_1_ren),
    .write_byte_en (4'b1111),
    .write_addr    (cachereq_idx),
    .write_data    ( { 4'h0, cachereq_tag } ),
    .out_domain    (tag_array_1_domain)
  );

  wire           {L}                        data_array_domain;
  wire [clw-1:0] {Data data_array_domain} data_array_out;

  wire [clw-1:0] {Data domain}            data_array_read_out;
  assign data_array_read_out = ( data_array_domain == domain ) ? data_array_out : 0;

  // Data array
  vc_CombinationalSRAM_1rw #(clw, nblocks) data_array
  (
    .clk           (clk),
    .reset         (reset),
    // Whether way_sel is appended or prepended does not matter since
    // it's just a matter of how the cachelines are actually organized in
    // the data_array
    .in_domain     (domain),
    .read_addr     ( { cachereq_idx, way_sel } ),
    .read_data     (data_array_out),
    .write_en      (data_array_wen),
    .read_en       (data_array_ren),
    .write_byte_en (data_array_wben),
    .write_addr    ( { cachereq_idx, way_sel } ),
    .write_data    (refill_mux_out),
    .out_domain    (data_array_domain)
  );

  // Eq comparator to check for tag matching (tag_compare_0)
  vc_EqComparator #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4) tag_compare_0
  (
    .domain(domain),
    .in0 (cachereq_tag),
    .in1 (tag_array_0_read_out[27:0]),
    .out (tag_match_0)
  );

  // Eq comparator to check for tag matching (tag_compare_1)
  vc_EqComparator #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4) tag_compare_1
  (
    .domain(domain),
    .in0 (cachereq_tag),
    .in1 (tag_array_1_read_out[27:0]),
    .out (tag_match_1)
  );

  // Mux that selects between the ways for requesting from memory
  wire [27:0]    {Ctrl domain} way_sel_mux_out;

  vc_Mux2 #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4) way_sel_mux
  (
    .domain(domain),
    .in0 (tag_array_0_read_out[27:0]),
    .in1 (tag_array_1_read_out[27:0]),
    .sel (way_sel),
    .out (way_sel_mux_out)
  );

  // Read data register

  wire [clw-1:0]   {Data domain} read_data_reg_out;

  vc_EnResetReg #(clw, 0) read_data_reg
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (read_data_reg_en),
    .d      (data_array_read_out),
    .q      (read_data_reg_out)
  );

  // Read data register

  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4-1:0]   {Ctrl domain} read_tag_reg_out;

  vc_EnResetReg_Ctrl #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4, 0) read_tag_reg
  (
    .clk    (clk),
    .reset  (reset),
    .domain (domain),
    .en     (read_tag_reg_en),
    .d      (way_sel_mux_out),
    .q      (read_tag_reg_out)
  );

  // Memreq Type Mux

  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4-1:0] {Ctrl domain} memreq_type_mux_out;

  vc_Mux2 #(`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-4) memreq_type_mux
  (
    .domain(domain),
    .in0  (cachereq_tag),
    .in1  (read_tag_reg_out),
    // TODO: change the following
    .sel  (memreq_type[0]),
    .out  (memreq_type_mux_out)
  );

  // Pack address for memory request

  wire [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,clw)-1:0] {Ctrl domain} memreq_addr;
  assign memreq_addr = { memreq_type_mux_out, 4'b0000 };

  // Select byte for cache response

  // vc_Mux4 #(dbw) read_byte_sel_mux
  // (
  //   .in0  (read_data_reg_out[dbw-1:0]),
  //   .in1  (read_data_reg_out[2*dbw-1:1*dbw]),
  //   .in2  (read_data_reg_out[3*dbw-1:2*dbw]),
  //   .in3  (read_data_reg_out[4*dbw-1:3*dbw]),
  //   .sel  (read_byte_sel),
  //   .out  (read_byte_sel_mux_out)
  // );

  wire [`VC_MEM_RESP_MSG_DATA_NBITS(o,dbw)-1:0]	{Data domain} read_byte_sec_mux_out;
  vc_Mux2 #(dbw) sec_mux
  (
    .domain(domain),
	.in0  (read_data_reg_out),
	.in1  ('hx),
	.sel  (insecure),
	.out  (read_byte_sec_mux_out)
  );

  // Pack cache response

  vc_MemRespMsgPack#(o,dbw) cacheresp_msg_pack
  (
    .domain (domain),
    .type   (cacheresp_type),
    .opaque (cachereq_opaque_reg_out),
    .len    (0),
    .data   (read_byte_sec_mux_out),
    .msg    (cacheresp_msg)
  );

  // Pack cache response
  vc_MemReqMsgPack#(o,abw,clw) memreq_msg_pack
  (
    .domain (domain),
    .type   (memreq_type),
    .opaque (0),
    .addr   (memreq_addr),
    .len    (0),
    .data   (read_data_reg_out),
    .msg    (memreq_msg)
  );

endmodule

`endif
