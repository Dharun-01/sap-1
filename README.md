# SAP-1 (Simple As Possible) Parameterized Computer Architecture

A modular, hardware-accurate implementation of the SAP-1 (Simple As Possible) computer architecture written in structural and behavioral Verilog. This processor scales seamlessly from an 8-bit system up to any custom word size through fully parameterized design files. Every component, from foundational logic gates to complete pipeline subsystems, has been thoroughly verified via automated testbenches and visual logic simulators.

---

## Key Features

- **Customizable Word Size:** Fully parameterized design allowing the entire processor to scale effortlessly beyond the classic 8-bit boundary to store and process wider architectures.
- **Complete Phase Isolation:** Architecture is cleanly divided into decoupled modular pipeline stages: **Fetch Phase**, **Decode Phase**, and **Execution Phase**, each thoroughly tested and simulated.
- **Dual Simulation Verification:** \* High-fidelity RTL simulation using `Icarus Verilog` and waveform analysis using `GTKWave`.
  - Visual, gate-level interactive schematics using the `Digital` logic simulator tool.
- **Hardware-Accurate Primitive Core:** Built entirely from scratch using a custom dedicated foundational hardware library (primitive logic gates, flip-flops, multiplexers, and decoders).

---

## Instruction Set Architecture (ISA)

The processor natively decodes and executes a robust 10-instruction set capable of running full control loops, conditional arithmetic, and I/O tasks:

| Mnemonic | Instruction Type | Description                                                         |
| :------- | :--------------- | :------------------------------------------------------------------ |
| **LDA**  | Memory Reference | Load data from RAM into the Accumulator (Register A).               |
| **LDI**  | Immediate        | Load immediate value directly into the Accumulator.                 |
| **STA**  | Memory Reference | Store the contents of the Accumulator into a specified RAM address. |
| **ADD**  | Arithmetic       | Add the value from RAM to the Accumulator.                          |
| **SUB**  | Arithmetic       | Subtract the value from RAM from the Accumulator.                   |
| **JMP**  | Control Flow     | Unconditional jump to a targeted instruction address.               |
| **JC**   | Control Flow     | Conditional jump to address if the **Carry Flag** is set.           |
| **JZ**   | Control Flow     | Conditional jump to address if the **Zero Flag** is set.            |
| **OUT**  | Output           | Output the contents of the Accumulator to the display unit.         |
| **HLT**  | Control Flow     | Halt the clock execution system.                                    |

---

## Project Structure

```text
├── assets/                  # Contains .dig files of SAP-1 to run in the "Digital" simulator
├── sim/                     # Contains compiled binaries and VCD waveform output dumps for all modules
└── rtl/                     # Register-Transfer Level (RTL) source code
    ├── lib/                 # Foundational primitive hardware library utilities
    │   ├── gates/           # Basic logic gates (and, nand, nor, not, or, xnor, xor)
    │   ├── en_dff/          # Enabled D Flip-Flops
    │   ├── decoder/         # Binary address decoders
    │   ├── full_adder/      # Arithmetic adders
    │   ├── memory_row/      # RAM cell row slices
    │   ├── mux/             # Multiplexers
    │   └── tristate_buff_n/ # Tristate bus isolation buffers
    ├── submodules/          # Architectural structural functional blocks
    │   ├── alu/             # Arithmetic Logic Unit
    │   ├── control_unit/    # Microcode control matrix
    │   ├── display_unit/    # I/O peripheral visualization port
    │   ├── instruction_reg/ # Instruction Register (IR)
    │   ├── pc/              # Program Counter (PC)
    │   ├── ram/             # Customizable main memory unit
    │   ├── ram_address_sel/ # Memory Address Multiplexer (MAR selection logic)
    │   └── step_counter/    # T-state execution step tracking generator
    ├── subsystems_tests/    # Integrated pipeline validation (Fetch, Decode, Execution stages)
    └── top/                 # Top-level system wrapper and verification environment
        ├── sap_1.v          # Ultimate top module tying all submodules together
        └── sap_1_tb.v       # Top testbench executing an assembly countdown program
```

---

# General Commands to Run the Hardware Module

To compile the hardware module:

iverilog -o sim/folderName/fileName_sim rtl/folderName(s)/fileName.v rtl/folderName(s)/fileName_tb.v

To run the compiled code:

vvp sim/folderName/fileName_sim

To view the waveform of the simulation:

gtkwave sim/folderName/fileName.vcd

---

# To Run the sap-1 Module

1. iverilog -o sim/top/sap_1_sim -s sap_1_tb rtl/lib/\*/\*/\*.v rtl/lib/\*/\*.v rtl/submodules/\*/\*.v rtl/top/sap_1.v rtl/top/sap_1_tb.v

2. vvp sim/top/sap_1_sim

3. gtkwave sim/top/sap_1.vcd

---
