//========================================================================
// Cache Test Harness
//========================================================================
// This harness is meant to be instatiated for a specific implementation
// of a memory system module and optionally a cache implementation using
// the special IMPL defines like this:
//
// `define PLAB3_CACHE_IMPL     plab3_mem_BlockingCacheBase
// `define PLAB3_MEM_IMPL_STR  "plab3-mem-BlockingCacheBase"
//
// `include "plab3-mem-BlockingCacheBase.v"
// `include "plab3-mem-test-harness.v"

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-test.v"

`include "vc-TestRandDelayMem_1port.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness
(
  input         clk,
  input         reset,
  input         mem_clear,
  input  [31:0] src_max_delay,
  input  [31:0] mem_max_delay,
  input  [31:0] sink_max_delay,
  output [31:0] num_failed,
  output        done
);

  // Local parameters

  localparam c_cache_nbytes       = 256;
  localparam c_cache_opaque_nbits = 8;
  localparam c_cache_addr_nbits   = 32;
  localparam c_cache_data_nbits   = 32;

  localparam c_mem_nbytes       = 1<<16;
  localparam c_mem_opaque_nbits = 8;
  localparam c_mem_addr_nbits   = 32;
  localparam c_mem_data_nbits   = 128;

  localparam c_cache_req_nbits  = `VC_MEM_REQ_MSG_NBITS(c_cache_opaque_nbits,c_cache_addr_nbits,c_cache_data_nbits);
  localparam c_cache_resp_nbits = `VC_MEM_RESP_MSG_NBITS(c_cache_opaque_nbits,c_cache_data_nbits);

  localparam c_mem_req_nbits  = `VC_MEM_REQ_MSG_NBITS(c_mem_opaque_nbits,c_mem_addr_nbits,c_mem_data_nbits);
  localparam c_mem_resp_nbits = `VC_MEM_RESP_MSG_NBITS(c_mem_opaque_nbits,c_mem_data_nbits);

  // Test source
  wire                         src_val;
  wire                         src_rdy;
  wire [c_cache_req_nbits-1:0] src_msg;
  wire                         src_done;

  vc_TestRandDelaySource#(c_cache_req_nbits) src
  (
    .clk       (clk),
    .reset     (reset),
    .max_delay (src_max_delay),
    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),
    .done      (src_done)
  );

  // Cache under test

  wire                          sink_val;
  wire                          sink_rdy;
  wire [c_cache_resp_nbits-1:0] sink_msg;

  wire                          memreq_val;
  wire                          memreq_rdy;
  wire [c_mem_req_nbits-1:0]    memreq_msg;
  wire                          memresp_val;
  wire                          memresp_rdy;
  wire [c_mem_resp_nbits-1:0]   memresp_msg;

  `PLAB3_CACHE_IMPL
  #(
    .p_mem_nbytes   (c_cache_nbytes)
  )
  cache
  (
    .clk           (clk),
    .reset         (reset),

    .cachereq_val  (src_val),
    .cachereq_rdy  (src_rdy),
    .cachereq_msg  (src_msg),

    .cacheresp_val (sink_val),
    .cacheresp_rdy (sink_rdy),
    .cacheresp_msg (sink_msg),

    .memreq_val  (memreq_val),
    .memreq_rdy  (memreq_rdy),
    .memreq_msg  (memreq_msg),

    .memresp_val (memresp_val),
    .memresp_rdy (memresp_rdy),
    .memresp_msg (memresp_msg)
  );

  //----------------------------------------------------------------------
  // Initialize the test memory
  //----------------------------------------------------------------------

  vc_TestRandDelayMem_1port
  #(
    .p_mem_nbytes   (c_mem_nbytes),
    .p_opaque_nbits (c_mem_opaque_nbits),
    .p_addr_nbits   (c_mem_addr_nbits),
    .p_data_nbits   (c_mem_data_nbits)
  )
  test_mem
  (
    .clk          (clk),
    .reset        (reset),
    // we reset memory on reset
    .mem_clear    (reset),

    .max_delay    (mem_max_delay),

    .memreq_val   (memreq_val),
    .memreq_rdy   (memreq_rdy),
    .memreq_msg   (memreq_msg),

    .memresp_val  (memresp_val),
    .memresp_rdy  (memresp_rdy),
    .memresp_msg  (memresp_msg)
  );

  // Test sink

  wire [31:0] sink_num_failed;
  wire        sink_done;

  vc_TestRandDelaySink#(c_cache_resp_nbits) sink
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (sink_val),
    .rdy        (sink_rdy),
    .msg        (sink_msg),
    .num_failed (sink_num_failed),
    .done       (sink_done)
  );

  // Done when both source and sink are done for both ports

  assign done = src_done & sink_done;

  // Num failed is sum from both sinks

  assign num_failed = sink_num_failed;

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  vc_MemReqMsgTrace#(c_cache_opaque_nbits, c_cache_addr_nbits, c_cache_data_nbits) cachereq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (src_val),
    .rdy   (src_rdy),
    .msg   (src_msg)
  );

  vc_MemRespMsgTrace#(c_cache_opaque_nbits, c_cache_data_nbits) cacheresp_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (sink_val),
    .rdy   (sink_rdy),
    .msg   (sink_msg)
  );

  vc_MemReqMsgTrace#(c_mem_opaque_nbits, c_mem_addr_nbits, c_mem_data_nbits) memreq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (memreq_val),
    .rdy   (memreq_rdy),
    .msg   (memreq_msg)
  );

  vc_MemRespMsgTrace#(c_mem_opaque_nbits, c_mem_data_nbits) memresp_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (memresp_val),
    .rdy   (memresp_rdy),
    .msg   (memresp_msg)
  );

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    cachereq_trace.trace_module( trace );

    vc_trace_str( trace, " > " );

    cache.trace_module( trace );

    vc_trace_str( trace, " " );

    memreq_trace.trace_module( trace );

    vc_trace_str( trace, " | " );

    memresp_trace.trace_module( trace );

    vc_trace_str( trace, " > " );

    cacheresp_trace.trace_module( trace );

  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `PLAB3_MEM_IMPL_STR )
  
  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  reg         th_reset = 1;
  reg         th_mem_clear;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_mem_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire [31:0] th_num_failed;
  wire        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .mem_clear      (th_mem_clear),
    .src_max_delay  (th_src_max_delay),
    .mem_max_delay  (th_mem_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .num_failed     (th_num_failed),
    .done           (th_done)
  );

  //------------------------------------------------------------------------
  // Helper task to initialize source/sink delays
  //------------------------------------------------------------------------

  task init_test_case
  (
    input [31:0] src_max_delay,
    input [31:0] mem_max_delay,
    input [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_mem_max_delay  = mem_max_delay;
    th_sink_max_delay = sink_max_delay;
    // reset the index for test source/sink
    th_index = 0;

    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;
  end
  endtask

  //----------------------------------------------------------------------
  // task to load to test memory
  //----------------------------------------------------------------------

  task load_mem
  (
    input [31:0]  addr,
    input [127:0] data
  );
  begin
    th.test_mem.mem.m[ addr >> 4 ] = data;
  end
  endtask

  //------------------------------------------------------------------------
  // Helper task to initalize source/sink
  //------------------------------------------------------------------------

  reg [`VC_MEM_REQ_MSG_NBITS(8,32,32)-1:0] th_port_memreq;
  reg [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]   th_port_memresp;
  // index into the next test src/sink index
  reg [31:0] th_index = 0;

  task init_port
  (
    //input [1023:0] index,

    input [`VC_MEM_REQ_MSG_TYPE_NBITS(8,32,32)-1:0]   memreq_type,
    input [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,32,32)-1:0] memreq_opaque,
    input [`VC_MEM_REQ_MSG_ADDR_NBITS(8,32,32)-1:0]   memreq_addr,
    input [`VC_MEM_REQ_MSG_LEN_NBITS(8,32,32)-1:0]    memreq_len,
    input [`VC_MEM_REQ_MSG_DATA_NBITS(8,32,32)-1:0]   memreq_data,

    input [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]     memresp_type,
    input [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0]   memresp_opaque,
    input [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]      memresp_len,
    input [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]     memresp_data
  );
  begin
    th_port_memreq[`VC_MEM_REQ_MSG_TYPE_FIELD(8,32,32)]   = memreq_type;
    th_port_memreq[`VC_MEM_REQ_MSG_OPAQUE_FIELD(8,32,32)] = memreq_opaque;
    th_port_memreq[`VC_MEM_REQ_MSG_ADDR_FIELD(8,32,32)]   = memreq_addr;
    th_port_memreq[`VC_MEM_REQ_MSG_LEN_FIELD(8,32,32)]    = memreq_len;
    th_port_memreq[`VC_MEM_REQ_MSG_DATA_FIELD(8,32,32)]   = memreq_data;

    th_port_memresp[`VC_MEM_RESP_MSG_TYPE_FIELD(8,32)]    = memresp_type;
    th_port_memresp[`VC_MEM_RESP_MSG_OPAQUE_FIELD(8,32)]  = memresp_opaque;
    th_port_memresp[`VC_MEM_RESP_MSG_LEN_FIELD(8,32)]     = memresp_len;
    th_port_memresp[`VC_MEM_RESP_MSG_DATA_FIELD(8,32)]    = memresp_data;

    th.src.src.m[th_index]   = th_port_memreq;
    th.sink.sink.m[th_index] = th_port_memresp;

    // increment the index for the next call to init_port
    th_index = th_index + 1;

    // the following is to prevent previous test cases to "leak" into the
    // next cases
    th.src.src.m[th_index]   = 'hx;
    th.sink.sink.m[th_index] = 'hx;
  end
  endtask

  // Helper local params

  localparam c_req_rd  = `VC_MEM_REQ_MSG_TYPE_READ;
  localparam c_req_wr  = `VC_MEM_REQ_MSG_TYPE_WRITE;
  localparam c_req_wn  = `VC_MEM_REQ_MSG_TYPE_WRITE_INIT;
  localparam c_req_ad  = `VC_MEM_REQ_MSG_TYPE_AMO_ADD;
  localparam c_req_an  = `VC_MEM_REQ_MSG_TYPE_AMO_AND;
  localparam c_req_ao  = `VC_MEM_REQ_MSG_TYPE_AMO_OR;

  localparam c_resp_rd = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam c_resp_wr = `VC_MEM_RESP_MSG_TYPE_WRITE;
  localparam c_resp_wn = `VC_MEM_RESP_MSG_TYPE_WRITE_INIT;
  localparam c_resp_ad = `VC_MEM_RESP_MSG_TYPE_AMO_ADD;
  localparam c_resp_an = `VC_MEM_RESP_MSG_TYPE_AMO_AND;
  localparam c_resp_ao = `VC_MEM_RESP_MSG_TYPE_AMO_OR;

  //----------------------------------------------------------------------
  // Include Python-generated input datasets
  //----------------------------------------------------------------------

  `include "plab3-mem-input-gen_random-writeread.py.v"

  `include "plab3-mem-input-gen_random.py.v"

  `include "plab3-mem-input-gen_ustride.py.v"

  `include "plab3-mem-input-gen_stride2.py.v"

  `include "plab3-mem-input-gen_stride4.py.v"

  `include "plab3-mem-input-gen_shared.py.v"

  `include "plab3-mem-input-gen_ustride-shared.py.v"

  `include "plab3-mem-input-gen_loop-2d.py.v"

  `include "plab3-mem-input-gen_loop-3d.py.v"

  //------------------------------------------------------------------------
  // Long test: tests corner cases and conflict, compulsory, capacity misses
  //------------------------------------------------------------------------

  reg [31:0] i;

  task init_long;

  begin
    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wr, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_wr, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_wr, 8'h01, 32'h00000004, 2'd0, 32'h0e0f0102, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000004
    init_port( c_req_rd, 8'h02, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h0a0b0c0d ); // read  word  0x00000000
    init_port( c_req_rd, 8'h03, 32'h00000004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x00000004

    // try forcing some conflict misses to force evictions

    init_port( c_req_wr, 8'h04, 32'h00004000, 2'd0, 32'hcafecafe, c_resp_wr, 8'h04, 2'd0, 32'h???????? ); // write word  0x00004000
    init_port( c_req_wr, 8'h05, 32'h00004004, 2'd0, 32'hebabefac, c_resp_wr, 8'h05, 2'd0, 32'h???????? ); // write word  0x00004004
    init_port( c_req_rd, 8'h06, 32'h00004000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h06, 2'd0, 32'hcafecafe ); // read  word  0x00004000
    init_port( c_req_rd, 8'h07, 32'h00004004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'hebabefac ); // read  word  0x00004004

    init_port( c_req_wr, 8'h00, 32'h00008000, 2'd0, 32'haaaeeaed, c_resp_wr, 8'h00, 2'd0, 32'h???????? ); // write word  0x00008000
    init_port( c_req_wr, 8'h01, 32'h00008004, 2'd0, 32'h0e0f0102, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00008004
    init_port( c_req_rd, 8'h03, 32'h00008004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x00008004
    init_port( c_req_rd, 8'h02, 32'h00008000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'haaaeeaed ); // read  word  0x00008000

    init_port( c_req_wr, 8'h04, 32'h0000c000, 2'd0, 32'hcacafefe, c_resp_wr, 8'h04, 2'd0, 32'h???????? ); // write word  0x0000c000
    init_port( c_req_wr, 8'h05, 32'h0000c004, 2'd0, 32'hbeefbeef, c_resp_wr, 8'h05, 2'd0, 32'h???????? ); // write word  0x0000c004
    init_port( c_req_rd, 8'h06, 32'h0000c000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h06, 2'd0, 32'hcacafefe ); // read  word  0x0000c000
    init_port( c_req_rd, 8'h07, 32'h0000c004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'hbeefbeef ); // read  word  0x0000c004

    init_port( c_req_wr, 8'hf5, 32'h0000c004, 2'd0, 32'hdeadbeef, c_resp_wr, 8'hf5, 2'd0, 32'h???????? ); // write word  0x0000c004
    init_port( c_req_wr, 8'hd5, 32'h0000d004, 2'd0, 32'hbeefbeef, c_resp_wr, 8'hd5, 2'd0, 32'h???????? ); // write word  0x0000d004
    init_port( c_req_wr, 8'he5, 32'h0000e004, 2'd0, 32'hbeefbeef, c_resp_wr, 8'he5, 2'd0, 32'h???????? ); // write word  0x0000e004
    init_port( c_req_wr, 8'hc5, 32'h0000f004, 2'd0, 32'hbeefbeef, c_resp_wr, 8'hc5, 2'd0, 32'h???????? ); // write word  0x0000f004

    // now refill those same cache lines to make sure we wrote correctly
    // to the memory earlier and make sure we can read from memory

    init_port( c_req_rd, 8'h06, 32'h00004000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h06, 2'd0, 32'hcafecafe ); // read  word  0x00004000
    init_port( c_req_rd, 8'h07, 32'h00004004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'hebabefac ); // read  word  0x00004004
    init_port( c_req_rd, 8'h02, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h0a0b0c0d ); // read  word  0x00000000
    init_port( c_req_rd, 8'h03, 32'h00000004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x00000004
    init_port( c_req_rd, 8'h03, 32'h00008004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x00008004
    init_port( c_req_rd, 8'h02, 32'h00008000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'haaaeeaed ); // read  word  0x00008000
    init_port( c_req_rd, 8'h06, 32'h0000c000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h06, 2'd0, 32'hcacafefe ); // read  word  0x0000c000
    init_port( c_req_rd, 8'h07, 32'h0000c004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'hdeadbeef ); // read  word  0x0000c004
    init_port( c_req_rd, 8'h07, 32'h0000d004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'hbeefbeef ); // read  word  0x0000d004
    init_port( c_req_rd, 8'h08, 32'h0000e004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h08, 2'd0, 32'hbeefbeef ); // read  word  0x0000e004
    init_port( c_req_rd, 8'h09, 32'h0000f004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h09, 2'd0, 32'hbeefbeef ); // read  word  0x0000f004

    /*
    // now do some memory sweep to force capacity miss for small caches

    for ( i = 32'h00005000; i < 32'h00005200; i = i + 4 ) begin
      // write the inverse of the address as the data
      init_port( c_req_wr, 8'h00, i, 2'd0, ~i, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    end

    // check some of the data
    for ( i = 32'h00005000; i < 32'h00005200; i = i + 36 ) begin
      init_port( c_req_rd, 8'h02, i, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, ~i );
    end

    // finally check the older data

    init_port( c_req_rd, 8'h06, 32'h00004000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h06, 2'd0, 32'hcafecafe ); // read  word  0x00004000
    init_port( c_req_rd, 8'h07, 32'h00004004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'hebabefac ); // read  word  0x00004004
    init_port( c_req_rd, 8'h02, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h0a0b0c0d ); // read  word  0x00000000
    init_port( c_req_rd, 8'h03, 32'h00000004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x00000004
    init_port( c_req_rd, 8'h03, 32'h00008004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x00008004
    init_port( c_req_rd, 8'h02, 32'h00008000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'haaaeeaed ); // read  word  0x00008000
    init_port( c_req_rd, 8'h06, 32'h0000c000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h06, 2'd0, 32'hcacafefe ); // read  word  0x0000c000
    init_port( c_req_rd, 8'h07, 32'h0000c004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'hdeadbeef ); // read  word  0x0000c004
    init_port( c_req_rd, 8'h07, 32'h0000d004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'hbeefbeef ); // read  word  0x0000d004
    init_port( c_req_rd, 8'h08, 32'h0000e004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h08, 2'd0, 32'hbeefbeef ); // read  word  0x0000e004
    init_port( c_req_rd, 8'h09, 32'h0000f004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h09, 2'd0, 32'hbeefbeef ); // read  word  0x0000f004
*/
  end
  endtask

  task init_amo;
  begin

    init_port( c_req_wr, 8'h00, 32'h0000, 2'd0, 32'h0a0b0c0d, c_resp_wr, 8'h00, 2'd0, 32'h???????? ); // write word  0x0000
    init_port( c_req_wr, 8'h01, 32'h0010, 2'd0, 32'h0e0f0102, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x0010
    init_port( c_req_wr, 8'h01, 32'h0014, 2'd0, 32'h00000000, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x0014
    init_port( c_req_wr, 8'h01, 32'h0018, 2'd0, 32'h00000000, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x0018
    init_port( c_req_wr, 8'h01, 32'h001c, 2'd0, 32'h00000000, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x001c
    init_port( c_req_rd, 8'h02, 32'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h0a0b0c0d ); // read  word  0x0000
    init_port( c_req_rd, 8'h03, 32'h0010, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x0010

    // Test amos

    init_port( c_req_ao, 8'h02, 32'h0000, 2'd0, 32'hf0f0f0f0, c_resp_ao, 8'h02, 2'd0, 32'h0a0b0c0d ); // amo.or word  0x0000
    init_port( c_req_rd, 8'h03, 32'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'hfafbfcfd ); // read  word  0x0000
    init_port( c_req_ad, 8'h04, 32'h0010, 2'd0, 32'h00000fff, c_resp_ad, 8'h04, 2'd0, 32'h0e0f0102 ); // amo.add word  0x0010
    init_port( c_req_rd, 8'h05, 32'h0010, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h05, 2'd0, 32'h0e0f1101 ); // read  word  0x0010
    init_port( c_req_an, 8'h06, 32'h0000, 2'd0, 32'h33333333, c_resp_an, 8'h06, 2'd0, 32'hfafbfcfd ); // amo.and word  0x0000
    init_port( c_req_rd, 8'h07, 32'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'h32333031 ); // read  word  0x0000

  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    while ( !th_done && (th.trace_cycles < 5000) ) begin
      th.trace_display();
      #10;
    end

    `VC_TEST_INCREMENT_NUM_FAILED( th_num_failed );
    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // read hit path test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "read hit path (clean)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000000, 2'd0, 32'h0a0b0c0d, c_resp_wn, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_wn, 8'h01, 32'h00000004, 2'd0, 32'h0e0f0102, c_resp_wn, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000004
    init_port( c_req_rd, 8'h02, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h0a0b0c0d ); // read  word  0x00000000
    init_port( c_req_rd, 8'h03, 32'h00000004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x00000004

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // write hit path test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "write hit path (clean)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000000, 2'd0, 32'h0e1ec7ed, c_resp_wn, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_wr, 8'h01, 32'h00000000, 2'd0, 32'h05eaf00d, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_rd, 8'h02, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h05eaf00d ); // read  word  0x00000000

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // read hit path test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "read hit path (dirty)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000000, 2'd0, 32'heffec7ed, c_resp_wn, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_wr, 8'h01, 32'h00000000, 2'd0, 32'hb007ab1e, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // read  word  0x00000000
    init_port( c_req_rd, 8'h02, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'hb007ab1e ); // read  word  0x00000004

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // write hit path test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "write hit path (dirty)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000000, 2'd0, 32'h0c01de57, c_resp_wn, 8'h00, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_wr, 8'h01, 32'h00000000, 2'd0, 32'h5e77ab1e, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_wr, 8'h02, 32'h00000000, 2'd0, 32'hdeadbea7, c_resp_wr, 8'h02, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_rd, 8'h03, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'hdeadbea7 ); // read  word  0x00000000

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // refill path test
  //----------------------------------------------------------------------

    `VC_TEST_CASE_BEGIN( 5, "refill path (read miss)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_rd, 8'h00, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'hdeadbeef ); // read  word  0x00000000
    init_port( c_req_rd, 8'h01, 32'h00000004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'h00c0ffee ); // read  word  0x00000004

    load_mem( 32'h00000000, 128'h00000000_00000000_00c0ffee_deadbeef );

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // refill path test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "refill path (write miss)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_rd, 8'h00, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h0e5ca18d ); // read  word  0x00000000
    init_port( c_req_wr, 8'h01, 32'h00000100, 2'd0, 32'h00e1de57, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000100
    init_port( c_req_rd, 8'h02, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h00e1de57 ); // read  word  0x00000100

    load_mem( 32'h00000000, 128'h00000000_00000000_00ba11ad_0e5ca18d );

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // evict path test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "evict path (read miss)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_rd, 8'h00, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h5e1f1e55 ); // read  word  0x00000000
    init_port( c_req_wr, 8'h01, 32'h00000000, 2'd0, 32'h00beaded, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_rd, 8'h02, 32'h00000100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h00facade ); // read  word  0x00000100
    init_port( c_req_rd, 8'h03, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h00beaded ); // read  word  0x00000000

    load_mem( 32'h00000000, 128'h00000000_00000000_707a11ed_5e1f1e55 );
    load_mem( 32'h00000100, 128'h00000000_00000000_05ca1ded_00facade );

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // evict path test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 8, "evict path (write miss)" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_rd, 8'h00, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'h5eac0a57 ); // read  word  0x00000000
    init_port( c_req_wr, 8'h01, 32'h00000000, 2'd0, 32'ha77e57ed, c_resp_wr, 8'h01, 2'd0, 32'h???????? ); // write word  0x00000000
    init_port( c_req_rd, 8'h02, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'ha77e57ed ); // read  word  0x00000000
    init_port( c_req_wr, 8'h03, 32'h00000300, 2'd0, 32'h01ac705e, c_resp_wr, 8'h03, 2'd0, 32'h???????? ); // write word  0x00000300
    init_port( c_req_rd, 8'h04, 32'h00000300, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h04, 2'd0, 32'h01ac705e ); // write word  0x00000300

    load_mem( 32'h00000000, 128'h00000000_00000000_00000000_5eac0a57 );

    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // long test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 9, "long" )
  begin
    init_test_case( 0, 0, 0 );
    init_long;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // long test with random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 10, "long test with random delays (5, 3, 5)" )
  begin
    init_test_case( 5, 3, 5 );
    init_long;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // amo test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 11, "amo" )
  begin
    init_test_case( 0, 0, 0 );
    init_amo;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // amo test with random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 12, "amo test with random delays (5, 3, 5)" )
  begin
    init_test_case( 5, 3, 5 );
    init_amo;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // random write/read test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 13, "random-writeread" )
  begin
    init_test_case( 0, 0, 0 );
    init_random_writeread;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // random test with random delays
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 14, "random-writeread test with random delays (5, 3, 5)" )
  begin
    init_test_case( 5, 3, 5 );
    init_random_writeread;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // random test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 15, "random" )
  begin
    init_test_case( 0, 0, 0 );
    init_random;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // ustride test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 16, "ustride" )
  begin
    init_test_case( 0, 0, 0 );
    init_ustride;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // stride2 test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 17, "stride2" )
  begin
    init_test_case( 0, 0, 0 );
    init_stride2;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // stride4 test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 18, "stride4" )
  begin
    init_test_case( 0, 0, 0 );
    init_stride4;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // shared test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 19, "shared" )
  begin
    init_test_case( 0, 0, 0 );
    init_shared;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // ustride-shared test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 20, "ustride-shared" )
  begin
    init_test_case( 0, 0, 0 );
    init_ustride_shared;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // loop-2d test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 21, "loop-2d" )
  begin
    init_test_case( 0, 0, 0 );
    init_loop_2d;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // loop-3d test
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 22, "loop-3d" )
  begin
    init_test_case( 0, 0, 0 );
    init_loop_3d;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Set-assoc test (requires inspection of gtkwave)
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 23, "set-assoc test" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    // Write to cacheline 0 way 0
    init_port( c_req_wr, 8'h00, 32'h00000000, 2'd0, 32'hffffff00, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h01, 32'h00000004, 2'd0, 32'hffffff01, c_resp_wr, 8'h01, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h02, 32'h00000008, 2'd0, 32'hffffff02, c_resp_wr, 8'h02, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h03, 32'h0000000c, 2'd0, 32'hffffff03, c_resp_wr, 8'h03, 2'd0, 32'h???????? ); // LRU:1

    // Write to cacheline 0 way 1
    init_port( c_req_wr, 8'h04, 32'h00001000, 2'd0, 32'hffffff04, c_resp_wr, 8'h04, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h05, 32'h00001004, 2'd0, 32'hffffff05, c_resp_wr, 8'h05, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h06, 32'h00001008, 2'd0, 32'hffffff06, c_resp_wr, 8'h06, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h07, 32'h0000100c, 2'd0, 32'hffffff07, c_resp_wr, 8'h07, 2'd0, 32'h???????? ); // LRU:0

    // Evict way 0
    init_port( c_req_rd, 8'h08, 32'h00002000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h08, 2'd0, 32'h00facade ); // LRU:1
    // Read again from same cacheline to see if cache hits properly
    init_port( c_req_rd, 8'h09, 32'h00002004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h09, 2'd0, 32'h05ca1ded ); // LRU:1
    // Read from cacheline 0 way 1 to see if cache hits properly
    init_port( c_req_rd, 8'h0a, 32'h00001004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h0a, 2'd0, 32'hffffff05 ); // LRU:0
    // Write to cacheline 0 way 1 to see if cache hits properly
    init_port( c_req_wr, 8'h0b, 32'h0000100c, 2'd0, 32'hffffff09, c_resp_wr, 8'h0b, 2'd0, 32'h???????? ); // LRU:0
    // Read that back
    init_port( c_req_rd, 8'h0c, 32'h0000100c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h0c, 2'd0, 32'hffffff09 ); // LRU:0
    // Evict way 0 again
    init_port( c_req_rd, 8'h0d, 32'h00000000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h0d, 2'd0, 32'hffffff00 ); // LRU:1

    // Testing cacheline 7 now

    // Write to cacheline 7 way 0
    init_port( c_req_wr, 8'h10, 32'h00000070, 2'd0, 32'hffffff00, c_resp_wr, 8'h10, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h11, 32'h00000074, 2'd0, 32'hffffff01, c_resp_wr, 8'h11, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h12, 32'h00000078, 2'd0, 32'hffffff02, c_resp_wr, 8'h12, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h13, 32'h0000007c, 2'd0, 32'hffffff03, c_resp_wr, 8'h13, 2'd0, 32'h???????? ); // LRU:1

    // Write to cacheline 7 way 1
    init_port( c_req_wr, 8'h14, 32'h00001070, 2'd0, 32'hffffff04, c_resp_wr, 8'h14, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h15, 32'h00001074, 2'd0, 32'hffffff05, c_resp_wr, 8'h15, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h16, 32'h00001078, 2'd0, 32'hffffff06, c_resp_wr, 8'h16, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h17, 32'h0000107c, 2'd0, 32'hffffff07, c_resp_wr, 8'h17, 2'd0, 32'h???????? ); // LRU:0

    // Evict way 0
    init_port( c_req_rd, 8'h18, 32'h00002070, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h18, 2'd0, 32'h70facade ); // LRU:1
    // Read again from same cacheline to see if cache hits properly
    init_port( c_req_rd, 8'h19, 32'h00002074, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h19, 2'd0, 32'h75ca1ded ); // LRU:1
    // Read from cacheline 7 way 1 to see if cache hits properly
    init_port( c_req_rd, 8'h1a, 32'h00001074, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h1a, 2'd0, 32'hffffff05 ); // LRU:0
    // Write to cacheline 7 way 1 to see if cache hits properly
    init_port( c_req_wr, 8'h1b, 32'h0000107c, 2'd0, 32'hffffff09, c_resp_wr, 8'h1b, 2'd0, 32'h???????? ); // LRU:0
    // Read that back
    init_port( c_req_rd, 8'h1c, 32'h0000107c, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h1c, 2'd0, 32'hffffff09 ); // LRU:0
    // Evict way 0 again
    init_port( c_req_rd, 8'h1d, 32'h00000070, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h1d, 2'd0, 32'hffffff00 ); // LRU:1

    load_mem( 32'h00002000, 128'h00000000_00000000_05ca1ded_00facade );
    load_mem( 32'h00002070, 128'h00000000_00000000_75ca1ded_70facade );

    run_test;

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule
