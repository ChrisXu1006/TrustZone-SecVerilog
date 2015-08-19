#!/usr/bin/perl

use Term::ANSIColor;

my $z3home ="z3";
my $option = "smt2";
my $iverilog = "iverilog";

my $fail_counter = 0;
my $counter = 0;

sub print_ok {
  print colored("verified\n", 'green');
}

sub print_fail {
  print colored("fail\n", 'red');
}

# type check all files with .v extension in current directory
# first generate the z3 files
my @files = ("plab4-net-RouterAlt-Sep.v");
#my @files = ("plab5-mcore-ProcNetCacheMemDebug.v","plab2-proc-PipelinedProcBypass.v","plab2-proc-PipelinedProcBypassCtrl.v","plab2-proc-PipelinedProcBypassDpath.v","plab1-imul-IntMulVarLat.v","plab1-imul-msgs.v","plab1-imul-CountZeros.v","plab3-mem-BlockingL1Cache.v","plab3-mem-BlockingL1CacheCtrl.v","plab3-mem-BlockingL1CacheCtrl.v","plab3-mem-BlockingL1CacheDpath.v","plab3-mem-DecodeWben.v","plab5-mcore-proc-acc.v","plab5-mcore-MemNet-sep.v","plab5-mcore-mem-net-req.v","plab5-mcore-mem-net-resp.v","plab5-mcore-memreqcmsgpack.v","plab5-mcore-memreqcmsgunpack.v","plab5-mcore-memrespcmsgpack.v","plab4-net-RingNetAlt-sep.v","plab4-net-RouterAlt-Sep.v","plab4-net-demux.v","plab4-net-RouterInputCtrl-Arb-Sep.v","plab4-net-RouterAdaptiveInputTerminalCtrl-Sep.v","plab4-net-RouterOutputCtrl-Sep.v","plab4-net-RouterInputCtrl.v","plab4-net-AdaptiveRouteCompute.v","plab3-mem-BlockingCacheSec-FSM1.v","plab3-mem-PrefetchBuffer.v","plab3-mem-PrefetchBufferCtrl.v","plab3-mem-PrefetchBufferDpath.v","plab3-mem-BlockingL2Cache.v","plab3-mem-BlockingL2CacheCtrl.v","plab3-mem-BlockingL2CacheDpath.v","plab5-mcore-DMA-checker.v","plab5-mcore-DMA-controller.v","plab5-mcore-Debug-checker.v","plab5-mcore-Debug-Interface.v","plab5-mcore-proc2mem-trans.v","plab5-mcore-mem-addr-ctrl-FSM.v","plab5-mcore-mem-arbiter.v","plab5-mcore-TestMem_uni.v","vc-DropUnit.v","vc-PipeCtrl.v","vc-arithmetic.v","vc-muxes.v","vc-regs.v","vc-regfiles.v","vc-net-msgsunpack.v","vc-crossbars.v");
foreach my $file (@files) {
  if (-f $file and $file =~ /\.v$/) {
    # run iverilog to generate constraints
    print "Compiling file $file\n";
    `$iverilog -z $file`;
    #system ($iverilog, "-z", $file);
  }
}

my @files = <*>;
foreach my $file (@files) {
  if (-f $file and $file =~ /\.z3$/) {
    my ($prefix) = $file =~ m/(.*)\.z3$/;
    print "Verifying module $prefix ";

    # read the output of Z3
    my $str = `z3 -$option $file`;
    
    # parse the input constraint file to identify assertions
    open(FILE, "$file") or die "Can't read file $file\n";
    my @assertions = ();
    my $assertion;
    my $isassertion = 0;
    $counter = 0;

    while (<FILE>) {
      if (m/^\(push\)/) {
        $assertion = "";
        $isassertion = 1;
      }
      elsif (m/^\(check-sat\)/) {
        push(@assertions, $assertion);
        $isassertion = 0;
      }
      elsif ($isassertion) {
        $assertion = $_;
      }
    }
    
    close (FILE);
    
    # find "unsat" assertions, and output the corrensponding comment in constraint source file
    my $errors = "";
	#print $str;
    for(split /^/, $str) {
      if (/^sat/) {
        $assert = @assertions[$counter];
        $errors .= $assert;
	    $fail_counter ++;
        $counter ++;
      }
      elsif (/^unsat/) {
        $counter ++;
      }
    }
    if ($errors eq "") {
      print_ok();
    }
    else {
      print_fail();
      print $errors;
    }
  }
}

print "Total: $fail_counter assertions failed\n";

