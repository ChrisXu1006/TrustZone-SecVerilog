#=========================================================================
# plab1-imul Subpackage
#=========================================================================

plab1_imul_deps = vc

plab1_imul_srcs = \
  plab1-imul-msgs.v \
  plab1-imul-IntMulFL.v \
  plab1-imul-IntMulFixedLat.v \
  plab1-imul-IntMulVarLat.v \
  plab1-imul-test-harness.v \
  plab1-imul-sim-harness.v \

plab1_imul_test_srcs = \
  plab1-imul-msgs.t.v \
  plab1-imul-IntMulFL.t.v \
  plab1-imul-IntMulFixedLat.t.v \
  plab1-imul-CountZeros.t.v \
  plab1-imul-IntMulVarLat.t.v \

plab1_imul_sim_srcs = \
  plab1-imul-sim-fixed-lat.v \
  plab1-imul-sim-var-lat.v \

plab1_imul_pyv_srcs = \
  plab1-imul-input-gen_small.py.v \
  plab1-imul-input-gen_large.py.v \
  plab1-imul-input-gen_lomask.py.v \
  plab1-imul-input-gen_himask.py.v \
  plab1-imul-input-gen_lohimask.py.v \
  plab1-imul-input-gen_sparse.py.v \

#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# List of implementations and inputs to evaluate

plab1_imul_eval_impls  = fixed-lat var-lat
plab1_imul_eval_inputs = small large lomask himask lohimask sparse

# Template used to create rules for each impl/input pair

define plab1_imul_eval_template

plab1_imul_eval_outs += plab1-imul-sim-$(1)-$(2).out

plab1-imul-sim-$(1)-$(2).out : plab1-imul-sim-$(1)
	./$$< +input=$(2) +stats | tee $$@

endef

# Call template for each impl/input pair

$(foreach impl,$(plab1_imul_eval_impls), \
  $(foreach dataset,$(plab1_imul_eval_inputs), \
    $(eval $(call plab1_imul_eval_template,$(impl),$(dataset)))))

# Grep all evaluation results

eval-plab1-imul : $(plab1_imul_eval_outs)
	@echo ""
	@grep avg_num_cycles_per_imul $^ | column -s ":=" -t
	@echo ""

#-------------------------------------------------------------------------
# Rules to generate harness
#-------------------------------------------------------------------------

plab1-imul-harness :
	$(scripts_dir)/gen-harness --verbose \
    ece4750-lab1-imul \
    $(src_dir) \
    $(src_dir)/plab1-imul/plab1-imul-gen-harness-cfg

.PHONY: plab1-imul-harness

plab1_imul_junk += ece4750-lab1-imul ece4750-lab1-imul.tar.gz

