nasm -fbin -o kernel.bin kernel.asm
vfd open ..\qemu\floppy.img
copy kernel.bin A:
y
vfd save
vfd close
qemu -m 32 -fda ..\qemu\floppy.img -L ..\qemu