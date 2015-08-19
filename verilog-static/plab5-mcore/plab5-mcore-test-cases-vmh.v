//========================================================================
// VMH loader to run self-checking assembly tests
//========================================================================
// this file is to be `included by plab2-proc-test-harness.v


//------------------------------------------------------------------------
// Load vmh
//------------------------------------------------------------------------

integer fh;
reg [1023:0] exe_filename;

task init_vmh;
begin
  clear_mem;
  address( c_reset_vector );
  // we only expect to receive 1
  init_sink( 1 );

  // expect the executable as a command line option

  if ( ! $value$plusargs( "exe=%s", exe_filename ) ) begin
    $display( "\n WARNING: need to provide a vmh file using +exe flag \n" );
    exe_filename = "../apps/tests/build/vmh-cache/cache-parcv1-addu.vmh";
    $display( "using: %s \n", exe_filename );
  end

  // check that file exists
  fh = $fopen( exe_filename, "r" );
  if ( !fh ) begin
    $display( "\n ERROR: Could not open vmh file (%s) \n",
                                                      exe_filename );
    $finish;
  end
  $fclose(fh);

  $readmemh( exe_filename, th.mem.mem.m );

end
endtask


//------------------------------------------------------------------------
// Test Case: vmh no delay
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 1, "vmh no delay" )
begin
  init_rand_delays( 0, 0, 0 );
  init_vmh;
  run_test;
end
`VC_TEST_CASE_END

//------------------------------------------------------------------------
// Test Case: vmh with delay
//------------------------------------------------------------------------

`VC_TEST_CASE_BEGIN( 2, "vmh with delay" )
begin
  init_rand_delays( 4, 4, 4 );
  init_vmh;
  run_test;
end
`VC_TEST_CASE_END



