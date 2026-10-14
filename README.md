# ECEN 2350 Project 2: Calculator
*Last updated: October 14, 2026*

A four-function calculator written in SystemVerilog and implemented on the [Boolean Board](https://www.realdigital.org/hardware/boolean) (Xilinx Spartan-7 FPGA).

## Files

| File | Description |
|---|---|
| `ALU.sv` | Does the math |
| `MEM.sv` | Stores the operands, operator and result |
| `Top.sv` | Connects the memory and ALU |
| `*_tb.sv` | Testbenches |
| `Makefile` | Runs the simulations |

## ALU

Takes two 11-bit signed operands and a 2-bit operator, and outputs an 11-bit signed result.

| Operator | Operation |
|---|---|
| `00` | Operand1 + Operand2 |
| `01` | Operand1 - Operand2 |
| `10` | Operand1 × Operand2 |
| `11` | Operand1 ÷ Operand2 |

## Memory

Stores the two operands, the operator and the result so they persist across key presses and operations. All registers update only on the rising clock edge.

| Port | Direction | Width | Description |
|---|---|---|---|
| `clk` | In | 1 | Clock |
| `rst` | In | 1 | Clears all registers to 0 |
| `data_in` | In | 4 | Keypad digit |
| `result` | In | 11 | Answer from the ALU |
| `load_value` | In | 2 | Selects which register to write |
| `write_enable` | In | 1 | Writes on this clock edge when 1 |
| `Operand1`, `Operand2` | Out | 11 each | To the ALU |
| `Operator` | Out | 2 | To the ALU |
| `Result` | Out | 11 | Stored answer, to the display |

## Simulation

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/) and [Surfer](https://surfer-project.org) (or GTKWave).

| Command | What it does |
|---|---|
| `make` | Runs all three simulations |
| `make alu` | Runs only the ALU simulation (also `make mem`, `make top`) |
| `make clean` | Deletes the `build` folder |

Waveforms are saved in the `build` folder, one per simulation:

```
surfer build/mem.vcd
surfer build/top.vcd
```
