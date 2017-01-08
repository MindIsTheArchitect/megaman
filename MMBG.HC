I64 BgrState;
I64 BgrIncrS, BgrIncrX, BgrIncrY;

BgrIncrS=0;
BgrState=0;

U0 UpdateBgr() {
    if (BgrIncrS>24) { BgrIncrS -= 24; };
    if (BgrIncrS<0) { BgrIncrS += 24; };
    DCFill(Buffer, DKGRAY);
    for (BgrIncrY=480-(24*4);BgrIncrY<480;BgrIncrY += 24) {
        for (BgrIncrX=-48;BgrIncrX<640+48;BgrIncrX += 24) {
            MMSprite(SPR_Tiles, 0, BgrIncrX+BgrIncrS, BgrIncrY, 255, 0, 255+47, 0+47, 0);
        };
    };
};