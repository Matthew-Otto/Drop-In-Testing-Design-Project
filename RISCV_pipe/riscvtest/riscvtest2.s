# riscvtest.s
# Sarah.Harris@unlv.edu
# David_Harris@hmc.edu
# 27 Oct 2020
#
# Test the RISC-V processor.  
#  add, sub, and, or, slt, addi, lw, sw, beq, jal
# If successful, it should write the value 25 to address 100

#       RISC-V Assembly         Description               Address   Machine Code
main:   addi x2, x0, 5          # x2 = 5                  0         00500113   
        addi x3, x0, 12         # x3 = 12                 4         00C00193
        addi x7, x3, -9         # x7 = (12 - 9) = 3       8         FF718393
        or   x4, x7, x2         # x4 = (3 OR 5) = 7       C         0023E233
        slt  x4, x3, x4         # x4 = (12 < 7) = 0       1C        0041A233
	slt  x4, x7, x2         # x4 = (3 < 5)  = 1       28        0023A233
        sub  x7, x7, x2         # x7 = (12 - 5) = 7       30        402383B3
        sw   x7, 84(x3)         # [96] = 7                34        0471AA23 
        lw   x2, 96(x0)         # x2 = [96] = 7           38        06002103 
	add  x2, x2, x9         # x2 = (7 + 18)  = 25     48        00910133
        sw   x2, 0x20(x3)       # mem[100] = 25           4C        0221A023 
done:   beq  x2, x2, done       # infinite loop           50        00210063
        
        
