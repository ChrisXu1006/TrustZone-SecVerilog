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
]

include_partial_subpkgs = [
  "plab3-mem",
]

include_partial_subpkgs_full_files = [
  "plab3-mem/plab3-mem-BlockingCacheSimple.v",
  "plab3-mem/plab3-mem-BlockingCacheSimple.t.v",
  "plab3-mem/plab3-mem-BlockingCacheSimpleCtrl.v",
  "plab3-mem/plab3-mem-BlockingCacheSimpleDpath.v",
  "plab3-mem/plab3-mem-input-gen.py",
  "plab3-mem/plab3-mem-sim-harness.v",
  "plab3-mem/plab3-mem-test-harness.v",
  "plab3-mem/plab3-mem-sim-simple.v",
  "plab3-mem/plab3-mem-sim-base.v",
  "plab3-mem/plab3-mem-sim-alt.v",

]

include_partial_subpkgs_strip_files = [
  "plab3-mem/plab3-mem.mk",
]

