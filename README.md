# ECEN 2350 Project 2: Calculator
*Last updated: November 8, 2026*

A four-function calculator in SystemVerilog on the [Boolean Board](https://www.realdigital.org/hardware/boolean) (Spartan-7, `xc7s50csga324-1`). Input from a 3x4 keypad, a 1x4 keypad, or the switches; output on 7-segment display 0 and `led[10:0]`.

## Files

| File | Description |
|---|---|
| `INP.sv` | Scans the 3x4 and 1x4 keypads |
| `MEM.sv` | Stores the operands, operator and result |
| `ALU.sv` | Does the math |
| `DIS.sv` | Drives the 7-segment display and LEDs |
| `Top.sv` | Connects all blocks |
| `*_tb.sv` | Testbenches |
| `boolean.xdc` | Pin constraints |
| `Top.bit` | Bitstream for the board |
| `Makefile` | Runs the simulations |

## Simulation

Requires [Icarus Verilog](https://steveicarus.github.io/iverilog/) and [Surfer](https://surfer-project.org) (or GTKWave).

```
make            # all simulations (or: make alu | mem | dis | inp | top)
make clean      # delete build/
surfer build/*.vcd
```

## Wiring

Unplug the board first. Keypads face up, ribbon toward you: hole 1 is the leftmost.

| Keypad | Hole | Signal | Pmod pin | FPGA pin |
|---|---|---|---|---|
| 3x4 | 1-4 | `row[0]`-`row[3]` | A1-A4 | B13, A13, B14, A14 |
| 3x4 | 5-7 | `col[0]`-`col[2]` | A7-A9 | E12, D12, C13 |
| 1x4 | common | 3V3 | B 3V3 | - |
| 1x4 | button 1-4 | `op[0]`-`op[3]` (+ - x /) | B1-B4 | B15, A15, A17, B17 |

Leave all GND pins empty. Only the 1x4 common goes on 3V3.

## Build and load

1. In Vivado, add the five `.sv` files and `boolean.xdc`, set `Top` as top, and click **Generate Bitstream**.
2. Load `Top.bit` (reload after every power-up):
   ```
   openFPGALoader -c ft2232 Top.bit
   ```
   or use Vivado's Hardware Manager > Program Device.

## Use

Press **btn[3]** to reset.

**Keypad:** type `1` `2` `+` `3` `#` to get 15. `#` is equals, `*` clears. Press `*` before each new calculation.

**Switches:** set `sw[3:0]` to the value and `sw[5:4]` to the register, then press **btn[0]**.

| sw[5:4] | Register | sw[3:0] |
|---|---|---|
| 00 | Operand 1 | digit (repeat to add digits) |
| 01 | Operand 2 | digit |
| 10 | Operator | 0 +, 1 -, 2 x, 3 / |
| 11 | Result | X |
