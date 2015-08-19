#=========================================================================
# Configuration file for generating the lab harness
#=========================================================================

include_full_subpkgs = [
  "vc",
  "pex-regincr",
  "pex-sorter",
  "pex-gcd",
]

include_partial_subpkgs = [
  "plab1-imul",
]

include_partial_subpkgs_full_files = [
  "plab1-imul/plab1-imul-IntMulFL.t.v",
  "plab1-imul/plab1-imul-IntMulFL.v",
  "plab1-imul/plab1-imul-input-gen.py",
  "plab1-imul/plab1-imul-msgs.t.v",
  "plab1-imul/plab1-imul-msgs.v",
  "plab1-imul/plab1-imul-sim-fixed-lat.v",
  "plab1-imul/plab1-imul-sim-harness.v",
  "plab1-imul/plab1-imul-sim-var-lat.v",
  "plab1-imul/plab1-imul-test-harness.v",
  "plab1-imul/plab1-imul.mk"
]

include_partial_subpkgs_strip_files = [
  "plab1-imul/plab1-imul-IntMulFixedLat.t.v",
  "plab1-imul/plab1-imul-IntMulFixedLat.v",
  "plab1-imul/plab1-imul-IntMulVarLat.t.v",
  "plab1-imul/plab1-imul-IntMulVarLat.v",
]

