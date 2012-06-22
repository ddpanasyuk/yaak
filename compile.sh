
sudo nasm -fbin -o kernel.bin kernel.asm
sudo mount -o loop floppy.img /floppy
sudo ./rdg string.asm compile.sh
sudo cp kernel.bin /floppy
sudo cp initrd /floppy
sudo umount /floppy
qemu-kvm -m 64 -fda floppy.img
