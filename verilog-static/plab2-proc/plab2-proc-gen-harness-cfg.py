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
]

include_partial_subpkgs = [
  "plab2-proc",
]

include_partial_subpkgs_full_files = [
  "plab2-proc/plab2-proc-PipelinedProcSimple.t.v",
  "plab2-proc/plab2-proc-PipelinedProcSimple.v",
  "plab2-proc/plab2-proc-PipelinedProcSimpleCtrl.v",
  "plab2-proc/plab2-proc-PipelinedProcSimpleDpath.v",
  "plab2-proc/plab2-proc-test-cases-addiu.v",
  "plab2-proc/plab2-proc-test-cases-addu.v",
  "plab2-proc/plab2-proc-test-cases-and.v",
  "plab2-proc/plab2-proc-test-cases-beq.v",
  "plab2-proc/plab2-proc-test-cases-bne.v",
  "plab2-proc/plab2-proc-test-cases-j.v",
  "plab2-proc/plab2-proc-test-cases-jal.v",
  "plab2-proc/plab2-proc-test-cases-lui.v",
  "plab2-proc/plab2-proc-test-cases-lw.v",
  "plab2-proc/plab2-proc-test-cases-mngr.v",
  "plab2-proc/plab2-proc-test-cases-or.v",
  "plab2-proc/plab2-proc-test-cases-ori.v",
  "plab2-proc/plab2-proc-test-cases-sll.v",
  "plab2-proc/plab2-proc-test-cases-slt.v",
  "plab2-proc/plab2-proc-test-cases-sra.v",
  "plab2-proc/plab2-proc-test-cases-subu.v",
  "plab2-proc/plab2-proc-test-cases-sw.v",
  "plab2-proc/plab2-proc-sim-harness.v",
  "plab2-proc/plab2-proc-sim-stall.v",
  "plab2-proc/plab2-proc-sim-bypass.v",
  "plab2-proc/plab2-proc-ubmark-vvadd.v",
  "plab2-proc/plab2-proc-ubmark-masked-filter.v",
  "plab2-proc/plab2-proc-ubmark-cmplx-mult.v",
  "plab2-proc/plab2-proc-ubmark-bin-search.v",
]

include_partial_subpkgs_strip_files = [
  "plab2-proc/plab2-proc-dpath-components.v",
  "plab2-proc/plab2-proc-dpath-components.t.v",
  "plab2-proc/plab2-proc.mk",
  "plab2-proc/plab2-proc-test-harness.v",
  "plab2-proc/plab2-proc-test-cases-mul.v",
  "plab2-proc/plab2-proc-test-cases-jr.v",
]

