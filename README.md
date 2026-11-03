# ECEN 2350 Project 2: Calculator
*Last updated: October 14, 2026*

A four-function calculator written in SystemVerilog and implemented on the [Boolean Board](https://www.realdigital.org/hardware/boolean) (Xilinx Spartan-7 FPGA).

## Files

| File | Description |
|---|---|
| `ALU.sv` | Does the math |
| `MEM.sv` | Stores the operands, operator and result |
| `Top.sv` | Connects the memory and ALU |
| `DIS.sv` | Displays to 7-Segment display on the Boolean Board as well as LEDs |
| `INP.sv` | Integrates a 3x4 and 1x4 keypad that is used with the Boolean Board. |
| `*_tb.sv` | Testbenches |
| `Makefile` | Runs the simulations |


## Simulation

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/) and [Surfer](https://surfer-project.org) (or GTKWave).

| Command | What it does |
|---|---|
| `make` | Runs all simulations |
| `make alu` | Runs only the ALU simulation (also `make mem`, `make top`) |
| `make clean` | Deletes the `build` folder |

Waveforms are saved in the `build` folder, one per simulation:

```
surfer build/*.vcd
```
