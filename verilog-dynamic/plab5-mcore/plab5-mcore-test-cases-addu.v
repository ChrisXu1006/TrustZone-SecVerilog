//========================================================================
// Test Cases for addu instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_addu_basic;
begin
  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h00000005 );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h00000004 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "addu r3, r2, r1    " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000009 );
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

task init_addu_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rr_dest_byp( 0, "addu", 13, 11, 24 );
  test_rr_dest_byp( 1, "addu", 14, 11, 25 );
  test_rr_dest_byp( 2, "addu", 15, 11, 26 );

  test_rr_src01_byp( 0, 0, "addu", 13, 11, 24 );
  test_rr_src01_byp( 0, 1, "addu", 14, 11, 25 );
  test_rr_src01_byp( 0, 2, "addu", 15, 11, 26 );
  test_rr_src01_byp( 1, 0, "addu", 13, 11, 24 );
  test_rr_src01_byp( 1, 1, "addu", 14, 11, 25 );
  test_rr_src01_byp( 2, 0, "addu", 15, 11, 26 );

  test_rr_src10_byp( 0, 0, "addu", 13, 11, 24 );
  test_rr_src10_byp( 0, 1, "addu", 14, 11, 25 );
  test_rr_src10_byp( 0, 2, "addu", 15, 11, 26 );
  test_rr_src10_byp( 1, 0, "addu", 13, 11, 24 );
  test_rr_src10_byp( 1, 1, "addu", 14, 11, 25 );
  test_rr_src10_byp( 2, 0, "addu", 15, 11, 26 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_addu_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rr_op( "addu", 32'h00000000, 32'h00000000, 32'h00000000 );
  test_rr_op( "addu", 32'h00000001, 32'h00000001, 32'h00000002 );
  test_rr_op( "addu", 32'h00000003, 32'h00000007, 32'h0000000a );

  test_rr_op( "addu", 32'h00000000, 32'hffff8000, 32'hffff8000 );
  test_rr_op( "addu", 32'h80000000, 32'h00000000, 32'h80000000 );
  test_rr_op( "addu", 32'h80000000, 32'hffff8000, 32'h7fff8000 );

  test_rr_op( "addu", 32'h00000000, 32'h00007fff, 32'h00007fff );
  test_rr_op( "addu", 32'h7fffffff, 32'h00000000, 32'h7fffffff );
  test_rr_op( "addu", 32'h7fffffff, 32'h00007fff, 32'h80007ffe );

  test_rr_op( "addu", 32'h80000000, 32'h00007fff, 32'h80007fff );
  test_rr_op( "addu", 32'h7fffffff, 32'hffff8000, 32'h7fff7fff );

  test_rr_op( "addu", 32'h00000000, 32'hffffffff, 32'hffffffff );
  test_rr_op( "addu", 32'hffffffff, 32'h00000001, 32'h00000000 );
  test_rr_op( "addu", 32'hffffffff, 32'hffffffff, 32'hfffffffe );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rr_src0_eq_dest( "addu", 13, 11, 24 );
  test_rr_src1_eq_dest( "addu", 14, 11, 25 );
  test_rr_src0_eq_src1( "addu", 15, 30 );
  test_rr_srcs_eq_dest( "addu", 16, 32 );


  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long tests
//------------------------------------------------------------------------

integer idx;
task init_addu_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "addu", 32'h00000001, 32'h00000001, 32'h00000002 );
    test_rr_op( "addu", 32'h00000003, 32'h00000007, 32'h0000000a );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: addu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "addu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addu_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addu bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "addu bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addu_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addu value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "addu value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addu_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addu stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "addu stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_addu_long;
  run_test;
end
`VC_TEST_CASE_END



