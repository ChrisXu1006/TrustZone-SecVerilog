//========================================================================
// Test Cases for and instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_and_basic;
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
  inst( "and r3, r2, r1     " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000004 );
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

task init_and_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rr_dest_byp( 0, "and", 32'hff00ff00, 32'h0f0f0f0f, 32'h0f000f00 );
  test_rr_dest_byp( 1, "and", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h00f000f0 );
  test_rr_dest_byp( 2, "and", 32'h00ff00ff, 32'h0f0f0f0f, 32'h000f000f );

  test_rr_src01_byp( 0, 0, "and", 32'hff00ff00, 32'h0f0f0f0f, 32'h0f000f00 );
  test_rr_src01_byp( 0, 1, "and", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h00f000f0 );
  test_rr_src01_byp( 0, 2, "and", 32'h00ff00ff, 32'h0f0f0f0f, 32'h000f000f );
  test_rr_src01_byp( 1, 0, "and", 32'hff00ff00, 32'h0f0f0f0f, 32'h0f000f00 );
  test_rr_src01_byp( 1, 1, "and", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h00f000f0 );
  test_rr_src01_byp( 2, 0, "and", 32'h00ff00ff, 32'h0f0f0f0f, 32'h000f000f );

  test_rr_src10_byp( 0, 0, "and", 32'hff00ff00, 32'h0f0f0f0f, 32'h0f000f00 );
  test_rr_src10_byp( 0, 1, "and", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h00f000f0 );
  test_rr_src10_byp( 0, 2, "and", 32'h00ff00ff, 32'h0f0f0f0f, 32'h000f000f );
  test_rr_src10_byp( 1, 0, "and", 32'hff00ff00, 32'h0f0f0f0f, 32'h0f000f00 );
  test_rr_src10_byp( 1, 1, "and", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h00f000f0 );
  test_rr_src10_byp( 2, 0, "and", 32'h00ff00ff, 32'h0f0f0f0f, 32'h000f000f );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_and_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rr_op( "and", 32'hff00ff00, 32'h0f0f0f0f, 32'h0f000f00 );
  test_rr_op( "and", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h00f000f0 );
  test_rr_op( "and", 32'h00ff00ff, 32'h0f0f0f0f, 32'h000f000f );
  test_rr_op( "and", 32'hf00ff00f, 32'hf0f0f0f0, 32'hf000f000 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rr_src0_eq_dest( "and", 32'hff00ff00, 32'h0f0f0f0f, 32'h0f000f00);
  test_rr_src1_eq_dest( "and", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h00f000f0);
  test_rr_src0_eq_src1( "and", 32'hff00ff00, 32'hff00ff00 );
  test_rr_srcs_eq_dest( "and", 32'hff00ff00, 32'hff00ff00 );


  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_and_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "and", 32'hff00ff00, 32'h0f0f0f0f, 32'h0f000f00 );
    test_rr_op( "and", 32'h0ff00ff0, 32'hf0f0f0f0, 32'h00f000f0 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: and basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "and basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_and_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: and bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "and bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_and_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: and value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "and value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_and_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: and stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "and stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_and_long;
  run_test;
end
`VC_TEST_CASE_END

