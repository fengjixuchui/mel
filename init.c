void user_test(void) __attribute__((section(".ring3")));

// This is the first program to be runned in usermode.

void user_test(void)
{
	asm("mov edi, 1");
	asm("int 0x30");
	asm("jmp $");
}
