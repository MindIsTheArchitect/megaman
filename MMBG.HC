I64 BgrIncrX, BgrIncrY;
I64 BgrState;
I64 BgrMapStartPosY, BgrMapPosX, BgrMapPosY;
I64 BgrScrollPosX, BgrScrollPosY;
U8 *BgrMap[20];
BgrMap[00] = "........................................................................................................";
BgrMap[01] = "........................................................................................................";
BgrMap[02] = "........................................................................................................";
BgrMap[03] = "........................................................................................................";
BgrMap[04] = "........................................................................................................";
BgrMap[05] = "..=====.=====.==.==.====..=.....=====..===...====.......................................................";
BgrMap[06] = "....=...=.....=====.=...=.=.....=.....=...=.=...........................................................";
BgrMap[07] = "....=...===...=.=.=.====..=.....===...=...=..===........................................................";
BgrMap[08] = "....=...=.....=...=.=.....=.....=.....=...=.....=.................h246668:..............................";
BgrMap[09] = "....=...=====.=...=.=.....=====.=====..===..====..................H1355579..............................";
BgrMap[10] = "..................................................................H1355579..............................";
BgrMap[11] = "..................................................................H1355579..............................";
BgrMap[12] = "0000000000000000000000....000000000000000000000000000000000000000000000000000000000000000000000000000000";
BgrMap[13] = "0000000000000000000000....000000000000000000000000000000000000000000000000000000000000000000000000000000";
BgrMap[14] = "........................................................................................................";
BgrMap[15] = "........................................................................................................";
BgrMap[16] = "........................................................................................................";
BgrMap[17] = "........................................................................................................";
BgrMap[18] = "........................................................................................................";
BgrMap[19] = "........................................................................................................";
U16 GetTilesAdj(I64 _xx, I64 _yy, I64 _dir) {
    I64 TileIncr, TileH, TileL, TileZ;
    TileIncr = 0;
    TileZ = _yy;
    if (_dir==1) { _xx += 48; };
    while (TileZ<0) { TileZ += 48; TileIncr++; };
    TileH = BgrMap[((BgrScrollPosY+TileZ) / 48)+0+BgrMapStartPosY-TileIncr][(BgrScrollPosX+_xx) / 48];
    TileL = BgrMap[((BgrScrollPosY+TileZ) / 48)+1+BgrMapStartPosY-TileIncr][(BgrScrollPosX+_xx) / 48];
    return (TileH * 256) + TileL;
};
U16 GetTilesBot(I64 _xx, I64 _yy) {
    I64 TileIncr, TileH, TileL, TileZ;
    TileIncr = 0;
    TileZ = _yy;
    while (TileZ<0) { TileZ += 48; TileIncr++; };
    TileH = BgrMap[((BgrScrollPosY+TileZ) / 48)+2+BgrMapStartPosY-TileIncr][(BgrScrollPosX+_xx) / 48];
    TileL = BgrMap[((BgrScrollPosY+TileZ) / 48)+2+BgrMapStartPosY-TileIncr][((BgrScrollPosX+_xx) / 48)+1];
    return (TileH * 256) + TileL;
};
U16 GetTilesTop(I64 _xx, I64 _yy) {
    I64 TileIncr, TileH, TileL, TileZ;
    TileIncr = 0;
    TileZ = _yy;
    while (TileZ<0) { TileZ += 48; TileIncr++; };
    TileH = BgrMap[((BgrScrollPosY+TileZ) / 48)-1+BgrMapStartPosY-TileIncr][(BgrScrollPosX+_xx) / 48];
    TileL = BgrMap[((BgrScrollPosY+TileZ) / 48)-1+BgrMapStartPosY-TileIncr][((BgrScrollPosX+_xx) / 48)+1];
    return (TileH * 256) + TileL;
};

I64 AlignToLadderTile(I64 _xx, I64 _yy) {
    I64 TileIncr, TileH, TileL, TileZ, LTXX, LTIX, LTIY;
    LTXX = -1;
    LTIX = -1;
    LTIY = -1;
    TileIncr = 0;
    TileZ = _yy;
    while (TileZ<0) { TileZ += 48; TileIncr++; };
    TileH = BgrMap[((BgrScrollPosY+TileZ) / 48)-1+BgrMapStartPosY-TileIncr][(BgrScrollPosX+_xx) / 48];
    TileL = BgrMap[((BgrScrollPosY+TileZ) / 48)-1+BgrMapStartPosY-TileIncr][((BgrScrollPosX+_xx) / 48)+1];
    if (TileH==0x48) {
        LTIY = ((BgrScrollPosY+TileZ) / 48)-1+BgrMapStartPosY-TileIncr;
        LTIX = (BgrScrollPosX+_xx) / 48;
    };
    if (TileL==0x48) {
        LTIY = ((BgrScrollPosY+TileZ) / 48)-1+BgrMapStartPosY-TileIncr;
        LTIX = ((BgrScrollPosX+_xx) / 48)+1;
    };
    if (LTIX>-1) {
        BgrIncrX=0;
        BgrIncrY=0;
        BgrMapPosX=BgrScrollPosX/48;
        BgrMapPosY=BgrMapStartPosY;
        while (BgrIncrY<(48*20)) {
            BgrIncrX = 0;
            while (BgrIncrX<(48*26)) {
                if (BgrMapPosY==LTIY && BgrMapPosX==LTIX) { return BgrIncrX - (BgrScrollPosX % 48); };
                BgrIncrX += 48;
                BgrMapPosX++;
                if (BgrMapPosX>(BgrScrollPosX/48)+25) {
                    BgrMapPosX = BgrScrollPosX/48;
                    BgrMapPosY++;
                };
            };
        BgrIncrY += 48;
        };
    };
    return LTXX;
};

U0 FreeBgrs() {
	Free(BgrMap);
};

U0 UpdateBgr() {
    BgrIncrX=0;
    BgrIncrY=0;
    BgrMapPosX=BgrScrollPosX/48;
    BgrMapPosY=BgrMapStartPosY;
    DCFill(Buffer, DKGRAY);
    while (BgrIncrY<(48*20)) {
        BgrIncrX = 0;
        while (BgrIncrX<(48*26)) {
            switch (BgrMap[BgrMapPosY][BgrMapPosX]) {
                // Ground tiles
                case 0x30:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 255, 0, 255+47, 0+47, 0);
                break;
                // Jump-through blocks
                case 0x3D:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 455, 0, 455+47, 0+47, 0);
                break;
                // Left1stPanel
                case 0x31:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 0, 51, 0+47, 51+47, 0);
                break;
                // TopLeft1stPanel
                case 0x32:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 0, 0, 0+47, 0+47, 0);
                break;
                // Left2ndPanel
                case 0x33:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 51, 51, 51+47, 51+47, 0);
                break;
                // TopLeft2ndPanel
                case 0x34:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 51, 0, 51+47, 0+47, 0);
                break;
                // MidPanel
                case 0x35:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 102, 51, 102+47, 51+47, 0);
                break;
                // TopMidPanel
                case 0x36:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 102, 0, 102+47, 0+47, 0);
                break;
                // Right2ndPanel
                case 0x37:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 153, 51, 153+47, 51+47, 0);
                break;
                // TopRight2ndPanel
                case 0x38:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 153, 0, 153+47, 0+47, 0);
                break;
                // Right1stPanel
                case 0x39:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 204, 51, 204+47, 51+47, 0);
                break;
                // TopRight1stPanel
                case 0x3A:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 204, 0, 204+47, 0+47, 0);
                break;
                // Ladder
                case 0x48:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 0, 204, 0+47, 204+47, 0);
                break;
                // Ladder (top, can stand on)
                case 0x68:
                MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 0, 204, 0+47, 204+47, 0);
                break;
            };
            BgrIncrX += 48;
            BgrMapPosX++;
            if (BgrMapPosX>(BgrScrollPosX/48)+25) {
                BgrMapPosX = BgrScrollPosX/48;
                BgrMapPosY++;
            };
        };
        BgrIncrY += 48;
    };
};