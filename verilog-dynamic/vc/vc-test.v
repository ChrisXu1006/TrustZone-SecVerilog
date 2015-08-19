//========================================================================
// Macros for unit tests
//========================================================================
// This file contains various macros to help write unit tests for
// small verilog blocks. Here is a simple example of a test harness
// for a two input mux.
//
// `include "vc-test.v"
//
// module tester;
//
//  reg clk = 1;
//  always #5 clk = ~clk;
//
//  `VC_TEST_SUITE_BEGIN( "vc_Muxes" );
//
//  reg  [31:0] mux2_in0;
//  reg  [31:0] mux2_in0;
//  reg         mux2_sel;
//  wire [31:0] mux2_out;
//
//  vc_Mux2#(32) mux2( mux2_in0, mux2_in1, mux2_sel, mux2_out );
//
//  `VC_TEST_CASE_BEGIN( 1, "vc_Mux2" )
//  begin
//
//    mux2_in0 = 32'h0a0a0a0a;
//    mux2_in1 = 32'hb0b0b0b0;
//
//    mux2_sel = 1'd0;
//    #25;
//    `VC_TEST_NET( mux2_out, 32'h0a0a0a0a );
//
//    mux2_sel = 1'd1;
//    #25;
//    `VC_TEST_NET( mux2_out, 32'hb0b0b0b0 );
//
//  end
//  `VC_TEST_CASE_END
//
//  `VC_TEST_SUITE_END
// endmodule
//
// Note that you need a clk even if you are only testing a combinational
// block since the test infrastructure includes a clocked state element.
// Each of the macros are discussed in more detail below.
//
// By default only checks which fail are displayed. The user can specify
// verbose output using the +verbose=2 command line parameter. When
// verbose output is enabled, all checks are displayed regardless of
// whether or not they pass or fail.

`ifndef VC_TEST_V
`define VC_TEST_V

//------------------------------------------------------------------------
// VC_TEST_SUITE_BEGIN( suite-name )
//------------------------------------------------------------------------
// The single parameter should be a quoted string indicating the name of
// the test suite.

`define VC_TEST_SUITE_BEGIN( name_ )                                    \
  reg        clk = 1;                                                   \
  reg        _vc_test_cases_done = 1;                                   \
  reg [3:0]  _vc_test_verbose;                                          \
  reg [31:0] _vc_test_num_failed;                                       \
  reg [9:0]  _vc_test_case_num_only;                                    \
  reg [9:0]  _vc_test_case_num = 0;                                     \
  reg [9:0]  _vc_test_next_case_num = 0;                                \
                                                                        \
  initial begin                                                         \
    if ( !$value$plusargs( "test-case=%d", _vc_test_case_num_only ) ) begin \
      _vc_test_case_num_only = 0;                                       \
    end                                                                 \
    if ( !$value$plusargs( "verbose=%d", _vc_test_verbose ) ) begin     \
      _vc_test_verbose = 0;                                             \
    end                                                                 \
    if ( $test$plusargs( "help" ) ) begin                               \
      $display( "" );                                                   \
      $display( " %s [options]",{name_,"-test"} );                      \
      $display( "" );                                                   \
      $display( "   +help               : this message" );              \
      $display( "   +test-case=<int>    : execute just given test case" ); \
      $display( "   +trace=<int>        : enable line tracing" ); \
      $display( "   +verbose=<int>      : enable more verbose output" ); \
      $display( "                         1 = show failing tests" ); \
      $display( "                         2 = show passing and failing tests" ); \
      $display( "" );                                                   \
      $finish;                                                          \
    end                                                                 \
    $dumpfile({name_,"-test.vcd"});                                     \
    $dumpvars;                                                          \
    $display("");                                                       \
    $display(" Test Suite: %s", name_ );                                \
  end                                                                   \
                                                                        \
  always #5 clk = ~clk;                                                 \
                                                                        \
  always @(*)                                                           \
    if ( _vc_test_case_num == 0 )                                       \
    begin                                                               \
      #20;                                                              \
      if ( _vc_test_case_num_only != 0 )                                \
        _vc_test_next_case_num = _vc_test_case_num_only;                \
      else                                                              \
        _vc_test_next_case_num = _vc_test_case_num + 1;                 \
    end                                                                 \
                                                                        \
  always @( posedge clk )                                               \
    _vc_test_case_num <= _vc_test_next_case_num;

//------------------------------------------------------------------------
// VC_TEST_SUITE_END
//------------------------------------------------------------------------
// You must include this macro at the end of the tester module right
// before endmodule.

`define VC_TEST_SUITE_END                                               \
  reg [3:0] _vc_test_num_cycles_cases_done = 0;                         \
  always @( posedge clk ) begin                                         \
                                                                        \
    if ( _vc_test_num_cycles_cases_done > 3 ) begin                     \
      $display("");                                                     \
      $finish;                                                          \
    end                                                                 \
                                                                        \
    if ( _vc_test_cases_done )                                          \
      _vc_test_num_cycles_cases_done <= _vc_test_num_cycles_cases_done + 1; \
    else                                                                \
      _vc_test_num_cycles_cases_done <= 0;                              \
                                                                        \
  end

//------------------------------------------------------------------------
// VC_TEST_CASE_BEGIN( test-case-num, test-case-name )
//------------------------------------------------------------------------
// This should directly proceed a begin-end block which contains the
// actual test case code. The test-case-num must be an increasing
// number and it must be unique. It is very easy to accidently reuse a
// test case number and this will cause multiple test cases to run
// concurrently jumbling the corresponding output.

`define VC_TEST_CASE_BEGIN( num_, name_ )                               \
  always @(*) begin                                                     \
    if ( _vc_test_case_num == num_ ) begin                              \
      if ( _vc_test_cases_done == 0 ) begin                             \
        $display( "\n FAILED: Test case %s has the same test case number (%x) as another test case!\n", name_, num_ ); \
        $finish;                                                        \
      end                                                               \
      _vc_test_cases_done = 0;                                          \
      _vc_test_num_failed = 0;                                          \
      $display( "  + Test Case %0d: %s", num_, name_ );

//------------------------------------------------------------------------
// VC_TEST_CASE_END
//------------------------------------------------------------------------
// This should directly follow the begin-end block for the test case.

`define VC_TEST_CASE_END                                                \
      if ( (_vc_test_verbose == 0) && (_vc_test_num_failed > 0) ) begin \
        $display( "     [ FAILED ] number of failing tests: %0d",       \
                  _vc_test_num_failed );                                \
      end                                                               \
      _vc_test_cases_done = 1;                                          \
      if ( _vc_test_case_num_only != 0 )                                \
        _vc_test_next_case_num = 1023;                                  \
      else                                                              \
        _vc_test_next_case_num = _vc_test_case_num + 1;                 \
    end                                                                 \
  end

//------------------------------------------------------------------------
// VC_TEST_NOTE( msg )
//------------------------------------------------------------------------
// Output some text only if verbose

`define VC_TEST_NOTE( msg_ )                                            \
  if ( _vc_test_verbose > 1 )                                           \
    $display( "                %s", msg_ );                             \
  if (1)

//------------------------------------------------------------------------
// VC_TEST_NOTE_INPUTS_1( in1_ )
//------------------------------------------------------------------------

`define VC_TEST_NOTE_INPUTS_1( in1_ )                                   \
  if ( _vc_test_verbose > 1 )                                           \
    $display( "                Inputs:%s", "in1_ = ", in1_ );           \
  if (1)

//------------------------------------------------------------------------
// VC_TEST_NOTE_INPUTS_2( in1_, in2_ )
//------------------------------------------------------------------------

`define VC_TEST_NOTE_INPUTS_2( in1_, in2_ )                             \
  if ( _vc_test_verbose > 1 )                                           \
    $display( "                Inputs:%s = %x,%s = %x",                 \
              "in1_", in1_, "in2_", in2_ );                             \
  if (1)

//------------------------------------------------------------------------
// VC_TEST_NOTE_INPUTS_3( in1_, in2_, in3_ )
//------------------------------------------------------------------------

`define VC_TEST_NOTE_INPUTS_3( in1_, in2_, in3_ )                       \
  if ( _vc_test_verbose > 1 )                                           \
    $display( "                Inputs:%s = %x,%s = %x,%s = %x",         \
              "in1_", in1_, "in2_", in2_, "in3_", in3_ );               \
  if (1)

//------------------------------------------------------------------------
// VC_TEST_NOTE_INPUTS_4( in1_, in2_, in3_, in4_ )
//------------------------------------------------------------------------

`define VC_TEST_NOTE_INPUTS_4( in1_, in2_, in3_, in4_ )                 \
  if ( _vc_test_verbose > 1 )                                           \
    $display( "                Inputs:%s = %x,%s = %x,%s = %x,%s = %x", \
              "in1_", in1_, "in2_", in2_, "in3_", in3_, "in4_", in4_ ); \
  if (1)

//------------------------------------------------------------------------
// VC_TEST_NET( tval_, cval_ )
//------------------------------------------------------------------------
// This macro is used to check that tval == cval.

`define VC_TEST_NET( tval_, cval_ )                                     \
  if ( tval_ === 'hz ) begin                                            \
    _vc_test_num_failed = _vc_test_num_failed + 1;                      \
    if ( _vc_test_verbose > 0 ) begin                                   \
      $display( "     [ FAILED ]%s, expected = %x, actual = %x",        \
                "tval_", cval_, tval_ );                                \
    end                                                                 \
  end                                                                   \
  else                                                                  \
  casez ( tval_ )                                                       \
    cval_ :                                                             \
      if ( _vc_test_verbose > 1 )                                       \
         $display( "     [ passed ]%s, expected = %x, actual = %x",     \
                   "tval_", cval_, tval_ );                             \
    default : begin                                                     \
      _vc_test_num_failed = _vc_test_num_failed + 1;                    \
      if ( _vc_test_verbose > 0 ) begin                                 \
        $display( "     [ FAILED ]%s, expected = %x, actual = %x",      \
                  "tval_", cval_, tval_ );                              \
      end                                                               \
    end                                                                 \
  endcase                                                               \
  if (1)

//------------------------------------------------------------------------
// VC_TEST_FAIL( tval_, msg_ )
//------------------------------------------------------------------------
// This macro is used to force a failure and display some message. This is
// useful if we want to fail due to some reason other than equality.

`define VC_TEST_FAIL( tval_, msg_ )                                     \
  _vc_test_num_failed = _vc_test_num_failed + 1;                        \
  if ( _vc_test_verbose > 0 ) begin                                     \
    $display( "     [ FAILED ]%s, actual = %x, %s",                     \
              "tval_", tval_, msg_ );                                   \
  end                                                                   \
  if (1)

//------------------------------------------------------------------------
// VC_TEST_INCREMENT_NUM_FAILED( num_failed_ )
//------------------------------------------------------------------------
// This macro is used to increment the count of failing tests. This is
// useful when we have child modules that are doing the actual test
// verification (e.g., test sinks).

`define VC_TEST_INCREMENT_NUM_FAILED( num_failed_ )                     \
  _vc_test_num_failed = _vc_test_num_failed + num_failed_;              \
  if (1)

`endif /* VC_TEST_V */

