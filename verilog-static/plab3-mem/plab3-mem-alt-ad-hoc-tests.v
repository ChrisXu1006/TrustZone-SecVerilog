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
  integer dumper_index;
  initial begin
    // Dump data_array
    for(dumper_index = 0; dumper_index < 16; dumper_index = dumper_index + 1)
      $dumpvars(0, th.cache.dpath.data_array.mem[dumper_index]);
    // Dump tag_array_0
    for(dumper_index = 0; dumper_index < 8; dumper_index = dumper_index + 1)
      $dumpvars(0, th.cache.dpath.tag_array_0.mem[dumper_index]);
    // Dump tag_array_1
    for(dumper_index = 0; dumper_index < 8; dumper_index = dumper_index + 1)
      $dumpvars(0, th.cache.dpath.tag_array_1.mem[dumper_index]);
    // Dump dirty_bits_0
    for(dumper_index = 0; dumper_index < 8; dumper_index = dumper_index + 1)
      $dumpvars(0, th.cache.ctrl.dirty_bits_0.rfile[dumper_index]);
    // Dump dirty_bits_1
    for(dumper_index = 0; dumper_index < 8; dumper_index = dumper_index + 1)
      $dumpvars(0, th.cache.ctrl.dirty_bits_1.rfile[dumper_index]);
    // Dump valid_bits_0
    for(dumper_index = 0; dumper_index < 8; dumper_index = dumper_index + 1)
      $dumpvars(0, th.cache.ctrl.valid_bits_0.rfile[dumper_index]);
    // Dump valid_bits_1
    for(dumper_index = 0; dumper_index < 8; dumper_index = dumper_index + 1)
      $dumpvars(0, th.cache.ctrl.valid_bits_1.rfile[dumper_index]);
    // Dump lru_bits
    for(dumper_index = 0; dumper_index < 8; dumper_index = dumper_index + 1)
      $dumpvars(0, th.cache.ctrl.lru_bits.rfile[dumper_index]);
  end

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

  localparam c_resp_rd = `VC_MEM_RESP_MSG_TYPE_READ;
  localparam c_resp_wr = `VC_MEM_RESP_MSG_TYPE_WRITE;
  localparam c_resp_wn = `VC_MEM_RESP_MSG_TYPE_WRITE_INIT;

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
  // Ad-hoc test: init loads one byte
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "init - loading one word in the 0th cacheline" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ----------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000000, 2'd0, 32'he110341d, c_resp_wn, 8'h00, 2'd0, 32'h???????? );

    run_test;

    if ( th.done )
      `VC_ASSERT( th.cache.dpath.data_array.mem[0][31:0] == 32'he110341d );

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Ad-hoc test: init loads second byte
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "init - loading second word in the 0th cacheline" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ----------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000004, 2'd0, 32'h0c1a55e5, c_resp_wn, 8'h00, 2'd0, 32'h???????? );

    run_test;

    if ( th.done ) begin
      `VC_ASSERT( th.cache.dpath.data_array.mem[0][63:32] == 32'h0c1a55e5 );
    end

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Ad-hoc test: init loads a full cacheline
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "init - loading the full 0th cacheline" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ----------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000000, 2'd0, 32'h1abe1ed0, c_resp_wn, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wn, 8'h00, 32'h00000004, 2'd0, 32'h1abe1ed1, c_resp_wn, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wn, 8'h00, 32'h00000008, 2'd0, 32'h1abe1ed2, c_resp_wn, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wn, 8'h00, 32'h0000000c, 2'd0, 32'h1abe1ed3, c_resp_wn, 8'h00, 2'd0, 32'h???????? );

    run_test;

    if ( th.done ) begin
      `VC_ASSERT( th.cache.dpath.data_array.mem[0] == 128'h1abe1ed3_1abe1ed2_1abe1ed1_1abe1ed0 );
    end

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Ad-hoc test: init loads cacheline 5
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "init - loading the full 5th cacheline" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ----------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000050, 2'd0, 32'hddc0ffee, c_resp_wn, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wn, 8'h00, 32'h00000054, 2'd0, 32'ha5a1ad5a, c_resp_wn, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wn, 8'h00, 32'h00000058, 2'd0, 32'h1ea1fa1f, c_resp_wn, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wn, 8'h00, 32'h0000005c, 2'd0, 32'hde1ec7ab, c_resp_wn, 8'h00, 2'd0, 32'h???????? );

    run_test;

    if ( th.done ) begin
      `VC_ASSERT( th.cache.dpath.data_array.mem[10] == 128'hde1ec7ab1e_a1fa1fa_5a1ad5_add_c0ffee );
    end

  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Ad-hoc test: init tries to write to a dirty cacheline
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "init - try to write to dirty cacheline" )
  begin
    init_test_case( 0, 0, 0 );

    // Initialize Port

    //         ----------------- memory request ----------------  --------- memory response ----------
    //         type      opaque addr          len   data          type       opaque len   data

    init_port( c_req_wn, 8'h00, 32'h00000050, 2'd0, 32'hde18de18, c_resp_wn, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wr, 8'h00, 32'h00000050, 2'd0, 32'hbeadbead, c_resp_wr, 8'h00, 2'd0, 32'h???????? );
    init_port( c_req_wn, 8'h00, 32'h00000058, 2'd0, 32'hc001c001, c_resp_wn, 8'h00, 2'd0, 32'h???????? );

    run_test;

    if ( th.done ) begin
      `VC_ASSERT( th.cache.dpath.data_array.mem[10][31:0] == 32'hbeadbead );
      `VC_ASSERT( th.cache.dpath.data_array.mem[10][95:64] == 32'hc001c001 );
    end

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule
