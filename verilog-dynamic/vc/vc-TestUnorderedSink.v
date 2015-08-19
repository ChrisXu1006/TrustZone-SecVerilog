//========================================================================
// Verilog Components: Test Unordered Sink
//========================================================================
// This is similar to TestSink, except the messages it expects can come in
// any order.
//
// p_sim_mode should be set to one in simulators. This will cause the
// sink to abort after the first failure with an appropriate error
// message.

`ifndef VC_TEST_UNORDERED_SINK_V
`define VC_TEST_UNORDERED_SINK_V

`include "vc-regs.v"
`include "vc-test.v"

module vc_TestUnorderedSink
#(
  parameter p_msg_nbits = 1,
  parameter p_num_msgs  = 1024,
  parameter p_sim_mode  = 0
)(
  input                    clk,
  input                    reset,

  // Sink message interface

  input                    val,
  output                   rdy,
  input  [p_msg_nbits-1:0] msg,

  // Keeps track of how many messages failed

  output [31:0]            num_failed,

  // Goes high once all sink data has been received

  output                   done
);

  //----------------------------------------------------------------------
  // Local parameters
  //----------------------------------------------------------------------

  // Size of a physical address for the memory in bits

  localparam c_index_nbits = $clog2(p_num_msgs);

  //----------------------------------------------------------------------
  // State
  //----------------------------------------------------------------------

  // Memory which stores messages to verify against those received

  reg [p_msg_nbits-1:0] m[p_num_msgs-1:0];

  // Bitmask that indicates seen messages

  reg [p_num_msgs-1:0] seen;

  // Register reset

  reg reset_reg;
  always @( posedge clk )
    reset_reg <= reset;

  //----------------------------------------------------------------------
  // Combinational logic
  //----------------------------------------------------------------------

  // Counters for number of messages expected and received

  reg [31:0] num_expected;
  reg [31:0] num_seen;

  // We check number of expected and seen, and when they are the same, we
  // are done

  assign done = !reset_reg && ( num_seen >= num_expected );

  // Sink message interface is ready as long as we are not done

  assign rdy = !reset_reg && !done;

  // The go signal is high when a message is transferred

  wire go = val && rdy;

  //----------------------------------------------------------------------
  // Verification logic
  //----------------------------------------------------------------------

  // Index register that we use to check m

  reg [31:0] index;

  reg [31:0] num_failed;
  reg [31:0] _vc_test_num_failed;
  reg [3:0]  _vc_test_verbose;

  initial begin
    if ( !$value$plusargs( "verbose=%d", _vc_test_verbose ) )
      _vc_test_verbose = 0;
  end

  always @( posedge clk ) begin
    if ( reset ) begin
      _vc_test_num_failed <= 0;
      num_failed <= 0;

      // we clear the seen bitmask and counters on reset
      seen <= 0;
      num_seen <= 0;
      num_expected <= 0;

    end
    // because reset is more expensive because of looping through an
    // array, for the time being, using this hack to reset only once
    else if ( !reset && reset_reg ) begin

      begin: COUNT_EXPECTED_LOOP
        for ( index = 0; index < p_num_msgs; index = index + 1 ) begin
          // we break from the loop if we see Xs which marks the end
          if ( m[index] === {p_msg_nbits{1'bx}} ) begin
            disable COUNT_EXPECTED_LOOP;
          end else begin
            // note: this is deliberately a blocking assignment
            num_expected = num_expected + 1;
          end
        end
      end

    end
    else if ( !reset && go ) begin

      if ( _vc_test_verbose > 1 )
        $display( "                %m checking message number %0d", index );

      // loop over m to see if we expect this message. also note that
      // we're labeling this loop to be able to disable it (break)
      begin: VERIFY_LOOP
        for ( index = 0; index <= num_expected; index = index + 1 ) begin
          // if we haven't encountered this message, then it's failure
          if ( index == num_expected ) begin
            `VC_TEST_FAIL( msg, "arrived message not expected in sink." );
          end
          // if we found the message, then we call VC_TEST_NET and mark it
          // as seen
          else if ( msg === m[index] && !seen[index] ) begin
            `VC_TEST_NET( msg, m[index] );
            seen[index] <= 1'b1;
            // we break if we have seen this
            disable VERIFY_LOOP;
          end
        end
      end

      // regardless of fail or pass, we mark this as a seen message
      num_seen <= num_seen + 1;

      num_failed <= _vc_test_num_failed;

      if ( p_sim_mode && (_vc_test_num_failed > 0) ) begin
        $display( "" );
        $display( " ERROR: Test sink found a failure!" );
        $display( "  - module   : %m" );
        $display( "  - expected : %x", m[index] );
        $display( "  - actual   : %x", msg );
        $display( "" );
        $display( " Verify that all unit tests pass; if they do, then debug" );
        $display( " the failure and add a new unit test which would have" );
        $display( " caught the bug in the first place." );
        $display( "" );
        $finish_and_return(1);
      end

    end
  end

  //----------------------------------------------------------------------
  // Assertions
  //----------------------------------------------------------------------

  always @( posedge clk ) begin
    if ( !reset ) begin
      `VC_ASSERT_NOT_X( val );
      `VC_ASSERT_NOT_X( rdy );
    end
  end

  //----------------------------------------------------------------------
  // Line Tracing
  //----------------------------------------------------------------------

  `include "vc-trace-tasks.v"

  reg [`VC_TRACE_NBITS_TO_NCHARS(p_msg_nbits)*8-1:0] msg_str;
  task trace_module( inout [vc_trace_nbits-1:0] trace );
  begin
    $sformat( msg_str, "%x", msg );
    vc_trace_str_val_rdy( trace, val, rdy, msg_str );
  end
  endtask

endmodule

`endif /* VC_TEST_UNORDERED_SINK_V */

