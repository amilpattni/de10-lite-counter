VERILATOR := verilator

ROOT_DIR := $(CURDIR)
RTL_DIR := $(ROOT_DIR)/rtl
SIM_DIR := $(ROOT_DIR)/sim
BUILD_DIR := $(ROOT_DIR)/build
QUARTUS_DIR := $(ROOT_DIR)/quartus

COMMON_RTL := \
    $(RTL_DIR)/tick_generator.sv \
    $(RTL_DIR)/counter.sv \
    $(RTL_DIR)/seven_segment_decoder.sv

SYSTEM_RTL := $(COMMON_RTL) $(RTL_DIR)/counter_system.sv
BOARD_RTL := $(SYSTEM_RTL) $(RTL_DIR)/de10_lite_top.sv
SMOKE_RTL := $(RTL_DIR)/de10_lite_smoke_test.sv

QSF := $(QUARTUS_DIR)/de10_lite_top.qsf
PIN_FILE := $(QUARTUS_DIR)/output_files/de10_lite_top.pin

.DEFAULT_GOAL := test

.PHONY: test lint check-qsf check-pins \
        test-tick test-counter test-decoder test-system

test: check-qsf lint test-tick test-counter test-decoder test-system

lint:
	$(VERILATOR) --lint-only $(RTL_DIR)/tick_generator.sv
	$(VERILATOR) --lint-only $(RTL_DIR)/counter.sv
	$(VERILATOR) --lint-only $(RTL_DIR)/seven_segment_decoder.sv
	$(VERILATOR) --lint-only --top-module counter_system $(SYSTEM_RTL)
	$(VERILATOR) --lint-only --top-module de10_lite_top $(BOARD_RTL)
	$(VERILATOR) --lint-only --top-module de10_lite_smoke_test $(SMOKE_RTL)

check-qsf:
	@count=$$(grep -c '^set_location_assignment' $(QSF)); \
	if [ "$$count" -ne 69 ]; then \
		echo "FAIL: expected 69 pin-location assignments, found $$count."; \
		exit 1; \
	fi
	@if grep -q '^set_location_assignment.*{' $(QSF); then \
		echo "FAIL: incompatible braces found around bus pin names."; \
		exit 1; \
	fi
	@echo "PASS: Quartus QSF contains 69 compatible pin assignments."

check-pins: check-qsf
	@test -f $(PIN_FILE) || { \
		echo "FAIL: compile the Quartus project before running check-pins."; \
		exit 1; \
	}
	@grep -Eq '^MAX10_CLK1_50[[:space:]]+: P11[[:space:]]+:' $(PIN_FILE) || { echo "FAIL: clock pin is incorrect."; exit 1; }
	@grep -Eq '^SW\[0\][[:space:]]+: C10[[:space:]]+:' $(PIN_FILE) || { echo "FAIL: SW0 pin is incorrect."; exit 1; }
	@grep -Eq '^LEDR\[0\][[:space:]]+: A8[[:space:]]+:' $(PIN_FILE) || { echo "FAIL: LEDR0 pin is incorrect."; exit 1; }
	@grep -Eq '^HEX0\[0\][[:space:]]+: C14[[:space:]]+:' $(PIN_FILE) || { echo "FAIL: HEX0 pin is incorrect."; exit 1; }
	@grep -Eq '^HEX5\[7\][[:space:]]+: L19[[:space:]]+:' $(PIN_FILE) || { echo "FAIL: HEX5 pin is incorrect."; exit 1; }
	@echo "PASS: key fitted DE10-Lite pin assignments are correct."

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
	$(VERILATOR) --cc --exe --build --Mdir $(BUILD_DIR)/counter_system --top-module counter_system -GCYCLES_PER_TICK=4 $(SYSTEM_RTL) $(SIM_DIR)/counter_system_tb.cpp
	$(BUILD_DIR)/counter_system/Vcounter_system
	