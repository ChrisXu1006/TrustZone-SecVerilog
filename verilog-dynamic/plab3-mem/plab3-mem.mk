#=========================================================================
# plab3-mem Subpackage
#=========================================================================

#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

plab3_mem_deps = \
  vc \

plab3_mem_srcs = \
  plab3-mem-DecodeWben.v \
  plab3-mem-BlockingCacheSimpleDpath.v \
  plab3-mem-BlockingCacheSimpleCtrl.v \
  plab3-mem-BlockingCacheSimple.v \
  plab3-mem-BlockingCacheBaseDpath.v \
  plab3-mem-BlockingCacheBaseCtrl.v \
  plab3-mem-BlockingCacheBase.v \
  plab3-mem-BlockingCacheAltDpath.v \
  plab3-mem-BlockingCacheAltDpath-insecure.v \
  plab3-mem-BlockingCacheAltCtrl.v \
  plab3-mem-BlockingCacheAlt.v \
  plab3-mem-BlockingCacheAlt-insecure.v \
  plab3-mem-BlockingCacheSec.v \
  plab3-mem-BlockingCacheSec-FSM.v \

plab3_mem_test_srcs = \
  plab3-mem-DecodeWben.t.v \
  plab3-mem-BlockingCacheSimple.t.v \
  plab3-mem-BlockingCacheBase.t.v \
  plab3-mem-BlockingCacheAlt.t.v \

plab3_mem_sim_srcs = \
  plab3-mem-sim-simple.v \
  plab3-mem-sim-base.v \
  plab3-mem-sim-alt.v \

plab3_mem_pyv_srcs = \
  plab3-mem-input-gen_random-writeread.py.v \
  plab3-mem-input-gen_random.py.v \
  plab3-mem-input-gen_ustride.py.v \
  plab3-mem-input-gen_stride2.py.v \
  plab3-mem-input-gen_stride4.py.v \
  plab3-mem-input-gen_shared.py.v \
  plab3-mem-input-gen_ustride-shared.py.v \
  plab3-mem-input-gen_loop-2d.py.v \
  plab3-mem-input-gen_loop-3d.py.v \

#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# List of implementations and inputs to evaluate

plab3_mem_eval_impls  = simple base alt
plab3_mem_eval_inputs = random ustride stride2 stride4 \
												shared ustride-shared loop-2d loop-3d

# Template used to create rules for each impl/input pair

define plab3_mem_eval_template

plab3_mem_eval_outs += plab3-mem-sim-$(1)-$(2).out

plab3-mem-sim-$(1)-$(2).out : plab3-mem-sim-$(1)
	./$$< +input=$(2) +stats | tee $$@

endef

# Call template for each impl/input pair

$(foreach impl,$(plab3_mem_eval_impls), \
  $(foreach dataset,$(plab3_mem_eval_inputs), \
    $(eval $(call plab3_mem_eval_template,$(impl),$(dataset)))))

# Grep all evaluation results

eval-plab3-mem : $(plab3_mem_eval_outs)
	@echo ""
	@echo "AMAL:"
	@grep amal $^ | column -s ":=" -t
	@echo ""


#-------------------------------------------------------------------------
# Rules to generate harness
#-------------------------------------------------------------------------

plab3-mem-harness :
	$(scripts_dir)/gen-harness --verbose \
    ece4750-lab3-mem \
    $(src_dir) \
    $(src_dir)/plab3-mem/plab3-mem-gen-harness-cfg
	cd ece4750-lab3-mem/plab3-mem/; \
	for i in `ls plab3-mem-BlockingCache*`;  \
		do echo renaming $$i; \
		cat $$i | \
			sed "s/Simple/Base/g" | \
			sed "s/SIMPLE/BASE/g" > \
			`echo $$i | sed "s/Simple/Base/g"`; \
		done; \
	for i in `ls plab3-mem-BlockingCache*`;  \
		do echo renaming $$i; \
		cat $$i | \
			sed "s/Simple/Alt/g" | \
			sed "s/SIMPLE/ALT/g" > \
			`echo $$i | sed "s/Simple/Alt/g"`; \
		done; \
	cd ../..; \
	tar czvf ece4750-lab3-mem.tar.gz ece4750-lab3-mem \

.PHONY: plab3-mem-harness

plab3_mem_junk += ece4750-lab3-mem ece4750-lab3-mem.tar.gz


#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++

#+++ gen-harness : begin insert ++++++++++++++++++++++++++++++++++++++++++
#
# plab3_mem_deps = \
#   vc \
#
# plab3_mem_srcs = \
#   plab3-mem-BlockingCacheSimpleDpath.v \
#   plab3-mem-BlockingCacheSimpleCtrl.v \
#   plab3-mem-BlockingCacheSimple.v \
#   plab3-mem-BlockingCacheBaseDpath.v \
#   plab3-mem-BlockingCacheBaseCtrl.v \
#   plab3-mem-BlockingCacheBase.v \
#   plab3-mem-BlockingCacheAltDpath.v \
#   plab3-mem-BlockingCacheAltCtrl.v \
#   plab3-mem-BlockingCacheAlt.v \
#
# plab3_mem_test_srcs = \
#   plab3-mem-BlockingCacheSimple.t.v \
#   plab3-mem-BlockingCacheBase.t.v \
#   plab3-mem-BlockingCacheAlt.t.v \
#
# plab3_mem_sim_srcs = \
#   plab3-mem-sim-simple.v \
#   plab3-mem-sim-base.v \
#   plab3-mem-sim-alt.v \
#
# plab3_mem_pyv_srcs = \
#   plab3-mem-input-gen_random-writeread.py.v \
#   plab3-mem-input-gen_random.py.v \
#   plab3-mem-input-gen_ustride.py.v \
#   plab3-mem-input-gen_stride2.py.v \
#   plab3-mem-input-gen_stride4.py.v \
#   plab3-mem-input-gen_shared.py.v \
#   plab3-mem-input-gen_ustride-shared.py.v \
#   plab3-mem-input-gen_loop-2d.py.v \
#   plab3-mem-input-gen_loop-3d.py.v \
#
# #-------------------------------------------------------------------------
# # Evaluation
# #-------------------------------------------------------------------------
#
# # List of implementations and inputs to evaluate
#
# plab3_mem_eval_impls  = simple base alt
# plab3_mem_eval_inputs = random ustride stride2 stride4 \
# 												shared ustride-shared loop-2d loop-3d
#
# # Template used to create rules for each impl/input pair
#
# define plab3_mem_eval_template
#
# plab3_mem_eval_outs += plab3-mem-sim-$(1)-$(2).out
#
# plab3-mem-sim-$(1)-$(2).out : plab3-mem-sim-$(1)
# 	./$$< +input=$(2) +stats | tee $$@
#
# endef
#
# # Call template for each impl/input pair
#
# $(foreach impl,$(plab3_mem_eval_impls), \
#   $(foreach dataset,$(plab3_mem_eval_inputs), \
#     $(eval $(call plab3_mem_eval_template,$(impl),$(dataset)))))
#
# # Grep all evaluation results
#
# eval-plab3-mem : $(plab3_mem_eval_outs)
# 	@echo ""
# 	@echo "AMAL:"
# 	@grep amal $^ | column -s ":=" -t
# 	@echo ""
#
#+++ gen-harness : end insert ++++++++++++++++++++++++++++++++++++++++++++
