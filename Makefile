# Simulate the calculator blocks with Icarus Verilog.
#   make        run all four simulations
#   make alu | make mem | make display | make top
#   make clean  delete build files
#
# Waveforms are saved as build/alu.vcd, build/mem.vcd, build/display.vcd and build/top.vcd.

IVERILOG = iverilog -g2012
BUILD    = build

.PHONY: all alu mem dis top clean

all: alu mem dis top

alu: $(BUILD)
	@echo "=== ALU ==="
	$(IVERILOG) -o $(BUILD)/alu ALU.sv ALU_tb.sv
	cd $(BUILD) && vvp -n alu && if [ -f wave.vcd ]; then mv wave.vcd alu.vcd; fi

mem: $(BUILD)
	@echo "=== Memory ==="
	$(IVERILOG) -o $(BUILD)/mem MEM.sv MEM_tb.sv
	cd $(BUILD) && vvp -n mem && if [ -f wave.vcd ]; then mv wave.vcd mem.vcd; fi

dis: $(BUILD)
	@echo "=== Display ==="
	$(IVERILOG) -o $(BUILD)/display DIS.sv DIS_tb.sv
	cd $(BUILD) && vvp -n display && if [ -f wave.vcd ]; then mv wave.vcd display.vcd; fi

top: $(BUILD)
	@echo "=== Top level ==="
	$(IVERILOG) -o $(BUILD)/top MEM.sv ALU.sv Display.sv Top.sv Top_tb.sv
	cd $(BUILD) && vvp -n top && if [ -f wave.vcd ]; then mv wave.vcd top.vcd; fi

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)