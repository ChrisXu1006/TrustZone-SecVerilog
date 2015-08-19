#=========================================================================
# plab4-net Subpackage
#=========================================================================

plab4_net_deps = \
  vc \

plab4_net_srcs = \
  plab4-net-RouterInputCtrl.v \
  plab4-net-RouterInputTerminalCtrl.v \
  plab4-net-RouterOutputCtrl.v \
  plab4-net-Router.v \
  plab4-net-RingNet.v \

plab4_net_test_srcs = \
  plab4-net-RingNetSimple.t.v \
  plab4-net-RouterInputCtrl.t.v \
  plab4-net-RouterInputTerminalCtrl.t.v \
  plab4-net-RouterOutputCtrl.t.v \
  plab4-net-RouterOutputCtrl-Sep.t.v \
  plab4-net-RouterBase.t.v \
  plab4-net-RingNetBase.t.v \
  plab4-net-RouterAlt.t.v \
  plab4-net-RingNetAlt.t.v \
  plab4-net-RingNetAlt-sep.t.v \

plab4_net_sim_srcs = \
  plab4-net-sim-simple.v \
  plab4-net-sim-base.v \
  plab4-net-sim-alt.v \

plab4_net_pyv_srcs = \
  plab4-net-input-gen_urandom.py.v \
  plab4-net-input-gen_tornado.py.v \

#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

plab4_net_srcs += \
  plab4-net-GreedyRouteCompute.v \
  plab4-net-AdaptiveRouteCompute.v \
  plab4-net-RouterAdaptiveInputTerminalCtrl.v \

plab4_net_test_srcs += \
  plab4-net-GreedyRouteCompute.t.v \
  plab4-net-AdaptiveRouteCompute.t.v \
  plab4-net-RouterAdaptiveInputTerminalCtrl.t.v \

#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++

#-------------------------------------------------------------------------
# Evaluation
#-------------------------------------------------------------------------

# List of implementations and inputs to evaluate

plab4_net_eval_impls  = simple base alt
plab4_net_eval_inputs = urandom \
                        partition2 \
                        partition4 \
                        tornado \
                        neighbor \
                        complement \
                        reverse \
                        rotation \

# Template used to create rules for each impl/input pair

define plab4_net_eval_template

plab4_net_eval_outs += plab4-net-sim-$(1)-$(2).out
plab4_net_eval_$(2)_outs += plab4-net-sim-$(1)-$(2).out

plab4-net-sim-$(1)-$(2).out : plab4-net-sim-$(1)
	./$$< +input=$(2) +stats | tee $$@

endef

define plab4_net_eval_plot_template

plab4_net_eval_plots += plab4-net-$(1)-plot.png

plab4-net-$(1)-plot.png : plab4-net-plot-gen.py $$(plab4_net_eval_$(1)_outs)
	$(PYTHON) $$< -f $$@ $$(plab4_net_eval_$(1)_outs)

endef

# Call template for each impl/input pair

$(foreach impl,$(plab4_net_eval_impls), \
  $(foreach dataset,$(plab4_net_eval_inputs), \
    $(eval $(call plab4_net_eval_template,$(impl),$(dataset)))))

$(foreach dataset,$(plab4_net_eval_inputs), \
	$(eval $(call plab4_net_eval_plot_template,$(dataset))))

plab4_net_junk += $(plab4_net_eval_plots)

# Generate all of the plots

eval-plab4-net : $(plab4_net_eval_plots) $(plab4_net_eval_outs)
	@echo ""
	@echo "Zero load latency:"
	@grep zero_load_lat $(plab4_net_eval_outs) | column -s ":=*" -t
	@echo ""
	@echo "Injection rate that saturates the network:"
	@grep sat_inj_rate $(plab4_net_eval_outs) | column -s ":=*" -t
	@echo ""
	@echo "plots generated: $(plab4_net_eval_plots)"


#+++ gen-harness : begin cut +++++++++++++++++++++++++++++++++++++++++++++

#-------------------------------------------------------------------------
# Rules to generate harness
#-------------------------------------------------------------------------

plab4_net_harness_conv = plab4-net-RouterBase.v \
  plab4-net-RouterBase.t.v \
  plab4-net-RingNetBase.v \

plab4-net-harness :
	$(scripts_dir)/gen-harness --verbose \
    ece4750-lab4-net \
    $(src_dir) \
    $(src_dir)/plab4-net/plab4-net-gen-harness-cfg
	cd ece4750-lab4-net/plab4-net/; \
	for i in $(plab4_net_harness_conv);  \
		do echo renaming $$i; \
		cat $$i | \
			sed "s/Base/Alt/g" | \
			sed "s/BASE/ALT/g" > \
			`echo $$i | sed "s/Base/Alt/g"`; \
		done; \
	cd ../..; \
	tar czvf ece4750-lab4-net.tar.gz ece4750-lab4-net \

lab4-net-harness : plab4-net-harness

.PHONY: plab4-net-harness lab4-net-harness

plab4_net_junk += ece4750-lab4-net ece4750-lab4-net.tar.gz

#+++ gen-harness : end cut +++++++++++++++++++++++++++++++++++++++++++++++
