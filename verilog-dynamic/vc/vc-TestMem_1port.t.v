//========================================================================
// vc-TestMem_1port Unit Tests
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-TestMem_1port.v"
`include "vc-test.v"

//------------------------------------------------------------------------
// Test Harness
//------------------------------------------------------------------------

module TestHarness
(
  input         clk,
  input         reset,
  input         mem_clear,
  input  [31:0] src_max_delay,
  input  [31:0] sink_max_delay,
  output [31:0] num_failed,
  output        done
);

  // Local parameters

  localparam c_mem_nbytes   = 1024;
  localparam c_opaque_nbits = 8;
  localparam c_addr_nbits   = 16;
  localparam c_data_nbits   = 32;

  localparam c_req_nbits  = `VC_MEM_REQ_MSG_NBITS(c_opaque_nbits,c_addr_nbits,c_data_nbits);
  localparam c_resp_nbits = `VC_MEM_RESP_MSG_NBITS(c_opaque_nbits,c_data_nbits);

  // Test source

  wire                   src_val;
  wire                   src_rdy;
  wire [c_req_nbits-1:0] src_msg;
  wire                   src_done;

  vc_TestRandDelaySource#(c_req_nbits) src
  (
    .clk       (clk),
    .reset     (reset),
    .max_delay (src_max_delay),
    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),
    .done      (src_done)
  );

  // Test memory

  wire                     sink_val;
  wire                     sink_rdy;
  wire [c_resp_nbits-1:0]  sink_msg;

  vc_TestMem_1port
  #(
    .p_mem_nbytes   (c_mem_nbytes),
    .p_opaque_nbits (c_opaque_nbits),
    .p_addr_nbits   (c_addr_nbits),
    .p_data_nbits   (c_data_nbits)
  )
  mem
  (
    .clk          (clk),
    .reset        (reset),
    .mem_clear    (mem_clear),

    .memreq_val  (src_val),
    .memreq_rdy  (src_rdy),
    .memreq_msg  (src_msg),

    .memresp_val (sink_val),
    .memresp_rdy (sink_rdy),
    .memresp_msg (sink_msg)
  );

  // Test sink

  wire [31:0] sink_num_failed;
  wire        sink_done;

  vc_TestRandDelaySink#(c_resp_nbits) sink
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

  assign num_failed = sink_num_failed;

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    src.trace_module( trace );
    vc_trace_str( trace, " > " );

    mem.trace_module( trace );

    vc_trace_str( trace, " > " );
    sink.trace_module( trace );

  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "vc-TestMem_1port" )

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  reg         th_reset = 1;
  reg         th_mem_clear;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire [31:0] th_num_failed;
  wire        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .mem_clear      (th_mem_clear),
    .src_max_delay  (th_src_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .num_failed     (th_num_failed),
    .done           (th_done)
  );

  // Helper task to initialize source/sink delays

  task init_rand_delays
  (
    input [31:0] src_max_delay,
    input [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask

  // Helper task to initalize

  reg [`VC_MEM_REQ_MSG_NBITS(8,16,32)-1:0] th_port_memreq;
  reg [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]   th_port_memresp;

  task init_port
  (
    input [1023:0] index,

    input [`VC_MEM_REQ_MSG_TYPE_NBITS(8,16,32)-1:0]   memreq_type,
    input [`VC_MEM_REQ_MSG_OPAQUE_NBITS(8,16,32)-1:0] memreq_opaque,
    input [`VC_MEM_REQ_MSG_ADDR_NBITS(8,16,32)-1:0]   memreq_addr,
    input [`VC_MEM_REQ_MSG_LEN_NBITS(8,16,32)-1:0]    memreq_len,
    input [`VC_MEM_REQ_MSG_DATA_NBITS(8,16,32)-1:0]   memreq_data,

    input [`VC_MEM_RESP_MSG_TYPE_NBITS(8,32)-1:0]     memresp_type,
    input [`VC_MEM_RESP_MSG_OPAQUE_NBITS(8,32)-1:0]   memresp_opaque,
    input [`VC_MEM_RESP_MSG_LEN_NBITS(8,32)-1:0]      memresp_len,
    input [`VC_MEM_RESP_MSG_DATA_NBITS(8,32)-1:0]     memresp_data
  );
  begin
    th_port_memreq[`VC_MEM_REQ_MSG_TYPE_FIELD(8,16,32)]   = memreq_type;
    th_port_memreq[`VC_MEM_REQ_MSG_OPAQUE_FIELD(8,16,32)] = memreq_opaque;
    th_port_memreq[`VC_MEM_REQ_MSG_ADDR_FIELD(8,16,32)]   = memreq_addr;
    th_port_memreq[`VC_MEM_REQ_MSG_LEN_FIELD(8,16,32)]    = memreq_len;
    th_port_memreq[`VC_MEM_REQ_MSG_DATA_FIELD(8,16,32)]   = memreq_data;

    th_port_memresp[`VC_MEM_RESP_MSG_TYPE_FIELD(8,32)]    = memresp_type;
    th_port_memresp[`VC_MEM_RESP_MSG_OPAQUE_FIELD(8,32)]  = memresp_opaque;
    th_port_memresp[`VC_MEM_RESP_MSG_LEN_FIELD(8,32)]     = memresp_len;
    th_port_memresp[`VC_MEM_RESP_MSG_DATA_FIELD(8,32)]    = memresp_data;

    th.src.src.m[index]   = th_port_memreq;
    th.sink.sink.m[index] = th_port_memresp;
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

  // Common dataset

  task init_common;
  begin
    // Clear the memory

    #5;   th_mem_clear = 1'b1;
    #20;  th_mem_clear = 1'b0;

    // Initialize Port

    //         ----------------- memory request ----------------  --------- memory response ----------
    //         idx type      opaque addr      len   data          type       opaque len   data

    init_port( 0,  c_req_wr, 8'h00, 16'h0000, 2'd0, 32'h0a0b0c0d, c_resp_wr, 8'h00, 2'd0, 32'h???????? ); // write word  0x0000
    init_port( 1,  c_req_wn, 8'h01, 16'h0004, 2'd0, 32'h0e0f0102, c_resp_wn, 8'h01, 2'd0, 32'h???????? ); // write word  0x0004
    init_port( 2,  c_req_rd, 8'h02, 16'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h0a0b0c0d ); // read  word  0x0000
    init_port( 3,  c_req_rd, 8'h03, 16'h0004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x0004

    // Test byte accesses

    init_port( 4,  c_req_wr, 8'h04, 16'h0008, 2'd0, 32'h0a0b0c0d, c_resp_wr, 8'h04, 2'd0, 32'h???????? ); // write word  0x0008
    init_port( 5,  c_req_wr, 8'h05, 16'h0008, 2'd1, 32'hdeadbeef, c_resp_wr, 8'h05, 2'd1, 32'h???????? ); // write byte  0x0008
    init_port( 6,  c_req_rd, 8'h06, 16'h0008, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h06, 2'd1, 32'h??????ef ); // read  byte  0x0008
    init_port( 7,  c_req_rd, 8'h07, 16'h0009, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd1, 32'h??????0c ); // read  byte  0x0009
    init_port( 8,  c_req_rd, 8'h08, 16'h000a, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h08, 2'd1, 32'h??????0b ); // read  byte  0x000a
    init_port( 9,  c_req_rd, 8'h09, 16'h000b, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h09, 2'd1, 32'h??????0a ); // read  byte  0x000b

    // Test halfword accesses

    init_port(10,  c_req_wr, 8'h0a, 16'h000c, 2'd0, 32'h01020304, c_resp_wr, 8'h0a, 2'd0, 32'h???????? ); // write word  0x000c
    init_port(11,  c_req_wr, 8'h0b, 16'h000c, 2'd2, 32'hdeadbeef, c_resp_wr, 8'h0b, 2'd2, 32'h???????? ); // write hword 0x000c
    init_port(12,  c_req_rd, 8'h0c, 16'h000c, 2'd2, 32'hxxxxxxxx, c_resp_rd, 8'h0c, 2'd2, 32'h????beef ); // read  hword 0x000c
    init_port(13,  c_req_rd, 8'h0d, 16'h000e, 2'd2, 32'hxxxxxxxx, c_resp_rd, 8'h0d, 2'd2, 32'h????0102 ); // read  hword 0x000e

    // Test address truncation

    init_port(14,  c_req_wr, 8'h0e, 16'h0014, 2'd0, 32'ha0b0c0d0, c_resp_wr, 8'h0e, 2'd0, 32'h???????? ); // write word  0x0014
    init_port(15,  c_req_wr, 8'h0f, 16'h1014, 2'd0, 32'he0102030, c_resp_wr, 8'h0f, 2'd0, 32'h???????? ); // write word  0x1014
    init_port(16,  c_req_rd, 8'h00, 16'h0014, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'he0102030 ); // read  word  0x0014
    init_port(17,  c_req_rd, 8'h01, 16'h1014, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'he0102030 ); // read  word  0x1014

    // Test amos

    init_port(18,  c_req_ao, 8'h02, 16'h0000, 2'd0, 32'hf0f0f0f0, c_resp_ao, 8'h02, 2'd0, 32'h0a0b0c0d ); // amo.or word  0x0000
    init_port(19,  c_req_rd, 8'h03, 16'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'hfafbfcfd ); // read  word  0x0000
    init_port(20,  c_req_ad, 8'h04, 16'h0004, 2'd0, 32'h00000fff, c_resp_ad, 8'h04, 2'd0, 32'h0e0f0102 ); // amo.add word  0x0004
    init_port(21,  c_req_rd, 8'h05, 16'h0004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h05, 2'd0, 32'h0e0f1101 ); // read  word  0x0004
    init_port(22,  c_req_an, 8'h06, 16'h0000, 2'd0, 32'h33333333, c_resp_an, 8'h06, 2'd0, 32'hfafbfcfd ); // amo.and word  0x0000
    init_port(23,  c_req_rd, 8'h07, 16'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'h32333031 ); // read  word  0x0000

  end
  endtask

  // Helper task to run test

  task run_test;
  begin
    #5;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.trace_cycles < 500) ) begin
      th.trace_display();
      #10;
    end

    `VC_TEST_INCREMENT_NUM_FAILED( th_num_failed );
    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // src delay = 0, sink delay = 0
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "src delay = 0, sink delay = 0" )
  begin
    init_rand_delays( 0, 0 );
    init_common;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // src delay = 3, sink delay = 10
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "src delay = 3, sink delay = 10" )
  begin
    init_rand_delays( 3, 10 );
    init_common;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // src delay = 10, sink delay = 3
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "src delay = 10, sink delay = 3" )
  begin
    init_rand_delays( 10, 3 );
    init_common;
    run_test;
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

