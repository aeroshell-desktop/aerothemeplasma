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
    FrameTexture::FrameTexture(int l, int r, int t, int b, qreal w, qreal h, QPixmap* p, qreal opacity, bool align) : normal(p), l(l), r(r), t(t), b(b), alignPixels(align)
    {
        for(int i = 0; i < 9; i++)
        {
            fragments[i].opacity = opacity;
            fragments[i].rotation = 0.0;
            fragments[i].scaleY = 1.0;
            fragments[i].scaleX = 1.0;
        }
        // TopLeft
        fragments[0].sourceLeft = 0;
        fragments[0].sourceTop = 0;
        fragments[0].width = l;
        fragments[0].height = t;
        fragments[0].x = (0 + fragments[0].width / 2);
        fragments[0].y = (0 + fragments[0].height / 2);

        // TopRight
        fragments[2].sourceLeft = normal->width() - r;
        fragments[2].sourceTop = 0;
        fragments[2].width = r;
        fragments[2].height = t;
        fragments[2].x = (w - r + fragments[2].width / 2);
        fragments[2].y = (0     + fragments[2].height / 2);

        // BottomLeft
        fragments[6].sourceLeft = 0;
        fragments[6].sourceTop = normal->height() - b;
        fragments[6].width = l;
        fragments[6].height = b;
        fragments[6].x = (0     + fragments[6].width / 2);
        fragments[6].y = (h - b + fragments[6].height / 2);

        // BottomRight
        fragments[8].sourceLeft = normal->width() - r;
        fragments[8].sourceTop = normal->height() - b;
        fragments[8].width = r;
        fragments[8].height = b;
        fragments[8].x = (w - r + fragments[8].width / 2);
        fragments[8].y = (h - b + fragments[8].height / 2);

        // Top
        fragments[1].sourceLeft = l;
        fragments[1].sourceTop = 0;
        fragments[1].width = normal->width() - l - r;
        fragments[1].height = t;
        fragments[1].scaleX = clip(w-l-r) / fragments[1].width;
        fragments[1].x = (l + fragments[1].width*fragments[1].scaleX / 2);
        fragments[1].y = (0 + fragments[1].height*fragments[1].scaleY / 2);

        // Left
        fragments[3].sourceLeft = 0;
        fragments[3].sourceTop = t;
        fragments[3].width = l;
        fragments[3].height = normal->height() - t - b;
        fragments[3].scaleY = clip(h-t-b) / fragments[3].height;
        fragments[3].x = (0 + fragments[3].width*fragments[3].scaleX / 2);
        fragments[3].y = (t + fragments[3].height*fragments[3].scaleY / 2);

        // Right
        fragments[5].sourceLeft = normal->width() - r;
        fragments[5].sourceTop = t;
        fragments[5].width = r;
        fragments[5].height = normal->height() - t - b;
        fragments[5].scaleY = clip(h-t-b) / fragments[5].height;
        fragments[5].x = (w-r + fragments[5].width*fragments[5].scaleX / 2);
        fragments[5].y = (t   + fragments[5].height*fragments[5].scaleY / 2);

        // Center
        fragments[4].sourceLeft = l;
        fragments[4].sourceTop = t;
        fragments[4].width = normal->width() - l - r;
        fragments[4].height = normal->height() - t - b;
        fragments[4].scaleX = clip(w-l-r) / fragments[4].width;
        fragments[4].scaleY = clip(h-t-b) / fragments[4].height;
        fragments[4].x = (l + fragments[4].width*fragments[4].scaleX / 2);
        fragments[4].y = (t + fragments[4].height*fragments[4].scaleY / 2);

        // Bottom
        fragments[7].sourceLeft = l;
        fragments[7].sourceTop = normal->height() - b;
        fragments[7].width = normal->width() - l - r;
        fragments[7].height = b;
        fragments[7].scaleX = clip(w-l-r) / fragments[7].width;
        fragments[7].x = (l + fragments[7].width*fragments[7].scaleX / 2);
        fragments[7].y = (h-b + fragments[7].height*fragments[7].scaleY / 2);
        if(alignPixels)
        {
            for(int i = 0; i < 9; i++)
            {
                fragments[i].x = floor(fragments[i].x);
                fragments[i].y = floor(fragments[i].y);
            }
        }
    }

    void FrameTexture::setGeometry(qreal w, qreal h)
    {
        fragments[2].x = (w - r + fragments[2].width / 2);
        fragments[6].y = (h - b + fragments[6].height / 2);
        fragments[8].x = (w - r + fragments[8].width / 2);
        fragments[8].y = (h - b + fragments[8].height / 2);
        fragments[1].scaleX = clip(w-l-r) / fragments[1].width;
        fragments[3].scaleY = clip(h-t-b) / fragments[3].height;
        fragments[5].scaleY = clip(h-t-b) / fragments[5].height;
        fragments[5].x = (w-r + fragments[5].width*fragments[5].scaleX / 2);
        fragments[4].scaleX = clip(w-l-r) / fragments[4].width;
        fragments[4].scaleY = clip(h-t-b) / fragments[4].height;
        fragments[7].scaleX = clip(w-l-r) / fragments[7].width;
        fragments[7].y = (h-b + fragments[7].height*fragments[7].scaleY / 2);
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
