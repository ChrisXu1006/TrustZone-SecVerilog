//========================================================================
// plab5-mcore-ProcNetCacheMemDebug-Insecure Unit Tests
//========================================================================

`define PLAB5_MCORE_IMPL		plab5_mcore_ProcNetCacheMemDebug_insecure
`define PLAB5_MCORE_IMPL_STR	"plab5-mcore-ProcNetCacheMemDebug-insecure-%INST"
`define PLAB5_MCORE_TEST_CASES_FILE	"plab5-mcore-test-cases-%INST%.v"
`define PLAB5_MCORE_NUM_CORES	2

`include "plab5-mcore-ProcNetCacheMemDebug-insecure.v"
`include "plab5-mcore-test-harness-cachemem.v"
