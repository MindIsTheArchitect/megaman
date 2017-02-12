Bool MM_EDIT_MODE = FALSE;
CDC *Buffer = DCAlias();
CDC *BgrImage = GRRead("BG1.GR.Z");
CDC *BgrMap = GRRead("LEVEL.LVL.Z");
CDC *BgrLayer = DCNew(640, 480);

I64 PtrMsGrab, PtrMsStd;
U8 ScanCode;

PtrMsGrab = *gr.fp_draw_grab_ms;
PtrMsStd = *gr.fp_draw_ms;

#include "GRBLOTR";

#include "MMFONT";
#include "MMPALETTE";
#include "MMSOUND";
#include "MMSPRITE";
#include "MMBG";

U0 HideMs() { MsSet(639,479,0); };

#include "MMGAME";
