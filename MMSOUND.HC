#define MUS_STOP 		0x40
#define MUS_DEMO	 	0x41

#define SFX_MMTELIN 	0x54
#define SFX_MMSHOT		0x55
#define SFX_MMJUMP 		0x56
#define SFX_MMHIT 		0x57
#define SFX_MMDEATH		0x58
#define SFX_ENHIT		0x59

U0 Sfx(U8 _Snd) {
	OutU8(0x03F8, _Snd);
};
