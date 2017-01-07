CDC *SPR_Evilman; 
CDC *SPR_Megaman;
CDC *SprClip;

U0 LoadSprites() {
	SPR_Evilman = GRRead("MM");
	SPR_Megaman = GRRead("MM");
	DCColorChg(SPR_Evilman, BLUE, RED);
	DCColorChg(SPR_Evilman, LTCYAN, LTRED);
};

U0 FreeSprites() {
	DCDel(SPR_Evilman);
	DCDel(SPR_Megaman);
};

U0 MMSprite(CDC *SprDC, I64 ScrOffsetX, I64 ScrOffsetY, I64 SprOffsetX, I64 SprOffsetY, I64 SprClipX, I64 SprClipY, I64 SprDir) {
	SprClip = DCExt(SprDC, SprOffsetX, SprOffsetY, SprClipX, SprClipY);
	if (SprDir==0) { GrBlot(Buffer, ScrOffsetX, ScrOffsetY, SprClip); };
    if (SprDir==1) { GrBlotR(Buffer, ScrOffsetX, ScrOffsetY, SprClip); };
    DCDel(SprClip);
};
