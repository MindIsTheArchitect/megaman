I64 BgrState;
BgrState=0;

U0 UpdateBgr() {
    I64 DocIncr;
    switch(BgrState) {
        case 0:
        DocClear;
        DocTop;
        Print("$BG,BLUE$");
        for (DocIncr=0;DocIncr<48;DocIncr++) {
            Print("\n");
        };
        Print("$BG,BROWN$");
        for (DocIncr=0;DocIncr<12;DocIncr++) {
            Print("\n");
        };
        break;
    };
    BgrState++;
};