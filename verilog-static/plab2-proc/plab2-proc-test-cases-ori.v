//========================================================================
// Test Cases for ori instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_ori_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000021 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "ori r3, r2, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000023 );

  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_ori_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "ori", 32'h0ff00ff0, 16'hf0f0, 32'h0ff0fff0 );
  test_rimm_dest_byp( 1, "ori", 32'h00ff00ff, 16'h0f0f, 32'h00ff0fff );
  test_rimm_dest_byp( 2, "ori", 32'hf00ff00f, 16'hf0f0, 32'hf00ff0ff );

  test_rimm_src0_byp( 0, "ori", 32'h0ff00ff0, 16'hf0f0, 32'h0ff0fff0 );
  test_rimm_src0_byp( 1, "ori", 32'h00ff00ff, 16'h0f0f, 32'h00ff0fff );
  test_rimm_src0_byp( 2, "ori", 32'hf00ff00f, 16'hf0f0, 32'hf00ff0ff );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_ori_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rimm_op( "ori", 32'hff00ff00, 16'h0f0f, 32'hff00ff0f );
  test_rimm_op( "ori", 32'h0ff00ff0, 16'hf0f0, 32'h0ff0fff0 );
  test_rimm_op( "ori", 32'h00ff00ff, 16'h0f0f, 32'h00ff0fff );
  test_rimm_op( "ori", 32'hf00ff00f, 16'hf0f0, 32'hf00ff0ff );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "ori", 32'hff00ff00, 16'hf0f0, 32'hff00fff0 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_ori_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "ori", 32'hff00ff00, 16'h0f0f, 32'hff00ff0f );
    test_rimm_op( "ori", 32'h0ff00ff0, 16'hf0f0, 32'h0ff0fff0 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: ori basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "ori basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_ori_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: ori bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "ori bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_ori_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: ori value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "ori value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_ori_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: ori stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "ori stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_ori_long;
  run_test;
end
`VC_TEST_CASE_END

