//========================================================================
// Test Cases for addiu instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_addiu_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "mfc0 r2, mngr2proc   " ); init_src(  32'h00000005 );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "addiu r3, r2, 0x0004 " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "nop                  " );
  inst( "mtc0 r3, proc2mngr   " ); init_sink( 32'h00000009 );

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

task init_addiu_bypass;
begin
  clear_mem;

  address( c_reset_vector );

  test_rimm_dest_byp( 0, "addiu", 13, 11, 24 );
  test_rimm_dest_byp( 1, "addiu", 13, 10, 23 );
  test_rimm_dest_byp( 2, "addiu", 13,  9, 22 );

  test_rimm_src0_byp( 0, "addiu", 13, 11, 24 );
  test_rimm_src0_byp( 1, "addiu", 13, 10, 23 );
  test_rimm_src0_byp( 2, "addiu", 13,  9, 22 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_addiu_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------

  test_rimm_op( "addiu", 32'h00000000, 16'h0000, 32'h00000000 );
  test_rimm_op( "addiu", 32'h00000001, 16'h0001, 32'h00000002 );
  test_rimm_op( "addiu", 32'h00000003, 16'h0007, 32'h0000000a );

  test_rimm_op( "addiu", 32'h00000000, 16'h8000, 32'hffff8000 );
  test_rimm_op( "addiu", 32'h80000000, 16'h0000, 32'h80000000 );
  test_rimm_op( "addiu", 32'h80000000, 16'h8000, 32'h7fff8000 );

  test_rimm_op( "addiu", 32'h00000000, 16'h7fff, 32'h00007fff );
  test_rimm_op( "addiu", 32'h7fffffff, 16'h0000, 32'h7fffffff );
  test_rimm_op( "addiu", 32'h7fffffff, 16'h7fff, 32'h80007ffe );

  test_rimm_op( "addiu", 32'h80000000, 16'h7fff, 32'h80007fff );
  test_rimm_op( "addiu", 32'h7fffffff, 16'h8000, 32'h7fff7fff );

  test_rimm_op( "addiu", 32'h00000000, 16'hffff, 32'hffffffff );
  test_rimm_op( "addiu", 32'hffffffff, 16'h0001, 32'h00000000 );
  test_rimm_op( "addiu", 32'hffffffff, 16'hffff, 32'hfffffffe );

  //----------------------------------------------------------------------
  // Source/Destination tests
  //----------------------------------------------------------------------

  test_rimm_src0_eq_dest( "addiu", 13, 11, 24 );

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------
integer idx;
task init_addiu_long;
begin
  clear_mem;

  address( c_reset_vector );

  // create a long sequence of instructions to test stalls and bubbles
  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rimm_op( "addiu", 32'h00000001, 16'h0001, 32'h00000002 );
    test_rimm_op( "addiu", 32'h00000003, 16'h0007, 32'h0000000a );
  end

  test_insert_nops( 8 );

end
endtask



//------------------------------------------------------------------------
// Test Case: addiu basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "addiu basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addiu_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addiu bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "addiu bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addiu_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addiu value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "addiu value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_addiu_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: addiu stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "addiu stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_addiu_long;
  run_test;
end
`VC_TEST_CASE_END


