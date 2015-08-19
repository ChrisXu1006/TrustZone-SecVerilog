//========================================================================
// vc-TestMem_2ports Unit Tests
//========================================================================

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-TestMem_2ports.v"
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

  // Test source for port 0

  wire                   src0_val;
  wire                   src0_rdy;
  wire [c_req_nbits-1:0] src0_msg;
  wire                   src0_done;

  vc_TestRandDelaySource#(c_req_nbits) src0
  (
    .clk       (clk),
    .reset     (reset),
    .max_delay (src_max_delay),
    .val       (src0_val),
    .rdy       (src0_rdy),
    .msg       (src0_msg),
    .done      (src0_done)
  );

  // Test source for port 1

  wire                   src1_val;
  wire                   src1_rdy;
  wire [c_req_nbits-1:0] src1_msg;
  wire                   src1_done;

  vc_TestRandDelaySource#(c_req_nbits) src1
  (
    .clk       (clk),
    .reset     (reset),
    .max_delay (src_max_delay),
    .val       (src1_val),
    .rdy       (src1_rdy),
    .msg       (src1_msg),
    .done      (src1_done)
  );

  // Test memory

  wire                     sink0_val;
  wire                     sink0_rdy;
  wire [c_resp_nbits-1:0]  sink0_msg;

  wire                     sink1_val;
  wire                     sink1_rdy;
  wire [c_resp_nbits-1:0]  sink1_msg;

  vc_TestMem_2ports
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

    .memreq0_val  (src0_val),
    .memreq0_rdy  (src0_rdy),
    .memreq0_msg  (src0_msg),

    .memreq1_val  (src1_val),
    .memreq1_rdy  (src1_rdy),
    .memreq1_msg  (src1_msg),

    .memresp0_val (sink0_val),
    .memresp0_rdy (sink0_rdy),
    .memresp0_msg (sink0_msg),

    .memresp1_val (sink1_val),
    .memresp1_rdy (sink1_rdy),
    .memresp1_msg (sink1_msg)
  );

  // Test sink for port 0

  wire [31:0] sink0_num_failed;
  wire        sink0_done;

  vc_TestRandDelaySink#(c_resp_nbits) sink0
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (sink0_val),
    .rdy        (sink0_rdy),
    .msg        (sink0_msg),
    .num_failed (sink0_num_failed),
    .done       (sink0_done)
  );

  // Test sink for port 1

  wire [31:0] sink1_num_failed;
  wire        sink1_done;

  vc_TestRandDelaySink#(c_resp_nbits) sink1
  (
    .clk        (clk),
    .reset      (reset),
    .max_delay  (sink_max_delay),
    .val        (sink1_val),
    .rdy        (sink1_rdy),
    .msg        (sink1_msg),
    .num_failed (sink1_num_failed),
    .done       (sink1_done)
  );

  // Done when both source and sink are done for both ports

  assign done = src0_done & sink0_done & src1_done & sink1_done;

  // Num failed is sum from both sinks

  assign num_failed = sink0_num_failed + sink1_num_failed;

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin

    src0.trace_module( trace );
    vc_trace_str( trace, "|" );
    src1.trace_module( trace );
    vc_trace_str( trace, " > " );

    mem.trace_module( trace );

    vc_trace_str( trace, " > " );
    sink0.trace_module( trace );
    vc_trace_str( trace, "|" );
    sink1.trace_module( trace );

  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "vc-TestMem_2ports" )

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

  // Helper task to initalize port 0 source/sink

  reg [`VC_MEM_REQ_MSG_NBITS(8,16,32)-1:0] th_port0_memreq;
  reg [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]   th_port0_memresp;

  task init_port0
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
    th_port0_memreq[`VC_MEM_REQ_MSG_TYPE_FIELD(8,16,32)]   = memreq_type;
    th_port0_memreq[`VC_MEM_REQ_MSG_OPAQUE_FIELD(8,16,32)] = memreq_opaque;
    th_port0_memreq[`VC_MEM_REQ_MSG_ADDR_FIELD(8,16,32)]   = memreq_addr;
    th_port0_memreq[`VC_MEM_REQ_MSG_LEN_FIELD(8,16,32)]    = memreq_len;
    th_port0_memreq[`VC_MEM_REQ_MSG_DATA_FIELD(8,16,32)]   = memreq_data;

    th_port0_memresp[`VC_MEM_RESP_MSG_TYPE_FIELD(8,32)]    = memresp_type;
    th_port0_memresp[`VC_MEM_RESP_MSG_OPAQUE_FIELD(8,32)]  = memresp_opaque;
    th_port0_memresp[`VC_MEM_RESP_MSG_LEN_FIELD(8,32)]     = memresp_len;
    th_port0_memresp[`VC_MEM_RESP_MSG_DATA_FIELD(8,32)]    = memresp_data;

    th.src0.src.m[index]   = th_port0_memreq;
    th.sink0.sink.m[index] = th_port0_memresp;
  end
  endtask

  // Helper task to initalize port 1 source/sink

  reg [`VC_MEM_REQ_MSG_NBITS(8,16,32)-1:0] th_port1_memreq;
  reg [`VC_MEM_RESP_MSG_NBITS(8,32)-1:0]   th_port1_memresp;

  task init_port1
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
    th_port1_memreq[`VC_MEM_REQ_MSG_TYPE_FIELD(8,16,32)]   = memreq_type;
    th_port1_memreq[`VC_MEM_REQ_MSG_OPAQUE_FIELD(8,16,32)] = memreq_opaque;
    th_port1_memreq[`VC_MEM_REQ_MSG_ADDR_FIELD(8,16,32)]   = memreq_addr;
    th_port1_memreq[`VC_MEM_REQ_MSG_LEN_FIELD(8,16,32)]    = memreq_len;
    th_port1_memreq[`VC_MEM_REQ_MSG_DATA_FIELD(8,16,32)]   = memreq_data;

    th_port1_memresp[`VC_MEM_RESP_MSG_TYPE_FIELD(8,32)]    = memresp_type;
    th_port1_memresp[`VC_MEM_RESP_MSG_OPAQUE_FIELD(8,32)]  = memresp_opaque;
    th_port1_memresp[`VC_MEM_RESP_MSG_LEN_FIELD(8,32)]     = memresp_len;
    th_port1_memresp[`VC_MEM_RESP_MSG_DATA_FIELD(8,32)]    = memresp_data;

    th.src1.src.m[index]   = th_port1_memreq;
    th.sink1.sink.m[index] = th_port1_memresp;
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

    // Initialize Port 0

    //          ----------------- memory request ----------------  --------- memory response ----------
    //          idx type      opaque addr      len   data          type       opaque len   data

    init_port0( 0,  c_req_wr, 8'h00, 16'h0000, 2'd0, 32'h0a0b0c0d, c_resp_wr, 8'h00, 2'd0, 32'h???????? ); // write word  0x0000
    init_port0( 1,  c_req_wn, 8'h01, 16'h0004, 2'd0, 32'h0e0f0102, c_resp_wn, 8'h01, 2'd0, 32'h???????? ); // write word  0x0004
    init_port0( 2,  c_req_rd, 8'h02, 16'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h02, 2'd0, 32'h0a0b0c0d ); // read  word  0x0000
    init_port0( 3,  c_req_rd, 8'h03, 16'h0004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'h0e0f0102 ); // read  word  0x0004

    // Test byte accesses

    init_port0( 4,  c_req_wr, 8'h04, 16'h0008, 2'd0, 32'h0a0b0c0d, c_resp_wr, 8'h04, 2'd0, 32'h???????? ); // write word  0x0008
    init_port0( 5,  c_req_wr, 8'h05, 16'h0008, 2'd1, 32'hdeadbeef, c_resp_wr, 8'h05, 2'd1, 32'h???????? ); // write byte  0x0008
    init_port0( 6,  c_req_rd, 8'h06, 16'h0008, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h06, 2'd1, 32'h??????ef ); // read  byte  0x0008
    init_port0( 7,  c_req_rd, 8'h07, 16'h0009, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd1, 32'h??????0c ); // read  byte  0x0009
    init_port0( 8,  c_req_rd, 8'h08, 16'h000a, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h08, 2'd1, 32'h??????0b ); // read  byte  0x000a
    init_port0( 9,  c_req_rd, 8'h09, 16'h000b, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h09, 2'd1, 32'h??????0a ); // read  byte  0x000b

    // Test halfword accesses

    init_port0(10,  c_req_wr, 8'h0a, 16'h000c, 2'd0, 32'h01020304, c_resp_wr, 8'h0a, 2'd0, 32'h???????? ); // write word  0x000c
    init_port0(11,  c_req_wr, 8'h0b, 16'h000c, 2'd2, 32'hdeadbeef, c_resp_wr, 8'h0b, 2'd2, 32'h???????? ); // write hword 0x000c
    init_port0(12,  c_req_rd, 8'h0c, 16'h000c, 2'd2, 32'hxxxxxxxx, c_resp_rd, 8'h0c, 2'd2, 32'h????beef ); // read  hword 0x000c
    init_port0(13,  c_req_rd, 8'h0d, 16'h000e, 2'd2, 32'hxxxxxxxx, c_resp_rd, 8'h0d, 2'd2, 32'h????0102 ); // read  hword 0x000e

    // Test address truncation

    init_port0(14,  c_req_wr, 8'h0e, 16'h0014, 2'd0, 32'ha0b0c0d0, c_resp_wr, 8'h0e, 2'd0, 32'h???????? ); // write word  0x0014
    init_port0(15,  c_req_wr, 8'h0f, 16'h1014, 2'd0, 32'he0102030, c_resp_wr, 8'h0f, 2'd0, 32'h???????? ); // write word  0x1014
    init_port0(16,  c_req_rd, 8'h00, 16'h0014, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'he0102030 ); // read  word  0x0014
    init_port0(17,  c_req_rd, 8'h01, 16'h1014, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'he0102030 ); // read  word  0x1014

    // Test amos

    init_port0(18,  c_req_ao, 8'h02, 16'h0000, 2'd0, 32'hf0f0f0f0, c_resp_ao, 8'h02, 2'd0, 32'h0a0b0c0d ); // amo.or word  0x0000
    init_port0(19,  c_req_rd, 8'h03, 16'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'hfafbfcfd ); // read  word  0x0000
    init_port0(20,  c_req_ad, 8'h04, 16'h0004, 2'd0, 32'h00000fff, c_resp_ad, 8'h04, 2'd0, 32'h0e0f0102 ); // amo.add word  0x0004
    init_port0(21,  c_req_rd, 8'h05, 16'h0004, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h05, 2'd0, 32'h0e0f1101 ); // read  word  0x0004
    init_port0(22,  c_req_an, 8'h06, 16'h0000, 2'd0, 32'h33333333, c_resp_an, 8'h06, 2'd0, 32'hfafbfcfd ); // amo.and word  0x0000
    init_port0(23,  c_req_rd, 8'h07, 16'h0000, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'h32333031 ); // read  word  0x0000


    // Initialize Port 1

    //          ----------------- memory request ----------------  --------- memory response ----------
    //          idx type      opaque addr      len   data          type       opaque len   data

    init_port1( 0,  c_req_wr, 8'h10, 16'h0100, 2'd0, 32'h1a1b1c1d, c_resp_wr, 8'h10, 2'd0, 32'h???????? ); // write word  0x0100
    init_port1( 1,  c_req_wr, 8'h11, 16'h0104, 2'd0, 32'h1e1f1112, c_resp_wr, 8'h11, 2'd0, 32'h???????? ); // write word  0x0104
    init_port1( 2,  c_req_rd, 8'h12, 16'h0100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h12, 2'd0, 32'h1a1b1c1d ); // read  word  0x0100
    init_port1( 3,  c_req_rd, 8'h13, 16'h0104, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h13, 2'd0, 32'h1e1f1112 ); // read  word  0x0104

    // Test byte accesses

    init_port1( 4,  c_req_wn, 8'h14, 16'h0108, 2'd0, 32'h1a1b1c1d, c_resp_wn, 8'h14, 2'd0, 32'h???????? ); // write word  0x0108
    init_port1( 5,  c_req_wr, 8'h15, 16'h0108, 2'd1, 32'hdeadbeef, c_resp_wr, 8'h15, 2'd1, 32'h???????? ); // write byte  0x0108
    init_port1( 6,  c_req_rd, 8'h16, 16'h0108, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h16, 2'd1, 32'h??????ef ); // read  byte  0x0108
    init_port1( 7,  c_req_rd, 8'h17, 16'h0109, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h17, 2'd1, 32'h??????1c ); // read  byte  0x0109
    init_port1( 8,  c_req_rd, 8'h18, 16'h010a, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h18, 2'd1, 32'h??????1b ); // read  byte  0x010a
    init_port1( 9,  c_req_rd, 8'h19, 16'h010b, 2'd1, 32'hxxxxxxxx, c_resp_rd, 8'h19, 2'd1, 32'h??????1a ); // read  byte  0x010b

    // Test halfword accesses

    init_port1(10,  c_req_wr, 8'h1a, 16'h010c, 2'd0, 32'h11121314, c_resp_wr, 8'h1a, 2'd0, 32'h???????? ); // write word  0x010c
    init_port1(11,  c_req_wr, 8'h1b, 16'h010c, 2'd2, 32'hdeadbeef, c_resp_wr, 8'h1b, 2'd2, 32'h???????? ); // write hword 0x010c
    init_port1(12,  c_req_rd, 8'h1c, 16'h010c, 2'd2, 32'hxxxxxxxx, c_resp_rd, 8'h1c, 2'd2, 32'h????beef ); // read  hword 0x010c
    init_port1(13,  c_req_rd, 8'h1d, 16'h010e, 2'd2, 32'hxxxxxxxx, c_resp_rd, 8'h1d, 2'd2, 32'h????1112 ); // read  hword 0x010e

    // Test address truncation

    init_port1(14,  c_req_wr, 8'h0e, 16'h0114, 2'd0, 32'ha0b0c0d0, c_resp_wr, 8'h0e, 2'd0, 32'h???????? ); // write word  0x0114
    init_port1(15,  c_req_wr, 8'h0f, 16'h1114, 2'd0, 32'he0102030, c_resp_wr, 8'h0f, 2'd0, 32'h???????? ); // write word  0x1114
    init_port1(16,  c_req_rd, 8'h00, 16'h0114, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h00, 2'd0, 32'he0102030 ); // read  word  0x0114
    init_port1(17,  c_req_rd, 8'h01, 16'h1114, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h01, 2'd0, 32'he0102030 ); // read  word  0x1114

    // Test amos

    init_port1(18,  c_req_ao, 8'h02, 16'h0100, 2'd0, 32'hf0f0f0f0, c_resp_ao, 8'h02, 2'd0, 32'h1a1b1c1d ); // amo.or word  0x0000
    init_port1(19,  c_req_rd, 8'h03, 16'h0100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h03, 2'd0, 32'hfafbfcfd ); // read  word  0x0000
    init_port1(20,  c_req_ad, 8'h04, 16'h0104, 2'd0, 32'h00000fff, c_resp_ad, 8'h04, 2'd0, 32'h1e1f1112 ); // amo.add word  0x0004
    init_port1(21,  c_req_rd, 8'h05, 16'h0104, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h05, 2'd0, 32'h1e1f2111 ); // read  word  0x0004
    init_port1(22,  c_req_an, 8'h06, 16'h0100, 2'd0, 32'h33333333, c_resp_an, 8'h06, 2'd0, 32'hfafbfcfd ); // amo.and word  0x0000
    init_port1(23,  c_req_rd, 8'h07, 16'h0100, 2'd0, 32'hxxxxxxxx, c_resp_rd, 8'h07, 2'd0, 32'h32333031 ); // read  word  0x0000


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

