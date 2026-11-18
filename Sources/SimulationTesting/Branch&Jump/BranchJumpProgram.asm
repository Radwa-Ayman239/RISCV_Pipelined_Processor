# Setup: x5 = 5, x6 = 5, x7 = -5
0:   addi x5,  x0, 5
1:   addi x6,  x0, 5
2:   addi x7,  x0, -5

# JAL test: skip mem[4], mem[5]; x1 = 16
3:   jal  x1, +12            # -> mem[6]
4:   addi x31, x31, 1        # FAIL (must be skipped)
5:   addi x31, x31, 1        # FAIL (must be skipped)
6:   addi x10, x10, 1        # PASS (JAL)

# JALR test: jump to absolute address 40 (mem[10]); x29 = 36
7:   addi x28, x0, 40
8:   jalr x29, x28, 0        # -> mem[10]
9:   addi x31, x31, 1        # FAIL (must be skipped)
10:  addi x10, x10, 1        # PASS (JALR)

# BEQ
11:  beq  x5, x6, +8         # taken
12:  addi x31, x31, 1        # FAIL
13:  addi x10, x10, 1        # PASS
14:  beq  x5, x7, +8         # not taken
15:  jal  x0, +8
16:  addi x31, x31, 1        # FAIL
17:  addi x10, x10, 1        # PASS

# BNE
18:  bne  x5, x7, +8         # taken
19:  addi x31, x31, 1        # FAIL
20:  addi x10, x10, 1        # PASS
21:  bne  x5, x6, +8         # not taken
22:  jal  x0, +8
23:  addi x31, x31, 1        # FAIL
24:  addi x10, x10, 1        # PASS

# BLT (signed)
25:  blt  x7, x5, +8         # -5 < 5, taken
26:  addi x31, x31, 1        # FAIL
27:  addi x10, x10, 1        # PASS
28:  blt  x5, x7, +8         # 5 < -5, not taken
29:  jal  x0, +8
30:  addi x31, x31, 1        # FAIL
31:  addi x10, x10, 1        # PASS

# BGE (signed)
32:  bge  x5, x7, +8         # 5 >= -5, taken
33:  addi x31, x31, 1        # FAIL
34:  addi x10, x10, 1        # PASS
35:  bge  x7, x5, +8         # -5 >= 5, not taken
36:  jal  x0, +8
37:  addi x31, x31, 1        # FAIL
38:  addi x10, x10, 1        # PASS

# BLTU (unsigned: -5 = 0xFFFFFFFB is huge)
39:  bltu x5, x7, +8         # 5 < 0xFFFFFFFB, taken
40:  addi x31, x31, 1        # FAIL
41:  addi x10, x10, 1        # PASS
42:  bltu x7, x5, +8         # not taken
43:  jal  x0, +8
44:  addi x31, x31, 1        # FAIL
45:  addi x10, x10, 1        # PASS

# BGEU
46:  bgeu x7, x5, +8         # 0xFFFFFFFB >= 5, taken
47:  addi x31, x31, 1        # FAIL
48:  addi x10, x10, 1        # PASS
49:  bgeu x5, x7, +8         # not taken
50:  jal  x0, +8
51:  addi x31, x31, 1        # FAIL
52:  addi x10, x10, 1        # PASS

# Self-check: all 14 tests passed?
53:  addi x11, x0, 14
54:  bne  x10, x11, +8       # mismatch -> skip to EBREAK
55:  addi x30, x0, 1         # x30 = 1 means ALL PASSED
56:  ebreak
