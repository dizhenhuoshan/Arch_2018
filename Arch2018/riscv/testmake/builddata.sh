riscv32-unknown-elf-as test.s -o test.o -march=rv32i
riscv32-unknown-elf-ld test.o -o test.om
riscv32-unknown-elf-objcopy -O binary test.om test.bin
python bin2ascii.py test.bin test.data
rm -f *.bin *.om *.o
