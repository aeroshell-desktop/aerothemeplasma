#include "frametexture.h"
/*
 * Convention:
 * 0 - topleft,    1 - top,    2 - topright,
 * 3 - left,       4 - center, 5 - right,
 * 6 - bottomleft, 7 - bottom, 8 - bottomright
 */

namespace Breeze
{
    qreal clip(qreal a)
    {
        return a < 0 ? 0 : a;
    }
    FrameTexture::FrameTexture(int l, int r, int t, int b, qreal w, qreal h, QPixmap* p, qreal opacity, bool align, qreal o_x, qreal o_y, qreal src_w, qreal src_h) : normal(p), l(l), r(r), t(t), b(b), alignPixels(align), off_x(o_x), off_y(o_y), width(src_w), height(src_h)
    {
        if(width == -1) width = normal->width();
        if(height == -1) height = normal->height();
        for(int i = 0; i < 9; i++)
        {
            fragments[i].opacity = opacity;
            fragments[i].rotation = 0.0;
            fragments[i].scaleY = 1.0;
            fragments[i].scaleX = 1.0;
        }
        // TopLeft
        fragments[TOPLEFT].sourceLeft = 0;
        fragments[TOPLEFT].sourceTop = 0;
        fragments[TOPLEFT].width = l;
        fragments[TOPLEFT].height = t;
        fragments[TOPLEFT].x = (0 + fragments[TOPLEFT].width / 2);
        fragments[TOPLEFT].y = (0 + fragments[TOPLEFT].height / 2);

        // TopRight
        fragments[TOPRIGHT].sourceLeft = width - r;
        fragments[TOPRIGHT].sourceTop = 0;
        fragments[TOPRIGHT].width = r;
        fragments[TOPRIGHT].height = t;
        fragments[TOPRIGHT].x = (w - r + fragments[TOPRIGHT].width / 2);
        fragments[TOPRIGHT].y = (0     + fragments[TOPRIGHT].height / 2);

        // BottomLeft
        fragments[BOTTOMLEFT].sourceLeft = 0;
        fragments[BOTTOMLEFT].sourceTop = height - b;
        fragments[BOTTOMLEFT].width = l;
        fragments[BOTTOMLEFT].height = b;
        fragments[BOTTOMLEFT].x = (0     + fragments[BOTTOMLEFT].width / 2);
        fragments[BOTTOMLEFT].y = (h - b + fragments[BOTTOMLEFT].height / 2);

        // BottomRight
        fragments[BOTTOMRIGHT].sourceLeft = width - r;
        fragments[BOTTOMRIGHT].sourceTop = height - b;
        fragments[BOTTOMRIGHT].width = r;
        fragments[BOTTOMRIGHT].height = b;
        fragments[BOTTOMRIGHT].x = (w - r + fragments[BOTTOMRIGHT].width / 2);
        fragments[BOTTOMRIGHT].y = (h - b + fragments[BOTTOMRIGHT].height / 2);

        // Top
        fragments[TOP].sourceLeft = l;
        fragments[TOP].sourceTop = 0;
        fragments[TOP].width = width - l - r;
        fragments[TOP].height = t;
        fragments[TOP].scaleX = clip(w-l-r) / fragments[TOP].width;
        fragments[TOP].x = (l + fragments[TOP].width* fragments[TOP].scaleX / 2);
        fragments[TOP].y = (0 + fragments[TOP].height*fragments[TOP].scaleY / 2);

        // Left
        fragments[LEFT].sourceLeft = 0;
        fragments[LEFT].sourceTop = t;
        fragments[LEFT].width = l;
        fragments[LEFT].height = height - t - b;
        fragments[LEFT].scaleY =       clip(h-t-b) / fragments[LEFT].height;
        fragments[LEFT].x = (0 + fragments[LEFT].width* fragments[LEFT].scaleX / 2);
        fragments[LEFT].y = (t + fragments[LEFT].height*fragments[LEFT].scaleY / 2);

        // Right
        fragments[RIGHT].sourceLeft = width - r;
        fragments[RIGHT].sourceTop = t;
        fragments[RIGHT].width = r;
        fragments[RIGHT].height = height - t - b;
        fragments[RIGHT].scaleY =         clip(h-t-b) / fragments[RIGHT].height;
        fragments[RIGHT].x = (w-r + fragments[RIGHT].width* fragments[RIGHT].scaleX / 2);
        fragments[RIGHT].y = (t   + fragments[RIGHT].height*fragments[RIGHT].scaleY / 2);

        // Center
        fragments[CENTER].sourceLeft = l;
        fragments[CENTER].sourceTop = t;
        fragments[CENTER].width = width - l - r;
        fragments[CENTER].height = height - t - b;
        fragments[CENTER].scaleX = clip(w-l-r) / fragments[CENTER].width;
        fragments[CENTER].scaleY = clip(h-t-b) / fragments[CENTER].height;
        fragments[CENTER].x = (l + fragments[CENTER].width* fragments[CENTER].scaleX / 2);
        fragments[CENTER].y = (t + fragments[CENTER].height*fragments[CENTER].scaleY / 2);

        // Bottom
        fragments[BOTTOM].sourceLeft = l;
        fragments[BOTTOM].sourceTop = height - b;
        fragments[BOTTOM].width = width - l - r;
        fragments[BOTTOM].height = b;
        fragments[BOTTOM].scaleX =         clip(w-l-r) / fragments[BOTTOM].width;
        fragments[BOTTOM].x = (l +   fragments[BOTTOM].width* fragments[BOTTOM].scaleX / 2);
        fragments[BOTTOM].y = (h-b + fragments[BOTTOM].height*fragments[BOTTOM].scaleY / 2);
        for(int i = 0; i < 9; i++)
        {
            fragments[i].sourceLeft += off_x;
            fragments[i].sourceTop += off_y;

            if(alignPixels)
            {
                fragments[i].x = floor(fragments[i].x);
                fragments[i].y = floor(fragments[i].y);
            }
        }
    }

    void FrameTexture::translate(int x, int y)
    {
        for(int i = 0; i < 9; i++)
        {
            fragments[i].x += x;
            fragments[i].y += y;
        }
    }
    void FrameTexture::setGeometry(qreal w, qreal h)
    {
        fragments[TOPRIGHT].x = (w - r + fragments[TOPRIGHT].width / 2);
        fragments[BOTTOMLEFT].y = (h - b + fragments[BOTTOMLEFT].height / 2);
        fragments[BOTTOMRIGHT].x = (w - r + fragments[BOTTOMRIGHT].width / 2);
        fragments[BOTTOMRIGHT].y = (h - b + fragments[BOTTOMRIGHT].height / 2);
        fragments[TOP].scaleX = clip(w-l-r) / fragments[TOP].width;
        fragments[LEFT].scaleY = clip(h-t-b) / fragments[LEFT].height;
        fragments[RIGHT].scaleY = clip(h-t-b) / fragments[RIGHT].height;
        fragments[RIGHT].x = (w-r + fragments[RIGHT].width*fragments[RIGHT].scaleX / 2);
        fragments[CENTER].scaleX = clip(w-l-r) / fragments[CENTER].width;
        fragments[CENTER].scaleY = clip(h-t-b) / fragments[CENTER].height;
        fragments[BOTTOM].scaleX = clip(w-l-r) / fragments[BOTTOM].width;
        fragments[BOTTOM].y = (h-b + fragments[BOTTOM].height*fragments[BOTTOM].scaleY / 2);
    }
    void FrameTexture::setOpacity(qreal opacity)
    {
        for(int i = 0; i < 9; i++)
            fragments[i].opacity = opacity;
    }
    void FrameTexture::render(QPainter *painter)
    {
        painter->drawPixmapFragments(fragments, 9, *normal);
    }


}
