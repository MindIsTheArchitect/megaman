CDC *MMFont = GRRead("FONT");
CDC *FontClip;
I64 TextOffset, MMFontOffsetX, MMFontOffsetY, ScrOffsetIncr;

U0 Text(U8 *_Text, I64 ScrOffsetX, I64 ScrOffsetY, I64 _Color) {
    ScrOffsetIncr = 0;
    if (_Color != WHITE) { DCColorChg(MMFont, WHITE, _Color); };
    for (TextOffset=0; _Text[TextOffset] != 0x0; TextOffset++) {
        MMFontOffsetX = 616;
        MMFontOffsetY = 184;
        // Numeric
        if(_Text[TextOffset]>0x29 && _Text[TextOffset]<0x40) { MMFontOffsetX = 24*(_Text[TextOffset]-0x30); MMFontOffsetY = 0; };
        if(_Text[TextOffset]>0x33 && _Text[TextOffset]<0x38) { MMFontOffsetX += 2; };
        if(_Text[TextOffset]>0x37 && _Text[TextOffset]<0x40) { MMFontOffsetX += 5; };
        // Alpha
        if(_Text[TextOffset]>0x40 && _Text[TextOffset]<0x5B) { MMFontOffsetX = 24*(_Text[TextOffset]-0x41); MMFontOffsetY = 27; };
        if(_Text[TextOffset]>0x51 && _Text[TextOffset]<0x5B) { MMFontOffsetX += 2; };
        FontClip = DCExt(MMFont, MMFontOffsetX, MMFontOffsetY, MMFontOffsetX+23, MMFontOffsetY+23);
        GrBlot(Buffer, ScrOffsetX+ScrOffsetIncr, ScrOffsetY, FontClip);
        DCDel(FontClip);
        ScrOffsetIncr += 24;
    };
    if (_Color != WHITE) { DCColorChg(MMFont, _Color, WHITE); };
};