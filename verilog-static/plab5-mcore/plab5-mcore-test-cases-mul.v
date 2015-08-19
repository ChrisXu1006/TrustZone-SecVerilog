//========================================================================
// Test Cases for mul instruction
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Basic tests
//------------------------------------------------------------------------

task init_mul_basic;
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
  inst( "mul r3, r2, r1     " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "mtc0 r3, proc2mngr " ); init_sink( 32'h00000014 );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );
  inst( "nop                " );

end
endtask

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test vectors here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Bypassing tests
//------------------------------------------------------------------------

task init_mul_bypass;
begin

  clear_mem;

  address( c_reset_vector );

  test_rr_dest_byp( 0, "mul", 13, 11, 143 );
  test_rr_dest_byp( 1, "mul", 14, 11, 154 );
  test_rr_dest_byp( 2, "mul", 15, 11, 165 );
  test_rr_dest_byp( 3, "mul", 16, 11, 176 );
  test_rr_dest_byp( 4, "mul", 17, 11, 187 );

  test_rr_src01_byp( 0, 0, "mul", 13, 11, 143 );
  test_rr_src01_byp( 0, 1, "mul", 14, 11, 154 );
  test_rr_src01_byp( 0, 2, "mul", 15, 11, 165 );
  test_rr_src01_byp( 0, 3, "mul", 16, 11, 176 );
  test_rr_src01_byp( 0, 4, "mul", 17, 11, 187 );

  test_rr_src01_byp( 1, 0, "mul", 13, 11, 143 );
  test_rr_src01_byp( 1, 1, "mul", 14, 11, 154 );
  test_rr_src01_byp( 2, 0, "mul", 15, 11, 165 );

  test_rr_src10_byp( 0, 0, "mul", 13, 11, 143 );
  test_rr_src10_byp( 0, 1, "mul", 14, 11, 154 );
  test_rr_src10_byp( 0, 2, "mul", 15, 11, 165 );
  test_rr_src10_byp( 0, 3, "mul", 16, 11, 176 );
  test_rr_src10_byp( 0, 4, "mul", 17, 11, 187 );

  test_rr_src10_byp( 1, 0, "mul", 13, 11, 143 );
  test_rr_src10_byp( 1, 1, "mul", 14, 11, 154 );
  test_rr_src10_byp( 2, 0, "mul", 15, 11, 165 );

  //--------------------------------------------------------------------
  // Structural hazard tests
  //--------------------------------------------------------------------

  inst( "mfc0 r1, mngr2proc " ); init_src(  32'h0000000c );
  inst( "mfc0 r2, mngr2proc " ); init_src(  32'h0000000f );
  inst( "mfc0 r3, mngr2proc " ); init_src(  32'h0000000a );
  inst( "mul r4, r2, r1     " );
  inst( "mul r5, r3, r1     " );
  inst( "mul r6, r2, r3     " );
  inst( "mul r7, r1, r2     " );
  inst( "mul r8, r3, r2     " );
  inst( "mul r9, r2, r1     " );
  inst( "mtc0 r4, proc2mngr " ); init_sink( 32'h000000b4 );
  inst( "mtc0 r5, proc2mngr " ); init_sink( 32'h00000078 );
  inst( "mtc0 r6, proc2mngr " ); init_sink( 32'h00000096 );
  inst( "mtc0 r7, proc2mngr " ); init_sink( 32'h000000b4 );
  inst( "mtc0 r8, proc2mngr " ); init_sink( 32'h00000096 );
  inst( "mtc0 r9, proc2mngr " ); init_sink( 32'h000000b4 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Value tests
//------------------------------------------------------------------------

task init_mul_value;
begin

  clear_mem;

  address( c_reset_vector );

  //----------------------------------------------------------------------
  // Arithmetic tests
  //----------------------------------------------------------------------
  // Zero and one operands

  test_rr_op( "mul",  0,  0, 0 );
  test_rr_op( "mul",  0,  1, 0 );
  test_rr_op( "mul",  1,  0, 0 );
  test_rr_op( "mul",  1,  1, 1 );
  test_rr_op( "mul",  0, -1, 0 );
  test_rr_op( "mul", -1,  0, 0 );
  test_rr_op( "mul", -1, -1, 1 );

  // Positive operands

  test_rr_op( "mul",    42,   13,       546 );
  test_rr_op( "mul",   716,   89,     63724 );
  test_rr_op( "mul", 20154, 8330, 167882820 );

  // Negative operands

  test_rr_op( "mul",    42,    -13,      -546 );
  test_rr_op( "mul",  -716,     89,    -63724 );
  test_rr_op( "mul", -20154, -8330, 167882820 );

  // Mixed tests

  test_rr_op( "mul", 32'h0deadbee, 32'h10000000, 32'he0000000 );
  test_rr_op( "mul", 32'hdeadbeef, 32'h10000000, 32'hf0000000 );

  //--------------------------------------------------------------------
  // Source/Destination tests
  //--------------------------------------------------------------------

  test_rr_src0_eq_dest( "mul", 13, 11, 143 );
  test_rr_src1_eq_dest( "mul", 14, 11, 154 );
  test_rr_src0_eq_src1( "mul", 15, 225 );
  test_rr_srcs_eq_dest( "mul", 16, 256 );

  test_insert_nops( 8 );

end
endtask

//------------------------------------------------------------------------
// Long test
//------------------------------------------------------------------------

integer idx;
task init_mul_long;
begin

  clear_mem;

  address( c_reset_vector );

  for ( idx = 0; idx < 100; idx = idx + 1 ) begin
    test_rr_op( "mul",    42,   13,       546 );
    test_rr_op( "mul",   716,   89,     63724 );
  end

  test_insert_nops( 8 );

end
endtask

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++

//------------------------------------------------------------------------
// Test Case: mul basic
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "mul basic" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mul_basic;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : begin insert +++++++++++++++++++++++++++++++++++++++++
// // add more test cases here

//+++ gen-harness : end insert +++++++++++++++++++++++++++++++++++++++++++

//+++ gen-harness : begin cut ++++++++++++++++++++++++++++++++++++++++++++
//------------------------------------------------------------------------
// Test Case: mul bypass
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "mul bypass" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mul_bypass;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: mul value
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 3, "mul value" )
begin
  init_rand_delays( 0, 0, 0 );
  init_mul_value;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: mul stalls/bubbles
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 4, "mul stalls/bubbles" )
begin
  init_rand_delays( 4, 4, 4 );
  init_mul_long;
  run_test;
end
`VC_TEST_CASE_END

//+++ gen-harness : end cut ++++++++++++++++++++++++++++++++++++++++++++++
