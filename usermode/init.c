void user_test(void) __attribute__((section(".ring3")));

void user_test(void)
{
	asm("int 0x30");
	asm("jmp $");
}
