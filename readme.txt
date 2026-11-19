# RISC-V Pipelined Processor

**CSCE 3301 – Computer Architecture | Fall 2026**  
**Project 1 – Milestone 3 Submission**

---

## 1. Student Information

| Information | Details |
|---|---|
| **Team Member 1** | Ghada Sherif Ismail – 900221630 |
| **Team Member 2** | Radwa Ayman AbuElfotouh – 900242263 |
| **Course** | CSCE 3301 – Computer Architecture |
| **Instructor** | Dr. Cherif Salama |
| **Department** | Computer Science and Engineering |
| **University** | The American University in Cairo (AUC) |
| **Submission Date** | November 18, 2026 |

---

## 2. Project Overview

This project involves the design and Verilog HDL implementation of a **32-bit, five-stage pipelined RISC-V processor**, supporting the complete base RV32I instruction set, the RV32M multiplication and division extension, hardware hazard management, and unified memory arbitration.

### Pipeline Architecture

The processor implements five stages:

| Stage | Name | Function |
|---|---|---|
| IF | Instruction Fetch | Fetches instructions from unified memory |
| ID | Instruction Decode | Decodes instructions and reads registers |
| EX | Execute | Performs ALU operations, multiplication/division, and branch evaluation |
| MEM | Memory Access | Performs load and store operations |
| WB | Write Back | Writes computation and load results to registers |

### Main Features

- **RV32I Instruction Set:** Complete implementation of 42 user-level instructions.
- **Bonus Feature 1 – RV32M Extension:** Full integer multiplication and division support using `MultiplierDivider.v`.
  - `MUL`, `MULH`, `MULHSU`, `MULHU`
  - `DIV`, `DIVU`, `REM`, `REMU`
- **Bonus Feature 2 – Priority-Based Memory Arbiter:** `MemoryArbiter.v` resolves structural hazards in the single-ported unified memory using dynamic stalling.
  - Dynamic CPI ≈ 1.2
  - Baseline static CPI = 2.0
- **Hardware Hazard Management:**
  - Data forwarding using `ForwardingUnit.v`
  - Load-use stall detection using `HazardDetectionUnit.v`
  - Control hazard flushing
- **FPGA Implementation:**
  - Digilent Nexys A7-100T
  - Single-step manual clocking
  - Multiplexed LED debugging interface
  - Seven-segment display debugging interface

---

## 3. Design Assumptions

### 3.1 Single-Ported Memory Constraint

A single physical memory module, `UnifiedMemory.v`, stores both instructions and data.

The memory provides one 32-bit address bus and performs either an instruction fetch or a data read/write during any given clock cycle.

### 3.2 Memory Alignment

All memory accesses are assumed to be naturally aligned:

- Halfword accesses (`LH`, `LHU`, `SH`) use 2-byte alignment.
- Word accesses (`LW`, `SW`) use 4-byte alignment.

### 3.3 Byte-Addressable Word Indexing

The unified memory contains:

- **512 words**, each 32 bits wide.
- **2048 bytes** of total storage.
- `addr[10:2]` selects the memory word.
- `addr[1:0]` selects the byte offset within the word.

### 3.4 Architectural Register x0

Register `x0` is permanently hardwired to zero.

- Writes targeting `x0` are discarded.
- Forwarding from register `x0` is suppressed.

### 3.5 Special Instruction Behavior

| Instruction | Behavior |
|---|---|
| `EBREAK` | Permanently halts processor execution and freezes pipeline updates |
| `ECALL` | Executed as NOP |
| `PAUSE` | Executed as NOP |
| `FENCE` | Executed as NOP |
| `FENCE.TSO` | Executed as NOP |

The `EBREAK` instruction encoding is `0x00100073`.

---

## 4. Working Features

### 4.1 Instruction Execution

The processor supports the complete required RV32I instruction set and the bonus RV32M extension.

| Instruction Category | Supported Instructions |
|---|---|
| R-Type | `ADD`, `SUB`, `SLL`, `SLT`, `SLTU`, `XOR`, `SRL`, `SRA`, `OR`, `AND` |
| I-Type | `ADDI`, `SLTI`, `SLTIU`, `XORI`, `ORI`, `ANDI`, `SLLI`, `SRLI`, `SRAI` |
| Loads | `LB`, `LBU`, `LH`, `LHU`, `LW` |
| Stores | `SB`, `SH`, `SW` |
| Branches | `BEQ`, `BNE`, `BLT`, `BGE`, `BLTU`, `BGEU` |
| Jumps | `JAL`, `JALR` |
| Upper Immediates | `LUI`, `AUIPC` |
| RV32M Extension | `MUL`, `MULH`, `MULHSU`, `MULHU`, `DIV`, `DIVU`, `REM`, `REMU` |
| System | `EBREAK`, `ECALL`, `PAUSE`, `FENCE`, `FENCE.TSO` |

**Additional Instruction Details**

- Loads perform appropriate sign extension or zero extension.
- Stores use byte-enable masking for byte and halfword accesses.
- Branch instructions support both taken and not-taken conditions.
- `JAL` uses PC-relative addressing.
- `JALR` uses register-indirect addressing with least-significant-bit clearing.
- Jump instructions write the return address (`PC + 4`) into `rd`.
- `AUIPC` computes `PC + Immediate`.

**RV32M Division-by-Zero Handling**

| Operation | Division-by-Zero Result |
|---|---|
| `DIV` | `0xFFFFFFFF` |
| `DIVU` | `0xFFFFFFFF` |
| `REM` | Original dividend |
| `REMU` | Original dividend |

### 4.2 Hazard Handling and Pipeline Control

#### Data Forwarding

Implemented in `ForwardingUnit.v`.

- Supports EX-to-EX forwarding.
- Supports MEM-to-EX forwarding.
- Prioritizes EX/MEM forwarding over MEM/WB forwarding.
- Suppresses forwarding from register `x0`.

#### Store Data Forwarding

Forwarded store data is routed directly to the memory write-data register, bypassing the immediate multiplexer.

#### Load-Use Hazard Detection

Implemented in `HazardDetectionUnit.v`.

When a load-use dependency occurs:

1. `PC_Write` is stalled.
2. `IF_ID_Write` is stalled.
3. A zeroed control bubble is injected into ID/EX.
4. Execution resumes after one stall cycle.

#### Control Hazard Flushing

Branches are evaluated during the EX stage.

When a branch is taken:

- Incorrectly fetched instructions are flushed.
- A `0x00000013` NOP is inserted into IF/ID.
- Relevant pipeline control registers are cleared.
- Wrong-path instructions are prevented from committing architectural changes.

#### Unified Memory Arbitration

Implemented in `MemoryArbiter.v`.

The memory arbiter:

- Gives priority to data memory accesses over instruction fetching.
- Resolves structural hazards caused by the single-ported unified memory.
- Dynamically stalls instruction fetching during load/store memory accesses.
- Avoids the need for unconditional instruction-fetch stalling.

### 4.3 Verification Results

Verification was performed using **Vivado XSim**.

- Modular test programs were implemented in `UnifiedMemory.v`.
- Register results were verified using simulation waveforms.
- The automated regression testbench `RISCV_pipeline_TB.v` passed **11 out of 11 checks**.
- A total of **65 register writebacks** were observed.
- Memory store contents were verified.

---

## 5. Known Limitations and Workarounds

### Unaligned Memory Accesses

The current hardware does not support unaligned halfword or word memory accesses.

All test programs must use naturally aligned addresses:

- 2-byte boundaries for halfword operations.
- 4-byte boundaries for word operations.

This is an implementation limitation; the processor assumes naturally aligned memory accesses.

---

## 6. How to Simulate and Run

### Requirements

- Xilinx Vivado 2020.2 or later
- Vivado XSim Simulator
- Verilog HDL source files

### Simulation Instructions

**Step 1 – Open Vivado**

Launch Xilinx Vivado and create or open the project containing the Verilog source files.

**Step 2 – Configure the Simulation Top Module**

Set the simulation top module to:

`RISCV_pipeline_TB`

**Step 3 – Select the Test Program**

Open `UnifiedMemory.v` and choose one of the available programs.

| Test Program | Source Lines |
|---|---|
| Full Automated Regression Test | 34–191 |
| Program 1 | 204–238 |
| Program 2 | 280–345 |
| Program 3 | 371–392 |
| Program 4 | 431–451 |

For the full regression test, ensure lines 34–191 are active.

For modular testing, uncomment the desired program and ensure that only the intended memory initialization program is active.

**Step 4 – Run Behavioral Simulation**

Run the behavioral simulation for:

`5000 ns`

**Step 5 – Verify Results**

Check the XSim console for:

`ALL IMPLEMENTED CHECKS PASSED`

Compare register writeback values, memory contents, and pipeline signals with the waveform screenshots in:

`Sources/SimulationTesting/`

---

## 7. Project Summary

The project implements a five-stage, 32-bit pipelined RISC-V processor with complete RV32I instruction support, bonus RV32M arithmetic capabilities, and a priority-based arbiter for unified memory access.

The architecture incorporates data forwarding, load-use stalls, branch flushing, and dynamic memory arbitration to manage pipeline hazards.

Simulation testing demonstrates successful execution of the implemented instruction categories and passing results for all 11 automated regression checks.

---

**American University in Cairo – CSCE 3301 – Fall 2026**  
**Project 1 | Milestone 3**
