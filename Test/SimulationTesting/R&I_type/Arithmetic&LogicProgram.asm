.text
.globl _start

_start:
    # --- Immediate Instructions (I-Type) & U-Type ---
    LUI x1, 0x12345        # Load Upper Immediate: x1 = 0x12345000
    AUIPC x2, 0x10         # Add Upper Immediate to PC: x2 = PC + 0x10000
    
    ADDI x3, x0, 10        # Add Immediate: x3 = 10[cite: 1]
    ADDI x4, x0, -5        # Add Immediate: x4 = -5[cite: 1]
    
    # Signed vs Unsigned Immediate Comparisons (Tested Twice)
    SLTI x5, x4, 0         # Set Less Than Imm (Signed 1): Is -5 < 0? x5 = 1[cite: 1]
    SLTI x6, x3, 0         # Set Less Than Imm (Signed 2): Is 10 < 0? x6 = 0[cite: 1]
    SLTIU x7, x4, 20       # Set Less Than Imm Unsigned (Unsigned 1): Is 0xFFFFFFFB < 20? x7 = 0[cite: 1]
    SLTIU x8, x3, 20       # Set Less Than Imm Unsigned (Unsigned 2): Is 10 < 20? x8 = 1[cite: 1]
    
    XORI x9, x3, 0xF       # XOR Immediate: x9 = x3 ^ 0xF[cite: 1]
    ORI x10, x3, 0xF       # OR Immediate: x10 = x3 | 0xF[cite: 1]
    ANDI x11, x3, 0xF      # AND Immediate: x11 = x3 & 0xF[cite: 1]
    
    SLLI x12, x3, 2        # Shift Left Logical Imm: x12 = 10 << 2 (40)[cite: 1]
    SRLI x13, x3, 1        # Shift Right Logical Imm: x13 = 10 >> 1 (5)[cite: 1]
    SRAI x14, x4, 1        # Shift Right Arith Imm: x14 = -5 >> 1 (sign extended)[cite: 1]

    # --- Register-Register Instructions (R-Type) ---
    ADD x15, x3, x4        # Add: x15 = 10 + (-5) = 5[cite: 1]
    SUB x16, x3, x4        # Subtract: x16 = 10 - (-5) = 15[cite: 1]
    
    # Signed vs Unsigned Register Comparisons (Tested Twice)
    SLT x17, x4, x3        # Set Less Than (Signed 1): Is -5 < 10? x17 = 1[cite: 1]
    SLT x18, x3, x4        # Set Less Than (Signed 2): Is 10 < -5? x18 = 0[cite: 1]
    SLTU x19, x4, x3       # Set Less Than Unsigned (Unsigned 1): Is 0xFFFFFFFB < 10? x19 = 0[cite: 1]
    SLTU x20, x3, x4       # Set Less Than Unsigned (Unsigned 2): Is 10 < 0xFFFFFFFB? x20 = 1[cite: 1]
    
    XOR x21, x3, x4        # Bitwise XOR: x21 = x3 ^ x4[cite: 1]
    OR x22, x3, x4         # Bitwise OR: x22 = x3 | x4[cite: 1]
    AND x23, x3, x4        # Bitwise AND: x23 = x3 & x4[cite: 1]
    
    SLL x24, x3, x15       # Shift Left Logical: x24 = x3 << x15[cite: 1]
    SRL x25, x3, x15       # Shift Right Logical: x25 = x3 >> x15[cite: 1]
    SRA x26, x4, x15       # Shift Right Arithmetic: x26 = x4 >> x15 (preserves sign)[cite: 1]