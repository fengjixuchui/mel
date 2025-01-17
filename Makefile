RAM=1G
QEMU=qemu-system-i386 -m $(RAM)
KERNEL=-kernel mel.elf
CCFLAGS= -c -w -m32 -fno-stack-protector -fno-pie -masm=intel

OBJS = main.o init.elf boot.elf kprint.o kmisc.o paging.o idt.o gdt.o keyboard.o azerty.o gdt.elf idt.elf irq.o pic.elf exceptions.o handler.o handler.elf ring3.elf keyboard.elf paging.elf 

mel.elf : $(OBJS) linker.ld
	ld -z noexecstack -m elf_i386 -T linker.ld $(OBJS) -o mel.elf

%.o : %.c
	gcc $(CCFLAGS) -O0 $<

%.o : libkernel/%.c
	gcc $(CCFLAGS) -O0 $<

gdt.elf : gdt/gdt.s
	as --32 gdt/gdt.s -o gdt.elf
gdt.o : gdt/gdt.c gdt/gdt.h gdt/tss.h
	gcc $(CCFLAGS) -O0 $< 

idt.o : idt/idt.c
	gcc $(CCFLAGS) -O0 idt/idt.c
idt.elf: idt/idt.s
	as --32 idt/idt.s -o idt.elf
irq.o : interrupts/irq/irq.c
	gcc $(CCFLAGS) -O0 interrupts/irq/irq.c
exceptions.o : interrupts/exceptions/exceptions.c
	gcc $(CCFLAGS) -O0 interrupts/exceptions/exceptions.c

%.o : syscalls/%.c
	gcc $(CCFLAGS) -O0 $<
handler.elf : syscalls/handler.s
	as --32 $< -o handler.elf


pic.elf : 8259_PIC/pic.s
	as --32 8259_PIC/pic.s -o pic.elf

%.o : keyboard/%.c
	gcc $(CCFLAGS) -O0 $<
keyboard.elf : keyboard/keyboard.s
	as --32 keyboard/keyboard.s -o keyboard.elf

paging.o : paging/paging.c
	gcc $(CCFLAGS) -O0 paging/paging.c
paging.elf : paging/paging.s
	as --32 paging/paging.s -o paging.elf

%.o : usermode/%.c
	gcc $(CCFLAGS) -O0 $<
ring3.elf : usermode/ring3.s
	as --32 usermode/ring3.s -o ring3.elf

boot.elf : boot/boot.s
	as --32 boot/boot.s -o boot.elf
init.elf : init.c
	gcc $(CCFLAGS) -O1 init.c -o init.elf

clean: 
	rm *.o *.elf 
run:
	$(QEMU) $(KERNEL)
kvm:
	$(QEMU) --enable-kvm $(KERNEL)
debug:
	$(QEMU) $(KERNEL) -d in_asm
cpu:
	$(QEMU) $(KERNEL) -d cpu
int:
	$(QEMU) $(KERNEL) -d int
gdb:
	$(QEMU) -s -S $(KERNEL)
all:
	make clean && make && make run
