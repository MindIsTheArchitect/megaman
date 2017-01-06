CDC *SPR_Megaman = GRRead("MM");

U0 MMSprite(CDC *SprDC, I64 ScrOffsetX, I64 ScrOffsetY, I64 SprOffsetX, I64 SprOffsetY, I64 SprClipX, I64 SprClipY, I64 SprRev) {
    if (SprRev==0) { GrBlot(Buffer, ScrOffsetX, ScrOffsetY, DCExt(SprDC, SprOffsetX, SprOffsetY, SprClipX, SprClipY)); };
    if (SprRev==1) { GrBlotR(Buffer, ScrOffsetX, ScrOffsetY, DCExt(SprDC, SprOffsetX, SprOffsetY, SprClipX, SprClipY)); };
};