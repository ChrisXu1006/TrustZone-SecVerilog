//=========================================================================
// Processor Test Harness
//=========================================================================
// This harness is meant to be instantiated for a specific implementation
// of the multiplier using the special IMPL macro like this:
//
//  `define PLAB2_PROC_IMPL     plab2_proc_Impl
//  `define PLAB2_PROC_IMPL_STR "plab2-proc-Impl-%INST%"
//  `define PLAB2_PROC_TEST_CASES_FILE plab2-proc-test-cases-%INST%.v
//
//  `include "plab2-proc-Impl.v"
//  `include "plab2-proc-test-harness.v"
//
// This test harness provides the logic and includes the test cases
// specified in `PLAB2_PROC_TEST_CASES_FILE.

`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-TestRandDelayMem_2ports.v"
`include "vc-test.v"
`include "pisa-inst.v"

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_mem_nbytes  = 1 << 16, // size of physical memory in bytes
  parameter p_num_msgs    = 1024
)(
  input        clk,
  input        reset,
  input        mem_clear,
  input [31:0] src_max_delay,
  input [31:0] mem_max_delay,
  input [31:0] sink_max_delay,
  output       done
);

  // Local parameters

  localparam c_req_msg_nbits  = `VC_MEM_REQ_MSG_NBITS(8,32,32);
  localparam c_resp_msg_nbits = `VC_MEM_RESP_MSG_NBITS(8,32);
  localparam c_opaque_nbits   = 8;
  localparam c_data_nbits     = 32;   // size of mem message data in bits
  localparam c_addr_nbits     = 32;   // size of mem message address in bits

  // wires

  wire [`PLAB2_PROC_FROM_MNGR_MSG_NBITS-1:0]  src_msg;
  wire                                        src_val;
  wire                                        src_rdy;
  wire                                        src_done;

  wire [`PLAB2_PROC_TO_MNGR_MSG_NBITS-1:0]    sink_msg;
  wire                                        sink_val;
  wire                                        sink_rdy;
  wire                                        sink_done;

  // from mngr source

  vc_TestRandDelaySource
  #(
    .p_msg_nbits       (`PLAB2_PROC_FROM_MNGR_MSG_NBITS),
    .p_num_msgs        (p_num_msgs)
  )
  src
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (src_max_delay),

    .val       (src_val),
    .rdy       (src_rdy),
    .msg       (src_msg),

    .done      (src_done)
  );

  // memory

  wire                        imemreq_val;
  wire                        imemreq_rdy;
  wire [c_req_msg_nbits-1:0]  imemreq_msg;

  wire                        imemresp_val;
  wire                        imemresp_rdy;
  wire [c_resp_msg_nbits-1:0] imemresp_msg;

  wire                        dmemreq_val;
  wire                        dmemreq_rdy;
  wire [c_req_msg_nbits-1:0]  dmemreq_msg;

  wire                        dmemresp_val;
  wire                        dmemresp_rdy;
  wire [c_resp_msg_nbits-1:0] dmemresp_msg;

  vc_TestRandDelayMem_2ports
  #(p_mem_nbytes, c_opaque_nbits, c_addr_nbits, c_data_nbits) mem
  (
    .clk          (clk),
    .reset        (reset),
    .mem_clear    (mem_clear),

    .max_delay    (mem_max_delay),

    .memreq0_val  (imemreq_val),
    .memreq0_rdy  (imemreq_rdy),
    .memreq0_msg  (imemreq_msg),

    .memresp0_val (imemresp_val),
    .memresp0_rdy (imemresp_rdy),
    .memresp0_msg (imemresp_msg),

    .memreq1_val  (dmemreq_val),
    .memreq1_rdy  (dmemreq_rdy),
    .memreq1_msg  (dmemreq_msg),

    .memresp1_val (dmemresp_val),
    .memresp1_rdy (dmemresp_rdy),
    .memresp1_msg (dmemresp_msg)
  );

  // processor

  `PLAB2_PROC_IMPL proc
  (
    .clk           (clk),
    .reset         (reset),

    .imemreq_val   (imemreq_val),
    .imemreq_rdy   (imemreq_rdy),
    .imemreq_msg   (imemreq_msg),

    .imemresp_val  (imemresp_val),
    .imemresp_rdy  (imemresp_rdy),
    .imemresp_msg  (imemresp_msg),

    .dmemreq_val   (dmemreq_val),
    .dmemreq_rdy   (dmemreq_rdy),
    .dmemreq_msg   (dmemreq_msg),

    .dmemresp_val  (dmemresp_val),
    .dmemresp_rdy  (dmemresp_rdy),
    .dmemresp_msg  (dmemresp_msg),

    .from_mngr_msg (src_msg),
    .from_mngr_val (src_val),
    .from_mngr_rdy (src_rdy),

    .to_mngr_msg   (sink_msg),
    .to_mngr_val   (sink_val),
    .to_mngr_rdy   (sink_rdy)
  );

  // to mngr sink

  vc_TestRandDelaySink
  #(
    .p_msg_nbits       (`PLAB2_PROC_TO_MNGR_MSG_NBITS),
    .p_num_msgs        (p_num_msgs)
  )
  sink
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (sink_max_delay),

    .val       (sink_val),
    .rdy       (sink_rdy),
    .msg       (sink_msg),

    .done      (sink_done)
  );

  assign done = src_done && sink_done;

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    src.trace_module( trace );
    vc_trace_str( trace, " > " );
    proc.trace_module( trace );
    //vc_trace_str( trace, " > " );
    //mem.trace_module( trace );
    vc_trace_str( trace, " > " );
    sink.trace_module( trace );
  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `PLAB2_PROC_IMPL_STR )

  pisa_InstTasks pisa();

  // the reset vector (the PC that the processor will start fetching from
  // after a reset)
  localparam c_reset_vector = 32'h1000;

  //----------------------------------------------------------------------
  // Test setup
  //----------------------------------------------------------------------

  // Instantiate the test harness

  reg         th_reset = 1;
  reg         th_mem_clear;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_mem_max_delay;
  reg  [31:0] th_sink_max_delay;
  reg  [31:0] th_inst_asm_str;
  reg  [31:0] th_addr;
  reg  [31:0] th_src_idx;
  reg  [31:0] th_sink_idx;
  wire        th_done;

  TestHarness th
  (
    .clk            (clk),
    .reset          (th_reset),
    .mem_clear      (th_mem_clear),
    .src_max_delay  (th_src_max_delay),
    .mem_max_delay  (th_mem_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .done           (th_done)
  );

  //----------------------------------------------------------------------
  // load_mem: helper task to load one word into memory
  //----------------------------------------------------------------------

  task load_mem
  (
    input [31:0] addr,
    input [31:0] data
  );
  begin
    th.mem.mem.m[ addr >> 2 ] = data;
  end
  endtask

  //----------------------------------------------------------------------
  // load_from_mngr: helper task to load an entry into the from_mngr source
  //----------------------------------------------------------------------

  task load_from_mngr
  (
    input [ 9:0]                                i,
    input [`PLAB2_PROC_FROM_MNGR_MSG_NBITS-1:0] msg
  );
  begin
    th.src.src.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // load_to_mngr: helper task to load an entry into the to_mngr sink
  //----------------------------------------------------------------------

  task load_to_mngr
  (
    input [ 9:0]                                i,
    input [`PLAB2_PROC_TO_MNGR_MSG_NBITS-1:0]   msg
  );
  begin
    th.sink.sink.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // clear_mem: clear the contents of memory and test sources and sinks
  //----------------------------------------------------------------------

  task clear_mem;
  begin
    #1;   th_mem_clear = 1'b1;
    #20;  th_mem_clear = 1'b0;
    th_src_idx = 0;
    th_sink_idx = 0;
    // in case there are no srcs/sinks, we set the first elements of them
    // to xs
    load_from_mngr( 0, 32'hxxxxxxxx );
    load_to_mngr(   0, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // init_src: add a data to the test src
  //----------------------------------------------------------------------

  task init_src
  (
    input [31:0] data
  );
  begin
    load_from_mngr( th_src_idx, data );
    th_src_idx = th_src_idx + 1;
    // we set the next address with x's so that src/sink stops here if
    // there isn't another call to init_src/sink
    load_from_mngr( th_src_idx, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // init_sink: add a data to the test sink
  //----------------------------------------------------------------------

  task init_sink
  (
    input [31:0] data
  );
  begin
    load_to_mngr( th_sink_idx, data );
    th_sink_idx = th_sink_idx + 1;
    // we set the next address with x's so that src/sink stops here if
    // there isn't another call to init_src/sink
    load_to_mngr( th_sink_idx, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // inst: assemble and put instruction to next addr
  //----------------------------------------------------------------------

  task inst
  (
    input [25*8-1:0] asm_str
  );
  begin
    th_inst_asm_str = pisa.asm( th_addr, asm_str );
    load_mem( th_addr, th_inst_asm_str );
    // increment pc
    th_addr = th_addr + 4;
  end
  endtask

  //----------------------------------------------------------------------
  // data: put data_in to next addr, useful for mem ops
  //----------------------------------------------------------------------

  task data
  (
    input [31:0] data_in
  );
  begin
    load_mem( th_addr, data_in );
    // increment pc
    th_addr = th_addr + 4;
  end
  endtask

  //----------------------------------------------------------------------
  // address: each consecutive call to inst and data would be put after
  // this address
  //----------------------------------------------------------------------

  task address
  (
    input [31:0] addr
  );
  begin
    th_addr = addr;
  end
  endtask

  //----------------------------------------------------------------------
  // test_insert_nops: insert count many nops
  //----------------------------------------------------------------------

  integer i;

  task test_insert_nops
  (
    input [31:0] count
  );
  begin
    for ( i = 0; i < count; i = i + 1 )
      inst( "nop" );
  end
  endtask

  //----------------------------------------------------------------------
  // test_imm: helper tasks for immediate instructions
  //----------------------------------------------------------------------

  reg [6*8-1:0] imm_str;

  task test_imm_op_helper
  (
    input [25*8-1:0] inst,
    input     [15:0] imm,
    input     [31:0] result,
    input     [31:0] dest_nops
  );
  begin
    // convert the immediate to string
    $sformat( imm_str, "0x%x", imm );

    // run the actual instruction
    inst( { inst, " r1, ", imm_str } );

    // copy the result back to the manager
    test_insert_nops( dest_nops );
    inst( { "mtc0 r1, proc2mngr" } ); init_sink( result );
  end
  endtask

  task test_imm_op
  (
    input [25*8-1:0] inst,
    input     [15:0] imm,
    input     [31:0] result
  );
  begin
    test_imm_op_helper( inst, imm, result, 0 );
  end
  endtask

  task test_imm_dest_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst,
    input     [15:0] imm,
    input     [31:0] result
  );
  begin
    test_imm_op_helper( inst, imm, result, nops );
  end
  endtask

  //----------------------------------------------------------------------
  // test_rimm: helper tasks for register-immediate instructions
  //----------------------------------------------------------------------

  task test_rimm_op_helper
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input  [3*8-1:0] src0_spec,
    input     [15:0] imm,
    input     [31:0] result,
    input  [3*8-1:0] result_spec,
    input     [31:0] src0_nops,
    input     [31:0] dest_nops
  );
  begin
    // convert the immediate to string
    $sformat( imm_str, "0x%x", imm );

    // load the input sources
    inst( { "mfc0 ", src0_spec, ", mngr2proc" } ); init_src( src0 );
    test_insert_nops( src0_nops );

    // run the actual instruction
    inst( { inst, " ", result_spec, ", ", src0_spec, ", ", imm_str } );

    // copy the result back to the manager
    test_insert_nops( dest_nops );
    inst( { "mtc0 ", result_spec, ", proc2mngr" } ); init_sink( result );
  end
  endtask

  task test_rimm_op
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [15:0] imm,
    input     [31:0] result
  );
  begin
    test_rimm_op_helper( inst, src0, "r1", imm, result, "r2", 0, 0 );
  end
  endtask

  task test_rimm_src0_eq_dest
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [15:0] imm,
    input     [31:0] result
  );
  begin
    test_rimm_op_helper( inst, src0, "r1", imm, result, "r1", 0, 0 );
  end
  endtask

  task test_rimm_dest_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [15:0] imm,
    input     [31:0] result
  );
  begin
    test_rimm_op_helper( inst, src0, "r1", imm, result, "r2", 0, nops );
  end
  endtask

  task test_rimm_src0_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [15:0] imm,
    input     [31:0] result
  );
  begin
    test_rimm_op_helper( inst, src0, "r1", imm, result, "r2", nops, 0 );
  end
  endtask

  //----------------------------------------------------------------------
  // test_rr: helper tasks for register-register instructions
  //----------------------------------------------------------------------

  task test_rr_op_helper
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input  [3*8-1:0] src0_spec,
    input     [31:0] src1,
    input  [3*8-1:0] src1_spec,
    input     [31:0] result,
    input  [3*8-1:0] result_spec,
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input     [31:0] dest_nops,
    input            src_reverse
  );
  begin
    // load the input sources
    inst( { "mfc0 ", src0_spec, ", mngr2proc" } ); init_src( src0 );
    test_insert_nops( src0_nops );


    // load only one input if both src0 and src1 use the same specifiers
    if ( src0_spec != src1_spec ) begin
      inst( { "mfc0 ", src1_spec, ", mngr2proc" } ); init_src( src1 );
      test_insert_nops( src1_nops );
    end

    // run the actual instruction
    if ( src_reverse )
      inst( { inst, " ", result_spec, ", ", src1_spec, ", ", src0_spec } );
    else
      inst( { inst, " ", result_spec, ", ", src0_spec, ", ", src1_spec } );

    // copy the result back to the manager
    test_insert_nops( dest_nops );
    inst( { "mtc0 ", result_spec, ", proc2mngr" } ); init_sink( result );
  end
  endtask

  task test_rr_op
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1,
    input     [31:0] result
  );
  begin
    test_rr_op_helper( inst, src0, "r1", src1, "r2", result, "r3", 0,0,0,0 );
  end
  endtask

  task test_rr_src0_eq_dest
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1,
    input     [31:0] result
  );
  begin
    test_rr_op_helper( inst, src0, "r1", src1, "r2", result, "r1", 0,0,0,0 );
  end
  endtask

  task test_rr_src1_eq_dest
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1,
    input     [31:0] result
  );
  begin
    test_rr_op_helper( inst, src0, "r1", src1, "r2", result, "r2", 0,0,0,0 );
  end
  endtask

  task test_rr_src0_eq_src1
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] result
  );
  begin
    test_rr_op_helper( inst, src0, "r1", src0, "r1", result, "r2", 0,0,0,0 );
  end
  endtask

  task test_rr_srcs_eq_dest
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] result
  );
  begin
    test_rr_op_helper( inst, src0, "r1", src0, "r1", result, "r1", 0,0,0,0 );
  end
  endtask

  task test_rr_dest_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1,
    input     [31:0] result
  );
  begin
    test_rr_op_helper( inst, src0, "r1", src1, "r2", result, "r3",
            0,0, nops, 0 );
  end
  endtask

  task test_rr_src01_byp
  (
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1,
    input     [31:0] result
  );
  begin
    test_rr_op_helper( inst, src0, "r1", src1, "r2", result, "r3",
            src0_nops, src1_nops, 0, 0 );
  end
  endtask

  task test_rr_src10_byp
  (
    input     [31:0] src1_nops,
    input     [31:0] src0_nops,
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1,
    input     [31:0] result
  );
  begin
    test_rr_op_helper( inst, src1, "r2", src0, "r1", result, "r3",
            src1_nops, src0_nops, 0, 1 );
  end
  endtask

  //----------------------------------------------------------------------
  // test_ld: helper tasks for load instructions
  //----------------------------------------------------------------------

  task test_ld_op_helper
  (
    input [25*8-1:0] inst,
    input     [15:0] offset,
    input     [31:0] base,
    input     [31:0] result,
    input     [31:0] src0_nops,
    input     [31:0] dest_nops
  );
  begin
    // convert the offset to string
    $sformat( imm_str, "0x%x", offset );

    // load the base pointer
    inst( "mfc0 r1, mngr2proc"); init_src( base );
    test_insert_nops( src0_nops );
    inst( { inst, " r2, ", imm_str, "(r1)" } );
    test_insert_nops( dest_nops );
    inst( "mtc0 r2, proc2mngr"); init_sink( result );
  end
  endtask

  task test_ld_op
  (
    input [25*8-1:0] inst,
    input     [15:0] offset,
    input     [31:0] base,
    input     [31:0] result
  );
  begin
    test_ld_op_helper( inst, offset, base, result, 0, 0 );
  end
  endtask

  task test_ld_dest_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst,
    input     [15:0] offset,
    input     [31:0] base,
    input     [31:0] result
  );
  begin
    test_ld_op_helper( inst, offset, base, result, 0, nops );
  end
  endtask

  task test_ld_src0_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst,
    input     [15:0] offset,
    input     [31:0] base,
    input     [31:0] result
  );
  begin
    test_ld_op_helper( inst, offset, base, result, nops, 0 );
  end
  endtask

  //----------------------------------------------------------------------
  // test_sw: helper tasks for store word instructions
  //----------------------------------------------------------------------

  task test_sw_op_helper
  (
    input [25*8-1:0] inst,
    input     [31:0] wdata,
    input     [15:0] offset,
    input     [31:0] base,
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input            reverse_srcs
  );
  begin
    // convert the offset to string
    $sformat( imm_str, "0x%x", offset );

    if ( reverse_srcs ) begin
      // load the write data
      inst( "mfc0 r2, mngr2proc"); init_src( wdata );
      test_insert_nops( src1_nops );
      // load the base pointer
      inst( "mfc0 r1, mngr2proc"); init_src( base );
      test_insert_nops( src0_nops );
    end else begin
      // load the base pointer
      inst( "mfc0 r1, mngr2proc"); init_src( base );
      test_insert_nops( src0_nops );
      // load the write data
      inst( "mfc0 r2, mngr2proc"); init_src( wdata );
      test_insert_nops( src1_nops );
    end

    // do the store
    inst( { inst, " r2, ", imm_str, "(r1)" } );
    // load the instruction back
    inst( { "lw r3, ", imm_str, "(r1)" } );

    // make sure we have written (and read) the correct data
    inst( "mtc0 r3, proc2mngr"); init_sink( wdata );
  end
  endtask

  task test_sw_op
  (
    input [25*8-1:0] inst,
    input     [31:0] wdata,
    input     [15:0] offset,
    input     [31:0] base
  );
  begin
    test_sw_op_helper( inst, wdata, offset, base, 0, 0, 0 );
  end
  endtask

  task test_sw_src01_byp
  (
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input [25*8-1:0] inst,
    input     [31:0] wdata,
    input     [15:0] offset,
    input     [31:0] base
  );
  begin
    test_sw_op_helper( inst, wdata, offset, base, src0_nops, src1_nops, 0 );
  end
  endtask

  task test_sw_src10_byp
  (
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input [25*8-1:0] inst,
    input     [31:0] wdata,
    input     [15:0] offset,
    input     [31:0] base
  );
  begin
    test_sw_op_helper( inst, wdata, offset, base, src0_nops, src1_nops, 1 );
  end
  endtask

  //----------------------------------------------------------------------
  // test_br2: helper tasks for branch two-source instructions
  //----------------------------------------------------------------------

  task test_br2_op_helper
  (
    input            taken,
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1
  );
  begin

    // load the pass value (1)
    inst( "mfc0 r3, mngr2proc"); init_src( 32'd1 );

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( src0 );
    inst( "mfc0 r2, mngr2proc"); init_src( src1 );

    // forward branch, if taken goto 2:
    inst( { inst, " r1, r2, [+4]" } );

    if ( taken ) begin
      // send fail value
      inst( "mtc0 r0, proc2mngr");
    end else begin
      // send pass value
      inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1 );
    end

    // goto 2:
    inst( "bne r3, r0, [+2]" );

    // 1: goto 3:
    inst( "bne r3, r0, [+3]" );

    // 2: backward branch, if taken goto 1:
    inst( { inst, " r1, r2, [-1]" } );

    if ( taken ) begin
      // send fail value
      inst( "mtc0 r0, proc2mngr");
    end else begin
      // send pass value
      inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1 );
    end

    // 3: send pass
    inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1 );
  end
  endtask

  task test_br2_op_taken
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1
  );
  begin
    test_br2_op_helper( 1, inst, src0, src1 );
  end
  endtask

  task test_br2_op_nottaken
  (
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1
  );
  begin
    test_br2_op_helper( 0, inst, src0, src1 );
  end
  endtask

  task test_br2_src01_byp
  (
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1
  );
  begin
    // load the pass value (1)
    inst( "mfc0 r3, mngr2proc"); init_src( 32'd1 );

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( src0 );
    test_insert_nops( src0_nops );
    inst( "mfc0 r2, mngr2proc"); init_src( src1 );
    test_insert_nops( src1_nops );

    // forward branch, we assume not taken
    inst( { inst, " r1, r2, [+2]" } );

    // branch taken to pass
    inst( "bne r3, r0, [+2]" );
    // fail
    inst( "mtc0 r0, proc2mngr");
    // pass
    inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1 );

  end
  endtask

  task test_br2_src10_byp
  (
    input     [31:0] src1_nops,
    input     [31:0] src0_nops,
    input [25*8-1:0] inst,
    input     [31:0] src0,
    input     [31:0] src1
  );
  begin
    // load the pass value (1)
    inst( "mfc0 r3, mngr2proc"); init_src( 32'd1 );

    // load the sources
    inst( "mfc0 r2, mngr2proc"); init_src( src1 );
    test_insert_nops( src1_nops );
    inst( "mfc0 r1, mngr2proc"); init_src( src0 );
    test_insert_nops( src0_nops );

    // forward branch, we assume not taken
    inst( { inst, " r1, r2, [+2]" } );

    // branch taken to pass
    inst( "bne r3, r0, [+2]" );
    // fail
    inst( "mtc0 r0, proc2mngr");
    // pass
    inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1 );

  end
  endtask

  //----------------------------------------------------------------------
  // test_jal: helper tasks for jump-and-link instructions
  //----------------------------------------------------------------------

  reg [31:0] temp_pc;

  task test_jal_dest_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst
  );
  begin

    // get the temp pc
    temp_pc = th_addr;

    // execute instruction, forward jump and link
    inst( { inst, " [+2]" } );

    // fail
    inst( "mtc0 r0, proc2mngr");

    test_insert_nops( nops );
    // pass
    inst( "mtc0 r31, proc2mngr"); init_sink( temp_pc + 4 );

  end
  endtask

  //+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++

  //----------------------------------------------------------------------
  // test_jr: helper tasks for jump register instructions
  //----------------------------------------------------------------------

  task test_jr_src0_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst
  );
  begin
    inst( "mfc0 r2, mngr2proc"); init_src( 32'd1 );
    // send the target address
    inst( "mfc0 r1, mngr2proc"); init_src( th_addr + (2 + nops) * 4 );

    test_insert_nops( nops );

    // execute instruction, forward jump and link
    inst( { inst, " r1" } );

    // fail
    inst( "mtc0 r0, proc2mngr");

    // pass
    inst( "mtc0 r2, proc2mngr"); init_sink( 32'd1 );

  end
  endtask

  //+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++

  //----------------------------------------------------------------------
  // Helper task to initialize random delay setup
  //----------------------------------------------------------------------

  task init_rand_delays
  (
    input [31:0] src_max_delay,
    input [31:0] mem_max_delay,
    input [31:0] sink_max_delay
  );
  begin
    th_src_max_delay  = src_max_delay;
    th_mem_max_delay  = mem_max_delay;
    th_sink_max_delay = sink_max_delay;
  end
  endtask

  //----------------------------------------------------------------------
  // Helper task to run test
  //----------------------------------------------------------------------

  task run_test;
  begin
    #1;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.trace_cycles < 5000) ) begin
      th.trace_display();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask


  //----------------------------------------------------------------------
  // include the actual test cases
  //----------------------------------------------------------------------

  `include `PLAB2_PROC_TEST_CASES_FILE

  `VC_TEST_SUITE_END
endmodule

