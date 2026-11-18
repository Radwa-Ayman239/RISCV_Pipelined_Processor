CSCE 3301 - Computer Architecture (Fall 2026)
Project 1: femtoRV32 (Pipelined RISC-V Processor)
Milestone 3 Submission

================================================================================
1. STUDENT INFORMATION
================================================================================
Team Members:
1. Ghada Sherif Ismail       - ID: 900221630
2. Radwa Ayman AbuElfotouh   - ID: 900242263

Course: CSCE 3301 -- Computer Architecture
Instructor: Dr. Cherif Salama
Department of Computer Science and Engineering
The American University in Cairo (AUC)
Submission Date: November 18, 2026

================================================================================
2. PROJECT OVERVIEW
================================================================================
Design and Verilog HDL implementation of a 32-bit five-stage pipelined RISC-V 
processor (IF, ID, EX, MEM, WB) supporting:
- The complete base RV32I integer instruction set (42 user-level instructions).
- Bonus Feature 1: Full RV32M integer multiplication and division extension 
  (MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU) via MultiplierDivider.v.
- Bonus Feature 2: Priority-based Memory Arbiter (MemoryArbiter.v) resolving 
  structural hazards on a single single-ported unified memory with dynamic 
  stalling (CPI ~ 1.2 instead of the baseline static CPI = 2.0).
- Hardware hazard management (ForwardingUnit.v and HazardDetectionUnit.v).
- FPGA support on Digilent Nexys A7-100T with single-step manual clocking and 
  multiplexed LED and 7-segment display debugging interfaces.

================================================================================
3. ASSUMPTIONS
================================================================================
1. Single-Ported Memory Constraint:
   A single physical memory (UnifiedMemory.v) holds both instructions and data.
   It provides one 32-bit address bus and performs either an instruction fetch 
   or a data read/write in any given clock cycle.
2. Memory Alignment:
   All halfword accesses (LH, LHU, SH) and word accesses (LW, SW) are assumed 
   to be naturally aligned to 2-byte and 4-byte boundaries, respectively.
3. Byte-Addressable Word Indexing:
   The memory comprises 512 32-bit words (2048 bytes). Byte address bits addr[10:2] 
   index the 32-bit word, while addr[1:0] specify the byte offset within the word.
4. Architectural Register x0:
   Register x0 is hardwired to constant 0. Any write operation targeting x0 is 
   discarded, and forwarding from x0 is strictly suppressed.
5. Special Instruction Behavior:
   - EBREAK (0x00100073) is treated as a terminal halt instruction that permanently 
     freezes the Program Counter and disables further pipeline updates.
   - ECALL, PAUSE, FENCE, and FENCE.TSO are executed as architectural NOPs.

================================================================================
4. WHAT WORKS
================================================================================
- Instruction Execution (100% of Required Base ISA + Bonus M-Extension):
  * R-Type: ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND.
  * I-Type: ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI.
  * Loads: LB, LBU, LH, LHU, LW with correct sign/zero extension.
  * Stores: SB, SH, SW with exact byte-enable masking across offsets.
  * Branches: BEQ, BNE, BLT, BGE, BLTU, BGEU (both taken and not-taken).
  * Jumps: JAL (PC-relative) and JALR (register-indirect with LSB clearing), 
    with link return address (PC+4) written to rd.
  * Upper Immediates: LUI and AUIPC (PC + Imm) writeback.
  * Bonus RV32M: MUL, MULH, MULHSU, MULHU, DIV, DIVU, REM, REMU with complete 
    division-by-zero protection (returning 0xFFFFFFFF for DIV/DIVU and dividend 
    for REM/REMU).
  * System: EBREAK cleanly halts CPU updates; ECALL/PAUSE/FENCE execute as NOPs.

- Hazard Handling & Pipeline Control:
  * RAW Data Forwarding: EX-to-EX and MEM-to-EX operand forwarding to ALU inputs 
    with strict EX/MEM priority over MEM/WB.
  * Store Data Forwarding: Forwarded store data routes directly to the memory 
    write register, bypassing the immediate multiplexer.
  * Load-Use Stalls: HazardDetectionUnit accurately stalls PC_Write and IF_ID_Write 
    for 1 cycle while injecting a zeroed control bubble into ID/EX.
  * Control Hazard Flushing: Branch condition evaluation in the EX stage triggers 
    synchronous pipeline flushing (inserting 0x00000013 NOP into IF/ID and clearing 
    control registers) to prevent wrong-path instructions from committing.
  * Memory Arbitration: MemoryArbiter prioritizes data memory access over instruction 
    fetch, stalling IF only during load/store cycles.

- Verification Results:
  * Modular test programs in UnifiedMemory.v verified in Vivado XSim with exact 
    register values confirmed in waveforms.
  * Automated regression testbench (RISCV_pipeline_TB.v) passed 11/11 automated checks, 
    observed 65 register writebacks, and verified memory store contents.

================================================================================
5. WHAT DOES NOT WORK / KNOWN ISSUES & WORKAROUNDS
================================================================================




. Unaligned Memory Accesses:
   - Halfword and word loads/stores that are not naturally aligned are not supported 
     by the hardware (in accordance with standard RV32I base specifications).

================================================================================
6. HOW TO SIMULATE & RUN
================================================================================
1. Open the project in Vivado (2020.2 or later).
2. Set `RISCV_pipeline_TB` as the top simulation module.
3. In `UnifiedMemory.v`:
   - To run the full regression test with 11 automated memory checks: ensure lines 
     34..191 are active.
   - To run modular tests: uncomment Program 1 (lines 204..238), Program 2 (lines 
     280..345), Program 3 (lines 371..392), or Program 4 (lines 431..451).
4. Run Behavioral Simulation for 5000 ns.
5. Observe the console output for "ALL IMPLEMENTED CHECKS PASSED" and compare 
   the waveform against the screenshots saved in `Sources/SimulationTesting/`.
