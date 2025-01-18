#pragma once
#include <QPixmap>
#include <QPainter>

namespace Breeze
{
class FrameTexture
{
public:

    /*
     * l - left margin
     * r - right margin
     * t - top margin
     * b - bottom margin - these values are 1:1 with SIZINGMARGINS in msstyles
     * w - target width  - The final resulting width and height of the texture
     * h - target height
     * p - source pixmap
     * alignPixels - cast float positions into integers
     * (off_x, off_y, src_w, src_h) form a rectangle that crops the source pixmap which gets rid of everything else we don't want to sample when 9-slicing'
     */
    FrameTexture(int l, int r, int t, int b, qreal w, qreal h, QPixmap* p, qreal opacity = 1.0, bool alignPixels = false, qreal off_x = 0, qreal off_y = 0, qreal src_w = -1, qreal src_h = -1);
    void setGeometry(qreal w, qreal h); // Update final size of the rendered texture
    void setOpacity(qreal opacity);
    void render(QPainter *painter);
    void translate(int x, int y); // Moves the texture relative to the paint coordinates
    enum fragments { TOPLEFT = 0, TOP, TOPRIGHT, LEFT, CENTER, RIGHT, BOTTOMLEFT, BOTTOM, BOTTOMRIGHT };

    /*
     * Convention:
     * 0 - topleft,    1 - top,    2 - topright,
     * 3 - left,       4 - center, 5 - right,
     * 6 - bottomleft, 7 - bottom, 8 - bottomright
     */

private:
    QPainter::PixmapFragment fragments[9];
    QPixmap *normal;
    qreal off_x, off_y;
    qreal width, height;
    int l,r,t,b;
    bool alignPixels;
};
}
