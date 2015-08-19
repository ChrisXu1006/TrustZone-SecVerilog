//========================================================================
// Test Cases for subu instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_subu_basic;
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
  inst( "subu r3, r1, r2    " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000001 );
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

task init_subu_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rr_dest_byp( 0, "subu", 13, 11, 2 );
  test_rr_dest_byp( 1, "subu", 14, 11, 3 );
  test_rr_dest_byp( 2, "subu", 15, 11, 4 );

  test_rr_src01_byp( 0, 0, "subu", 13, 11, 2 );
  test_rr_src01_byp( 0, 1, "subu", 14, 11, 3 );
  test_rr_src01_byp( 0, 2, "subu", 15, 11, 4 );
  test_rr_src01_byp( 1, 0, "subu", 13, 11, 2 );
  test_rr_src01_byp( 1, 1, "subu", 14, 11, 3 );
  test_rr_src01_byp( 2, 0, "subu", 15, 11, 4 );

  test_rr_src10_byp( 0, 0, "subu", 13, 11, 2 );
  test_rr_src10_byp( 0, 1, "subu", 14, 11, 3 );
  test_rr_src10_byp( 0, 2, "subu", 15, 11, 4 );
  test_rr_src10_byp( 1, 0, "subu", 13, 11, 2 );
  test_rr_src10_byp( 1, 1, "subu", 14, 11, 3 );
  test_rr_src10_byp( 2, 0, "subu", 15, 11, 4 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_subu_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rr_op( "subu", 32'h00000000, 32'h00000000, 32'h00000000 );
  test_rr_op( "subu", 32'h00000001, 32'h00000001, 32'h00000000 );
  test_rr_op( "subu", 32'h00000003, 32'h00000007, 32'hfffffffc );

  test_rr_op( "subu", 32'h00000000, 32'hffff8000, 32'h00008000 );
  test_rr_op( "subu", 32'h80000000, 32'h00000000, 32'h80000000 );
  test_rr_op( "subu", 32'h80000000, 32'hffff8000, 32'h80008000 );

  test_rr_op( "subu", 32'h00000000, 32'h00007fff, 32'hffff8001 );
  test_rr_op( "subu", 32'h7fffffff, 32'h00000000, 32'h7fffffff );
  test_rr_op( "subu", 32'h7fffffff, 32'h00007fff, 32'h7fff8000 );

  test_rr_op( "subu", 32'h80000000, 32'h00007fff, 32'h7fff8001 );
  test_rr_op( "subu", 32'h7fffffff, 32'hffff8000, 32'h80007fff );

  test_rr_op( "subu", 32'h00000000, 32'hffffffff, 32'h00000001 );
  test_rr_op( "subu", 32'hffffffff, 32'h00000001, 32'hfffffffe );
  test_rr_op( "subu", 32'hffffffff, 32'hffffffff, 32'h00000000 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rr_src0_eq_dest( "subu", 13, 11, 2 );
  test_rr_src1_eq_dest( "subu", 14, 11, 3 );
  test_rr_src0_eq_src1( "subu", 15, 0 );
  test_rr_srcs_eq_dest( "subu", 16, 0 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_subu_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "subu", 32'h00000001, 32'h00000001, 32'h00000000 );
    test_rr_op( "subu", 32'h00000003, 32'h00000007, 32'hfffffffc );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: subu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "subu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_subu_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: subu bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "subu bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_subu_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: subu value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "subu value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_subu_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: subu stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "subu stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_subu_long;
  run_test;
end
`VC_TEST_CASE_END

