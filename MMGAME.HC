I64 BufferClipX;
I64 BufferClipY;

I64 LFIncr, LMIncr, LYIncr;

I64 MMDeath, MMDeathFlop, MMDeathInit, MMDeathX[13], MMDeathY[13];
I64 MMEnDamage[8], MMEnDir[8], MMEnHealth[8], MMEnInit, MMEnState[8], MMEnType[8], MMEnX[8], MMEnY[8];
I64 MMJump, MMJumpY;
I64 MMHit, MMHitDir, MMHitFlop;
I64 MMInvCtr;
I64 MMInvFlop;
I64 MMProjDir[8], MMProjInit, MMProjX[8], MMProjY[8];
I64 MMX, MMXBound, MMXMax, MMY;
I64 MMAct;
I64 MMCrouch;
I64 MMDir;
I64 MMExit;
I64 MMESCtr;
I64 MMHealth;
I64 MMPixScale;
I64 MMPSCtr;
I64 MMShoot;
I64 MMSlide;
I64 MMState;
I64 MMVBase;

I64 RMIncr, RMFlop;
I64 SysTimerCnt;
I64 TelY;

U8 MMScanCode;

U0 NewEnemy(I64 EnXX, I64 EnYY, I64 EnDamage, I64 EnDir, I64 EnHealth, I64 EnState, I64 EnType) {
    for (MMESCtr=0;MMESCtr<8;MMESCtr++) {
        if (MMEnDir[MMESCtr]==-1) {
            MMEnDamage[MMESCtr] = EnDamage;
            MMEnDir[MMESCtr] = EnDir;
            MMEnHealth[MMESCtr] = EnHealth;
            MMEnState[MMESCtr] = EnState;
            MMEnType[MMESCtr] = EnType;
            MMEnX[MMESCtr] = EnXX;
            MMEnY[MMESCtr] = EnYY;
            break;
        };
    };
};

U0 NewProjectile(I64 ProjXX, I64 ProjYY, I64 ProjDir) {
    for (MMPSCtr=0;MMPSCtr<8;MMPSCtr++) {
        if (MMProjDir[MMPSCtr]==-1) {
            MMProjX[MMPSCtr] = ProjXX;
            MMProjY[MMPSCtr] = ProjYY;
            MMProjDir[MMPSCtr] = ProjDir;
            break;
        };
    };
};

U0 DrawEnemies() {
    for (MMESCtr=0;MMESCtr<8;MMESCtr++) {
        if (MMEnX[MMESCtr]>=BufferClipX && MMEnY[MMESCtr]>=BufferClipY && MMEnX[MMESCtr]<(BufferClipX+640) && MMEnY[MMESCtr]<(BufferClipY+480)) {
            if (MMEnState[MMESCtr]>-1) {
                for (MMPSCtr=0;MMPSCtr<8;MMPSCtr++) {
                    if (MMProjDir[MMPSCtr]>-1) {
                        if(MMProjY[MMPSCtr]>=(MMEnY[MMESCtr]-BufferClipY) && MMProjY[MMPSCtr]+8*3<=(MMEnY[MMESCtr]-BufferClipY)+32*3) {
                            if(MMProjX[MMPSCtr]>=(MMEnX[MMESCtr]-BufferClipX) && MMProjX[MMPSCtr]+8*3<=(MMEnX[MMESCtr]-BufferClipX)+32*3) {
                                Sfx(SFX_ENHIT);
                                MMProjDir[MMPSCtr]=-1;
                                MMEnHealth[MMESCtr] -= 3;
                                if (MMEnHealth[MMESCtr]<1) { MMEnState[MMESCtr]=-1; };
                            };
                        };
                    };
                };
                switch(MMEnType[MMESCtr]) {
                    case 0:
                        switch(MMEnState[MMESCtr]) {
                            case 1:
                            MMSprite(SPR_Evilman, 0, MMEnX[MMESCtr]-BufferClipX, MMEnY[MMESCtr]-BufferClipY, ((32*3)*1), ((32*3)*0), ((32*3)*2)-1, ((32*3)*1)-1, MMEnDir[   MMESCtr]);
                                break;
                            case 2:
                            MMSprite(SPR_Evilman, 0, MMEnX[MMESCtr]-BufferClipX, MMEnY[MMESCtr]-BufferClipY, ((32*3)*2), ((32*3)*0), ((32*3)*3)-1, ((32*3)*1)-1, MMEnDir[   MMESCtr]);
                                break;
                            case 3:
                            MMSprite(SPR_Evilman, 0, MMEnX[MMESCtr]-BufferClipX, MMEnY[MMESCtr]-BufferClipY, ((32*3)*3), ((32*3)*0), ((32*3)*4)-1, ((32*3)*1)-1, MMEnDir[   MMESCtr]);
                                break;
                            case 4:
                            MMSprite(SPR_Evilman, 0, MMEnX[MMESCtr]-BufferClipX, MMEnY[MMESCtr]-BufferClipY, ((32*3)*2), ((32*3)*0), ((32*3)*3)-1, ((32*3)*1)-1, MMEnDir[   MMESCtr]);
                                break;
                        };
                        break;
                };
            };
        };
        if (MMEnState[MMESCtr]>0) {
            switch(MMEnDir[MMESCtr]) {
                case 0:
                    if (MMEnX[MMESCtr] >= 8) { MMEnX[MMESCtr] -= 4; } else { MMEnDir[MMESCtr] = 1; };
                    break;
                case 1:
                    if (MMEnX[MMESCtr] <= MMXMax) { MMEnX[MMESCtr] += 4; } else { MMEnDir[MMESCtr] = 0; };
                    break;
            };
            MMEnState[MMESCtr]++;
            if (MMEnState[MMESCtr]>4) { MMEnState[MMESCtr] = 1; };
        };
    };
};

U0 DrawMMLifeMeter() {
    Buffer->color = BLACK;
    GrRect(Buffer, 48, 32, 8*MMPixScale, 56*MMPixScale);
    Buffer->color = LTGRAY;
    LMIncr = 27*(MMPixScale*2);
    for (LFIncr=0;LFIncr<(MMHealth/2);LFIncr++) {
        for (LYIncr=0;LYIncr<MMPixScale;LYIncr++) {
            GrLine(Buffer, 48+(1*MMPixScale), 32+(LMIncr+LYIncr), 48+(7*MMPixScale), 32+(LMIncr+LYIncr));
        };
        LMIncr -= MMPixScale*2;
    };
    Buffer->color = WHITE;
    LMIncr = 27*(MMPixScale*2);
    for (LFIncr=0;LFIncr<(MMHealth/2);LFIncr++) {
        for (LYIncr=0;LYIncr<MMPixScale;LYIncr++) {
            GrLine(Buffer, 48+(3*MMPixScale), 32+(LMIncr+LYIncr), 48+(5*MMPixScale), 32+(LMIncr+LYIncr));
        };
        LMIncr -= MMPixScale*2;
    };
};

U0 DrawProjectiles() {
    for (MMPSCtr=0;MMPSCtr<8;MMPSCtr++) {
        if (MMProjDir[MMPSCtr]>-1) {
            MMSprite(SPR_Megaman, MMInvFlop, MMProjX[MMPSCtr], MMProjY[MMPSCtr], ((32*0)*0), ((32*3)*3), ((32*0)*3)+24, ((32*3)*3)+24, 0);
            if (MMProjDir[MMPSCtr]==0) { MMProjX[MMPSCtr] -= 32; };
            if (MMProjDir[MMPSCtr]==1) { MMProjX[MMPSCtr] += 32; };
            if (MMProjX[MMPSCtr]>630) { MMProjDir[MMPSCtr] = -1; };
            if (MMProjX[MMPSCtr]<0)   { MMProjDir[MMPSCtr] = -1; };
        };
    };
};

U0 ReadyMsg() {
    RMFlop = 0;
    for (RMIncr=0;RMIncr<24;RMIncr++) {
        UpdateBgr;
        if (RMFlop==0) { Text("READY", 262, 216, WHITE); }
        RMFlop++;
        if (RMFlop>1) { RMFlop = 0; };
        GrUpdateScrn;
        Sleep(60);
    };
};

U0 MMTeleportIn() {
    for (TelY=0;TelY<MMY;TelY+=48) {
        UpdateBgr;
        MMSprite(SPR_Megaman, MMInvFlop, MMX, TelY, ((32*3)*5), ((32*3)*0), ((32*3)*6)-1, ((32*3)*1)-1, MMDir);
        DrawMMLifeMeter;
        GrUpdateScrn;
        Sleep(0);
    };

    Sfx(SFX_MMTELIN);
    UpdateBgr; 
    MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*5), ((32*3)*1)+2, ((32*3)*6)-1, ((32*3)*2)-1, MMDir);
    DrawMMLifeMeter;
    GrUpdateScrn;
    Sleep(0);

    UpdateBgr; 
    MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*5), ((32*3)*2)+2, ((32*3)*6)-1, ((32*3)*3)-1, MMDir);
    DrawMMLifeMeter;
    GrUpdateScrn;
    Sleep(0);

    UpdateBgr; 
    MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*5), ((32*3)*0), ((32*3)*6)-1, ((32*3)*1)-1, MMDir);
    DrawMMLifeMeter;
    GrUpdateScrn;
    Sleep(0);
};

U0 InitGameSettings() {
    BgrIncrX=0;
    BgrIncrY=0;
    BgrMapPosX=0;
    BgrMapPosY=0;
    BgrScrollPosX=0;
    BgrScrollPosY=0;
    BgrState=0;
    BufferClipX = 0;
    BufferClipY = 0;
    MMHealth = 56;
    MMInvCtr = 0;
    MMInvFlop = 0;
    MMDeath = 0;
    MMExit = 0;
    MMCrouch = 0;
    MMState = 1;
    MMAct = 0;
    MMJump = 0;
    MMHit = 0;
    MMHitDir = 0;
    MMHitFlop = 0;
    MMSlide = 0;
    MMShoot = 0;
    MMJumpY = 0;
    MMVBase = 24;
    MMX = 240;
    MMXBound = 300; 
    MMXMax = 1280; 
    MMDir = 1;
    MMPixScale = 3;
    MMY = 311;
    // Clear projectiles.
    for (MMProjInit=0;MMProjInit<8;MMProjInit++) { MMProjX[MMProjInit]=0; MMProjY[MMProjInit]=0; MMProjDir[MMProjInit]=-1; };
    // Clear enemies.
    for (MMEnInit=0;MMEnInit<8;MMEnInit++) { MMEnX[MMEnInit]=0; MMEnY[MMEnInit]=0; MMEnDir[MMEnInit]=-1; MMEnState[MMEnInit]=-1; MMEnHealth[MMEnInit]=-1; };
    // Set Mega Man default state.
    MMState = 1;
    // Spawn some "evil" Mega Men on the playfield.
    NewEnemy(MMX+(16*MMPixScale)+(48*MMPixScale), MMY, 15, 0, 10, 1, 0);
    NewEnemy(MMX+(128*MMPixScale)+(48*MMPixScale), MMY, 15, 0, 10, 1, 0);
};

U0 GameLoop() {
    UpdateBgr;
    ReadyMsg;
    MMTeleportIn;
    while (TRUE) {
        SysTimerCnt=SysTimerRead;
        UpdateBgr;
        DrawProjectiles;
        DrawEnemies;
        if(MMHit<1 && MMDeath==0) {
            for (MMESCtr=0;MMESCtr<8;MMESCtr++) {
                if(MMEnState[MMESCtr]>-1) {
                    if(MMY-MMJumpY>=(MMEnY[MMESCtr]-BufferClipY)-32*1 && (MMY-MMJumpY)+32*3<=(MMEnY[MMESCtr]-BufferClipY)+32*5) {
                        if(MMInvCtr==0 && MMX>=(MMEnX[MMESCtr]-BufferClipX)-32*1 && MMX+32*3<=(MMEnX[MMESCtr]-BufferClipX)+32*5) {
                            MMHit=1;
                            MMHealth -= MMEnDamage[MMESCtr];
                            if (MMHealth>0) { Sfx(SFX_MMHIT); MMInvCtr = 1; MMInvFlop = 0; };
                            if (MMHealth<=0) {
                                for(MMDeathInit=0;MMDeathInit<12;MMDeathInit++) { MMDeathX[MMDeathInit] = MMX; MMDeathY[MMDeathInit] = MMY-MMJumpY; }
                                Sfx(SFX_MMDEATH);
                                MMDeath=1;
                                MMState=99;
                                MMHit=0;
                                MMJump=0;
                                MMShoot=0;
                                MMDeathFlop=0;
                            };
                            MMSlide=0;
                            MMShoot=0;
                            MMHitDir = 0;
                            if (MMDir==1) { MMHitDir=1; };
                        };
                    };
                };
            };
        };
        if (MMDeath>0) {
            for(MMDeathInit=1;MMDeathInit<12;MMDeathInit++) {
                if (MMDeathFlop==0) { MMSprite(SPR_Megaman, MMInvFlop, MMDeathX[MMDeathInit], MMDeathY[MMDeathInit], ((32*3)*1), ((32*3)*3), ((32*3)*2)-1, ((32*3)*4)-1, MMDir); };
                if (MMDeathFlop==1) { MMSprite(SPR_Megaman, MMInvFlop, MMDeathX[MMDeathInit]+8, MMDeathY[MMDeathInit], ((32*3)*2), ((32*3)*3), ((32*3)*3)-1, ((32*3)*4)-1, MMDir); };
                if (MMDeathFlop==2) { MMSprite(SPR_Megaman, MMInvFlop, MMDeathX[MMDeathInit]+8, MMDeathY[MMDeathInit], ((32*3)*3), ((32*3)*3), ((32*3)*4)-1, ((32*3)*4)-1, MMDir); };
                if (MMDeathFlop==3) { MMSprite(SPR_Megaman, MMInvFlop, MMDeathX[MMDeathInit]+8, MMDeathY[MMDeathInit], ((32*3)*4), ((32*3)*3), ((32*3)*5)-1, ((32*3)*4)-1, MMDir); };
            };
            MMDeathX[1] -= 12;
            MMDeathX[2] -= 24;
            MMDeathX[3] += 12;
            MMDeathX[4] += 24;
            MMDeathY[5] -= 12;
            MMDeathY[6] -= 24;
            MMDeathY[7] += 12;
            MMDeathY[8] += 24;
            MMDeathX[9] -= 24;
            MMDeathX[10] -= 24;
            MMDeathX[11] += 24;
            MMDeathX[12] += 24;
            MMDeathY[9] -= 24;
            MMDeathY[10] += 24;
            MMDeathY[11] -= 24;
            MMDeathY[12] += 24;
            MMDeath += 2;
            MMDeathFlop++;
            if(MMDeathFlop>3) {
                MMDeathFlop = 0;
            };
        };
        if(MMHit>0) {
            MMHit += 2;
            if (MMHitDir==0) { MMX += 4; };
            if (MMHitDir==1) { MMX -= 4; };
        };
        if(MMJump>0) { MMJump += 2; };
        if(MMSlide>0) { MMSlide += 2; };
        if(MMShoot>0) {
            if(MMShoot==1) {
                if (MMDir==0) { NewProjectile(MMX+(16*MMPixScale)-(12*MMPixScale), ((MMY-MMJumpY)+(3*MMPixScale)+(8*MMPixScale))-8, MMDir); };
                if (MMDir==1) { NewProjectile(MMX+(16*MMPixScale)+(12*MMPixScale), ((MMY-MMJumpY)+(3*MMPixScale)+(8*MMPixScale))-8, MMDir); };
            };
            MMShoot += 1;
        };
        if(MMShoot>4) { MMShoot = 0; if(MMState==0) { MMState = 1; }; };
        if(MMJump>1) { MMJumpY = MMVBase * MMJump; };
        if(MMJump>8) { MMJumpY = (MMVBase * 8) + ((MMVBase * 8) - (MMVBase * MMJump)); };
        if(MMJump>16) { MMJump = 0; MMJumpY = 0; if(MMState==0) { MMState = 1; }; };
        if(MMState>9 & MMState<14) {

            // if (MMDir==0) { if (MMX>MMVBase) { MMX -= (MMVBase+(MMSlide*2)); }; };
            // if (MMDir==1) { if (MMX<500) { MMX += (MMVBase+(MMSlide*2)); }; };

            if (MMDir==0) {
                if(MMX>MMXBound) { MMX -= (MMVBase+(MMSlide*2)); };
                if(MMX<=MMXBound && BufferClipX>0) { BufferClipX -= (MMVBase+(MMSlide*2)); BgrScrollPosX -= 12; };
                if(MMX<=MMXBound && BufferClipX<=0 && MMX>0) { MMX -= (MMVBase+(MMSlide*2)); };
            };

            if (MMDir==1) {
                if(MMX<MMXBound) { MMX += (MMVBase+(MMSlide*2)); };
                if(MMX>=MMXBound && BufferClipX<MMXMax) { BufferClipX += (MMVBase+(MMSlide*2)); BgrScrollPosX += 12; };
                if(MMX>=MMXBound && BufferClipX>=MMXMax && MMX < 520) { MMX += (MMVBase+(MMSlide*2)); };
            };

        };
        if (MMJump>0) {
            if(MMShoot==0) {  MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*4), ((32*3)*0), ((32*3)*5)-1, ((32*3)*1)-1, MMDir); };
            if(MMShoot>0) {   MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*4), ((32*3)*1), ((32*3)*5)-1, ((32*3)*2)-1, MMDir); };
        };
        if (MMSlide>0) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY-12, ((32*3)*0), ((32*3)*2), ((32*3)*1)-1, ((32*3)*3)-1, MMDir); };
        if(MMSlide>12) { MMSlide = 0; if(MMState==0) { MMState = 1; }; };
        if (MMHit>0) {
            MMHitFlop++;
            if (MMHitFlop==1) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY-12, ((32*3)*3), ((32*3)*2), ((32*3)*4)-1, ((32*3)*3)-1, MMDir); }
            if (MMHitFlop==2) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY-12, ((32*3)*4), ((32*3)*2), ((32*3)*5)-1, ((32*3)*3)-1, MMDir); }
            if (MMHitFlop>2) { MMHitFlop = 0; };
        };
        if (MMHit>12) { MMHit = 0; if(MMState==0) { MMState = 1; }; };
        if (MMDeath>128) { break; };
        if (MMJump==0 && MMSlide==0 && MMHit==0  && MMDeath==0) {
            if (MMState<10) { if (MMShoot>0) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*0), ((32*3)*1), ((32*3)*1)-1, ((32*3)*2)-1, MMDir); }; };
            if (MMState==12) {
                if (MMShoot==0) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*3), ((32*3)*0), ((32*3)*4)-1, ((32*3)*1)-1, MMDir); };
                if (MMShoot>0)  { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*3), ((32*3)*1), ((32*3)*4)-1, ((32*3)*2)-1, MMDir); };
                MMState = 13;
            };
            if (MMState==11) {
                if (MMShoot==0) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*2), ((32*3)*0), ((32*3)*3)-1, ((32*3)*1)-1, MMDir); };
                if (MMShoot>0)  { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*2), ((32*3)*1), ((32*3)*3)-1, ((32*3)*2)-1, MMDir); };
                MMState = 12;
            };
            if (MMState==10) {
                if (MMShoot==0) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*1), ((32*3)*0), ((32*3)*2)-1, ((32*3)*1)-1, MMDir); };
                if (MMShoot>0)  { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*1), ((32*3)*1), ((32*3)*2)-1, ((32*3)*2)-1, MMDir); };
                MMState = 11;
            };
            if (MMState==0) {
                if (MMShoot==0) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*0), ((32*3)*0), ((32*3)*1)-1, ((32*3)*1)-1, MMDir); };
                MMState = 0;
            };
            if (MMState==1) {
                if (MMShoot==0) { MMSprite(SPR_Megaman, MMInvFlop, MMX, MMY-MMJumpY, ((32*3)*0), ((32*3)*0), ((32*3)*1)-1, ((32*3)*1)-1, MMDir); };
                MMState = 0;
            };
            if (MMState==13) {
                if (MMAct==1) { MMState = 10; };
                if (MMAct==0) { MMState = 1; };
            };
        };
        MMAct = 0;
        MMScanCode = InU8(0x60);
        if (MMScanCode==0x01) { MMExit = 1; break; };
        if (MMScanCode==0x1d) {
            if (MMSlide==0 && MMHit==0 && MMDeath==0) {
                MMAct = 1;
                if (MMShoot==0) {  MMShoot = 1; Sfx(SFX_MMSHOT); }
            };
        };
        if (MMScanCode==0x38 && MMDeath==0) {
            MMAct = 1;
            if(MMCrouch==1) {
                if (MMSlide==0 && MMHit==0 && MMDeath==0) { if(MMJump==0) { MMSlide = 1; MMState=10; }; };
            };
            if(MMCrouch==0) {
                if (MMJump==0) { if(MMSlide==0 && MMHit==0 && MMDeath==0) { MMJump = 1; Sfx(SFX_MMJUMP); }; };
            };
        };
        if (MMScanCode==0x4b && MMDeath==0) {
            MMAct = 1;
            MMDir = 0;
            if (MMState<10) { MMState = 10; };
        };
        if (MMScanCode==0x4d && MMDeath==0) {
            MMAct = 1;
            MMDir = 1;
            if (MMState<10) { MMState = 10; };
        };
        if (MMAct == 0) { if (MMState>15) { MMState = 1; } };
        MMCrouch = 0;
        if (MMScanCode==0x50 && MMDeath==0) {
            MMCrouch = 1;
        };
        if (MMInvCtr>0) {
            MMInvCtr++;
            MMInvFlop++;
            if (MMInvFlop>1) { MMInvFlop = 0; };
        };
        if (MMInvCtr>48) { MMInvCtr = 0; MMInvFlop = 0; };
        DrawMMLifeMeter;
        GrUpdateScrn;
        while (SysTimerRead<SysTimerCnt+60000) {
            Sleep(0);
        };
    };
};

// Start Application.
U0 MegaMan() {
    LoadSprites;
    MMExit = 0;
    SettingsPush;
    WinMax;
    AutoComplete;
    DocCursor;
    WinBorder;
    MsSet(639,479,0);
    GameSetPalette;
    DCFill(Buffer,BLACK);
    MMSprite(SPR_Logo, 0, 48, 48, 0, 0, 545, 167, 0);
    Text("   PRESS ENTER KEY", 64, 256, WHITE);
    PressAKey;
    while (MMExit==0) {
        InitGameSettings;
        DCFill(Buffer,BLACK);
        GameLoop;
        // BgrTileTest;
        GrUpdateScrn;
        // PressAKey;
        // MMExit = 1;
    };
    // Exit game.
    FreeSprites;
    PaletteSetStd;
    DCFill(DCAlias(),TRANSPARENT);
    GrUpdateScrn;
    DocClear;
    SettingsPop;
};