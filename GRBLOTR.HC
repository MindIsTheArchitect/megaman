public I64 GrBlotR(CDC *dc=gr.dc,I64 x,I64 y,CDC *img)
{//2D. Clipping but not transformation..
    I64 i,j,k,k1,kk,kk1,w1,h1,w2,h2,dist,
    leading_pixels,leading_pixel_mask,whole_I64s,
    trailing_pixels,trailing_pixel_mask,
    reg bit_shift,win_z_buf_line_inc,win_z_buf_line_dec,win_z_num,
    color_mask;
    U8 reg *dst,*src;
    I32 *db;
    U16 reg *win_z_buf_ptr;
    CColorROPU32 color,c,old_color;
    CTask *win_task;
    if (dc->flags & DCF_SCRN_BITMAP) {
        win_task=dc->win_task;
        x+=win_task->scroll_x;
        y+=win_task->scroll_y;
    }
    if (x<0)
    w1=-x;
    else
    w1=0;
    if (y<0)
    h1=-y;
    else
    h1=0;
    w2=img->width;
    h2=img->height;
    if (dc->flags & DCF_SCRN_BITMAP) {
        x+=win_task->pix_left;
        y+=win_task->pix_top;
    }
    if (dc->flags & DCF_LOCATE_NEAREST) {
        dist=DistSqrI64(x+img->width>>1,y+img->height>>1,dc->cur_x,dc->cur_y);
        if (dist<=dc->nearest_dist)
        dc->nearest_dist=dist;
    }
    if (dc->flags & DCF_SCRN_BITMAP) {
        if (x+w1<0) w1=-x;
        if (x+w2>win_task->pix_right+1)
        w2=win_task->pix_right+1-x;
        if (y+h1<0) h1=-y;
        if (y+h2>win_task->pix_bottom+1)
        h2=win_task->pix_bottom+1-y;
    }
    if (x+w2>dc->width)
    w2=dc->width-x;
    if (y+h2>dc->height)
    h2=dc->height-y;
    if (w1<w2<=img->width && h1<h2<=img->height) {
        if (dc->flags & DCF_RECORD_EXTENTS) {
            if (x+w1<dc->min_x) dc->min_x=x+w1;
            if (x+w2-1>dc->max_x) dc->max_x=x+w2-1;
            if (y+h1<dc->min_y) dc->min_y=y+h1;
            if (y+h2-1>dc->max_y) dc->max_y=y+h2-1;
        }
        if (dc->flags & DCF_DONT_DRAW)
        return 1;
        old_color=dc->color;
        db=dc->depth_buf;
        dc->depth_buf=NULL;
        dc->color&=~ROPF_DITHER;
        color=dc->color;
        leading_pixels=-(w1+x)&7;
        leading_pixel_mask=gr.to_8_bits[0xFF>>leading_pixels];
        bit_shift=-x&7;
        whole_I64s=(w2-w1-leading_pixels)>>3;
        if (whole_I64s<0) whole_I64s=0;
        trailing_pixels=(x+w2)&7;
        trailing_pixel_mask=gr.to_8_bits[0xFF<<trailing_pixels&0xFF];
        if (leading_pixels+trailing_pixels>w2-w1) {
            leading_pixel_mask|=trailing_pixel_mask;
            trailing_pixels=0;
        }
        switch (color.c0.rop) {
            case ROPB_COLLISION: //TODO: Might want to check win_z_buf
            color =dc->bkcolor.c0.color;
            k=h1*img->width_internal;
            k1=(h1+y)*dc->width_internal+x;
            for (j=h2-h1;j;j--) {
                for (i=w1;i<w2;i++) {
                    c=dc->body[k1+((w2-1)-i)];
                    if (c!=TRANSPARENT&&c!=color&&img->body[k+((w2-1)-i)]!=TRANSPARENT)
                    dc->collision_cnt++;
                }
                k+=img->width_internal;
                k1+=dc->width_internal;
            }
            break;
            case ROPB_MONO:
            color_mask=gr.to_8_colors[color.c0.color];
            if (img->flags&DCF_NO_TRANSPARENTS) {
                if (!(dc->flags & DCF_SCRN_BITMAP) || dc->flags&DCF_ON_TOP)
                win_z_buf_ptr=NULL;
                else {
                    win_z_num=win_task->win_z_num;
                    win_z_buf_ptr=gr.win_z_buf(U8 *)+((h1+y)/FONT_HEIGHT*TEXT_COLS+
                    (w1+x)/FONT_WIDTH)*sizeof(U16);
                    win_z_buf_line_dec=whole_I64s;
                    if (leading_pixels)
                    win_z_buf_line_dec++;
                    if (trailing_pixels)
                    win_z_buf_line_dec++;
                    win_z_buf_line_dec*=sizeof(U16);
                    win_z_buf_line_inc=TEXT_COLS*sizeof(U16)-win_z_buf_line_dec;
                }
                kk = h1   *img ->width_internal+w1;
                kk1=(h1+y)*dc->width_internal+x+w1;
                kk =(kk-bit_shift)&~7+bit_shift;
                bit_shift*=8;
                if (win_z_buf_ptr)
                for (j=h1;j<h2;j++) {
                    src=img->body+kk&~7;
                    dst=dc->body+kk1&~7;
                    if (leading_pixels) {
                        if (win_z_num>=*win_z_buf_ptr++) {
                            if (bit_shift)
                            *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                            (*src(U64 *)++>>bit_shift|
                            *src(I64 *)<<(64-bit_shift))&
                            ~leading_pixel_mask&color_mask;
                            else
                            *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                            *src(I64 *)++&~leading_pixel_mask&color_mask;
                            } else {
                            src(I64 *)++;
                            dst(I64 *)++;
                        }
                    }
                    if (bit_shift)
                    for (i=0;i<whole_I64s;i++)
                    if (win_z_num>=*win_z_buf_ptr++)
                    *dst(I64 *)++=(*src(U64 *)++>>bit_shift|
                    *src(I64 *)<<(64-bit_shift))&color_mask;
                    else {
                        src(I64 *)++;
                        dst(I64 *)++;
                    }
                    else
                    for (i=0;i<whole_I64s;i++)
                    if (win_z_num>=*win_z_buf_ptr++)
                    *dst(I64 *)++=*src(I64 *)++&color_mask;
                    else {
                        src(I64 *)++;
                        dst(I64 *)++;
                    }
                    if (trailing_pixels && win_z_num>=*win_z_buf_ptr++) {
                        if (bit_shift)
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        (*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift))&
                        ~trailing_pixel_mask&color_mask;
                        else
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        *src(I64 *)++&~trailing_pixel_mask&color_mask;
                    }
                    kk +=img->width_internal;
                    kk1+=dc->width_internal;
                    if ((j+y)&7==7)
                    win_z_buf_ptr(U8 *)+=win_z_buf_line_inc;
                    else
                    win_z_buf_ptr(U8 *)-=win_z_buf_line_dec;
                }
                else
                for (j=h2-h1;j;j--) {
                    src=img->body+kk&~7;
                    dst=dc->body+kk1&~7;
                    if (leading_pixels) {
                        if (bit_shift)
                        *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                        (*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift))&
                        ~leading_pixel_mask&color_mask;
                        else
                        *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                        *src(I64 *)++&~leading_pixel_mask&color_mask;
                    }
                    if (bit_shift)
                    for (i=0;i<whole_I64s;i++)
                    *dst(I64 *)++=(*src(U64 *)++>>bit_shift|
                    *src(I64 *)<<(64-bit_shift))&color_mask;
                    else
                    for (i=0;i<whole_I64s;i++)
                    *dst(I64 *)++=*src(I64 *)++&color_mask;
                    if (trailing_pixels) {
                        if (bit_shift)
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        (*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift))&
                        ~trailing_pixel_mask&color_mask;
                        else
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        *src(I64 *)++&~trailing_pixel_mask&color_mask;
                    }
                    kk +=img->width_internal;
                    kk1+=dc->width_internal;
                }
                } else {
                k=h1*img->width_internal;
                if (!(dc->flags & DCF_SCRN_BITMAP) || dc->flags&DCF_ON_TOP) {
                    for (j=h1;j<h2;j++) {
                        for (i=w1;i<w2;i++)
                        if (img->body[k+((w2-1)-i)])
                        GrPlot0(dc,x+i,y+j);
                        k+=img->width_internal;
                    }
                    } else {
                    win_z_num           =win_task->win_z_num;
                    win_z_buf_ptr       =gr.win_z_buf(U8 *)+
                    ((h1+y)/FONT_HEIGHT*TEXT_COLS+(w1+x)/FONT_WIDTH)*sizeof(U16);
                    win_z_buf_line_dec=whole_I64s;
                    if (leading_pixels)
                    win_z_buf_line_dec++;
                    if (trailing_pixels)
                    win_z_buf_line_dec++;
                    win_z_buf_line_dec*=sizeof(U16);
                    win_z_buf_line_inc=TEXT_COLS*sizeof(U16)-win_z_buf_line_dec;
                    for (j=h1;j<h2;j++) {
                        if (win_z_num>=*win_z_buf_ptr++)
                        color_mask=TRUE;
                        else
                        color_mask=FALSE;
                        for (i=w1;i<w2;) {
                            if (color_mask)
                            if (img->body[k+((w2-1)-i)])
                            GrPlot0(dc,x+i,y+j);
                            if (!((++i+x) &7) && i<w2) {
                                if (win_z_num>=*win_z_buf_ptr++)
                                color_mask=TRUE;
                                else
                                color_mask=FALSE;
                            }
                        }
                        if ((j+y)&7==7)
                        win_z_buf_ptr(U8 *)+=win_z_buf_line_inc;
                        else
                        win_z_buf_ptr(U8 *)-=win_z_buf_line_dec;
                        k+=img->width_internal;
                    }
                }
            }
            break;
            case ROPB_EQU:
            if (img->flags&DCF_NO_TRANSPARENTS) {
                if (!(dc->flags & DCF_SCRN_BITMAP) || dc->flags&DCF_ON_TOP)
                win_z_buf_ptr=NULL;
                else {
                    win_z_num=win_task->win_z_num;
                    win_z_buf_ptr=gr.win_z_buf(U8 *)+
                    ((h1+y)/FONT_HEIGHT*TEXT_COLS+(w1+x)/FONT_WIDTH)*sizeof(U16);
                    win_z_buf_line_dec=whole_I64s;
                    if (leading_pixels)
                    win_z_buf_line_dec++;
                    if (trailing_pixels)
                    win_z_buf_line_dec++;
                    win_z_buf_line_dec*=sizeof(U16);
                    win_z_buf_line_inc=TEXT_COLS*sizeof(U16)-win_z_buf_line_dec;
                }
                kk = h1   *img ->width_internal+w1;
                kk1=(h1+y)*dc->width_internal+x+w1;
                kk =(kk-bit_shift)&~7+bit_shift;
                bit_shift*=8;
                if (win_z_buf_ptr)
                for (j=h1;j<h2;j++) {
                    src=img->body+kk&~7;
                    dst=dc->body+kk1&~7;
                    if (leading_pixels) {
                        if (win_z_num>=*win_z_buf_ptr++) {
                            if (bit_shift)
                            *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                            (*src(U64 *)++>>bit_shift|
                            *src(I64 *)<<(64-bit_shift))&~leading_pixel_mask;
                            else
                            *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                            *src(I64 *)++&~leading_pixel_mask;
                            } else {
                            src(I64 *)++;
                            dst(I64 *)++;
                        }
                    }
                    if (bit_shift)
                    for (i=0;i<whole_I64s;i++)
                    if (win_z_num>=*win_z_buf_ptr++)
                    *dst(I64 *)++=*src(U64 *)++>>bit_shift|
                    *src(I64 *)<<(64-bit_shift);
                    else {
                        src(I64 *)++;
                        dst(I64 *)++;
                    }
                    else
                    for (i=0;i<whole_I64s;i++)
                    if (win_z_num>=*win_z_buf_ptr++)
                    *dst(I64 *)++=*src(I64 *)++;
                    else {
                        src(I64 *)++;
                        dst(I64 *)++;
                    }
                    if (trailing_pixels && win_z_num>=*win_z_buf_ptr++) {
                        if (bit_shift)
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        (*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift))&~trailing_pixel_mask;
                        else
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        *src(I64 *)++&~trailing_pixel_mask;
                    }
                    kk +=img->width_internal;
                    kk1+=dc->width_internal;
                    if ((j+y)&7==7)
                    win_z_buf_ptr(U8 *)+=win_z_buf_line_inc;
                    else
                    win_z_buf_ptr(U8 *)-=win_z_buf_line_dec;
                }
                else
                for (j=h2-h1;j;j--) {
                    src=img->body+kk&~7;
                    dst=dc->body+kk1&~7;
                    if (leading_pixels) {
                        if (bit_shift)
                        *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                        (*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift))&~leading_pixel_mask;
                        else
                        *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                        *src(I64 *)++&~leading_pixel_mask;
                    }
                    if (bit_shift)
                    for (i=0;i<whole_I64s;i++)
                    *dst(I64 *)++=*src(U64 *)++>>bit_shift|
                    *src(I64 *)<<(64-bit_shift);
                    else
                    for (i=0;i<whole_I64s;i++)
                    *dst(I64 *)++=*src(I64 *)++;
                    if (trailing_pixels) {
                        if (bit_shift)
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        (*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift))&~trailing_pixel_mask;
                        else
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        *src(I64 *)++&~trailing_pixel_mask;
                    }
                    kk +=img->width_internal;
                    kk1+=dc->width_internal;
                }
                } else {
                here1a:
                k=h1*img->width_internal;
                if (!(dc->flags & DCF_SCRN_BITMAP) || dc->flags&DCF_ON_TOP) {
                    for (j=h1;j<h2;j++) {
                        for (i=w1;i<w2;i++) {
                            c=img->body[k+((w2-1)-i)];
                            if (c!=TRANSPARENT) {
                                dc->color.c0.color=c;
                                GrPlot0(dc,x+i,y+j);
                            }
                        }
                        k+=img->width_internal;
                    }
                    } else {
                    win_z_num           =win_task->win_z_num;
                    win_z_buf_ptr       =gr.win_z_buf(U8 *)+
                    ((h1+y)/FONT_HEIGHT*TEXT_COLS+(w1+x)/FONT_WIDTH)*sizeof(U16);
                    win_z_buf_line_dec=whole_I64s;
                    if (leading_pixels)
                    win_z_buf_line_dec++;
                    if (trailing_pixels)
                    win_z_buf_line_dec++;
                    win_z_buf_line_dec*=sizeof(U16);
                    win_z_buf_line_inc=TEXT_COLS*sizeof(U16)-win_z_buf_line_dec;
                    for (j=h1;j<h2;j++) {
                        if (win_z_num>=*win_z_buf_ptr++)
                        color_mask=TRUE;
                        else
                        color_mask=FALSE;
                        for (i=w1;i<w2;) {
                            if (color_mask) {
                                c=img->body[k+((w2-1)-i)];
                                if (c!=TRANSPARENT) {
                                    dc->color.c0.color=c;
                                    GrPlot0(dc,x+i,y+j);
                                }
                            }
                            if (!((++i+x) &7) && i<w2) {
                                if (win_z_num>=*win_z_buf_ptr++)
                                color_mask=TRUE;
                                else
                                color_mask=FALSE;
                            }
                        }
                        if ((j+y)&7==7)
                        win_z_buf_ptr(U8 *)+=win_z_buf_line_inc;
                        else
                        win_z_buf_ptr(U8 *)-=win_z_buf_line_dec;
                        k+=img->width_internal;
                    }
                }
                dc->color=color;
            }
            break;
            case ROPB_XOR:
            if (img->flags&DCF_NO_TRANSPARENTS) {
                if (!(dc->flags & DCF_SCRN_BITMAP) || dc->flags&DCF_ON_TOP)
                win_z_buf_ptr=NULL;
                else {
                    win_z_num=win_task->win_z_num;
                    win_z_buf_ptr=gr.win_z_buf(U8 *)+
                    ((h1+y)/FONT_HEIGHT*TEXT_COLS+(w1+x)/FONT_WIDTH)*sizeof(U16);
                    win_z_buf_line_dec=whole_I64s;
                    if (leading_pixels)
                    win_z_buf_line_dec++;
                    if (trailing_pixels)
                    win_z_buf_line_dec++;
                    win_z_buf_line_dec*=sizeof(U16);
                    win_z_buf_line_inc=TEXT_COLS*sizeof(U16)-win_z_buf_line_dec;
                }
                kk = h1   *img ->width_internal  +w1;
                kk1=(h1+y)*dc->width_internal+x+w1;
                kk =(kk-bit_shift)&~7+bit_shift;
                bit_shift*=8;
                if (win_z_buf_ptr)
                for (j=h1;j<h2;j++) {
                    src=img->body+kk&~7;
                    dst=dc->body+kk1&~7;
                    if (leading_pixels) {
                        if (win_z_num>=*win_z_buf_ptr++) {
                            if (bit_shift)
                            *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                            (*dst(I64 *)^(*src(U64 *)++>>bit_shift|
                            *src(I64 *)<<(64-bit_shift)))&~leading_pixel_mask;
                            else
                            *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                            (*dst(I64 *)^*src(I64 *)++)&~leading_pixel_mask;
                            } else {
                            src(I64 *)++;
                            dst(I64 *)++;
                        }
                    }
                    if (bit_shift)
                    for (i=0;i<whole_I64s;i++)
                    if (win_z_num>=*win_z_buf_ptr++)
                    *dst(I64 *)++^=*src(U64 *)++>>bit_shift|
                    *src(I64 *)<<(64-bit_shift);
                    else {
                        src(I64 *)++;
                        dst(I64 *)++;
                    }
                    else
                    for (i=0;i<whole_I64s;i++)
                    if (win_z_num>=*win_z_buf_ptr++)
                    *dst(I64 *)++^=*src(I64 *)++;
                    else {
                        src(I64 *)++;
                        dst(I64 *)++;
                    }
                    if (trailing_pixels && win_z_num>=*win_z_buf_ptr++) {
                        if (bit_shift)
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        (*dst(I64 *)^(*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift)))&~trailing_pixel_mask;
                        else
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        (*dst(I64 *)^*src(I64 *)++)&~trailing_pixel_mask;
                    }
                    kk +=img->width_internal;
                    kk1+=dc->width_internal;
                    if ((j+y)&7==7)
                    win_z_buf_ptr(U8 *)+=win_z_buf_line_inc;
                    else
                    win_z_buf_ptr(U8 *)-=win_z_buf_line_dec;
                }
                else
                for (j=h2-h1;j;j--) {
                    src=img->body+kk&~7;
                    dst=dc->body+kk1&~7;
                    if (leading_pixels) {
                        if (bit_shift)
                        *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                        (*dst(I64 *)^(*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift)))&~leading_pixel_mask;
                        else
                        *dst(I64 *)++=*dst(I64 *)&leading_pixel_mask|
                        (*dst(I64 *)^*src(I64 *)++)&~leading_pixel_mask;
                    }
                    if (bit_shift)
                    for (i=0;i<whole_I64s;i++)
                    *dst(I64 *)++^=*src(U64 *)++>>bit_shift|
                    *src(I64 *)<<(64-bit_shift);
                    else
                    for (i=0;i<whole_I64s;i++)
                    *dst(I64 *)++^=*src(I64 *)++;
                    if (trailing_pixels) {
                        if (bit_shift)
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        (*dst(I64 *)^(*src(U64 *)++>>bit_shift|
                        *src(I64 *)<<(64-bit_shift)))&~trailing_pixel_mask;
                        else
                        *dst(I64 *)=*dst(I64 *)&trailing_pixel_mask|
                        (*dst(I64 *)^*src(I64 *)++)&~trailing_pixel_mask;
                    }
                    kk +=img->width_internal;
                    kk1+=dc->width_internal;
                }
            } else
            goto here1a;
            break;
        }
        dc->depth_buf=db;
        dc->color=old_color;
        return 1;
    } else
    return 0;
}