//=========================================================================
// Prefetch buffer control unit 
//=========================================================================

`ifndef PLAB3_MEM_PREFETCH_BUFFER_CTRL_V
`define PLAB3_MEM_PREFETCH_BUFFER_CTRL_V

`include "plab3-mem-DecodeWben.v"
`include "vc-mem-msgs.v"
`include "vc-regs.v"
`include "vc-assert.v"

module plab3_mem_PrefetchBufferCtrl
#(
  parameter size    = 256,            // Cache size in bytes

  parameter p_idx_shamt = 0,

  parameter p_opaque_nbits  = 8,

  // local parameters not meant to be set from outside
  parameter dbw     = 32,             // Short name for data bitwidth
  parameter abw     = 32,             // Short name for addr bitwidth
  parameter clw     = 128,            // Short name for cacheline bitwidth
  parameter nblocks = size*8/clw,     // Number of blocks in the cache

  parameter o = p_opaque_nbits
)
(
  input                                               {L}   clk,
  input                                               {L}   reset,

  input                                               {L}   domain,

  // indicate the content is found in the buffer
  output reg [1:0]									  {Ctrl domain} found,

  // Cache Request

  input                                               {Ctrl domain} cachereq_val,
  output reg                                          {Ctrl domain} cachereq_rdy,

  // Cache Response

  output reg                                          {Ctrl domain} cacheresp_val,
  input                                               {Ctrl domain} cacheresp_rdy,

  // Memory Request

  output reg                                          {Ctrl domain} memreq_val,
  input                                               {Ctrl domain} memreq_rdy,

  // Memory Response

  input                                               {Ctrl domain} memresp_val,
  output reg                                          {Ctrl domain} memresp_rdy,

  // control signals (ctrl->dpath)
  output reg [1:0]                                    {Ctrl domain} amo_sel,
  output reg                                          {Ctrl domain} cachereq_en,
  output reg                                          {Ctrl domain} memresp_en,
  output reg                                          {Ctrl domain} is_refill,
  output reg                                          {Ctrl domain} tag_array_0_wen,
  output reg                                          {Ctrl domain} tag_array_0_ren,
  output reg                                          {Ctrl domain} tag_array_1_wen,
  output reg                                          {Ctrl domain} tag_array_1_ren,
  output                                              {Ctrl domain} way_sel,
  output reg                                          {Ctrl domain} data_array_wen,
  output reg                                          {Ctrl domain} data_array_ren,
  // width of cacheline divided by number of bits per byte
  output reg [clw/8-1:0]                              {Ctrl domain} data_array_wben,
  output reg                                          {Ctrl domain} read_data_reg_en,
  output reg                                          {Ctrl domain} read_tag_reg_en,
  output [$clog2(clw/dbw)-1:0]                        {Ctrl domain} read_byte_sel,
  output reg [`VC_MEM_RESP_MSG_TYPE_NBITS(o,clw)-1:0] {Ctrl domain} memreq_type,
  output reg [`VC_MEM_RESP_MSG_TYPE_NBITS(o,dbw)-1:0] {Ctrl domain} cacheresp_type,

   // status signals (dpath->ctrl)
  input [`VC_MEM_REQ_MSG_TYPE_NBITS(o,abw,dbw)-1:0]   {Ctrl domain} cachereq_type,
  input [`VC_MEM_REQ_MSG_ADDR_NBITS(o,abw,dbw)-1:0]   {Ctrl domain} cachereq_addr,
  input                                               {Ctrl domain} tag_match_0,
  input                                               {Ctrl domain} tag_match_1
 );

  //----------------------------------------------------------------------
  // State Definitions
  //----------------------------------------------------------------------

  localparam STATE_IDLE               = 4'd0;
  localparam STATE_TAG_CHECK          = 4'd1;
  localparam STATE_READ_DATA_ACCESS   = 4'd2;
  localparam STATE_WRITE_DATA_ACCESS  = 4'd3;
  localparam STATE_WAIT               = 4'd4;
  localparam STATE_REFILL_REQUEST     = 4'd5;
  localparam STATE_REFILL_WAIT        = 4'd6;
  localparam STATE_REFILL_UPDATE      = 4'd7;
  localparam STATE_INIT_DATA_ACCESS   = 4'd15;

  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( reset ) begin
      state_reg <= 4'd0;
    end
    else begin
      state_reg <= state_next;
    end
  end

  //----------------------------------------------------------------------
  // State Transitions
  //----------------------------------------------------------------------

  wire {Ctrl domain} in_go        = cachereq_val  && cachereq_rdy;
  wire {Ctrl domain} out_go       = cacheresp_val && cacheresp_rdy;
  wire {Ctrl domain} hit_0        = is_valid_0 && tag_match_0;
  wire {Ctrl domain} hit_1        = is_valid_1 && tag_match_1;
  wire {Ctrl domain} hit          = hit_0 || hit_1;
  wire {Ctrl domain} is_read      = cachereq_type == `VC_MEM_REQ_MSG_TYPE_READ;
  wire {Ctrl domain} is_write     = cachereq_type == `VC_MEM_REQ_MSG_TYPE_WRITE;
  wire {Ctrl domain} is_init      = cachereq_type == `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  wire {Ctrl domain} is_amo       = amo_sel != 0;
  wire {Ctrl domain} read_hit     = is_read && hit;
  wire {Ctrl domain} write_hit    = is_write && hit;
  wire {Ctrl domain} amo_hit      = is_amo && hit;
  wire {Ctrl domain} miss_0       = !hit_0;
  wire {Ctrl domain} miss_1       = !hit_1;
  wire {Ctrl domain} refill       = cachereq_type == `VC_MEM_REQ_MSG_TYPE_PRELW;
  wire {Ctrl domain} evict        = (miss_0 && is_dirty_0 && !lru_way) || (miss_1 && is_dirty_1 && lru_way);

  reg [3:0] {Ctrl domain} state_reg;
  reg [3:0] {Ctrl domain} state_next;

  always @(*) begin

    state_next = state_reg;
    case ( state_reg )

      STATE_IDLE:
             if ( in_go        ) state_next = 4'd1;

      STATE_TAG_CHECK:
			 if ( read_hit     ) state_next = 4'd2;
        else if ( refill       ) state_next = 4'd5;
			else				 state_next = 4'd0; 

      STATE_READ_DATA_ACCESS:
        state_next = 4'd4;

      STATE_WRITE_DATA_ACCESS:
        state_next = 4'd4;

      STATE_INIT_DATA_ACCESS:
        state_next = 4'd4;

      STATE_REFILL_REQUEST:
             if ( memreq_rdy   ) state_next = 4'd6;
        else if ( !memreq_rdy  ) state_next = 4'd5;

      STATE_REFILL_WAIT:
			 if ( memresp_val  ) state_next = 4'd7;
        else if ( !memresp_val ) state_next = 4'd6;

      STATE_REFILL_UPDATE:
			state_next = 4'd4;            

      STATE_WAIT:
             if ( out_go       ) state_next = 4'd0;

    endcase

  end

  //----------------------------------------------------------------------
  // Valid/Dirty bits record
  //----------------------------------------------------------------------

  wire [2:0] {Ctrl domain} cachereq_idx = cachereq_addr[4+p_idx_shamt +: 3];
  reg        {Ctrl domain} valid_bit_in;
  reg        {Ctrl domain} valid_bits_write_en;
  wire       {Ctrl domain} valid_bits_write_en_0 = valid_bits_write_en && !way_sel;
  wire       {Ctrl domain} valid_bits_write_en_1 = valid_bits_write_en && way_sel;
  wire       {Ctrl domain} is_valid_0;
  wire       {Ctrl domain} is_valid_1;

  vc_ResetRegfile_1r1w#(1,8) valid_bits_0
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (cachereq_idx),
    .read_data  (is_valid_0),
    .write_en   (valid_bits_write_en_0),
    .write_addr (cachereq_idx),
    .write_data (valid_bit_in)
  );

  vc_ResetRegfile_1r1w#(1,8) valid_bits_1
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (cachereq_idx),
    .read_data  (is_valid_1),
    .write_en   (valid_bits_write_en_1),
    .write_addr (cachereq_idx),
    .write_data (valid_bit_in)
  );

  reg        {Ctrl domain} dirty_bit_in;
  reg        {Ctrl domain} dirty_bits_write_en;
  wire       {Ctrl domain} dirty_bits_write_en_0 = dirty_bits_write_en && !way_sel;
  wire       {Ctrl domain} dirty_bits_write_en_1 = dirty_bits_write_en && way_sel;
  wire       {Ctrl domain} is_dirty_0;
  wire       {Ctrl domain} is_dirty_1;

  vc_ResetRegfile_1r1w#(1,8) dirty_bits_0
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (cachereq_idx),
    .read_data  (is_dirty_0),
    .write_en   (dirty_bits_write_en_0),
    .write_addr (cachereq_idx),
    .write_data (dirty_bit_in)
  );

  vc_ResetRegfile_1r1w#(1,8) dirty_bits_1
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (cachereq_idx),
    .read_data  (is_dirty_1),
    .write_en   (dirty_bits_write_en_1),
    .write_addr (cachereq_idx),
    .write_data (dirty_bit_in)
  );

  reg        {Ctrl domain} lru_bit_in;
  reg        {Ctrl domain} lru_bits_write_en;
  wire       {Ctrl domain} lru_way;

  vc_ResetRegfile_1r1w#(1,8) lru_bits
  (
    .clk        (clk),
    .reset      (reset),
    .read_addr  (cachereq_idx),
    .read_data  (lru_way),
    .write_en   (lru_bits_write_en),
    .write_addr (cachereq_idx),
    .write_data (lru_bit_in)
  );

  //----------------------------------------------------------------------
  // Way selection.
  //   The way is determined in the tag check state, and is
  //   then recorded for the entire transaction
  //----------------------------------------------------------------------

  reg        {Ctrl domain} way_record_en;
  reg        {Ctrl domain} way_record_in;

  always @(*) begin
    if (hit) begin
      way_record_in = hit_0 ? 1'b0 :
                      ( hit_1 ? 1'b1 : 1'bx );
    end
    else
      way_record_in = lru_way; // If miss, write to the LRU way
  end

  vc_EnResetReg_Ctrl #(1, 0) way_record
  (
    .clk    (clk),
    .reset  (reset),
    .en     (way_record_en),
    .d      (way_record_in),
    .q      (way_sel)
  );

  //----------------------------------------------------------------------
  // State Outputs
  //----------------------------------------------------------------------

  // General parameters
  localparam x       = 1'dx;

  // Parameters for is_refill
  localparam r_x     = 1'dx;
  localparam r_c     = 1'd0; // fill data array from _c_ache
  localparam r_m     = 1'd1; // fill data array from _m_em

  // Parameters for memreq_type_mux
  localparam m_x     = 1'dx;
  localparam m_e     = `VC_MEM_REQ_MSG_TYPE_WRITE; // write to memory in an _e_vict
  localparam m_r     = `VC_MEM_REQ_MSG_TYPE_READ;  // write to memory in a _r_efill

  reg {Ctrl domain} tag_array_wen;
  reg {Ctrl domain} tag_array_ren;

  task cs
  (
   input cs_cachereq_rdy,
   input cs_cacheresp_val,
   input cs_memreq_val,
   input cs_memresp_rdy,
   input cs_cachereq_en,
   input cs_memresp_en,
   input cs_is_refill,
   input cs_tag_array_wen,
   input cs_tag_array_ren,
   input cs_data_array_wen,
   input cs_data_array_ren,
   input cs_read_data_reg_en,
   input cs_read_tag_reg_en,
   input cs_memreq_type,
   input cs_valid_bit_in,
   input cs_valid_bits_write_en,
   input cs_dirty_bit_in,
   input cs_dirty_bits_write_en,
   input cs_lru_bits_write_en,
   input cs_way_record_en,
   input[1:0] cs_found
  );
  begin
    cachereq_rdy        = cs_cachereq_rdy;
    cacheresp_val       = cs_cacheresp_val;
    memreq_val          = cs_memreq_val;
    memresp_rdy         = cs_memresp_rdy;
    cachereq_en         = cs_cachereq_en;
    memresp_en          = cs_memresp_en;
    is_refill           = cs_is_refill;
    tag_array_wen       = cs_tag_array_wen;
    tag_array_ren       = cs_tag_array_ren;
    data_array_wen      = cs_data_array_wen;
    data_array_ren      = cs_data_array_ren;
    read_data_reg_en    = cs_read_data_reg_en;
    read_tag_reg_en     = cs_read_tag_reg_en;
    memreq_type         = cs_memreq_type;
    valid_bit_in        = cs_valid_bit_in;
    valid_bits_write_en = cs_valid_bits_write_en;
    dirty_bit_in        = cs_dirty_bit_in;
    dirty_bits_write_en = cs_dirty_bits_write_en;
    lru_bits_write_en   = cs_lru_bits_write_en;
    way_record_en       = cs_way_record_en;
	found				= cs_found;
  end
  endtask

  // Set outputs using a control signal "table"

  always @(*) begin
                                   cs( 0,   0,    0,  0,   x,    x,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0,    0,    0,      0 );
    case ( state_reg )
      //                              cache cache mem mem  cache mem         tag   tag   data  data  read read mem  valid valid dirty dirty lru   way     found
      //                              req   resp  req resp req   resp is     array array array array data tag  req  bit   write bit   write write record
      //                              rdy   val   val rdy  en    en   refill wen   ren   wen   ren   en   en   type in    en    in    en    en    en
      STATE_IDLE:                  cs( 1,   0,    0,  0,   1,    0,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0,    0,    0,      2 );
      STATE_TAG_CHECK:             cs( 0,   0,    0,  0,   0,    0,   r_x,   0,    1,    0,    0,    0,   0,   m_x, x,    0,    x,    0,    0,    1,      0 );
      STATE_READ_DATA_ACCESS:      cs( 0,   0,    0,  0,   0,    0,   r_x,   0,    0,    0,    1,    1,   0,   m_x, x,    0,    x,    0,    1,    0,      1 );
      STATE_WRITE_DATA_ACCESS:     cs( 0,   0,    0,  0,   0,    0,   r_c,   1,    0,    1,    0,    0,   0,   m_x, 1,    1,    1,    1,    1,    0,      0 );
      STATE_INIT_DATA_ACCESS:      cs( 0,   0,    0,  0,   0,    0,   r_c,   1,    0,    1,    0,    0,   0,   m_x, 1,    1,    0,    1,    1,    0,      0 );
      STATE_REFILL_REQUEST:        cs( 0,   0,    1,  0,   0,    0,   r_x,   0,    0,    0,    0,    0,   0,   m_r, x,    0,    x,    0,    0,    0,      0 );
      STATE_REFILL_WAIT:           cs( 0,   0,    0,  1,   0,    1,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0,    0,    0,      0 );
      STATE_REFILL_UPDATE:         cs( 0,   0,    0,  0,   0,    0,   r_m,   1,    0,    1,    0,    0,   0,   m_x, 1,    1,    0,    1,    0,    0,      0 );
      STATE_WAIT:                  cs( 0,   1,    0,  0,   0,    0,   r_x,   0,    0,    0,    0,    0,   0,   m_x, x,    0,    x,    0,    0,    0,      0 );

    endcase
  end

  // lru bit determination
  always @(*) begin
    lru_bit_in = !way_sel;
  end

  // tag array enables

  always @(*) begin
    tag_array_0_wen = tag_array_wen && !way_sel;
    tag_array_0_ren = tag_array_ren;
    tag_array_1_wen = tag_array_wen && way_sel;
    tag_array_1_ren = tag_array_ren;
  end

  // Building data_array_wben
  // This is in control because we want to facilitate more complex patterns
  //   when we want to start supporting subword accesses

  wire [1:0]  {Ctrl domain} cachereq_offset = cachereq_addr[3:2];
  wire [15:0] {Ctrl domain} wben_decoder_out;

  plab3_mem_DecoderWben#(2) wben_decoder
  (
    .in  (cachereq_offset),
    .out (wben_decoder_out)
  );

  // Choose byte to read from cacheline based on what the offset was

  assign read_byte_sel = cachereq_offset;

  // managing the wben

  always @(*) begin
    // Logic to enable writing of the entire cacheline in case of refill and just one word for writes and init

    if ( is_refill )
      data_array_wben = 16'hffff;
    else
      data_array_wben = wben_decoder_out;

    // Managing the cache response type based on cache request type

    cacheresp_type = cachereq_type;
  end

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( cachereq_val  );
      `VC_ASSERT_NOT_X( cacheresp_rdy );
      `VC_ASSERT_NOT_X( memreq_rdy    );
      `VC_ASSERT_NOT_X( memresp_val   );
    end
  end

endmodule

`endif

