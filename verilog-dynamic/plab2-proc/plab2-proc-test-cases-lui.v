//========================================================================
// Test Cases for lui instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v

//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_lui_basic;
begin

  clear_mem;

  address( c_reset_vector );
  inst( "lui  r1, 0x0001   " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "mtc0 r1, proc2mngr" ); init_sink(  32'h00010000 );

  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );
  inst( "nop               " );

end
endtask

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_lui_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_imm_dest_byp( 0, "lui", 16'hffff, 32'hffff0000 );
  test_imm_dest_byp( 1, "lui", 16'h7fff, 32'h7fff0000 );
  test_imm_dest_byp( 2, "lui", 16'h8000, 32'h80000000 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_lui_value;
begin

  clear_mem;

  address( c_reset_vector );

  test_imm_op( "lui", 16'h0000, 32'h00000000 );
  test_imm_op( "lui", 16'hffff, 32'hffff0000 );
  test_imm_op( "lui", 16'h7fff, 32'h7fff0000 );
  test_imm_op( "lui", 16'h8000, 32'h80000000 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_lui_long;
begin

  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_imm_op( "lui", 16'h0000, 32'h00000000 );
    test_imm_op( "lui", 16'hffff, 32'hffff0000 );
  end

  test_insert_nops( 8 );

end
endtask


//------------------------------------------------------------------------
// Test Case: lui basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(1, "lui basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lui_basic;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lui bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN(2, "lui bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lui_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lui value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "lui value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_lui_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: lui stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "lui stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_lui_long;
  run_test;
end
`VC_TEST_CASE_END



