#=========================================================================
# Configuration file for generating the tutorial's harness
#=========================================================================

include_full_subpkgs = [
  "vc",
  "pex-gcd",
]

include_partial_subpkgs = [
  "pex-sorter",
]

include_partial_subpkgs_full_files = [
  "pex-sorter/pex-sorter-SorterFlat.v",
  "pex-sorter/pex-sorter-SorterStruct.v",
  "pex-sorter/pex-sorter-input-gen.py",
  "pex-sorter/pex-sorter-test-harness.v",
  "pex-sorter/pex-sorter-sim-harness.v",
  "pex-sorter/pex-sorter-sim-flat.v",
  "pex-sorter/pex-sorter-sim-struct.v",
]

include_partial_subpkgs_strip_files = [
  "pex-sorter/pex-sorter.mk",
  "pex-sorter/pex-sorter-MinMaxUnit.v",
  "pex-sorter/pex-sorter-SorterFlat.t.v",
  "pex-sorter/pex-sorter-SorterStruct.t.v",
]

