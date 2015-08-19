//========================================================================
// Unit Tests for Pipe Control
//========================================================================

`include "vc-PipeCtrl.v"
`include "vc-regs.v"
`include "vc-TestRandDelaySource.v"
`include "vc-TestRandDelaySink.v"
`include "vc-test.v"

//------------------------------------------------------------------------
// Stage Module
//------------------------------------------------------------------------
// Datapath+Control for a pipeline stage, it shifts the message by shamt
// (default by half byte) it takes the least significant half byte (or
// other size specified by shamt) and stalls by the number of cycles
// specified in the half byte. if the half byte is all 1s (i.e. 0xf),
// then it squashes. it passes on the message that is shifted right by
// shamt

module TestStage
#(
  parameter p_msg_nbits = 32,
  parameter p_shamt     = 4
)(
  input                    clk,
  input                    reset,

  input  [p_msg_nbits-1:0] prev_msg,
  input                    prev_val,
  output                   prev_stall,
  output                   prev_squash,

  output [p_msg_nbits-1:0] next_msg,
  output                   next_val,
  input                    next_stall,
  input                    next_squash
);

  wire curr_stall;
  wire curr_squash;
  wire curr_reg_en;
  wire curr_val;
  wire [p_msg_nbits-1:0] reg_out;

  // the pipeline stage is a register

  vc_EnResetReg #( p_msg_nbits, 0 ) pipe_reg
  (
    .clk    ( clk         ),
    .reset  ( reset       ),
    .en     ( curr_reg_en ),
    .d      ( prev_msg    ),
    .q      ( reg_out     )
  );

  // next_msg is the output of register shifted by shamt. also if we need
  // are propagating a squash, we are passing 0 as the message

  assign next_msg = next_squash ? 0 : ( reg_out >> p_shamt );

  // Pipe control unit

  vc_PipeCtrl pipe_ctrl
  (
    .clk         ( clk          ),
    .reset       ( reset        ),

    .prev_val    ( prev_val     ),
    .prev_stall  ( prev_stall   ),
    .prev_squash ( prev_squash  ),

    .curr_reg_en ( curr_reg_en  ),
    .curr_val    ( curr_val     ),
    .curr_stall  ( curr_stall   ),
    .curr_squash ( curr_squash  ),

    .next_val    ( next_val     ),
    .next_stall  ( next_stall   ),
    .next_squash ( next_squash  )
  );



  // stall while ctr is not 0

  assign curr_stall = (ctr != 0) && !curr_squash;

  // all 1s means squash and we only squash on valid entry

  assign curr_squash = curr_val & ( ctr == {p_shamt{1'b1}} );

  reg [p_shamt-1:0] ctr;

  // sequential stall/squash logic

  always @( posedge clk ) begin
    if ( reset )
      ctr <= 0;
    else if ( curr_reg_en )
      // we strip shamt of the message and set it as the counter
      ctr <= prev_msg[p_shamt-1:0];
    else if ( curr_squash && !prev_stall )
      // we reset the counter on squash to prevent stalling for many
      // cycles
      ctr <= 0;
    else if ( ctr > 0 && ctr != {p_shamt{1'b1}} )
      // decrement the counter
      ctr <= ctr - 1;
  end

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `include "vc-trace-tasks.v"

  reg [`VC_TRACE_NBITS_TO_NCHARS(p_msg_nbits)*8-1:0] msg_str;
  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    $sformat( msg_str, "%x", next_msg );
    // TODO: change hardcode!!!!
    pipe_ctrl.trace_pipe_stage( trace, msg_str, 8 );
  end
  endtask


endmodule

//------------------------------------------------------------------------
// Helper Module
//------------------------------------------------------------------------

module TestHarness
#(
  parameter p_msg_nbits  = 32,
  parameter p_num_msgs   = 1024,
  parameter p_num_stages = 1
)(
  input         clk,
  input         reset,
  input  [31:0] src_max_delay,
  input  [31:0] sink_max_delay,
  output [31:0] num_failed,
  output        done
);

  wire [p_msg_nbits-1:0] src_msg;
  wire                   src_val;
  wire                   src_rdy;
  wire                   src_done;

  wire [p_msg_nbits-1:0] sink_msg;
  wire                   sink_val;
  wire                   sink_rdy;
  wire                   sink_done;

  vc_TestRandDelaySource#(p_msg_nbits,p_num_msgs) src
  (
    .clk       ( clk           ),
    .reset     ( reset         ),

    .max_delay ( src_max_delay ),

    .val       ( src_val       ),
    .rdy       ( src_rdy       ),
    .msg       ( src_msg       ),

    .done      ( src_done      )
  );

  // declare the wires between pipeline stages, note there are
  // p_num_stages+1 wires to account for the connections to the sink

  wire [p_msg_nbits-1:0] msg    [p_num_stages:0];
  wire                   val    [p_num_stages:0];
  wire                   stall  [p_num_stages:0];
  wire                   squash [p_num_stages:0];

  // the pipeline protocol logic <-> val/rdy interfacing

  assign msg[0] = src_msg;
  assign val[0] = src_val & ~squash[0];
  assign src_rdy = ~stall[0] & ~squash[0];

  assign sink_msg = msg[p_num_stages];
  assign sink_val = val[p_num_stages];
  assign stall[p_num_stages] = ~sink_rdy;

  // the sink never squashes

  assign squash[p_num_stages] = 1'b0;

  // the DUT -- our combined test stage which includes the pipeline
  // register and the control

  // we use a generate loop to build the pipeline stages

  genvar s;

  generate
  for ( s = 0; s < p_num_stages; s = s + 1 ) begin: STAGE

    TestStage#(p_msg_nbits) stage
    (
      .clk      ( clk     ),
      .reset    ( reset   ),

      .prev_msg     ( msg   [s] ),
      .prev_val     ( val   [s] ),
      .prev_stall   ( stall [s] ),
      .prev_squash  ( squash[s] ),

      .next_msg     ( msg   [s+1] ),
      .next_val     ( val   [s+1] ),
      .next_stall   ( stall [s+1] ),
      .next_squash  ( squash[s+1] )
    );

  end
  endgenerate

  vc_TestRandDelaySink#(p_msg_nbits,p_num_msgs) sink
  (
    .clk        ( clk            ),
    .reset      ( reset          ),

    .max_delay  ( sink_max_delay ),

    .val        ( sink_val       ),
    .rdy        ( sink_rdy       ),
    .msg        ( sink_msg       ),

    .num_failed ( num_failed     ),
    .done       ( sink_done      )
  );

  assign done = src_done && sink_done;

  `include "vc-trace-tasks.v"

  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    src.trace_module( trace );
    vc_trace_str( trace, " > " );
    // NOTE: ideally, we would use a for loop here and iterate on number
    // of stages, however I couldn't figure out how to loop over without
    // iverilog complaining about indexing into STAGE
    STAGE[0].stage.trace_module( trace );
    if ( p_num_stages > 1 ) begin
      vc_trace_str( trace, "|" );
      STAGE[1].stage.trace_module( trace );
    end
    if ( p_num_stages > 2 ) begin
      vc_trace_str( trace, "|" );
      STAGE[2].stage.trace_module( trace );
    end
    if ( p_num_stages > 3 ) begin
      vc_trace_str( trace, "|" );
      STAGE[3].stage.trace_module( trace );
    end
    if ( p_num_stages > 4 ) begin
      vc_trace_str( trace, "|" );
      STAGE[4].stage.trace_module( trace );
    end
    if ( p_num_stages > 5 ) begin
      vc_trace_str( trace, "|" );
      STAGE[5].stage.trace_module( trace );
    end
    if ( p_num_stages > 6 ) begin
      vc_trace_str( trace, "|" );
      STAGE[6].stage.trace_module( trace );
    end
    if ( p_num_stages > 7 ) begin
      vc_trace_str( trace, "|" );
      STAGE[7].stage.trace_module( trace );
    end
    if ( p_num_stages > 8 ) begin
      vc_trace_str( trace, "|" );
      STAGE[8].stage.trace_module( trace );
    end
    if ( p_num_stages > 9 ) begin
      vc_trace_str( trace, "|" );
      STAGE[9].stage.trace_module( trace );
    end
    vc_trace_str( trace, " > " );
    sink.trace_module( trace );
  end
  endtask

endmodule

//------------------------------------------------------------------------
// Main Tester Module
//------------------------------------------------------------------------

module top;
  `VC_TEST_SUITE_BEGIN( "vc-PipeCtrl" )

  //----------------------------------------------------------------------
  // Test Setup
  //----------------------------------------------------------------------

  reg         th_reset = 1'b1;
  reg  [31:0] th_src_max_delay;
  reg  [31:0] th_sink_max_delay;
  wire [31:0] th_num_failed;
  wire        th_done;

  TestHarness
  #(
    .p_msg_nbits  (32),
    .p_num_stages (6)
  )
  th
  (
    .clk            (clk),
    .reset          (th_reset),
    .src_max_delay  (th_src_max_delay),
    .sink_max_delay (th_sink_max_delay),
    .num_failed     (th_num_failed),
    .done           (th_done)
  );

  // helper task to initialize source/sink

  task init_in
  (
    input [ 9:0] i,
    input [32:0] in
  );
  begin
    th.src.src.m[i]   = in;
  end
  endtask

  task init_out
  (
    input [ 9:0] i,
    input [32:0] out
  );
  begin
    th.sink.sink.m[i] = out;
  end
  endtask

  // simple dataset with no stalls or squashes

  task init_nostall;
  begin
    //       i  in                        i  out
    init_in( 0, 32'he0000000 ); init_out( 0, 32'he0 );
    init_in( 1, 32'h01000000 ); init_out( 1, 32'h01 );
    init_in( 2, 32'h10000000 ); init_out( 2, 32'h10 );
    init_in( 3, 32'hd1000000 ); init_out( 3, 32'hd1 );
    init_in( 4, 32'haa000000 ); init_out( 4, 32'haa );
    init_in( 5, 32'h01000000 ); init_out( 5, 32'h01 );
    init_in( 6, 32'h96000000 ); init_out( 6, 32'h96 );
    init_in( 7, 32'h80000000 ); init_out( 7, 32'h80 );
    init_in( 8, 32'h10000000 ); init_out( 8, 32'h10 );
    init_in( 9, 32'h31000000 ); init_out( 9, 32'h31 );
    init_in(10, 32'h33000000 ); init_out(10, 32'h33 );
    init_in(11, 32'h19000000 ); init_out(11, 32'h19 );
    init_in(12, 32'hff000000 ); init_out(12, 32'hff );
  end
  endtask

  // dataset with stalls

  task init_stall;
  begin
    //       i  in                        i  out
    init_in( 0, 32'he0010500 ); init_out( 0, 32'he0 );
    init_in( 1, 32'h01003000 ); init_out( 1, 32'h01 );
    init_in( 2, 32'h10601010 ); init_out( 2, 32'h10 );
    init_in( 3, 32'hd1000000 ); init_out( 3, 32'hd1 );
    init_in( 4, 32'haa000000 ); init_out( 4, 32'haa );
    init_in( 5, 32'h01000000 ); init_out( 5, 32'h01 );
    init_in( 6, 32'h96000000 ); init_out( 6, 32'h96 );
    init_in( 7, 32'h80111111 ); init_out( 7, 32'h80 );
    init_in( 8, 32'h10000000 ); init_out( 8, 32'h10 );
    init_in( 9, 32'h31030000 ); init_out( 9, 32'h31 );
    init_in(10, 32'h33000220 ); init_out(10, 32'h33 );
    init_in(11, 32'h19030000 ); init_out(11, 32'h19 );
    init_in(12, 32'hff000110 ); init_out(12, 32'hff );
  end
  endtask

  // dataset with squashes and stalls

  task init_squash;
  begin
    //       i  in                        i  out
    init_in( 0, 32'he0010500 ); init_out( 0, 32'he0 );
    init_in( 1, 32'h010030f0 ); init_out( 1, 32'h01 );
    init_in( 2, 32'h10601010 );
    init_in( 3, 32'hd1000000 ); init_out( 2, 32'hd1 );
    init_in( 4, 32'haa000000 ); init_out( 3, 32'haa );
    init_in( 5, 32'h01000000 ); init_out( 4, 32'h01 );
    init_in( 6, 32'h96000000 ); init_out( 5, 32'h96 );
    init_in( 7, 32'h80111111 ); init_out( 6, 32'h80 );
    init_in( 8, 32'h10f00000 ); init_out( 7, 32'h10 );
    init_in( 9, 32'h31030000 ); init_out( 8, 32'hxx );
    init_in(10, 32'h33000220 );
    init_in(11, 32'h19030000 );
    init_in(12, 32'hff000110 );
  end
  endtask

  // helper task to run test

  task run_test;
  begin
    #5;   th_reset = 1'b1;
    #20;  th_reset = 1'b0;

    while ( !th_done && (th.trace_cycles < 5000) ) begin
      th.trace_display();
      #10;
    end

    `VC_TEST_INCREMENT_NUM_FAILED( th_num_failed );
    `VC_TEST_NET( th_done, 1'b1 );
  end
  endtask

  //----------------------------------------------------------------------
  // Test case: no stall src delay = 0, sink delay = 0
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 1, "no stall src delay = 0, sink delay = 0" )
  begin
    th_src_max_delay  = 0;
    th_sink_max_delay = 0;
    init_nostall;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test case: no stall src delay = 4, sink delay = 0
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 2, "no stall src delay = 4, sink delay = 0" )
  begin
    th_src_max_delay  = 4;
    th_sink_max_delay = 0;
    init_nostall;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test case: no stall src delay = 0, sink delay = 4
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 3, "no stall src delay = 0, sink delay = 4" )
  begin
    th_src_max_delay  = 0;
    th_sink_max_delay = 4;
    init_nostall;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test case: no stall src delay = 4, sink delay = 4
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 4, "no stall src delay = 4, sink delay = 4" )
  begin
    th_src_max_delay  = 4;
    th_sink_max_delay = 4;
    init_nostall;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test case: stall src delay = 0, sink delay = 0
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 5, "stall src delay = 0, sink delay = 0" )
  begin
    th_src_max_delay  = 0;
    th_sink_max_delay = 0;
    init_stall;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test case: stall src delay = 4, sink delay = 0
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 6, "stall src delay = 4, sink delay = 0" )
  begin
    th_src_max_delay  = 4;
    th_sink_max_delay = 0;
    init_stall;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test case: stall src delay = 0, sink delay = 4
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 7, "stall src delay = 0, sink delay = 4" )
  begin
    th_src_max_delay  = 0;
    th_sink_max_delay = 4;
    init_stall;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test case: no stall src delay = 4, sink delay = 4
  //----------------------------------------------------------------------

  `VC_TEST_CASE_BEGIN( 8, "stall src delay = 4, sink delay = 4" )
  begin
    th_src_max_delay  = 4;
    th_sink_max_delay = 4;
    init_stall;
    run_test;
  end
  `VC_TEST_CASE_END

  //----------------------------------------------------------------------
  // Test case: squash src delay = 0, sink delay = 0
  //----------------------------------------------------------------------
  // note: this is the only squash test, because the squashing behavior
  // is dependent what currently is on the pipeline, which depends on the
  // delays on sources and sinks

  `VC_TEST_CASE_BEGIN( 9, "squash src delay = 0, sink delay = 0" )
  begin
    th_src_max_delay  = 0;
    th_sink_max_delay = 0;
    init_squash;
    run_test;
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END
endmodule

