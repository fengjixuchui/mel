int ktype = 0;

unsigned char read_keyboard()
{
        unsigned char read;
        do {
                read = input(0x64);
        } while (!(read & 1));
        read = input(0x60); 
        return read;
}

unsigned char read_wait(){
        char read;
        while (1)
        {
                read = input(0x60);
                if (read > 0) return read;
        }
}
extern char azerty2c(int keycode, int maj);

char k2ascii(int keycode, int maj)
{
	switch(ktype)
	{
		case 0: return azerty2c(keycode, maj); break;
	}
}
