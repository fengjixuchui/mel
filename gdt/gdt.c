#include "gdt.h"
#include "tss.h"
#define KERNELSTACK 0x00800000
#define FILL_GDT_ENTRY(n, l015, b015, b1623, ac, gr, b2431) \
                gdt[n].limit_0_15 = l015; \
                gdt[n].base_0_15 = b015; \
                gdt[n].base_16_23 = b1623; \
                gdt[n].access = ac; \
                gdt[n].granularity = gr; \
                gdt[n].base_24_31 = b2431;

struct GDT gdt[6];
struct GDT_PTR gdt_ptr;

extern void load_gdt(struct GDT*);
struct TSS tss; 

void init_gdt()
{
        FILL_GDT_ENTRY(0,0,0,0,0,0,0);

        FILL_GDT_ENTRY(1,0xFFFF,0,0,0b10011010,0b11001111,0); //ring0 code
        FILL_GDT_ENTRY(2,0xFFFF,0,0,0b10010010,0b11001111,0); //ring0 data

        FILL_GDT_ENTRY(3,0xFFFF,0,0,0b11111010,0b11001111,0); //ring3 code
        FILL_GDT_ENTRY(4,0xFFFF,0,0,0b11110010,0b11001111,0); //ring3 data
	
	memset(&tss, 0, 104);
	tss.ss0  = 0x10;
        tss.esp0 = KERNELSTACK;
        tss.iopb = 104;

        FILL_GDT_ENTRY(5,104,(unsigned int)(&tss)&0xFFFF, ((unsigned int)(&tss)&0x00FF0000)>>16,0xE9,0x00,((unsigned int)(&tss)&0xFF000000)>>24); //tss

        gdt_ptr.gdt_size = sizeof(gdt) - 1;
        gdt_ptr.gdt_addr = (struct GDT*)&gdt;
	load_gdt((struct GDT*)&gdt_ptr);
        kprint("Loaded GDT.\n", 15);

	asm("mov ax, 0x2b");
	asm("ltr ax");

	kprint("Loaded TSS.\n", 15);
}
