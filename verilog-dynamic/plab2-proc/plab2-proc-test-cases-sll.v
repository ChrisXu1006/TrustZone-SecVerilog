//========================================================================
// Test Cases for sll instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_sll_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h80008000 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "sll r3, r2, 0x0003   " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00040000 );

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

task init_sll_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "sll", 32'h00000001,  7, 32'h00000080 );
  test_rimm_dest_byp( 1, "sll", 32'h00000001, 14, 32'h00004000 );
  test_rimm_dest_byp( 2, "sll", 32'h00000001, 31, 32'h80000000 );

  test_rimm_src0_byp( 0, "sll", 32'h00000001,  7, 32'h00000080 );
  test_rimm_src0_byp( 1, "sll", 32'h00000001, 14, 32'h00004000 );
  test_rimm_src0_byp( 2, "sll", 32'h00000001, 31, 32'h80000000 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_sll_value;
begin
  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rimm_op( "sll", 32'h00000001,  0, 32'h00000001 );
  test_rimm_op( "sll", 32'h00000001,  1, 32'h00000002 );
  test_rimm_op( "sll", 32'h00000001,  7, 32'h00000080 );
  test_rimm_op( "sll", 32'h00000001, 14, 32'h00004000 );
  test_rimm_op( "sll", 32'h00000001, 31, 32'h80000000 );

  test_rimm_op( "sll", 32'hffffffff,  0, 32'hffffffff );
  test_rimm_op( "sll", 32'hffffffff,  1, 32'hfffffffe );
  test_rimm_op( "sll", 32'hffffffff,  7, 32'hffffff80 );
  test_rimm_op( "sll", 32'hffffffff, 14, 32'hffffc000 );
  test_rimm_op( "sll", 32'hffffffff, 31, 32'h80000000 );

  test_rimm_op( "sll", 32'h21212121,  0, 32'h21212121 );
  test_rimm_op( "sll", 32'h21212121,  1, 32'h42424242 );
  test_rimm_op( "sll", 32'h21212121,  7, 32'h90909080 );
  test_rimm_op( "sll", 32'h21212121, 14, 32'h48484000 );
  test_rimm_op( "sll", 32'h21212121, 31, 32'h80000000 );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "sll", 32'h00000001, 7, 32'h00000080 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long tests
//------------------------------------------------------------------------

integer idx;
task init_sll_long;
begin
  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "sll", 32'h00000001,  0, 32'h00000001 );
    test_rimm_op( "sll", 32'h00000001,  1, 32'h00000002 );
  end

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Test Case: sll basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "sll basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sll_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sll bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "sll bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sll_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sll value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "sll value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_sll_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: sll stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "sll stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_sll_long;
  run_test;
end
`VC_TEST_CASE_END


