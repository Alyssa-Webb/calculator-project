# Simulate the calculator blocks with Icarus Verilog.
#   make        run all five simulations
#   make alu | make mem | make dis | make inp | make top
#   make clean  delete build files
#
# Waveforms are saved as build/<target>.vcd

IVERILOG = iverilog -g2012
BUILD    = build

.PHONY: all alu mem dis inp top clean

all: alu mem dis inp top

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
	$(IVERILOG) -o $(BUILD)/dis DIS.sv DIS_tb.sv
	cd $(BUILD) && vvp -n dis && if [ -f wave.vcd ]; then mv wave.vcd dis.vcd; fi

inp: $(BUILD)
	@echo "=== Input ==="
	$(IVERILOG) -o $(BUILD)/inp INP.sv INP_tb.sv
	cd $(BUILD) && vvp -n inp && if [ -f wave.vcd ]; then mv wave.vcd inp.vcd; fi

top: $(BUILD)
	@echo "=== Top level ==="
	$(IVERILOG) -o $(BUILD)/top INP.sv MEM.sv ALU.sv DIS.sv Top.sv Top_tb.sv
	cd $(BUILD) && vvp -n top && if [ -f wave.vcd ]; then mv wave.vcd top.vcd; fi

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)