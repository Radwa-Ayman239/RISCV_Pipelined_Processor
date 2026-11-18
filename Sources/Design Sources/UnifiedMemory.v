
`timescale 1ns / 1ps

module UnifiedMemory (
    input wire clk,
    input wire MemRead,
    input wire MemWrite,
    input wire [1:0] MemSize,
    input wire LoadUnsigned,
    input wire InstrFetch,
    input wire [31:0] addr,
    input wire [31:0] data_in,
    output reg [31:0] data_out
);

    // 2048 bytes = 512 words of 32 bits
    reg [31:0] mem [0:511];

    wire valid_addr = (addr[31:11] == 21'b0);
    wire [8:0] word_addr = addr[10:2];
    wire [1:0] byte_offset = addr[1:0];

    integer i;

    // ==========================================
    // MEMORY INITIALIZATION
    // ==========================================

    initial begin
        for (i = 0; i < 512; i = i + 1)
            mem[i] = 32'b0;

 
//        // ==========================================
//        // R-TYPE: REGISTER ARITHMETIC
//        // ==========================================

//        mem[0]  = 32'h01100093; // ADDI x1, x0, 17   -> x1 = 17
//        mem[1]  = 32'h00900113; // ADDI x2, x0, 9    -> x2 = 9
//        mem[2]  = 32'hFFB00193; // ADDI x3, x0, -5   -> x3 = -5

//        mem[3]  = 32'h00208233; // ADD  x4, x1, x2   -> x4 = 26
//        mem[4]  = 32'h402082B3; // SUB  x5, x1, x2   -> x5 = 8
//        mem[5]  = 32'h00111333; // SLL  x6, x2, x1   -> x6 = 9 << 17
//        mem[6]  = 32'h0021A3B3; // SLT  x7, x3, x2   -> signed -5 < 9 = 1
//        mem[7]  = 32'h0021B433; // SLTU x8, x3, x2   -> unsigned comparison = 0
//        mem[8]  = 32'h0020C4B3; // XOR  x9, x1, x2   -> bitwise XOR
//        mem[9]  = 32'h0021D533; // SRL  x10,x3, x2   -> logical right shift by 9
//        mem[10] = 32'h4021D5B3; // SRA  x11,x3, x2   -> arithmetic right shift by 9
//        mem[11] = 32'h0020E633; // OR   x12,x1, x2   -> bitwise OR
//        mem[12] = 32'h0020F6B3; // AND  x13,x1, x2   -> bitwise AND

//        // ==========================================
//        // I-TYPE: IMMEDIATE ARITHMETIC
//        // ==========================================

//        mem[13] = 32'hFEC08713; // ADDI  x14,x1,-20 -> x14 = -3
//        mem[14] = 32'h0001A793; // SLTI  x15,x3,0   -> signed -5 < 0 = 1
//        mem[15] = 32'h00512813; // SLTI  x16,x2,5   -> signed 9 < 5 = 0
//        mem[16] = 32'h0091B893; // SLTIU x17,x3,9   -> unsigned comparison = 0
//        mem[17] = 32'h00A13913; // SLTIU x18,x2,10  -> unsigned 9 < 10 = 1
//        mem[18] = 32'h00F0C993; // XORI  x19,x1,15  -> 17 XOR 15 = 30
//        mem[19] = 32'h01016A13; // ORI   x20,x2,16  -> 9 OR 16 = 25
//        mem[20] = 32'h00F0FA93; // ANDI  x21,x1,15  -> 17 AND 15 = 1
//        mem[21] = 32'h00311B13; // SLLI  x22,x2,3   -> 9 << 3 = 72
//        mem[22] = 32'h0041DB93; // SRLI  x23,x3,4   -> logical right shift
//        mem[23] = 32'h4041DC13; // SRAI  x24,x3,4   -> arithmetic right shift
//        mem[24] = 32'h00000C93; // ADDI  x25,x0,0   -> x25 = 0
//        mem[25] = 32'h00912D13; // SLTI  x26,x2,9   -> 9 < 9 = 0
//        mem[26] = 32'h00913D93; // SLTIU x27,x2,9   -> 9 < 9 = 0
//        mem[27] = 32'h00011E13; // SLLI  x28,x2,0   -> x28 = 9
//        mem[28] = 32'h01F15E93; // SRLI  x29,x2,31  -> x29 = 0
//        mem[29] = 32'h41F1DF13; // SRAI  x30,x3,31  -> x30 = -1

//        // ==========================================
//        // LOAD AND STORE INSTRUCTIONS
//        // ==========================================

//        mem[30] = 32'h60000F93; // ADDI x31,x0,1536 -> data memory base address

//        mem[31] = 32'h008F8703; // LB  x14,8(x31)   -> signed byte (-5)
//        mem[32] = 32'h008FC783; // LBU x15,8(x31)   -> unsigned byte (251)
//        mem[33] = 32'h008F9803; // LH  x16,8(x31)   -> signed halfword (-5)
//        mem[34] = 32'h008FD883; // LHU x17,8(x31)   -> unsigned halfword
//        mem[35] = 32'h008FA903; // LW  x18,8(x31)   -> signed 32-bit word (-5)

//        mem[36] = 32'h000F8983; // LB  x19,0(x31)   -> load byte 17
//        mem[37] = 32'h000F9A03; // LH  x20,0(x31)   -> load halfword 17
//        mem[38] = 32'h000FAA83; // LW  x21,0(x31)   -> load word 17

//        mem[39] = 32'h003F8823; // SB  x3,16(x31)   -> store low byte of -5
//        mem[40] = 32'h010FCB03; // LBU x22,16(x31)  -> verify stored byte = 251
//        mem[41] = 32'h010F8B83; // LB  x23,16(x31)  -> verify signed byte = -5

//        mem[42] = 32'h003F9A23; // SH  x3,20(x31)   -> store low 16 bits of -5
//        mem[43] = 32'h014FDC03; // LHU x24,20(x31)  -> verify unsigned halfword
//        mem[44] = 32'h014F9C83; // LH  x25,20(x31)  -> verify signed halfword

//        mem[45] = 32'h003FAC23; // SW  x3,24(x31)   -> store 32-bit -5
//        mem[46] = 32'h018FAD03; // LW  x26,24(x31)  -> verify stored word = -5
//        mem[47] = 32'h011FCD83; // LBU x27,17(x31)  -> load adjacent byte
//        mem[48] = 32'h016FDE03; // LHU x28,22(x31)  -> load adjacent halfword
//        mem[49] = 32'h001FAE23; // SW  x1,28(x31)   -> store 17
//        mem[50] = 32'h01CFAE83; // LW  x29,28(x31)  -> verify stored 17

//        // ==========================================
//        // B-TYPE: CONDITIONAL BRANCHES
//        // ==========================================

//        mem[51] = 32'h00000F13; // ADDI x30,x0,0   -> reset branch result
//        mem[52] = 32'h00210463; // BEQ  x2,x2,+8   -> taken (equal)
//        mem[53] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped if branch works
//        mem[54] = 32'h00208463; // BEQ  x1,x2,+8   -> not taken (17 != 9)
//        mem[55] = 32'h001F0F13; // ADDI x30,x30,1  -> mark not-taken result
//        mem[56] = 32'h00209463; // BNE  x1,x2,+8   -> taken
//        mem[57] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[58] = 32'h00211463; // BNE  x2,x2,+8   -> not taken
//        mem[59] = 32'h002F0F13; // ADDI x30,x30,2  -> mark result
//        mem[60] = 32'h0021C463; // BLT  x3,x2,+8   -> taken (-5 < 9)
//        mem[61] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[62] = 32'h0020C463; // BLT  x1,x2,+8   -> not taken
//        mem[63] = 32'h004F0F13; // ADDI x30,x30,4  -> mark result
//        mem[64] = 32'h0020D463; // BGE  x1,x2,+8   -> taken (17 >= 9)
//        mem[65] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[66] = 32'h0021D463; // BGE  x3,x2,+8   -> not taken
//        mem[67] = 32'h008F0F13; // ADDI x30,x30,8  -> mark result
//        mem[68] = 32'h00116463; // BLTU x2,x1,+8   -> taken (9 < 17)
//        mem[69] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[70] = 32'h0021E463; // BLTU x3,x2,+8   -> not taken (unsigned)
//        mem[71] = 32'h010F0F13; // ADDI x30,x30,16 -> mark result
//        mem[72] = 32'h0021F463; // BGEU x3,x2,+8   -> taken (unsigned)
//        mem[73] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[74] = 32'h00117463; // BGEU x2,x1,+8   -> not taken
//        mem[75] = 32'h020F0F13; // ADDI x30,x30,32 -> mark result

//        // ==========================================
//        // J-TYPE: JUMPS
//        // ==========================================

//        mem[76] = 32'h00000F13; // ADDI x30,x0,0   -> reset jump result
//        mem[77] = 32'h00C00EEF; // JAL x29,+12     -> jump, save PC+4 in x29
//        mem[78] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[79] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[80] = 32'h001F0F13; // ADDI x30,x30,1  -> mark JAL success
//        mem[81] = 32'h15900D93; // ADDI x27,x0,345 -> JALR target address
//        mem[82] = 32'h000D8E67; // JALR x28,0(x27) -> jump to x27 & ~1
//        mem[83] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[84] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[85] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[86] = 32'h002F0F13; // ADDI x30,x30,2  -> mark JALR success
//        mem[87] = 32'h0080006F; // JAL x0,+8       -> unconditional jump
//        mem[88] = 32'h040F0F13; // ADDI x30,x30,64 -> skipped
//        mem[89] = 32'h004F0F13; // ADDI x30,x30,4  -> mark jump success

//        // ==========================================
//        // U-TYPE: UPPER IMMEDIATE
//        // ==========================================

//        mem[90] = 32'h12345DB7; // LUI x27,0x12345  -> x27 = 0x12345000
//        mem[91] = 32'h00002E17; // AUIPC x28,2      -> x28 = PC + 0x2000
//        mem[92] = 32'hFFFFFEB7; // LUI x29,0xFFFFF  -> x29 = 0xFFFFF000
//        mem[93] = 32'h00000F17; // AUIPC x30,0      -> x30 = current PC

//        // ==========================================
//        // SYSTEM AND MEMORY ORDERING
//        // ==========================================

//        mem[94] = 32'h00000073; // ECALL     -> environment call (CPU treats as NOP)
//        mem[95] = 32'h0000000F; // FENCE     -> memory ordering (treated as NOP)
//        mem[96] = 32'h8330000F; // FENCE.TSO -> memory ordering (treated as NOP)
//        mem[97] = 32'h0100000F; // PAUSE     -> processor hint (treated as NOP)
//        mem[98] = 32'h00100073; // EBREAK    -> halt processor
        
//        // ==========================================
//        // M-EXTENSION: MULTIPLICATION AND DIVISION
//        // ==========================================

//        mem[99]  = 32'h02208233; // MUL  x4, x1, x2 -> 17 * 9 = 153
//        mem[100] = 32'h023092B3; // MULH x5, x1, x3 -> high 32 bits of 17 * (-5) = FFFFFFFF
//        mem[101] = 32'h0220C333; // DIV  x6, x1, x2 -> 17 / 9 = 1
//        mem[102] = 32'h0220E3B3; // REM  x7, x1, x2 -> 17 % 9 = 8


//        // ==========================================
//        // INITIAL DATA MEMORY
//        // ==========================================

//        mem[384] = 32'h00000011; // Address 1536: decimal 17
//        mem[385] = 32'h00000009; // Address 1540: decimal 9
//        mem[386] = 32'hFFFFFFFB; // Address 1544: signed -5
//end 








// ==========================================
        // ==========================================
        // PROGRAM 1: ARITHMETIC AND LOGICAL
        // ==========================================
//        mem[0]  = 32'h123450B7; // LUI   x1, 0x12345    -> x1 = 0x12345000
//        mem[1]  = 32'h00010117; // AUIPC x2, 0x10       -> x2 = PC(4) + 0x10000 = 0x10004
//        mem[2]  = 32'h00A00193; // ADDI  x3, x0, 10     -> x3 = 10
//        mem[3]  = 32'hFFB00213; // ADDI  x4, x0, -5     -> x4 = -5 (0xFFFFFFFB)
        
//        mem[4]  = 32'h00022293; // SLTI  x5, x4, 0      -> x5 = 1  (-5 < 0)
//        mem[5]  = 32'h0001A313; // SLTI  x6, x3, 0      -> x6 = 0  (10 < 0 is false)
//        mem[6]  = 32'h01423393; // SLTIU x7, x4, 20     -> x7 = 0  (0xFFFFFFFB < 20 is false)
//        mem[7]  = 32'h0141B413; // SLTIU x8, x3, 20     -> x8 = 1  (10 < 20)
        
//        mem[8]  = 32'h00F1C493; // XORI  x9, x3, 0xF    -> x9 = 5  (10 ^ 15)
//        mem[9]  = 32'h00F1E513; // ORI   x10,x3, 0xF    -> x10= 15 (10 | 15)
//        mem[10] = 32'h00F1F593; // ANDI  x11,x3, 0xF    -> x11= 10 (10 & 15)
        
//        mem[11] = 32'h00219613; // SLLI  x12,x3, 2      -> x12= 40 (10 << 2)
//        mem[12] = 32'h0011D693; // SRLI  x13,x3, 1      -> x13= 5  (10 >> 1)
//        mem[13] = 32'h40125713; // SRAI  x14,x4, 1      -> x14= -3 (0xFFFFFFFD)
        
//        mem[14] = 32'h004187B3; // ADD   x15,x3, x4     -> x15= 5  (10 + -5)
//        mem[15] = 32'h40418833; // SUB   x16,x3, x4     -> x16= 15 (10 - -5)
        
//        mem[16] = 32'h003228B3; // SLT   x17,x4, x3     -> x17= 1  (-5 < 10)
//        mem[17] = 32'h0041A933; // SLT   x18,x3, x4     -> x18= 0  (10 < -5 is false)
//        mem[18] = 32'h003239B3; // SLTU  x19,x4, x3     -> x19= 0  (0xFFFFFFFB < 10 is false)
//        mem[19] = 32'h0041BA33; // SLTU  x20,x3, x4     -> x20= 1  (10 < 0xFFFFFFFB)
        
//        mem[20] = 32'h0041CAB3; // XOR   x21,x3, x4     -> x21= -15 (10 ^ -5)
//        mem[21] = 32'h0041EB33; // OR    x22,x3, x4     -> x22= -1  (10 | -5)
//        mem[22] = 32'h0041FBB3; // AND   x23,x3, x4     -> x23= 10  (10 & -5)
        
//        mem[23] = 32'h00F19C33; // SLL   x24,x3, x15    -> x24= 320 (10 << 5)
//        mem[24] = 32'h00F1DD33; // SRL   x25,x3, x15    -> x25= 0   (10 >> 5)
//        mem[25] = 32'h40F2DDB3; // SRA   x26,x4, x15    -> x26= -1  (-5 >> 5, signed)
//        mem[26] = 32'h00100073; // EBREAK               -> Halt

        /* 
         * EXPECTED FINAL REGISTER VALUES (SIGNED DECIMAL)
         * -----------------------------------------------
         * x1  = 305418240
         * x2  = 65540
         * x3  = 10
         * x4  = -5
         * x5  = 1
         * x6  = 0
         * x7  = 0
         * x8  = 1
         * x9  = 5
         * x10 = 15
         * x11 = 10
         * x12 = 40
         * x13 = 5
         * x14 = -3
         * x15 = 5
         * x16 = 15
         * x17 = 1
         * x18 = 0
         * x19 = 0
         * x20 = 1
         * x21 = -15
         * x22 = -1
         * x23 = 10
         * x24 = 320
         * x25 = 0
         * x26 = -1
         */







// ==========================================
        // PROGRAM 2: BRANCHES AND JUMPS
        // ==========================================
        // Setup
mem[0]  = 32'h00500293; // ADDI  x5, x0, 5
mem[1]  = 32'h00500313; // ADDI  x6, x0, 5
mem[2]  = 32'hFFB00393; // ADDI  x7, x0, -5
// JAL / JALR
mem[3]  = 32'h00C000EF; // JAL   x1, +12      -> mem[6], x1 = 16
mem[4]  = 32'h001F8F93; // ADDI  x31, x31, 1  (FAIL, skipped)
mem[5]  = 32'h001F8F93; // ADDI  x31, x31, 1  (FAIL, skipped)
mem[6]  = 32'h00150513; // ADDI  x10, x10, 1  (PASS)
mem[7]  = 32'h02800E13; // ADDI  x28, x0, 40
mem[8]  = 32'h000E0EE7; // JALR  x29, x28, 0  -> mem[10], x29 = 36
mem[9]  = 32'h001F8F93; // ADDI  x31, x31, 1  (FAIL, skipped)
mem[10] = 32'h00150513; // ADDI  x10, x10, 1  (PASS)
// BEQ
mem[11] = 32'h00628463; // BEQ   x5, x6, +8   taken
mem[12] = 32'h001F8F93; // FAIL
mem[13] = 32'h00150513; // PASS
mem[14] = 32'h00728463; // BEQ   x5, x7, +8   not taken
mem[15] = 32'h0080006F; // JAL   x0, +8
mem[16] = 32'h001F8F93; // FAIL
mem[17] = 32'h00150513; // PASS
// BNE
mem[18] = 32'h00729463; // BNE   x5, x7, +8   taken
mem[19] = 32'h001F8F93; // FAIL
mem[20] = 32'h00150513; // PASS
mem[21] = 32'h00629463; // BNE   x5, x6, +8   not taken
mem[22] = 32'h0080006F; // JAL   x0, +8
mem[23] = 32'h001F8F93; // FAIL
mem[24] = 32'h00150513; // PASS
// BLT
mem[25] = 32'h0053C463; // BLT   x7, x5, +8   taken
mem[26] = 32'h001F8F93; // FAIL
mem[27] = 32'h00150513; // PASS
mem[28] = 32'h0072C463; // BLT   x5, x7, +8   not taken
mem[29] = 32'h0080006F; // JAL   x0, +8
mem[30] = 32'h001F8F93; // FAIL
mem[31] = 32'h00150513; // PASS
// BGE
mem[32] = 32'h0072D463; // BGE   x5, x7, +8   taken
mem[33] = 32'h001F8F93; // FAIL
mem[34] = 32'h00150513; // PASS
mem[35] = 32'h0053D463; // BGE   x7, x5, +8   not taken
mem[36] = 32'h0080006F; // JAL   x0, +8
mem[37] = 32'h001F8F93; // FAIL
mem[38] = 32'h00150513; // PASS
// BLTU
mem[39] = 32'h0072E463; // BLTU  x5, x7, +8   taken
mem[40] = 32'h001F8F93; // FAIL
mem[41] = 32'h00150513; // PASS
mem[42] = 32'h0053E463; // BLTU  x7, x5, +8   not taken
mem[43] = 32'h0080006F; // JAL   x0, +8
mem[44] = 32'h001F8F93; // FAIL
mem[45] = 32'h00150513; // PASS
// BGEU
mem[46] = 32'h0053F463; // BGEU  x7, x5, +8   taken
mem[47] = 32'h001F8F93; // FAIL
mem[48] = 32'h00150513; // PASS
mem[49] = 32'h0072F463; // BGEU  x5, x7, +8   not taken
mem[50] = 32'h0080006F; // JAL   x0, +8
mem[51] = 32'h001F8F93; // FAIL
mem[52] = 32'h00150513; // PASS
// Self-check and halt
mem[53] = 32'h00E00593; // ADDI  x11, x0, 14
mem[54] = 32'h00B51463; // BNE   x10, x11, +8
mem[55] = 32'h00100F13; // ADDI  x30, x0, 1
mem[56] = 32'h00100073; // EBREAK

        /* 
         * EXPECTED FINAL REGISTER VALUES (SIGNED DECIMAL)
         * -----------------------------------------------
         // x0  = 0
        // x1  = 16
        // x5  = 5
        // x6  = 5
        // x7  = -5
        // x10 = 14
        // x11 = 14
        // x28 = 40
        // x29 = 36
        // x30 = 1
        // x31 = 0
        // all others = addr    
         */
         
         
         
         
        
        // ==========================================
        // PROGRAM 3: MEMORY ACCESS
        // ==========================================
    
//        mem[0]  = 32'h04000293; // ADDI  t0(x5), x0, 64 -> Base addr = 64 
        
//        mem[1]  = 32'h01200313; // ADDI  t1(x6), x0, 18 -> x6 = 18 (0x12)
        
//        mem[2]  = 32'h00628A23; // SB    x6, 20(x5)     -> mem[21] byte 0 = 0x12
//        mem[3]  = 32'h00629C23; // SH    x6, 24(x5)     -> mem[22] half 0 = 0x0012
//        mem[4]  = 32'h0062AE23; // SW    x6, 28(x5)     -> mem[23] word = 0x00000012
        
//        mem[5]  = 32'h01428383; // LB    t2(x7), 20(x5) -> x7 = 18
//        mem[6]  = 32'h01528403; // LB    s0(x8), 21(x5) -> x8 = 0 
//        mem[7]  = 32'h0142C483; // LBU   s1(x9), 20(x5) -> x9 = 18
//        mem[8]  = 32'h0152C503; // LBU   a0(x10),21(x5) -> x10 = 0
        
//        mem[9]  = 32'h01829583; // LH    a1(x11),24(x5) -> x11 = 18
//        mem[10] = 32'h01A29603; // LH    a2(x12),26(x5) -> x12 = 0
//        mem[11] = 32'h0182D683; // LHU   a3(x13),24(x5) -> x13 = 18
//        mem[12] = 32'h01A2D703; // LHU   a4(x14),26(x5) -> x14 = 0
        
//        mem[13] = 32'h01C2A783; // LW    a5(x15),28(x5) -> x15 = 18
//        mem[14] = 32'h0000000F; // FENCE                -> NOP
//        mem[15] = 32'h00100073; // EBREAK               -> Halt

        /* 
         * EXPECTED FINAL REGISTER VALUES (SIGNED DECIMAL)
         * -----------------------------------------------
         * x5  = 64
         * x6  = 18
         * x7  = 18
         * x8  = 0
         * x9  = 18
         * x10 = 0
         * x11 = 18
         * x12 = 0
         * x13 = 18
         * x14 = 0
         * x15 = 18
         */

        /* 
         * EXPECTED FINAL REGISTER VALUES (SIGNED DECIMAL)
         * -----------------------------------------------
         * x5  = 0
         * x6  = 18
         * x7  = 18
         * x8  = 0
         * x9  = 18
         * x10 = 0
         * x11 = 18
         * x12 = 0
         * x13 = 18
         * x14 = 0
         * x15 = 18
         */
         
         
         
         
         // ==========================================
        // PROGRAM 4: RV32M EXTENSION
        // ==========================================
//        mem[0]  = 32'h00F00293; // ADDI  t0(x5), x0, 15 -> x5 = 15
//        mem[1]  = 32'hFFC00313; // ADDI  t1(x6), x0, -4 -> x6 = -4 (0xFFFFFFFC)
//        mem[2]  = 32'h00700393; // ADDI  t2(x7), x0, 7  -> x7 = 7
        
//        mem[3]  = 32'h02628E33; // MUL   t3(x28), x5, x6-> x28 = -60 (0xFFFFFFC4)
//        mem[4]  = 32'h02629EB3; // MULH  t4(x29), x5, x6-> x29 = -1  (0xFFFFFFFF)
//        mem[5]  = 32'h02532F33; // MULHSU t5(x30),x6, x5-> x30 = -1  (0xFFFFFFFF)
//        mem[6]  = 32'h0272BFB3; // MULHU t6(x31), x5, x7-> x31 = 0
        
//         mem[7] = 32'h0262C8B3; // DIV   s1(x9), x5, x6 -> x9 = -3   (0xFFFFFFFD)
//        mem[8]  = 32'h02734533; // DIV   a0(x10),x6, x7 -> x10= 0
//        mem[9]  = 32'h0272D5B3; // DIVU  a1(x11),x5, x7 -> x11= 2
//        mem[10] = 32'h02735633; // DIVU  a2(x12),x6, x7 -> x12= 613566756 (0xFFFFFFFC / 7)
        
//        mem[11] = 32'h0262E6B3; // REM   a3(x13),x5, x6 -> x13= 3
//        mem[12] = 32'h02736733; // REM   a4(x14),x6, x7 -> x14= -4   (0xFFFFFFFC)
//        mem[13] = 32'h0272F7B3; // REMU  a5(x15),x5, x7 -> x15= 1
//        mem[14] = 32'h02737833; // REMU  a6(x16),x6, x7 -> x16= 0
        
//        mem[15] = 32'h00000073; // ECALL                -> System Call (Exit)

        /* 
         * EXPECTED FINAL REGISTER VALUES (SIGNED DECIMAL)
         * -----------------------------------------------
         * x5 (t0) = 15
         * x6 (t1) = -4
         * x7 (t2) = 7
         * x10 (a0)= 0
         * x11 (a1)= 2
         * x12 (a2)= 613566756
         * x13 (a3)= 3
         * x14 (a4)= -4
         * x15 (a5)= 1
         * x16 (a6)= 0
         * x17 = -3
         * x28 (t3)= -60
         * x29 (t4)= -1
         * x30 (t5)= -1
         * x31 (t6)= 0
         */
end 



































    // ==========================================
    // MEMORY READ
    // ==========================================

    wire [31:0] word_data = mem[word_addr];

    // Shift selected byte/halfword to low bits
    wire [31:0] shifted_data =
        word_data >> {byte_offset, 3'b000};

    wire [7:0] selected_byte =
        shifted_data[7:0];

    wire [15:0] selected_half =
        shifted_data[15:0];

    always @(*) begin
        data_out = 32'b0;

        if (valid_addr) begin

            if (InstrFetch) begin
                data_out = word_data;
            end

            else if (MemRead) begin
                case (MemSize)

                    // LB / LBU
                    2'b00: begin
                        if (LoadUnsigned)
                            data_out =
                                {24'b0, selected_byte};
                        else
                            data_out =
                                {{24{selected_byte[7]}},
                                 selected_byte};
                    end

                    // LH / LHU
                    2'b01: begin
                        if (LoadUnsigned)
                            data_out =
                                {16'b0, selected_half};
                        else
                            data_out =
                                {{16{selected_half[15]}},
                                 selected_half};
                    end

                    // LW
                    2'b10: begin
                        data_out = word_data;
                    end

                    default:
                        data_out = 32'b0;

                endcase
            end
        end
    end

    // ==========================================
    // MEMORY WRITE
    // ==========================================

    wire write_byte = (MemSize == 2'b00);
    wire write_half = (MemSize == 2'b01);
    wire write_word = (MemSize == 2'b10);

    wire [3:0] byte_enable =
        write_word ? 4'b1111 :
        write_half ?
            (byte_offset[1] ? 4'b1100 : 4'b0011) :
        write_byte ?
            (4'b0001 << byte_offset) :
            4'b0000;

    wire [31:0] aligned_write_data =
        data_in << {byte_offset, 3'b000};

    always @(posedge clk) begin
        if (MemWrite && valid_addr) begin

            if (byte_enable[0])
                mem[word_addr][7:0] <=
                    aligned_write_data[7:0];

            if (byte_enable[1])
                mem[word_addr][15:8] <=
                    aligned_write_data[15:8];

            if (byte_enable[2])
                mem[word_addr][23:16] <=
                    aligned_write_data[23:16];

            if (byte_enable[3])
                mem[word_addr][31:24] <=
                    aligned_write_data[31:24];

        end
    end

endmodule
