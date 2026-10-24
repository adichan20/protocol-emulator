VERILATOR  = verilator
WAVEVIEWER = surfer

RTL_DIR    = rtl
TB_DIR     = tb
SIM_DIR    = sim
BUILD_DIR  = obj_dir
WAVE_DIR   = waves
STATE_DIR  = scripts

%.lint:
	$(VERILATOR) --lint-only \
		$(RTL_DIR)/$*.sv

%.build:
	mkdir -p $(BUILD_DIR)/$*
	mkdir -p $(WAVE_DIR)

	$(VERILATOR) --cc --exe --build \
		--trace \
		--timing \
		$(RTL_DIR)/$*.sv \
		$(TB_DIR)/$*_tb.sv \
		$(SIM_DIR)/verilator_main.cpp \
		--top-module $*_tb \
		--prefix Vdut \
		--Mdir $(BUILD_DIR)/$*

%.sim: %.build
	./$(BUILD_DIR)/$*/Vdut $*

%.wav: %.sim
	@if [ -f "$(STATE_DIR)/$*.surf.ron" ]; then \
		$(WAVEVIEWER) "$(WAVE_DIR)/$*.vcd" \
			--state-file "$(STATE_DIR)/$*.surf.ron"; \
	else \
		$(WAVEVIEWER) "$(WAVE_DIR)/$*.vcd"; \
	fi

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(WAVE_DIR)/*.vcd
	rm -f $(WAVE_DIR)/*.fst

.PHONY: clean