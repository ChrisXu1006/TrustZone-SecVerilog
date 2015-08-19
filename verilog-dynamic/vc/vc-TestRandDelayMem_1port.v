//========================================================================
// Verilog Components: Test Memory with Random Delays
//========================================================================
// This is dual-ported test memory that handles a limited subset of
// memory request messages and returns memory response messages.

`ifndef VC_TEST_RAND_DELAY_MEM_1PORT_V
`define VC_TEST_RAND_DELAY_MEM_1PORT_V

`include "vc-mem-msgs.v"
`include "vc-TestMem_1port.v"
`include "vc-TestRandDelay.v"

module vc_TestRandDelayMem_1port
#(
  parameter p_mem_nbytes   = 1024, // size of physical memory in bytes
  parameter p_opaque_nbits = 8,    // mem message opaque field num bits
  parameter p_addr_nbits   = 32,   // mem message address num bits
  parameter p_data_nbits   = 32,   // mem message data num bits
  parameter p_reset_to_x   = 1,    // reset all values to X's

  // Shorter names for message type, not to be set from outside the module
  parameter o = p_opaque_nbits,
  parameter a = p_addr_nbits,
  parameter d = p_data_nbits,

  // Local constants not meant to be set from outside the module
  parameter c_req_nbits  = `VC_MEM_REQ_MSG_NBITS(o,a,d),
  parameter c_resp_nbits = `VC_MEM_RESP_MSG_NBITS(o,d)
)(
  input                     clk,
  input                     reset,

  // clears the content of memory

  input                     mem_clear,

  // maximum delay

  input  [31:0]             max_delay,

  // Memory request interface port

  input                     memreq_val,
  output                    memreq_rdy,
  input  [c_req_nbits-1:0]  memreq_msg,

  // Memory response interface port

  output                    memresp_val,
  input                     memresp_rdy,
  output [c_resp_nbits-1:0] memresp_msg
);

  //------------------------------------------------------------------------
  // Dual ported test memory
  //------------------------------------------------------------------------

  wire                    mem_memreq_val;
  wire                    mem_memreq_rdy;
  wire [c_req_nbits-1:0]  mem_memreq_msg;

  wire                    mem_memresp_val;
  wire                    mem_memresp_rdy;
  wire [c_resp_nbits-1:0] mem_memresp_msg;

  //------------------------------------------------------------------------
  // Test random delay
  //------------------------------------------------------------------------

  vc_TestRandDelay#(c_req_nbits) rand_req_delay
  (
    .clk       (clk),
    .reset     (reset),

    // dividing the max delay by two because we have delay for both in and
    // out
    .max_delay (max_delay >> 1),

    .in_val    (memreq_val),
    .in_rdy    (memreq_rdy),
    .in_msg    (memreq_msg),

    .out_val   (mem_memreq_val),
    .out_rdy   (mem_memreq_rdy),
    .out_msg   (mem_memreq_msg)

  );

  vc_TestMem_1port
  #(
    .p_mem_nbytes   (p_mem_nbytes),
    .p_opaque_nbits (p_opaque_nbits),
    .p_addr_nbits   (p_addr_nbits),
    .p_data_nbits   (p_data_nbits)
  )
  mem
  (
    .clk          (clk),
    .reset        (reset),
    .mem_clear    (mem_clear),

    .memreq_val  (mem_memreq_val),
    .memreq_rdy  (mem_memreq_rdy),
    .memreq_msg  (mem_memreq_msg),

    .memresp_val (mem_memresp_val),
    .memresp_rdy (mem_memresp_rdy),
    .memresp_msg (mem_memresp_msg)
  );

  //------------------------------------------------------------------------
  // Test random delay
  //------------------------------------------------------------------------

  vc_TestRandDelay#(c_resp_nbits) rand_resp_delay
  (
    .clk       (clk),
    .reset     (reset),

    // dividing the max delay by two because we have delay for both in and
    // out
    .max_delay (max_delay >> 1),

    .in_val    (mem_memresp_val),
    .in_rdy    (mem_memresp_rdy),
    .in_msg    (mem_memresp_msg),

    .out_val   (memresp_val),
    .out_rdy   (memresp_rdy),
    .out_msg   (memresp_msg)
  );

  //----------------------------------------------------------------------
  // Line tracing
  //----------------------------------------------------------------------

  vc_MemReqMsgTrace#(o,a,d) memreq_trace
  (
    .clk   (clk),
    .reset (reset),
    .val   (memreq_val),
    .rdy   (memreq_rdy),
    .msg   (memreq_msg)
  );

  vc_MemRespMsgTrace#(o,d) memresp_trace
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

    memreq_trace.trace_module( trace );

    vc_trace_str( trace, "()" );

    memresp_trace.trace_module( trace );

  end
  endtask

endmodule

`endif /* VC_TEST_RAND_DELAY_MEM_1PORT_V */

