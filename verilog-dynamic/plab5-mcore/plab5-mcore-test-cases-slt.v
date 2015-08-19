//========================================================================
// Test Cases for slt instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_slt_basic;
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
  inst( "slt r3, r2, r1     " );
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

task init_slt_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rr_dest_byp( 0, "slt", 11, 13, 1 );
  test_rr_dest_byp( 1, "slt", 14, 13, 0 );
  test_rr_dest_byp( 2, "slt", 12, 13, 1 );

  test_rr_src01_byp( 0, 0, "slt", 14, 13, 0 );
  test_rr_src01_byp( 0, 1, "slt", 11, 13, 1 );
  test_rr_src01_byp( 0, 2, "slt", 15, 13, 0 );
  test_rr_src01_byp( 1, 0, "slt", 10, 13, 1 );
  test_rr_src01_byp( 1, 1, "slt", 16, 13, 0 );
  test_rr_src01_byp( 2, 0, "slt",  9, 13, 1 );

  test_rr_src10_byp( 0, 0, "slt", 17, 13, 0 );
  test_rr_src10_byp( 0, 1, "slt",  8, 13, 1 );
  test_rr_src10_byp( 0, 2, "slt", 18, 13, 0 );
  test_rr_src10_byp( 1, 0, "slt",  7, 13, 1 );
  test_rr_src10_byp( 1, 1, "slt", 19, 13, 0 );
  test_rr_src10_byp( 2, 0, "slt",  6, 13, 1 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_slt_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rr_op( "slt", 32'h00000000, 32'h00000000, 0 );
  test_rr_op( "slt", 32'h00000001, 32'h00000001, 0 );
  test_rr_op( "slt", 32'h00000003, 32'h00000007, 1 );
  test_rr_op( "slt", 32'h00000007, 32'h00000003, 0 );

  test_rr_op( "slt", 32'h00000000, 32'hffff8000, 0 );
  test_rr_op( "slt", 32'h80000000, 32'h00000000, 1 );
  test_rr_op( "slt", 32'h80000000, 32'hffff8000, 1 );

  test_rr_op( "slt", 32'h00000000, 32'h00007fff, 1 );
  test_rr_op( "slt", 32'h7fffffff, 32'h00000000, 0 );
  test_rr_op( "slt", 32'h7fffffff, 32'h00007fff, 0 );

  test_rr_op( "slt", 32'h80000000, 32'h00007fff, 1 );
  test_rr_op( "slt", 32'h7fffffff, 32'hffff8000, 0 );

  test_rr_op( "slt", 32'h00000000, 32'hffffffff, 0 );
  test_rr_op( "slt", 32'hffffffff, 32'h00000001, 1 );
  test_rr_op( "slt", 32'hffffffff, 32'hffffffff, 0 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rr_src0_eq_dest( "slt", 14, 13, 0 );
  test_rr_src1_eq_dest( "slt", 11, 13, 1 );
  test_rr_src0_eq_src1( "slt", 15, 0 );
  test_rr_srcs_eq_dest( "slt", 16, 0 );


  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_slt_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "slt", 32'h00000001, 32'h00000001, 0 );
    test_rr_op( "slt", 32'h00000003, 32'h00000007, 1 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: slt basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "slt basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slt_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slt bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "slt bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slt_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slt value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "slt value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_slt_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: slt stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "slt stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_slt_long;
  run_test;
end
`VC_TEST_CASE_END


