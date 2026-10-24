# RV32I-CPU
32-bit RISC-V CPU using Verilog HDL

# RV32I RISC-V Processor Using Verilog HDL

## 1. Project Overview

This project focuses on the design and RTL simulation of a 32-bit RISC-V processor based on the RV32I instruction set architecture using Verilog HDL.

The processor is developed using Intel Quartus Prime Lite and verified through RTL simulation using Questa/ModelSim.

## 2. Project Objectives

- Understand the internal architecture of a RISC-V processor.
- Design processor modules using Verilog HDL.
- Implement arithmetic and logical operations.
- Understand instruction execution and the Program Counter (PC).
- Verify processor functionality through simulation.

## 3. Processor Architecture

The processor design consists of the following modules:

- Program Counter (PC)
- Instruction Memory
- Instruction Decoder / Immediate Generator
- Register File
- Arithmetic Logic Unit (ALU)
- Data Memory
- Control Logic

## 4. Verilog Modules

| Module | Description |
|---|---|
| alu.v | Performs arithmetic and logical operations |
| register_file.v | Stores processor registers |
| instruction_memory.v | Stores program instructions |
| data_memory.v | Handles data storage and access |
| immediate_generator.v | Generates immediate values |
| rv32i_cpu.v | Main processor module |
| rv32i_cpu_tb.v | Processor testbench |

## 5. Tools and Technologies

- Verilog HDL
- Intel Quartus Prime Lite
- Questa / ModelSim
- RTL Simulation

## 6. Simulation and Verification

The processor is tested using a Verilog testbench.

Simulation observations include:

- Clock signal operation
- Program Counter updates
- Instruction execution
- Register operations
- ALU operations
- Memory operations

Simulation waveforms are provided in the repository when available.

## 7. Project Structure

```text
RV32I-CPU/
│
├── alu.v
├── data_memory.v
├── immediate_generator.v
├── instruction_memory.v
├── register_file.v
├── rv32i_cpu.v
├── rv32i_cpu_tb.v
│
├── README.md
└── simulation/
```

## 8. Future Improvements

- Support additional RV32I instructions.
- Improve processor control logic.
- Optimize ALU operations.
- Explore pipelined processor architecture.
- Study FPGA implementation.

## 9. Author

Nithish Kumar P
