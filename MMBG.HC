I64 BgrIncrX, BgrIncrY;
I64 BgrState;
I64 BgrMapStartPosY, BgrMapPosX, BgrMapPosY;
I64 BgrScrollPosX, BgrScrollPosY;
U8 *BgrMap[20];

BgrMap[00] = "....................................................";
BgrMap[01] = "....................................................";
BgrMap[02] = "....................................................";
BgrMap[03] = "....................................................";
BgrMap[04] = "....................................................";
BgrMap[05] = "..=====.=====.==.==.====..=.....=====..===...====...";
BgrMap[06] = "....=...=.....=====.=...=.=.....=.....=...=.=.......";
BgrMap[07] = "....=...===...=.=.=.====..=.....===...=...=..===....";
BgrMap[08] = "....=...=.....=...=.=.....=.....=.....=...=.....=...";
BgrMap[09] = "....=...=====.=...=.=.....=====.=====..===..====....";
BgrMap[10] = "....................................................";
BgrMap[11] = "....................................................";
BgrMap[12] = "0000000000000000000000....00000000000000000000000000";
BgrMap[13] = "0000000000000000000000....00000000000000000000000000";
BgrMap[14] = "....................................................";
BgrMap[15] = "....................................................";
BgrMap[16] = "....................................................";
BgrMap[17] = "....................................................";
BgrMap[18] = "....................................................";
BgrMap[19] = "....................................................";

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
				case 0x30:
					MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 255, 0, 255+47, 0+47, 0);
					break;
				case 0x3D:
					MMSprite(SPR_Tiles, 0, BgrIncrX - (BgrScrollPosX % 48), BgrIncrY, 455, 0, 455+47, 0+47, 0);
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