//=========================================================================
// Processor Test Harness
//=========================================================================
// This harness is meant to be instantiated for a specific implementation
// of the multiplier using the special IMPL macro like this:
//
//  `define PLAB5_MCORE_IMPL     plab5_mcore_Impl
//  `define PLAB5_MCORE_IMPL_STR "plab5-mcore-Impl-%INST%"
//  `define PLAB5_MCORE_TEST_CASES_FILE plab5-mcore-test-cases-%INST%.v
//
//  `include "plab5-mcore-Impl.v"
//  `include "plab5-mcore-test-harness.v"
//
// This test harness provides the logic and includes the test cases
// specified in `PLAB5_MCORE_TEST_CASES_FILE.

`define SECURE

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

  localparam c_req_msg_nbits  = `VC_MEM_REQ_MSG_NBITS(8,32,128);
  localparam c_req_msg_cnbits = c_req_msg_nbits - c_data_nbits;
  localparam c_req_msg_dnbits = c_data_nbits;
  localparam c_resp_msg_nbits = `VC_MEM_RESP_MSG_NBITS(8,128);
  localparam c_resp_msg_cnbits= c_resp_msg_nbits - c_data_nbits;
  localparam c_resp_msg_dnbits= c_data_nbits;
  localparam c_opaque_nbits   = 8;
  localparam c_data_nbits     = 128;  // size of mem message data in bits
  localparam c_addr_nbits     = 32;   // size of mem message address in bits

  // wires

  wire [31:0] src_msg_proc0;
  wire        src_val_proc0;
  wire        src_rdy_proc0;
  wire        src_done_proc0;

  wire [31:0] sink_msg_proc0;
  wire        sink_val_proc0;
  wire        sink_rdy_proc0;
  wire        sink_done_proc0;

  wire [31:0] src_msg_proc1;
  wire        src_val_proc1;
  wire        src_rdy_proc1;
  wire        src_done_proc1;

  wire [31:0] sink_msg_proc1;
  wire        sink_val_proc1;
  wire        sink_rdy_proc1;
  wire        sink_done_proc1;

  // from mngr source

  vc_TestRandDelaySource
  #(
    .p_msg_nbits       (32),
    .p_num_msgs        (p_num_msgs)
  )
  src_proc0
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (src_max_delay),

    .val       (src_val_proc0),
    .rdy       (src_rdy_proc0),
    .msg       (src_msg_proc0),

    .done      (src_done_proc0)
  );

  vc_TestRandDelaySource
  #(
    .p_msg_nbits       (32),
    .p_num_msgs        (p_num_msgs)
  )
  src_proc1
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (src_max_delay),

    .val       (src_val_proc1),
    .rdy       (src_rdy_proc1),
    .msg       (src_msg_proc1),

    .done      (src_done_proc1)
  );

  // processor-network

  `PLAB5_MCORE_IMPL proc_cache_net
  (
    .clk					(clk),
    .reset					(reset),

	.mem_clear				(mem_clear),

    .proc0_from_mngr_msg	(src_msg_proc0),
    .proc0_from_mngr_val	(src_val_proc0),
    .proc0_from_mngr_rdy	(src_rdy_proc0),

    .proc0_to_mngr_msg		(sink_msg_proc0),
    .proc0_to_mngr_val		(sink_val_proc0),
    .proc0_to_mngr_rdy		(sink_rdy_proc0),

	.proc1_from_mngr_msg	(src_msg_proc1),
	.proc1_from_mngr_val	(src_val_proc1),
	.proc1_from_mngr_rdy	(src_rdy_proc1),

	.proc1_to_mngr_msg		(sink_msg_proc1),
	.proc1_to_mngr_val		(sink_val_proc1),
	.proc1_to_mngr_rdy		(sink_rdy_proc1)
  );

  // to mngr sink

  vc_TestRandDelaySink
  #(
    .p_msg_nbits       (32),
    .p_num_msgs        (p_num_msgs)
  )
  sink_proc0
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (sink_max_delay),

    .val       (sink_val_proc0),
    .rdy       (sink_rdy_proc0),
    .msg       (sink_msg_proc0),

    .done      (sink_done_proc0)
  );

  vc_TestRandDelaySink
  #(
    .p_msg_nbits       (32),
    .p_num_msgs        (p_num_msgs)
  )
  sink_proc1
  (
    .clk       (clk),
    .reset     (reset),

    .max_delay (sink_max_delay),

    .val       (sink_val_proc1),
    .rdy       (sink_rdy_proc1),
    .msg       (sink_msg_proc1),

    .done      (sink_done_proc1)
  );

  assign done = src_done_proc0 && src_done_proc1 && sink_done_proc0 && sink_done_proc1;

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    src_proc0.trace_module( trace );
    vc_trace_str( trace, " > " );
	src_proc1.trace_module( trace );
	vc_trace_str( trace, " > " );
    vc_trace_str( trace, " > " );
    sink_proc0.trace_module( trace );
	vc_trace_str( trace, " > " );
	sink_proc1.trace_module( trace );
  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( `PLAB5_MCORE_IMPL_STR )

  pisa_InstTasks pisa();

  // the reset vector (the PC that the processor will start fetching from
  // after a reset)
  localparam c_reset_vector	   = 32'h1000;
  localparam c_reset_vector_p0 = 32'h1000;
  localparam c_reset_vector_p1 = 32'h2000;

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
  reg  [31:0] th_inst_addr;
  reg  [31:0] th_data_addr;
  reg  [31:0] th_src_proc0_idx;
  reg  [31:0] th_src_proc1_idx;
  reg  [31:0] th_sink_proc0_idx;
  reg  [31:0] th_sink_proc1_idx;
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
  // load_inst_mem: helper task to load one word instrcution into memory
  //----------------------------------------------------------------------

  task load_inst_mem0
  (
    input [31:0] addr,
    input [31:0] data
  );
  begin
    th.proc_cache_net.inst_mem.m_pub[ addr >> 4 ][addr[3:2]*32 +: 32] = data;
	//$display("The address is %h", addr);
	//$display("The load address is in low and %h, the data is %h", addr >> 4, data );
  end
  endtask

  //----------------------------------------------------------------------
  // load_inst_mem: helper task to load one word instrcution into memory
  //----------------------------------------------------------------------

  task load_inst_mem1
  (
    input [31:0] addr,
    input [31:0] data
  );
  begin
    th.proc_cache_net.inst_mem.m_sec[ addr >> 4 - (1<<16)/64 ][addr[3:2]*32 +: 32] = data;
	//$display("The address is %h", addr);
	//$display("The load address is in high and %h", ((addr>>4)-(1<<16)/64));
  end
  endtask

  //----------------------------------------------------------------------
  // load_inst_mem: helper task to load one word data into memory
  //----------------------------------------------------------------------

  task load_data_mem0
  (
    input [31:0] addr,
    input [31:0] data
  );
  begin
    th.proc_cache_net.data_mem.m_pub[ (addr >> 4) - (1<<16)*2/64 ][addr[3:2]*32 +: 32] = data;
	//$display("The address is %h and data is %h", addr, data);
	//$display("The load address is in lower and %h", ((addr >> 4) - (1<<16)/32));
  end
  endtask

  //----------------------------------------------------------------------
  // load_inst_mem: helper task to load one word data into memory
  //----------------------------------------------------------------------

  task load_data_mem1
  (
    input [31:0] addr,
    input [31:0] data
  );
  begin
    th.proc_cache_net.data_mem.m_sec[ (addr >> 4) - (1<<16)*3/64 ][addr[3:2]*32 +: 32] = data;
	//$display("The address is %h", addr);
	//$display("The data	  is %h", data);
	//$display("The load address is in higher and %h", ((addr >> 4) - (1<<16)*3/64));
  end
  endtask

  //----------------------------------------------------------------------
  // load_from_mngr: helper task to load an entry into the from_mngr source 
  // of proc0
  //----------------------------------------------------------------------

  task load_from_mngr_proc0
  (
    input [ 9:0] i,
    input [31:0] msg
  );
  begin
    th.src_proc0.src.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // load_from_mngr: helper task to load an entry into the from_mngr source 
  // of proc2
  //----------------------------------------------------------------------

  task load_from_mngr_proc1
  (
    input [ 9:0] i,
    input [31:0] msg
  );
  begin
    th.src_proc1.src.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // load_to_mngr: helper task to load an entry into the to_mngr sink of
  // proc0
  //----------------------------------------------------------------------

  task load_to_mngr_proc0
  (
    input [ 9:0]  i,
    input [31:0]  msg
  );
  begin
    th.sink_proc0.sink.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // load_to_mngr: helper task to load an entry into the to_mngr sink of
  // proc2
  //----------------------------------------------------------------------

  task load_to_mngr_proc1
  (
    input [ 9:0]  i,
    input [31:0]  msg
  );
  begin
    th.sink_proc1.sink.m[i] = msg;
  end
  endtask

  //----------------------------------------------------------------------
  // clear_mem: clear the contents of memory and test sources and sinks
  //----------------------------------------------------------------------

  task clear_mem;
  begin
    #1;   th_mem_clear = 1'b1;
    #20;  th_mem_clear = 1'b0;
    th_src_proc0_idx = 0;
	th_src_proc1_idx = 0;
    th_sink_proc0_idx = 0;
	th_sink_proc1_idx = 0;
    // in case there are no srcs/sinks, we set the first elements of them
    // to xs
    load_from_mngr_proc0( 0, 32'hxxxxxxxx );
    load_from_mngr_proc1( 0, 32'hxxxxxxxx );
    load_to_mngr_proc0(   0, 32'hxxxxxxxx );
    load_to_mngr_proc1(   0, 32'hxxxxxxxx );
  end
  endtask

  //----------------------------------------------------------------------
  // init_src: add a data to the test src
  //----------------------------------------------------------------------

  task init_src
  (
    input [31:0] data,
    input		 proc_num
  );
  begin
	if ( proc_num == 1'b0 ) begin
		load_from_mngr_proc0( th_src_proc0_idx, data );
		th_src_proc0_idx = th_src_proc0_idx + 1;
		// we set the next address with x's so that src/sink stops here if
		// there isn't another call to init_src/sink
		load_from_mngr_proc0( th_src_proc0_idx, 32'hxxxxxxxx );
	end

	else if ( proc_num == 1'b1 ) begin
		load_from_mngr_proc1( th_src_proc1_idx, data );
		th_src_proc1_idx = th_src_proc1_idx + 1;
		// we set the next address with x's so that src/sink stops here if
		// there isn't another call to init src/sink
		load_from_mngr_proc1( th_src_proc1_idx, 32'hxxxxxxxx );
	end
  end
  endtask

  //----------------------------------------------------------------------
  // init_sink: add a data to the test sink
  //----------------------------------------------------------------------

  task init_sink
  (
    input [31:0] data,
	input		 proc_num
  );
  begin
	if ( proc_num == 1'b0 ) begin
		load_to_mngr_proc0( th_sink_proc0_idx, data );
		th_sink_proc0_idx = th_sink_proc0_idx + 1;
		// we set the next address with x's so that src/sink stops here if
		// there isn't another call to init_src/sink
		load_to_mngr_proc0( th_sink_proc0_idx, 32'hxxxxxxxx );
	end

	else if ( proc_num == 1'b1 ) begin
		load_to_mngr_proc1( th_sink_proc1_idx, data );
		th_sink_proc1_idx = th_sink_proc1_idx + 1;
		// we set the next address with x's so that src/sink stops here if
		// there isn't another call to inst_src/sink
		load_to_mngr_proc1( th_sink_proc1_idx, 32'hxxxxxxxx );
	end
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
    th_inst_asm_str = pisa.asm( th_inst_addr, asm_str );
	//$display("The instruction address is %h", th_inst_addr);
	if ( (th_inst_addr>>4) < (1 << 16) / 64 ) begin 
		load_inst_mem0( th_inst_addr, th_inst_asm_str );
	end

	else if ( (th_data_addr >> 4) >= ((1 << 16) / 64) &&
			(th_data_addr >> 4) < ((1 << 16) * 2 / 64) ) begin
		load_inst_mem1( th_inst_addr, th_inst_asm_str );
	end
    // increment pc
    th_inst_addr = th_inst_addr + 4;
  end
  endtask

  //----------------------------------------------------------------------
  // inst0: assemble and put instruction to next addr for processor 0
  //----------------------------------------------------------------------
  /*task inst0
  (
	input [25*8-1:0] asm_str
  );
  begin
	th_inst_asm_str = pisa.asm( th_inst_addr, asm_str );*/
	

  //----------------------------------------------------------------------
  // data: put data_in to next addr, useful for mem ops
  //----------------------------------------------------------------------

  task data
  (
    input [31:0] data_in
  );
  begin

	if ( (th_data_addr >> 4) >= ((1 << 16) * 2 / 64) &&
			(th_data_addr >> 4) < ((1 << 16) * 3 / 64) ) begin
		load_data_mem0( th_data_addr, data_in );
		//$display("Select m0 with %h and %h", (th_data_addr >> 4), ((1<<16)/32));
	end

	else begin
		load_data_mem1( th_data_addr, data_in );
		//$display("Select m1 with %h and %h", (th_data_addr >> 4), ((1<<16)/32));
    end
    // increment pc
    th_data_addr = th_data_addr + 4;
  end
  endtask

  //----------------------------------------------------------------------
  // inst_address: each instrcution consecutive call to inst and data 
  // would be put after this address
  //----------------------------------------------------------------------

  task inst_address
  (
    input [31:0] addr
  );
  begin
    th_inst_addr = addr;
  end
  endtask

  //----------------------------------------------------------------------
  // dataw_address: each data consecutive call to inst and data 
  // would be put after this address
  //----------------------------------------------------------------------

  task data_address
  (
    input [31:0] addr
  );
  begin
    th_data_addr = addr;
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
    inst( { "mtc0 r1, proc2mngr" } ); init_sink( result, 0 );
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
    inst( { "mfc0 ", src0_spec, ", mngr2proc" } ); init_src( src0, 0 );
    test_insert_nops( src0_nops );

    // run the actual instruction
    inst( { inst, " ", result_spec, ", ", src0_spec, ", ", imm_str } );

    // copy the result back to the manager
    test_insert_nops( dest_nops );
    inst( { "mtc0 ", result_spec, ", proc2mngr" } ); init_sink( result, 0 );
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
    inst( { "mfc0 ", src0_spec, ", mngr2proc" } ); init_src( src0, 0 );
    test_insert_nops( src0_nops );


    // load only one input if both src0 and src1 use the same specifiers
    if ( src0_spec != src1_spec ) begin
      inst( { "mfc0 ", src1_spec, ", mngr2proc" } ); init_src( src1, 0 );
      test_insert_nops( src1_nops );
    end

    // run the actual instruction
    if ( src_reverse )
      inst( { inst, " ", result_spec, ", ", src1_spec, ", ", src0_spec } );
    else
      inst( { inst, " ", result_spec, ", ", src0_spec, ", ", src1_spec } );

    // copy the result back to the manager
    test_insert_nops( dest_nops );
    inst( { "mtc0 ", result_spec, ", proc2mngr" } ); init_sink( result, 0 );
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
    input     [31:0] base_proc0,
	input	  [31:0] base_proc1,
    input     [31:0] result_proc0,
	input	  [31:0] result_proc1,
    input     [31:0] src0_nops,
    input     [31:0] dest_nops
  );
  begin
    // convert the offset to string
    $sformat( imm_str, "0x%x", offset );

    // load the base pointer
    inst( "mfc0 r1, mngr2proc"); 
	init_src( base_proc0, 0 ); 
	init_src( base_proc1, 1 );
    test_insert_nops( src0_nops );
    inst( { inst, " r2, ", imm_str, "(r1)" } );
    test_insert_nops( dest_nops );
    inst( "mtc0 r2, proc2mngr"); 
	init_sink( result_proc0, 0 );
	init_sink( result_proc1, 1 );
  end
  endtask

  task test_ld_op
  (
    input [25*8-1:0] inst,
    input     [15:0] offset,
    input     [31:0] base_proc0,
	input	  [31:0] base_proc1,
    input     [31:0] result_proc0,
	input	  [31:0] result_proc1
  );
  begin
    test_ld_op_helper( inst, offset, base_proc0, base_proc1, 
							result_proc0, result_proc1, 0, 0 );
  end
  endtask

  task test_ld_dest_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst,
    input     [15:0] offset,
    input     [31:0] base_proc0,
	input	  [31:0] base_proc1,
    input     [31:0] result_proc0,
	input	  [31:0] result_proc1
  );
  begin
    test_ld_op_helper( inst, offset, base_proc0, base_proc1,
							result_proc0, result_proc1, 0, nops );
  end
  endtask

  task test_ld_src_byp
  (
    input     [31:0] nops,
    input [25*8-1:0] inst,
    input     [15:0] offset,
    input     [31:0] base_proc0,
	input	  [31:0] base_proc1,
    input     [31:0] result_proc0,
	input	  [31:0] result_proc1
  );
  begin
    test_ld_op_helper( inst, offset, base_proc0, base_proc1,
							result_proc0, result_proc1, nops, 0 );
  end
  endtask

  //----------------------------------------------------------------------
  // test_sw: helper tasks for store word instructions
  //----------------------------------------------------------------------

  task test_sw_op_helper
  (
    input [25*8-1:0] inst,
    input     [31:0] wdata_proc0,
	input	  [31:0] wdata_proc1,
    input     [15:0] offset,
    input     [31:0] base_proc0,
	input	  [31:0] base_proc1,
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input            reverse_srcs
  );
  begin
    // convert the offset to string
    $sformat( imm_str, "0x%x", offset );

    if ( reverse_srcs ) begin
      // load the write data
      inst( "mfc0 r2, mngr2proc"); 
	  init_src( wdata_proc0, 0 );
	  init_src( wdata_proc1, 1 ); 
      test_insert_nops( src1_nops );
      // load the base pointer
      inst( "mfc0 r1, mngr2proc"); 
	  init_src( base_proc0, 0 );
	  init_src( base_proc1, 1 );
      test_insert_nops( src0_nops );
    end else begin
      // load the base pointer
      inst( "mfc0 r1, mngr2proc"); 
	  init_src( base_proc0, 0 );
	  init_src( base_proc1, 1 );
      test_insert_nops( src0_nops );
      // load the write data
      inst( "mfc0 r2, mngr2proc"); 
	  init_src( wdata_proc0, 0 );
	  init_src( wdata_proc1, 1 );
      test_insert_nops( src1_nops );
    end

    // do the store
    inst( { inst, " r2, ", imm_str, "(r1)" } );
    // load the instruction back
    inst( { "lw r3, ", imm_str, "(r1)" } );

    // make sure we have written (and read) the correct data
    inst( "mtc0 r3, proc2mngr"); 
	init_sink( wdata_proc0, 0 );
	init_sink( wdata_proc1, 1 );
  end
  endtask

  task test_sw_op
  (
    input [25*8-1:0] inst,
    input     [31:0] wdata_proc0,
    input     [31:0] wdata_proc1,
    input     [15:0] offset,
    input     [31:0] base_proc0,
    input     [31:0] base_proc1
  );
  begin
    test_sw_op_helper( inst, wdata_proc0, wdata_proc1, offset, 
						base_proc0, base_proc1, 0, 0, 0 );
  end
  endtask

  task test_sw_src01_byp
  (
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input [25*8-1:0] inst,
    input     [31:0] wdata_proc0,
	input	  [31:0] wdata_proc1,
    input     [15:0] offset,
    input     [31:0] base_proc0,
	input	  [31:0] base_proc1
  );
  begin
    test_sw_op_helper( inst, wdata_proc0, wdata_proc1, offset, 
						base_proc0, base_proc1, src0_nops, src1_nops, 0 );
  end
  endtask

  task test_sw_src10_byp
  (
    input     [31:0] src0_nops,
    input     [31:0] src1_nops,
    input [25*8-1:0] inst,
    input     [31:0] wdata_proc0,
	input	  [31:0] wdata_proc1,
    input     [15:0] offset,
    input     [31:0] base_proc0,
	input	  [31:0] base_proc1
  );
  begin
    test_sw_op_helper( inst, wdata_proc0, wdata_proc1, offset, 
						base_proc0, base_proc1, src0_nops, src1_nops, 1 );
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
    inst( "mfc0 r3, mngr2proc"); init_src( 32'd1, 0 );

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( src0, 0 );
    inst( "mfc0 r2, mngr2proc"); init_src( src1, 0 );

    // forward branch, if taken goto 2:
    inst( { inst, " r1, r2, [+4]" } );

    if ( taken ) begin
      // send fail value
      inst( "mtc0 r0, proc2mngr");
    end else begin
      // send pass value
      inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1, 0 );
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
      inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1, 0 );
    end

    // 3: send pass
    inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1, 0 );
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
    inst( "mfc0 r3, mngr2proc"); init_src( 32'd1, 0 );

    // load the sources
    inst( "mfc0 r1, mngr2proc"); init_src( src0, 0 );
    test_insert_nops( src0_nops );
    inst( "mfc0 r2, mngr2proc"); init_src( src1, 0 );
    test_insert_nops( src1_nops );

    // forward branch, we assume not taken
    inst( { inst, " r1, r2, [+2]" } );

    // branch taken to pass
    inst( "bne r3, r0, [+2]" );
    // fail
    inst( "mtc0 r0, proc2mngr");
    // pass
    inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1, 0 );

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
    inst( "mfc0 r3, mngr2proc"); init_src( 32'd1, 0 );

    // load the sources
    inst( "mfc0 r2, mngr2proc"); init_src( src1, 0 );
    test_insert_nops( src1_nops );
    inst( "mfc0 r1, mngr2proc"); init_src( src0, 0 );
    test_insert_nops( src0_nops );

    // forward branch, we assume not taken
    inst( { inst, " r1, r2, [+2]" } );

    // branch taken to pass
    inst( "bne r3, r0, [+2]" );
    // fail
    inst( "mtc0 r0, proc2mngr");
    // pass
    inst( "mtc0 r3, proc2mngr"); init_sink( 32'd1, 0 );

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
    temp_pc = th_inst_addr;

    // execute instruction, forward jump and link
    inst( { inst, " [+2]" } );

    // fail
    inst( "mtc0 r0, proc2mngr");

    test_insert_nops( nops );
    // pass
    inst( "mtc0 r31, proc2mngr"); init_sink( temp_pc + 4, 0 );

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
    inst( "mfc0 r2, mngr2proc"); init_src( 32'd1, 0 );
    // send the target address
    inst( "mfc0 r1, mngr2proc"); init_src( th_inst_addr + (2 + nops) * 4, 0 );

    test_insert_nops( nops );

    // execute instruction, forward jump and link
    inst( { inst, " r1" } );

    // fail
    inst( "mtc0 r0, proc2mngr");

    // pass
    inst( "mtc0 r2, proc2mngr"); init_sink( 32'd1, 0 );

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

    while ( !th_done && (th.trace_cycles < 10000) ) begin
      th.trace_display();
      #10;
    end

    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask


  //----------------------------------------------------------------------
  // include the actual test cases
  //----------------------------------------------------------------------

  `include `PLAB5_MCORE_TEST_CASES_FILE

  `VC_TEST_SUITE_END

endmodule

