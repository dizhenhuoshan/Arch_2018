.org 0x0
 	.global _start
_start:
    lui   x3, 0
    lui   x4, 0
    addi  x5, x3, 1
    sub   x6, x4, x5
    jalr  ra, x4, 12
    lui   x7, 2
    lui   x8, 2
    slt   x9, x4, x3
    slti  x10, x5, 300
    addi  x11, x10, 128
    sub   x12, x11, x5
