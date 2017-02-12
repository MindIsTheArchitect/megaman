Bool MM_EDIT_MODE = TRUE;
CDC *Buffer = DCAlias();
CDC *BgrImage = DCNew(0, 0);
CDC *BgrMap = DCNew(512, 512);
CDC *BgrLayer = DCNew(0, 0);

I64 PtrMsGrab, PtrMsStd;
I64 TxtB, TxtH, TxtL;
U8 ScanCode;
U8 Tile;
U8 TileOptC;
U8 TileOptM;
U8 *TileOpt = ".0=H123456789:hME~";

PtrMsGrab = *gr.fp_draw_grab_ms;
PtrMsStd = *gr.fp_draw_ms;

TileOptC = 0x0;
TileOptM = 0x0;
while (TileOpt[TileOptM] != 0x0) { TileOptM++; };

#include "GRBLOTR";

#include "MMFONT";
#include "MMPALETTE";
#include "MMSPRITE";
#include "MMBG";

U0 HideMs() {};

U8 H2N16(U8 _hb) {
    U8 *h2n_word;
    U8 *h2n_chars = "0123456789ABCDEF";
    h2n_word[0] = h2n_chars[_hb];
    h2n_word[1] = 0x0;
    return h2n_word;
};

U0 InitEditorSettings() {
    BgrIncrX=0;
    BgrIncrY=0;
    BgrMapPosX=0;
    BgrMapPosY=0;
    BgrMapStartPosY=0;
    BgrScrollPosX=0;
    BgrScrollPosY=0;
    BgrState=0;
};

U0 LvlEdit(U8 *BgrMapFile = "") {
	if (BgrMapFile[0]==0x0) {
		DCFill(BgrMap, 0x2E);
		BgrMapFile = "LEVEL.LVL.Z";
	}
	else {
		BgrMap = GRRead(BgrMapFile);
	};
    LoadSprites;
    SettingsPush;
    WinMax;
    AutoComplete;
    DocCursor;
    WinBorder;
    GameSetPalette;

    InitEditorSettings;
    *gr.fp_draw_grab_ms = &HideMs;
    *gr.fp_draw_ms = &HideMs;

    ScanCode = InU8(0x60);
    while (ScanCode != 0x01) {
    	UpdateBgr;
    	switch(TileOpt[TileOptC]) {
            // Ground tiles
            case 0x30:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 255, 0, 255+47, 0+47, 0);
            break;
            // Jump-through blocks
            case 0x3D:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 455, 0, 455+47, 0+47, 0);
            break;
            // Left1stPanel
            case 0x31:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 0, 51, 0+47, 51+47, 0);
            break;
            // TopLeft1stPanel
            case 0x32:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 0, 0, 0+47, 0+47, 0);
            break;
            // Left2ndPanel
            case 0x33:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 51, 51, 51+47, 51+47, 0);
            break;
            // TopLeft2ndPanel
            case 0x34:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 51, 0, 51+47, 0+47, 0);
            break;
            // MidPanel
            case 0x35:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 102, 51, 102+47, 51+47, 0);
            break;
            // TopMidPanel
            case 0x36:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 102, 0, 102+47, 0+47, 0);
            break;
            // Right2ndPanel
            case 0x37:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 153, 51, 153+47, 51+47, 0);
            break;
            // TopRight2ndPanel
            case 0x38:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 153, 0, 153+47, 0+47, 0);
            break;
            // Right1stPanel
            case 0x39:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 204, 51, 204+47, 51+47, 0);
            break;
            // TopRight1stPanel
            case 0x3A:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 204, 0, 204+47, 0+47, 0);
            break;
            // Ladder
            case 0x48:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 0, 204, 0+47, 204+47, 0);
            break;
            // Ladder (top, can stand on)
            case 0x68:
            MMSprite(SPR_Tiles, 0, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 0, 204, 0+47, 204+47, 0);
            break;
            // Bottom of pit (death, not screen transition)
            case 0x7E:
            Buffer->color=RED;
            GrRect(Buffer, 48*(ms.pos.x/48), 48*(ms.pos.y/48), 48, 48);
            break;

    	};
    	Buffer->color=WHITE;
    	GrHLine(Buffer, 48*(ms.pos.x/48), (48*(ms.pos.x/48))+47, 48*(ms.pos.y/48));
    	GrHLine(Buffer, 48*(ms.pos.x/48), (48*(ms.pos.x/48))+47, 48*(ms.pos.y/48)+47);
    	GrVLine(Buffer, 48*(ms.pos.x/48), 48*(ms.pos.y/48), (48*(ms.pos.y/48))+47);
    	GrVLine(Buffer, 48*(ms.pos.x/48)+47, 48*(ms.pos.y/48), (48*(ms.pos.y/48))+47);

    	ScanCode = InU8(0x60);

    	switch(ScanCode) {

    		case 0x1C:
    			BgrMap->color=TileOpt[TileOptC];
    			GrPlot(BgrMap, (BgrScrollPosX/48)+(ms.pos.x/48), (BgrScrollPosY/48)+(ms.pos.y/48));
    			break;
    		case 0x0E:
    			BgrMap->color=0x2E;
    			GrPlot(BgrMap, (BgrScrollPosX/48)+(ms.pos.x/48), (BgrScrollPosY/48)+(ms.pos.y/48));
    			break;

    		case 0x1D:
    			if (TileOptC>0) { TileOptC--; };
    			break;
    		case 0x38:
    			if (TileOptC<TileOptM) { TileOptC++; };
    			break;

    		case 0x4B:
    			if (BgrScrollPosX>0) { BgrScrollPosX -= 48; };
    			break;
    		case 0x4D:
    			if (BgrScrollPosX<((511-26)*48)) { BgrScrollPosX += 48; };
    			break;
    		case 0x48:
    			if (BgrScrollPosY>0) { BgrScrollPosY -= 48; };
    			break;
    		case 0x50:
    			if (BgrScrollPosY<((511-20)*48)) { BgrScrollPosY += 48; };
    			break;
    	};

    	TxtB = (BgrScrollPosX/48) / 256; TxtH = TxtB / 16; TxtL = TxtB & 0x0F;
    	Text("MX", 25, 25, WHITE);
    	Text(H2N16(TxtH), 75, 25, WHITE);
    	Text(H2N16(TxtL), 100, 25, WHITE);
    	TxtB = (BgrScrollPosX/48) & 0xFF; TxtH = TxtB / 16; TxtL = TxtB & 0x0F;
    	Text(H2N16(TxtH), 125, 25, WHITE);
    	Text(H2N16(TxtL), 150, 25, WHITE);

    	TxtB = (BgrScrollPosY/48) / 256; TxtH = TxtB / 16; TxtL = TxtB & 0x0F;
    	Text("MY", 25, 50, WHITE);
    	Text(H2N16(TxtH), 75, 50, WHITE);
    	Text(H2N16(TxtL), 100, 50, WHITE);
    	TxtB = (BgrScrollPosY/48) & 0xFF; TxtH = TxtB / 16; TxtL = TxtB & 0x0F;
    	Text(H2N16(TxtH), 125, 50, WHITE);
    	Text(H2N16(TxtL), 150, 50, WHITE);

    	GrUpdateScrn;
    	Sleep(50);
    };
    GRWrite("LEVEL.LVL.Z",BgrMap);
    *gr.fp_draw_grab_ms = PtrMsGrab;
    *gr.fp_draw_ms = PtrMsStd;
    FreeBgrs;
    FreeSprites;
    PaletteSetStd;
    DCFill(Buffer,TRANSPARENT);
    GrUpdateScrn;
    DocClear;
    SettingsPop;
};

