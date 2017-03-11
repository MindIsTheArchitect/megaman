
Adam("Bool PCSP_EXIT=FALSE;");
Adam("Bool PCSP_PLAY=FALSE;");

Adam("I64 PCM_LEN=0;");
Adam("I64 PCM_OFS=0;");
Adam("I64 PCM_POS=0;");
Adam("U8 PCM_TABLE[1048576];");

Adam("I64 SFX_NEXT=0x10;");
Adam("I64 SFX_OFS[0x3F];");
Adam("I64 SFX_LEN[0x3F];");

// 0x40
#define MUS_STOP 		0x00
#define MUS_DEMO	 	0x01

// 0x54
#define SFX_MMTELIN 	0x10
#define SFX_MMSHOT		0x11
#define SFX_MMJUMP 		0x12
#define SFX_MMHIT 		0x13
#define SFX_MMDEATH		0x14
#define SFX_ENHIT		0x15

SFX_OFS[9]=0;
SFX_LEN[9]=0;

U0 PCSP()
{
  I64 delay_loop;
  I64 sample_rate=16000;
  while (PCSP_EXIT==FALSE) {
  	while (PCSP_PLAY==TRUE) {
      while (PCM_POS < PCM_OFS+PCM_LEN) {
  	    Snd(PCM_TABLE[PCM_POS]*2);
	    PCM_POS++;
	    Sleep(0);
	    delay_loop=0;
	    while (delay_loop<sample_rate/((sample_rate*3) / 100)) {
          RDTSC
          delay_loop++;
        };	  
  	  };
  	  if (PCM_POS > (PCM_OFS+PCM_LEN)-1) {
  	    PCM_POS=0;
  	    PCM_OFS=0;
  	    PCM_LEN=0;
  	    PCSP_PLAY=FALSE;
  	  };
  	};
  	Sleep(0);
  };
};

U0 Sfx_PCSP(U8 _Snd)
{
  if (_Snd>0x0F) {
  	PCSP_PLAY=FALSE;
  	PCM_OFS=SFX_OFS[_Snd];
  	PCM_LEN=SFX_LEN[_Snd];
  	PCM_POS=PCM_OFS;
  	PCSP_PLAY=TRUE;
  };
};

U0 Sfx(U8 _Snd)
{
  Sfx_PCSP(_Snd);
};

U0 LoadSfx(U8 *sfx_file)
{
  CDirEntry *de = FilesFind(sfx_file);
  U8 *sfx_buffer = FileRead(de->full_name, de->size);
  MemCpy(PCM_TABLE+(SFX_OFS[SFX_NEXT-1]+SFX_LEN[SFX_NEXT-1]),sfx_buffer,de->size);
  SFX_OFS[SFX_NEXT]=(SFX_OFS[SFX_NEXT-1]+SFX_LEN[SFX_NEXT-1]);
  SFX_LEN[SFX_NEXT]=de->size;
  SFX_NEXT++;
  Free(sfx_buffer);
  DirEntryDel(de); 
};

LoadSfx("SFX_MMTELIN.RAW");
LoadSfx("SFX_MMSHOT.RAW");
LoadSfx("SFX_MMJUMP.RAW");
LoadSfx("SFX_MMHIT.RAW");
LoadSfx("SFX_MMDEATH.RAW");
LoadSfx("SFX_ENHIT.RAW");
