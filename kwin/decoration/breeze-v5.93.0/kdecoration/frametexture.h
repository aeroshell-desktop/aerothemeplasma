#pragma once
#include <QPixmap>
#include <QPainter>

namespace Breeze
{
class FrameTexture
{
public:
    FrameTexture(int l, int r, int t, int b, qreal w, qreal h, QPixmap* p, qreal opacity = 1.0, bool alignPixels = false);
    void setGeometry(qreal w, qreal h);
    void setOpacity(qreal opacity);
    void render(QPainter *painter);

private:
    QPainter::PixmapFragment fragments[9];
    QPixmap *normal;
    int l,r,t,b;
    bool alignPixels;
};
}
