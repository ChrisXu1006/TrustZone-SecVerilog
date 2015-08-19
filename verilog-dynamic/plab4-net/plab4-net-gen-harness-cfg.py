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
  "plab4-net",
]

include_partial_subpkgs_full_files = [
  "plab4-net/plab4-net-RingNetSimple.v",
  "plab4-net/plab4-net-RingNetSimple.t.v",
  "plab4-net/plab4-net-RingNetBase.v",
  "plab4-net/plab4-net-RingNetBase.t.v",
  "plab4-net/plab4-net-RingNetAlt.t.v",
  "plab4-net/plab4-net-RouterBase.t.v",
  "plab4-net/plab4-net-RouterOutputCtrl.t.v",
  "plab4-net/plab4-net-RouterInputTerminalCtrl.t.v",
  "plab4-net/plab4-net-test-harness.v",
  "plab4-net/plab4-net-sim-harness.v",
  "plab4-net/plab4-net-sim-alt.v",
  "plab4-net/plab4-net-sim-base.v",
  "plab4-net/plab4-net-sim-simple.v",
  "plab4-net/plab4-net-plot-gen.py",
  "plab4-net/plab4-net-input-gen.py",
]

include_partial_subpkgs_strip_files = [
  "plab4-net/plab4-net.mk",
  "plab4-net/plab4-net-RouterBase.v",
  "plab4-net/plab4-net-RouterInputCtrl.v",
  "plab4-net/plab4-net-RouterInputCtrl.t.v",
  "plab4-net/plab4-net-RouterOutputCtrl.v",
  "plab4-net/plab4-net-RouterInputTerminalCtrl.v",
]

