#=========================================================================
# Local Autoconf Macros
#=========================================================================
# This file contains the macros for the Modular Verilog/ASCI Build System
# and additional autoconf macros which developers can use in their
# configure.ac scripts.The documenation for each macro should include
# information about the author, date, and copyright.

#-------------------------------------------------------------------------
# MVABS_PROG_VERILOG
#-------------------------------------------------------------------------
# Setup Verilog simulation tools.

AC_DEFUN([MVABS_PROG_VERILOG_COMPILER],
[

  # First check for iverilog. We need iverilog even when we use vcs,
  # since we use iverilog as the verilog preprocessor.

  AC_CHECK_PROGS([iverilog],[iverilog],[no])
  AS_IF([test "${iverilog}" = "no"],
  [
    AC_MSG_ERROR([Modular Verilog/ASIC Build System requires iverilog])
  ])

  vpp="iverilog"
  vpp_flags="-E -s top -g2005 -Wall \
    -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array"

  # Add command line parameter to enable using vcs

  # AC_ARG_WITH(vcs,
  #   AS_HELP_STRING([--with-vcs],[Use Synopsys VCS for Verilog simulation]),
  #   [with_vcs="yes"],
  #   [with_vcs="no"])

  # If we are using vcs then check to make sure it is available,
  # otherwise use iverilog

  # AS_IF([test ${with_vcs} = "yes"],
  # [
  #   AC_CHECK_PROGS([vcs],[vcs],[no])
  #   AS_IF([test "${vcs}" = "no"],
  #   [
  #     AC_MSG_ERROR([User chose Synopsys VCS but it is not available!])
  #   ])
  #
  #   vcomp="vcs"
  #   vcomp_flags="-full64 -top top -sverilog +lint=all,noVCDE \
# +warn=noACC_CLI_ON -q \
# -notice -PP -line -timescale=1ns/10ps"
  #
  # ],[

     vcomp="iverilog"
     vcomp_flags="-s top -g2005 -Wall \
 -Wno-sensitivity-entire-vector -Wno-sensitivity-entire-array"

  # ])

  AC_CHECK_PROGS([python],[python],[no])
  AS_IF([test "$python" = "no"],
  [
    AC_MSG_ERROR([Modular Verilog/ASIC Build System requires python])
  ])

  # Substitute variables into Makefile

  AC_SUBST([vpp])
  AC_SUBST([vpp_flags])
  AC_SUBST([vcomp])
  AC_SUBST([vcomp_flags])
  AC_SUBST([python])

])
