# Simulate the calculator blocks with Icarus Verilog.
#   make        run all three simulations
#   make alu | make mem | make top  
#   make clean  delete build files
#
# Waveforms are saved as build/alu.vcd, build/mem.vcd and build/top.vcd.

IVERILOG = iverilog -g2012
BUILD    = build

.PHONY: all alu mem top clean

all: alu mem top

alu: $(BUILD)
	@echo "=== ALU ==="
	$(IVERILOG) -o $(BUILD)/alu ALU.sv ALU_tb.sv
	cd $(BUILD) && vvp -n alu && if [ -f wave.vcd ]; then mv wave.vcd alu.vcd; fi

mem: $(BUILD)
	@echo "=== Memory ==="
	$(IVERILOG) -o $(BUILD)/mem MEM.sv MEM_tb.sv
	cd $(BUILD) && vvp -n mem && if [ -f wave.vcd ]; then mv wave.vcd mem.vcd; fi

top: $(BUILD)
	@echo "=== Top level ==="
	$(IVERILOG) -o $(BUILD)/top MEM.sv ALU.sv Top.sv Top_tb.sv
	cd $(BUILD) && vvp -n top && if [ -f wave.vcd ]; then mv wave.vcd top.vcd; fi

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)