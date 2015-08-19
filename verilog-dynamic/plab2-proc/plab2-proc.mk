#=========================================================================
# plab2-proc Subpackage
#=========================================================================

#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

plab2_proc_deps = \
  vc \
  pisa \
  plab1-imul \

plab2_proc_srcs = \
	plab2-proc-dpath-components.v \
  plab2-proc-PipelinedProcSimpleDpath.v \
  plab2-proc-PipelinedProcSimpleCtrl.v \
  plab2-proc-PipelinedProcSimple.v \
  plab2-proc-PipelinedProcStallDpath.v \
  plab2-proc-PipelinedProcStallCtrl.v \
  plab2-proc-PipelinedProcStall.v \

plab2_proc_gen_simple_test_srcs = \
  plab2-proc-PipelinedProcSimple-mngr.t.v \
  plab2-proc-PipelinedProcSimple-addu.t.v \
  plab2-proc-PipelinedProcSimple-lw.t.v \
  plab2-proc-PipelinedProcSimple-bne.t.v \

plab2_proc_gen_stall_test_srcs = \
  plab2-proc-PipelinedProcStall-mngr.t.v \
  plab2-proc-PipelinedProcStall-addu.t.v \
  plab2-proc-PipelinedProcStall-lw.t.v \
  plab2-proc-PipelinedProcStall-bne.t.v \
  plab2-proc-PipelinedProcStall-beq.t.v \
  plab2-proc-PipelinedProcStall-addiu.t.v \
  plab2-proc-PipelinedProcStall-ori.t.v \
  plab2-proc-PipelinedProcStall-sra.t.v \
  plab2-proc-PipelinedProcStall-sll.t.v \
  plab2-proc-PipelinedProcStall-lui.t.v \
  plab2-proc-PipelinedProcStall-subu.t.v \
  plab2-proc-PipelinedProcStall-slt.t.v \
  plab2-proc-PipelinedProcStall-and.t.v \
  plab2-proc-PipelinedProcStall-or.t.v \
  plab2-proc-PipelinedProcStall-mul.t.v \
  plab2-proc-PipelinedProcStall-sw.t.v \
  plab2-proc-PipelinedProcStall-j.t.v \
  plab2-proc-PipelinedProcStall-jal.t.v \
  plab2-proc-PipelinedProcStall-jr.t.v \
  plab2-proc-PipelinedProcStall-vmh.t.v \

plab2_proc_gen_bypass_test_srcs = \
  plab2-proc-PipelinedProcBypass-mngr.t.v \
  plab2-proc-PipelinedProcBypass-addu.t.v \
  plab2-proc-PipelinedProcBypass-lw.t.v \
  plab2-proc-PipelinedProcBypass-bne.t.v \
  plab2-proc-PipelinedProcBypass-beq.t.v \
  plab2-proc-PipelinedProcBypass-addiu.t.v \
  plab2-proc-PipelinedProcBypass-ori.t.v \
  plab2-proc-PipelinedProcBypass-sra.t.v \
  plab2-proc-PipelinedProcBypass-sll.t.v \
  plab2-proc-PipelinedProcBypass-lui.t.v \
  plab2-proc-PipelinedProcBypass-subu.t.v \
  plab2-proc-PipelinedProcBypass-slt.t.v \
  plab2-proc-PipelinedProcBypass-and.t.v \
  plab2-proc-PipelinedProcBypass-or.t.v \
  plab2-proc-PipelinedProcBypass-mul.t.v \
  plab2-proc-PipelinedProcBypass-sw.t.v \
  plab2-proc-PipelinedProcBypass-j.t.v \
  plab2-proc-PipelinedProcBypass-jal.t.v \
  plab2-proc-PipelinedProcBypass-jr.t.v \
  plab2-proc-PipelinedProcBypass-vmh.t.v \

plab2_proc_test_srcs = \
	plab2-proc-dpath-components.t.v \
	$(plab2_proc_gen_simple_test_srcs) \
	$(plab2_proc_gen_stall_test_srcs) \
	$(plab2_proc_gen_bypass_test_srcs) \

plab2_proc_sim_srcs = \
  plab2-proc-sim-stall.v \
  plab2-proc-sim-bypass.v \

#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++

#+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++
#
# plab2_proc_deps = \
#   vc \
#   pisa \
#   plab1-imul \
#
# plab2_proc_srcs = \
#   plab2-proc-dpath-components.v \
#   plab2-proc-PipelinedProcStallDpath.v \
#   plab2-proc-PipelinedProcStallCtrl.v \
#   plab2-proc-PipelinedProcStall.v \
#   plab2-proc-PipelinedProcBypassDpath.v \
#   plab2-proc-PipelinedProcBypassCtrl.v \
#   plab2-proc-PipelinedProcBypass.v \
#
# plab2_proc_gen_stall_test_srcs = \
#   plab2-proc-PipelinedProcStall-mngr.t.v \
#   plab2-proc-PipelinedProcStall-addu.t.v \
#   plab2-proc-PipelinedProcStall-lw.t.v \
#   plab2-proc-PipelinedProcStall-bne.t.v \
#   plab2-proc-PipelinedProcStall-beq.t.v \
#   plab2-proc-PipelinedProcStall-addiu.t.v \
#   plab2-proc-PipelinedProcStall-ori.t.v \
#   plab2-proc-PipelinedProcStall-sra.t.v \
#   plab2-proc-PipelinedProcStall-sll.t.v \
#   plab2-proc-PipelinedProcStall-lui.t.v \
#   plab2-proc-PipelinedProcStall-subu.t.v \
#   plab2-proc-PipelinedProcStall-slt.t.v \
#   plab2-proc-PipelinedProcStall-and.t.v \
#   plab2-proc-PipelinedProcStall-or.t.v \
#   plab2-proc-PipelinedProcStall-mul.t.v \
#   plab2-proc-PipelinedProcStall-sw.t.v \
#   plab2-proc-PipelinedProcStall-j.t.v \
#   plab2-proc-PipelinedProcStall-jal.t.v \
#   plab2-proc-PipelinedProcStall-jr.t.v \
#
# plab2_proc_gen_bypass_test_srcs = \
#   plab2-proc-PipelinedProcBypass-mngr.t.v \
#   plab2-proc-PipelinedProcBypass-addu.t.v \
#   plab2-proc-PipelinedProcBypass-lw.t.v \
#   plab2-proc-PipelinedProcBypass-bne.t.v \
#   plab2-proc-PipelinedProcBypass-beq.t.v \
#   plab2-proc-PipelinedProcBypass-addiu.t.v \
#   plab2-proc-PipelinedProcBypass-ori.t.v \
#   plab2-proc-PipelinedProcBypass-sra.t.v \
#   plab2-proc-PipelinedProcBypass-sll.t.v \
#   plab2-proc-PipelinedProcBypass-lui.t.v \
#   plab2-proc-PipelinedProcBypass-subu.t.v \
#   plab2-proc-PipelinedProcBypass-slt.t.v \
#   plab2-proc-PipelinedProcBypass-and.t.v \
#   plab2-proc-PipelinedProcBypass-or.t.v \
#   plab2-proc-PipelinedProcBypass-mul.t.v \
#   plab2-proc-PipelinedProcBypass-sw.t.v \
#   plab2-proc-PipelinedProcBypass-j.t.v \
#   plab2-proc-PipelinedProcBypass-jal.t.v \
#   plab2-proc-PipelinedProcBypass-jr.t.v \
#
# plab2_proc_test_srcs = \
#   plab2-proc-dpath-components.t.v \
#   $(plab2_proc_gen_stall_test_srcs) \
#   $(plab2_proc_gen_bypass_test_srcs) \
#
# plab2_proc_sim_srcs = \
#   plab2-proc-sim-stall.v \
#   plab2-proc-sim-bypass.v \
#
#+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++

#-------------------------------------------------------------------------
# Rules to generate test harnesses based on instructions
#-------------------------------------------------------------------------

$(plab2_proc_gen_simple_test_srcs) : plab2-proc-PipelinedProcSimple-%.t.v \
	: plab2-proc-PipelinedProcSimple.t.v plab2-proc-test-cases-%.v \
	plab2-proc-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

$(plab2_proc_gen_stall_test_srcs) : plab2-proc-PipelinedProcStall-%.t.v \
	: plab2-proc-PipelinedProcStall.t.v plab2-proc-test-cases-%.v \
	plab2-proc-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

$(plab2_proc_gen_bypass_test_srcs) : plab2-proc-PipelinedProcBypass-%.t.v \
	: plab2-proc-PipelinedProcBypass.t.v plab2-proc-test-cases-%.v \
	plab2-proc-test-harness.v
	cat $< | sed "s/%INST%/$*/g" > $@

#-------------------------------------------------------------------------
# Rules to run assembly tests
#-------------------------------------------------------------------------

# Directory of vmh files

vmh_dir = $(top_dir)/apps/tests/build/vmh

# List of implementations and inputs to test

plab2_proc_check_vmh_impls  = PipelinedProcStall PipelinedProcBypass
plab2_proc_check_vmh_inputs = \
  parcv1-addiu \
  parcv1-addu \
  parcv1-bne \
  parcv1-jal \
  parcv1-jr \
  parcv1-lui \
  parcv1-lw \
  parcv1-ori \
  parcv1-sw \
  parcv2-and \
  parcv2-andi \
  parcv2-beq \
  parcv2-bgez \
  parcv2-bgtz \
  parcv2-blez \
  parcv2-bltz \
  parcv2-j \
  parcv2-jalr \
  parcv2-mul \
  parcv2-nor \
  parcv2-or \
  parcv2-sll \
  parcv2-sllv \
  parcv2-slt \
  parcv2-slti \
  parcv2-sltiu \
  parcv2-sltu \
  parcv2-sra \
  parcv2-srav \
  parcv2-srl \
  parcv2-srlv \
  parcv2-subu \
  parcv2-xor \
  parcv2-xori \

#  parcv2-div \
#  parcv2-divu \
#  parcv2-lb \
#  parcv2-lbu \
#  parcv2-lh \
#  parcv2-lhu \
#  parcv2-rem \
#  parcv2-remu \
#  parcv2-sb \
#  parcv2-sh \

# Template used to create rules for each impl/input pair

define plab2_proc_check_vmh_template

plab2_proc_check_vmh_outs += plab2-proc-$(1)-$(2)-vmh-test.out

plab2-proc-$(1)-$(2)-vmh-test.out : plab2-proc-$(1)-vmh-test
	./$$< +exe=$(vmh_dir)/$(2).vmh +verbose=2 | sed "s/$(1)/$(1)-$(2)/g" > $$@
endef

# Call template for each impl/input pair

$(foreach impl,$(plab2_proc_check_vmh_impls), \
  $(foreach dataset,$(plab2_proc_check_vmh_inputs), \
    $(eval $(call plab2_proc_check_vmh_template,$(impl),$(dataset)))))


# Generate summary and use the script to print the pass/fail

plab2-proc-check-vmh-summary.out : $(plab2_proc_check_vmh_outs)
	cat $^ > $@


plab2_proc_junk += $(plab2_proc_check_vmh_outs) \
	plab2-proc-check-vmh-summary.out


check-vmh-plab2-proc : plab2-proc-check-vmh-summary.out
	$(scripts_dir)/test-summary --verbose $<

.PHONY : check-vmh-plab2-proc

# Grep all evaluation results

# check-vmh-plab2-proc : $(plab2_proc_check_vmh_outs)
# 	@echo ""
# 	@echo "Verify:"
# 	@grep "\[ passed \]\|\[ FAILED \]" $^ | column -s ":=" -t
# 	@echo ""


#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# List of implementations and inputs to evaluate

plab2_proc_eval_impls  = stall bypass
plab2_proc_eval_inputs = \
  vvadd-unopt \
  vvadd-opt \
  cmplx-mult \
  bin-search \
  masked-filter \

# Template used to create rules for each impl/input pair

define plab2_proc_eval_template

plab2_proc_eval_outs += plab2-proc-sim-$(1)-$(2).out

plab2-proc-sim-$(1)-$(2).out : plab2-proc-sim-$(1)
	./$$< +input=$(2) +stats +verify | tee $$@

endef

# Call template for each impl/input pair

$(foreach impl,$(plab2_proc_eval_impls), \
  $(foreach dataset,$(plab2_proc_eval_inputs), \
    $(eval $(call plab2_proc_eval_template,$(impl),$(dataset)))))

plab2_proc_junk += $(plab2_proc_eval_outs)

# Grep all evaluation results

eval-plab2-proc : $(plab2_proc_eval_outs)
	@echo ""
	@echo "Verify:"
	@grep "\[ passed \]\|\[ FAILED \]" $^ | column -s ":=" -t
	@echo ""
	@echo "CPI:"
	@grep avg_num_cycles_per_inst $^ | column -s ":=" -t
	@echo ""


#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

#-------------------------------------------------------------------------
# Rules to generate harness
#-------------------------------------------------------------------------

plab2-proc-harness :
	$(scripts_dir)/gen-harness --verbose \
    ece4750-lab2-proc \
    $(src_dir) \
    $(src_dir)/plab2-proc/plab2-proc-gen-harness-cfg
	cd ece4750-lab2-proc/plab2-proc/; \
	for i in `ls plab2-proc-PipelinedProcSimple*`;  \
		do echo renaming $$i; \
		cat $$i | \
			sed "s/Simple/Stall/g" | \
			sed "s/SIMPLE/STALL/g" > \
			`echo $$i | sed "s/Simple/Stall/g"`; \
		done; \
	for i in `ls plab2-proc-PipelinedProcSimple*`;  \
		do echo renaming $$i; \
		cat $$i | \
			sed "s/Simple/Bypass/g" | \
			sed "s/SIMPLE/BYPASS/g" > \
			`echo $$i | sed "s/Simple/Bypass/g"`; \
		done; \
	rm plab2-proc-PipelinedProcSimple*; \
	cd ../..; \
	tar czvf ece4750-lab2-proc.tar.gz ece4750-lab2-proc \

.PHONY: plab2-proc-harness

plab2_proc_junk += ece4750-lab2-proc ece4750-lab2-proc.tar.gz

#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++
