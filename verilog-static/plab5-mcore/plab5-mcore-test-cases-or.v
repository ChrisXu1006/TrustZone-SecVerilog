//========================================================================
// Test Cases for or instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_or_basic;
begin
  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000005 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000014 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "or r3, r2, r1      " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000015 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_or_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rr_dest_byp( 0, "or", 32'hff00ff00, 32'h0f0f0f0f, 32'hff0fff0f );
  test_rr_dest_byp( 1, "or", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hfff0fff0 );
  test_rr_dest_byp( 2, "or", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0fff0fff );

  test_rr_src01_byp( 0, 0, "or", 32'hff00ff00, 32'h0f0f0f0f, 32'hff0fff0f );
  test_rr_src01_byp( 0, 1, "or", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hfff0fff0 );
  test_rr_src01_byp( 0, 2, "or", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0fff0fff );
  test_rr_src01_byp( 1, 0, "or", 32'hff00ff00, 32'h0f0f0f0f, 32'hff0fff0f );
  test_rr_src01_byp( 1, 1, "or", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hfff0fff0 );
  test_rr_src01_byp( 2, 0, "or", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0fff0fff );

  test_rr_src10_byp( 0, 0, "or", 32'hff00ff00, 32'h0f0f0f0f, 32'hff0fff0f );
  test_rr_src10_byp( 0, 1, "or", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hfff0fff0 );
  test_rr_src10_byp( 0, 2, "or", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0fff0fff );
  test_rr_src10_byp( 1, 0, "or", 32'hff00ff00, 32'h0f0f0f0f, 32'hff0fff0f );
  test_rr_src10_byp( 1, 1, "or", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hfff0fff0 );
  test_rr_src10_byp( 2, 0, "or", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0fff0fff );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_or_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rr_op( "or", 32'hff00ff00, 32'h0f0f0f0f, 32'hff0fff0f );
  test_rr_op( "or", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hfff0fff0 );
  test_rr_op( "or", 32'h00ff00ff, 32'h0f0f0f0f, 32'h0fff0fff );
  test_rr_op( "or", 32'hf00ff00f, 32'hf0f0f0f0, 32'hf0fff0ff );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rr_src0_eq_dest( "or", 32'hff00ff00, 32'h0f0f0f0f, 32'hff0fff0f);
  test_rr_src1_eq_dest( "or", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hfff0fff0);
  test_rr_src0_eq_src1( "or", 32'hff00ff00, 32'hff00ff00 );
  test_rr_srcs_eq_dest( "or", 32'hff00ff00, 32'hff00ff00 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_or_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "or", 32'hff00ff00, 32'h0f0f0f0f, 32'hff0fff0f );
    test_rr_op( "or", 32'h0ff00ff0, 32'hf0f0f0f0, 32'hfff0fff0 );
  end

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Test Case: or basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "or basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_or_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: or bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "or bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_or_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: or value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "or value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_or_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: or stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "or stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_or_long;
  run_test;
end
`VC_TEST_CASE_END

