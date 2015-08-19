#=========================================================================
# Configuration file for generating the lab harness
#=========================================================================

include_full_subpkgs = [
  "vc",
  "pex-regincr",
  "pex-sorter",
  "pex-gcd",
  "pisa",
  "plab1-imul",
  "plab2-proc",
  "plab3-mem",
  "plab4-net",
]

include_partial_subpkgs = [
  "plab5-mcore",
]

include_partial_subpkgs_full_files = [
  "plab5-mcore/plab5-mcore-MemNet.v",
  "plab5-mcore/plab5-mcore-MemNet.t.v",
  "plab5-mcore/plab5-mcore-mem-net-adapters.v",
  "plab5-mcore/plab5-mcore-mem-net-adapters.t.v",
  "plab5-mcore/plab5-mcore-ProNet.t.v"
  "plab5-mcore/plab5-mcore-test-harness.v",
  "plab5-mcore/plab5-mcore-test-cases-addiu.v",
  "plab5-mcore/plab5-mcore-test-cases-addu.v",
  "plab5-mcore/plab5-mcore-test-cases-and.v",
  "plab5-mcore/plab5-mcore-test-cases-beq.v",
  "plab5-mcore/plab5-mcore-test-cases-bne.v",
  "plab5-mcore/plab5-mcore-test-cases-j.v",
  "plab5-mcore/plab5-mcore-test-cases-jal.v",
  "plab5-mcore/plab5-mcore-test-cases-jr.v",
  "plab5-mcore/plab5-mcore-test-cases-lui.v",
  "plab5-mcore/plab5-mcore-test-cases-lw.v",
  "plab5-mcore/plab5-mcore-test-cases-mngr.v",
  "plab5-mcore/plab5-mcore-test-cases-mul.v",
  "plab5-mcore/plab5-mcore-test-cases-or.v",
  "plab5-mcore/plab5-mcore-test-cases-ori.v",
  "plab5-mcore/plab5-mcore-test-cases-sll.v",
  "plab5-mcore/plab5-mcore-test-cases-slt.v",
  "plab5-mcore/plab5-mcore-test-cases-sra.v",
  "plab5-mcore/plab5-mcore-test-cases-subu.v",
  "plab5-mcore/plab5-mcore-test-cases-sw.v",
  "plab5-mcore/plab5-mcore-test-cases-vmh.v",
]

include_partial_subpkgs_strip_files = [
  "plab5-mcore/plab5-mcore-ProcNet.v"
  "plab5-mcore/plab5-mcore.mk",
  # hacky: we use gen harness to cut quicksort to seem like it belongs to
  # this subproject, then in the .mk file, we will explicitly copy it to
  # its proper location
  "plab5-mcore/ubmark-quicksort.c",
  "plab5-mcore/mtbmark-sort.c",
]

