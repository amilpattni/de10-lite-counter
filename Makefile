VERILATOR := verilator

ROOT_DIR := $(CURDIR)
RTL_DIR := $(ROOT_DIR)/rtl
SIM_DIR := $(ROOT_DIR)/sim
BUILD_DIR := $(ROOT_DIR)/build

.DEFAULT_GOAL := test

.PHONY: lint test test-tick test-counter test-decoder test-system

test: lint test-tick test-counter test-decoder test-system

lint:
	$(VERILATOR) --lint-only $(RTL_DIR)/tick_generator.sv
	$(VERILATOR) --lint-only $(RTL_DIR)/counter.sv
	$(VERILATOR) --lint-only $(RTL_DIR)/seven_segment_decoder.sv
	$(VERILATOR) --lint-only --top-module counter_system $(RTL_DIR)/tick_generator.sv $(RTL_DIR)/counter.sv $(RTL_DIR)/seven_segment_decoder.sv $(RTL_DIR)/counter_system.sv
	$(VERILATOR) --lint-only --top-module de10_lite_top $(RTL_DIR)/tick_generator.sv $(RTL_DIR)/counter.sv $(RTL_DIR)/seven_segment_decoder.sv $(RTL_DIR)/counter_system.sv $(RTL_DIR)/de10_lite_top.sv

test-tick:
	mkdir -p $(BUILD_DIR)/tick_generator
	$(VERILATOR) --cc --exe --build --Mdir $(BUILD_DIR)/tick_generator --top-module tick_generator -GCYCLES_PER_TICK=4 $(RTL_DIR)/tick_generator.sv $(SIM_DIR)/tick_generator_tb.cpp
	$(BUILD_DIR)/tick_generator/Vtick_generator

test-counter:
	mkdir -p $(BUILD_DIR)/counter
	$(VERILATOR) --cc --exe --build --Mdir $(BUILD_DIR)/counter --top-module counter -GWIDTH=2 $(RTL_DIR)/counter.sv $(SIM_DIR)/counter_tb.cpp
	$(BUILD_DIR)/counter/Vcounter

test-decoder:
	mkdir -p $(BUILD_DIR)/seven_segment_decoder
	$(VERILATOR) --cc --exe --build --Mdir $(BUILD_DIR)/seven_segment_decoder --top-module seven_segment_decoder $(RTL_DIR)/seven_segment_decoder.sv $(SIM_DIR)/seven_segment_decoder_tb.cpp
	$(BUILD_DIR)/seven_segment_decoder/Vseven_segment_decoder

test-system:
	mkdir -p $(BUILD_DIR)/counter_system
	$(VERILATOR) --cc --exe --build --Mdir $(BUILD_DIR)/counter_system --top-module counter_system -GCYCLES_PER_TICK=4 $(RTL_DIR)/tick_generator.sv $(RTL_DIR)/counter.sv $(RTL_DIR)/seven_segment_decoder.sv $(RTL_DIR)/counter_system.sv $(SIM_DIR)/counter_system_tb.cpp
	$(BUILD_DIR)/counter_system/Vcounter_system