//========================================================================
// Test Cases for sra instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sra_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80008000 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sra r3, r2, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'hf0001000 );

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

task init_sra_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "sra", 32'h80000000,  7, 32'hff000000 );
  test_rimm_dest_byp( 1, "sra", 32'h80000000, 14, 32'hfffe0000 );
  test_rimm_dest_byp( 2, "sra", 32'h80000000, 31, 32'hffffffff );

  test_rimm_src0_byp( 0, "sra", 32'h80000000,  7, 32'hff000000 );
  test_rimm_src0_byp( 1, "sra", 32'h80000000, 14, 32'hfffe0000 );
  test_rimm_src0_byp( 2, "sra", 32'h80000000, 31, 32'hffffffff );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_sra_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rimm_op( "sra", 32'h80000000,  0, 32'h80000000 );
  test_rimm_op( "sra", 32'h80000000,  1, 32'hc0000000 );
  test_rimm_op( "sra", 32'h80000000,  7, 32'hff000000 );
  test_rimm_op( "sra", 32'h80000000, 14, 32'hfffe0000 );
  test_rimm_op( "sra", 32'h80000001, 31, 32'hffffffff );

  test_rimm_op( "sra", 32'h7fffffff,  0, 32'h7fffffff );
  test_rimm_op( "sra", 32'h7fffffff,  1, 32'h3fffffff );
  test_rimm_op( "sra", 32'h7fffffff,  7, 32'h00ffffff );
  test_rimm_op( "sra", 32'h7fffffff, 14, 32'h0001ffff );
  test_rimm_op( "sra", 32'h7fffffff, 31, 32'h00000000 );

  test_rimm_op( "sra", 32'h81818181,  0, 32'h81818181 );
  test_rimm_op( "sra", 32'h81818181,  1, 32'hc0c0c0c0 );
  test_rimm_op( "sra", 32'h81818181,  7, 32'hff030303 );
  test_rimm_op( "sra", 32'h81818181, 14, 32'hfffe0606 );
  test_rimm_op( "sra", 32'h81818181, 31, 32'hffffffff );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "sra", 32'h80000000, 7, 32'hff000000 );


  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_sra_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "sra", 32'h80000000,  0, 32'h80000000 );
    test_rimm_op( "sra", 32'h80000000,  1, 32'hc0000000 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: sra basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sra basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sra_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sra bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "sra bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sra_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sra value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "sra value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sra_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sra stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "sra stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sra_long;
  run_test;
end
`VC_TEST_CASE_END


