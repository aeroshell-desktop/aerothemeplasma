#include "../breezebutton.h"

#include <QPainter>

#include <KIconLoader>

namespace Breeze
{
using KDecoration2::DecorationButtonType;

static QImage hoverImage(const QImage &image, const QImage &hoverImage, qreal hoverProgress)
{
    if (hoverProgress <= 0.5 / 256)
    {
        return image;
    }

    if (hoverProgress >= 1.0 - 0.5 / 256)
    {
        return hoverImage;
    }

    QImage result = image;
    QImage over = hoverImage;
    QColor alpha = Qt::black;
    alpha.setAlphaF(hoverProgress);
    QPainter p;
    p.begin(&over);
    p.setCompositionMode(QPainter::CompositionMode_DestinationIn);
    p.fillRect(image.rect(), alpha);
    p.end();
    p.begin(&result);
    p.setCompositionMode(QPainter::CompositionMode_DestinationOut);
    p.fillRect(image.rect(), alpha);
    p.setCompositionMode(QPainter::CompositionMode_Plus);
    p.drawImage(0, 0, over);
    p.end();

    return result;
}

void Button::smodPaint(QPainter *painter, const QRect &repaintRegion)
{
    Q_UNUSED(repaintRegion)

    if (!decoration()) {
        return;
    }

    painter->save();
    auto deco = qobject_cast<Decoration *>(decoration());
    int titlebarHeight = deco->internalSettings()->titlebarSize();

    // translate from offset
    if (m_flag == FlagFirstInList)
    {
        painter->translate(m_offset);
    }
    else
    {
        painter->translate(0, m_offset.y());
    }

    if (!m_iconSize.isValid() || isStandAlone())
    {
        m_iconSize = geometry().size().toSize();
    }

    // menu button
    if (type() == DecorationButtonType::Menu)
    {
        const auto c = decoration()->client();
        QRectF iconRect(geometry().topLeft(), m_iconSize);

        iconRect.translate(0, (titlebarHeight - m_iconSize.height())/2);
        c->icon().paint(painter, iconRect.toRect());

    }
    else if (type() == DecorationButtonType::Close || type() == DecorationButtonType::Maximize || type() == DecorationButtonType::Minimize)
    {
        QRectF g = geometry();
        qreal w = g.width();
        qreal h = g.height();

        int l = 0;
        int t = 0;
        int r = 0;
        int b = 0;

        const auto c = decoration()->client();

        bool isSingleClose = !(c->isMinimizeable() || c->isMaximizeable());

        painter->translate(g.topLeft());

        if(c->isMaximized()) painter->translate(QPoint(-2, 0));

        auto d = qobject_cast<Decoration *>(decoration());

        QPixmap normal, hover, active, glyph, glyphHover, glyphActive;

        QPoint glyphOffset;

        QString dpiScale = "";

        if(titlebarHeight >= 22 && titlebarHeight < 25) dpiScale = "@1.25x";
        else if(titlebarHeight >= 25 && titlebarHeight < 27) dpiScale = "@1.5x";
        else if(titlebarHeight >= 27) dpiScale = "@2x";

        switch (type())
        {
            case DecorationButtonType::Minimize:

                if (c->isActive())
                {
                    glyph       = QPixmap(":/smod/decoration/minimize-glyph" + dpiScale);
                    glyphHover  = QPixmap(":/smod/decoration/minimize-hover-glyph" + dpiScale);
                    glyphActive = QPixmap(":/smod/decoration/minimize-active-glyph" + dpiScale);

                    normal      = QPixmap(":/smod/decoration/minimize");
                    hover       = QPixmap(":/smod/decoration/minimize-hover");
                    active      = QPixmap(":/smod/decoration/minimize-active");
                }
                else
                {
                    glyph       = QPixmap(":/smod/decoration/minimize-glyph" + dpiScale);
                    glyphHover  = QPixmap(":/smod/decoration/minimize-hover-glyph" + dpiScale);
                    glyphActive = QPixmap(":/smod/decoration/minimize-active-glyph" + dpiScale);

                    normal      = QPixmap(":/smod/decoration/minimize-unfocus");
                    hover       = QPixmap(":/smod/decoration/minimize-unfocus-hover");
                    active      = QPixmap(":/smod/decoration/minimize-unfocus-active");
                }

                if (!isEnabled())
                {
                    glyph = QPixmap(":/smod/decoration/minimize-inactive-glyph" + dpiScale);
                }

                glyphOffset = QPoint(ceil(w / 2.0 - glyph.width() / 2.0) + 1, floor((titlebarHeight-1) / 2.0) - glyph.height() / 2.0 - (titlebarHeight != 20 ? 1 : 0));
                l = 12;
                t = 6;
                r = 12;
                b = 8;
                if(titlebarHeight == 18 || titlebarHeight == 17) l--;
                break;
            case DecorationButtonType::Maximize:
                if (d && d->isMaximized())
                {

                    if (c->isActive())
                    {
                        glyph       = QPixmap(":/smod/decoration/restore-glyph" + dpiScale);
                        glyphHover  = QPixmap(":/smod/decoration/restore-hover-glyph" + dpiScale);
                        glyphActive = QPixmap(":/smod/decoration/restore-active-glyph" + dpiScale);

                        normal      = QPixmap(":/smod/decoration/maximize");
                        hover       = QPixmap(":/smod/decoration/maximize-hover");
                        active      = QPixmap(":/smod/decoration/maximize-active");
                    }
                    else
                    {
                        glyph       = QPixmap(":/smod/decoration/restore-glyph" + dpiScale);
                        glyphHover  = QPixmap(":/smod/decoration/restore-hover-glyph" + dpiScale);
                        glyphActive = QPixmap(":/smod/decoration/restore-active-glyph" + dpiScale);

                        normal      = QPixmap(":/smod/decoration/maximize-unfocus");
                        hover       = QPixmap(":/smod/decoration/maximize-unfocus-hover");
                        active      = QPixmap(":/smod/decoration/maximize-unfocus-active");
                    }

                    glyphOffset = QPoint(floor(w / 2.0 - glyph.width() / 2.0), floor((titlebarHeight-1) / 2.0) - glyph.height() / 2.0 - (titlebarHeight != 20 ? 1 : 0));
                }
                else
                {

                    if (c->isActive())
                    {
                        glyph       = QPixmap(":/smod/decoration/maximize-glyph" + dpiScale);
                        glyphHover  = QPixmap(":/smod/decoration/maximize-hover-glyph" + dpiScale);
                        glyphActive = QPixmap(":/smod/decoration/maximize-active-glyph" + dpiScale);

                        normal      = QPixmap(":/smod/decoration/maximize");
                        hover       = QPixmap(":/smod/decoration/maximize-hover");
                        active      = QPixmap(":/smod/decoration/maximize-active");
                    }
                    else
                    {
                        glyph       = QPixmap(":/smod/decoration/maximize-glyph" + dpiScale);
                        glyphHover  = QPixmap(":/smod/decoration/maximize-hover-glyph" + dpiScale);
                        glyphActive = QPixmap(":/smod/decoration/maximize-active-glyph" + dpiScale);

                        normal      = QPixmap(":/smod/decoration/maximize-unfocus");
                        hover       = QPixmap(":/smod/decoration/maximize-unfocus-hover");
                        active      = QPixmap(":/smod/decoration/maximize-unfocus-active");
                    }
                    glyphOffset = QPoint(ceil(w / 2.0) - glyph.width() / 2.0 + ((titlebarHeight < 21) ? 1 : 0), floor((titlebarHeight-1) / 2.0) - glyph.height() / 2.0 - (titlebarHeight != 20 ? 1 : 0));
                    if(deco->internalSettings()->alternativeButtonSizing()) glyphOffset += QPoint(titlebarHeight >= 20 ? 1 : -1, 0);
                }

                if (!isEnabled())
                {
                    glyph = QPixmap(":/smod/decoration/maximize-inactive-glyph" + dpiScale);
                }
                l = 12;
                t = 6;
                r = 12;
                b = 8;
                if(titlebarHeight == 18) l--;
                if(titlebarHeight == 17) l -= 2;
                break;
            case DecorationButtonType::Close:
                if (c->isActive())
                {
                    glyph       = QPixmap(":/smod/decoration/close-glyph" + dpiScale);
                    glyphHover  = QPixmap(":/smod/decoration/close-hover-glyph" + dpiScale);
                    glyphActive = QPixmap(":/smod/decoration/close-active-glyph" + dpiScale);

                    if(isSingleClose)
                    {
                        normal      = QPixmap(":/smod/decoration/close-single");
                        hover       = QPixmap(":/smod/decoration/close-single-hover");
                        active      = QPixmap(":/smod/decoration/close-single-active");
                    }
                    else
                    {
                        normal      = QPixmap(":/smod/decoration/close");
                        hover       = QPixmap(":/smod/decoration/close-hover");
                        active      = QPixmap(":/smod/decoration/close-active");
                    }
                }
                else
                {
                    glyph       = QPixmap(":/smod/decoration/close-glyph" + dpiScale);
                    glyphHover  = QPixmap(":/smod/decoration/close-hover-glyph" + dpiScale);
                    glyphActive = QPixmap(":/smod/decoration/close-active-glyph" + dpiScale);

                    if(isSingleClose)
                    {
                        normal      = QPixmap(":/smod/decoration/close-single-unfocus");
                        hover       = QPixmap(":/smod/decoration/close-single-unfocus-hover");
                        active      = QPixmap(":/smod/decoration/close-single-unfocus-active");
                    }
                    else
                    {
                        normal      = QPixmap(":/smod/decoration/close-unfocus");
                        hover       = QPixmap(":/smod/decoration/close-unfocus-hover");
                        active      = QPixmap(":/smod/decoration/close-unfocus-active");
                    }
                }

                if (!isEnabled())
                {
                    glyph = QPixmap(":/smod/decoration/close-inactive-glyph" + dpiScale);
                }

                glyphOffset = QPoint(floor(w / 2.0 - glyph.width() / 2.0), floor((titlebarHeight-1) / 2.0) - glyph.height() / 2.0 - (titlebarHeight != 20 ? 1 : 0));
                l = 20;
                t = 6;
                r = 20;
                b = 8;

                break;
            default:
                break;
        }

        QImage image, hImage, aImage;
        image = normal.toImage();
        hImage = hover.toImage();
        aImage = active.toImage();

        /*
         * Convention:
         * 0 - topleft,    1 - top,    2 - topright,
         * 3 - left,       4 - center, 5 - right,
         * 6 - bottomleft, 7 - bottom, 8 - bottomright
         */
        QPainter::PixmapFragment fragments[9];

        for(int i = 0; i < 9; i++)
        {
            fragments[i].opacity = 1.0;
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
        fragments[2].sourceLeft = normal.width() - r;
        fragments[2].sourceTop = 0;
        fragments[2].width = r;
        fragments[2].height = t;
        fragments[2].x = (w - r + fragments[2].width / 2);
        fragments[2].y = (0     + fragments[2].height / 2);

        // BottomLeft
        fragments[6].sourceLeft = 0;
        fragments[6].sourceTop = normal.height() - b;
        fragments[6].width = l;
        fragments[6].height = b;
        fragments[6].x = (0     + fragments[6].width / 2);
        fragments[6].y = (h - b + fragments[6].height / 2);

        // BottomRight
        fragments[8].sourceLeft = normal.width() - r;
        fragments[8].sourceTop = normal.height() - b;
        fragments[8].width = r;
        fragments[8].height = b;
        fragments[8].x = (w - r + fragments[8].width / 2);
        fragments[8].y = (h - b + fragments[8].height / 2);

        // Top
        fragments[1].sourceLeft = l;
        fragments[1].sourceTop = 0;
        fragments[1].width = normal.width() - l - r;
        fragments[1].height = t;
        fragments[1].scaleX = (w-l-r) / fragments[1].width;
        fragments[1].x = (l + fragments[1].width*fragments[1].scaleX / 2);
        fragments[1].y = (0 + fragments[1].height*fragments[1].scaleY / 2);

        // Left
        fragments[3].sourceLeft = 0;
        fragments[3].sourceTop = t;
        fragments[3].width = l;
        fragments[3].height = normal.height() - t - b;
        fragments[3].scaleY = (h-t-b) / fragments[3].height;
        fragments[3].x = (0 + fragments[3].width*fragments[3].scaleX / 2);
        fragments[3].y = (t + fragments[3].height*fragments[3].scaleY / 2);

        // Right
        fragments[5].sourceLeft = normal.width() - r;
        fragments[5].sourceTop = t;
        fragments[5].width = r;
        fragments[5].height = normal.height() - t - b;
        fragments[5].scaleY = (h-t-b) / fragments[5].height;
        fragments[5].x = (w-r + fragments[5].width*fragments[5].scaleX / 2);
        fragments[5].y = (t   + fragments[5].height*fragments[5].scaleY / 2);

        // Center
        fragments[4].sourceLeft = l;
        fragments[4].sourceTop = t;
        fragments[4].width = normal.width() - l - r;
        fragments[4].height = normal.height() - t - b;
        fragments[4].scaleX = (w-l-r) / fragments[4].width;
        fragments[4].scaleY = (h-t-b) / fragments[4].height;
        fragments[4].x = (l + fragments[4].width*fragments[4].scaleX / 2);
        fragments[4].y = (t + fragments[4].height*fragments[4].scaleY / 2);

        // Bottom
        fragments[7].sourceLeft = l;
        fragments[7].sourceTop = normal.height() - b;
        fragments[7].width = normal.width() - l - r;
        fragments[7].height = b;
        fragments[7].scaleX = (w-l-r) / fragments[7].width;
        fragments[7].x = (l + fragments[7].width*fragments[7].scaleX / 2);
        fragments[7].y = (h-b + fragments[7].height*fragments[7].scaleY / 2);

        painter->setRenderHint(QPainter::Antialiasing, true);
        painter->setRenderHint(QPainter::SmoothPixmapTransform, true);
        if (!isPressed())
        {
            image = hoverImage(image, hImage, m_hoverProgress);

            normal.convertFromImage(image);
            painter->drawPixmapFragments(fragments, 9, normal);
            painter->drawPixmap(glyphOffset.x(), glyphOffset.y(), glyph.width(), glyph.height(), glyph);
        }
        else
        {
            normal.convertFromImage(aImage);
            painter->drawPixmapFragments(fragments, 9, normal);
            painter->drawPixmap(glyphOffset.x(), glyphOffset.y(), glyph.width(), glyph.height(), glyph);
        }
    }
    else
    {
        drawIcon(painter);
    }

    painter->restore();
}
void Button::hoverEnterEvent(QHoverEvent *event)
{
    KDecoration2::DecorationButton::hoverEnterEvent(event);

    if (isHovered())
    {
        Q_EMIT buttonHoverStatus(type(), true, geometry().topLeft().toPoint());
        startHoverAnimation(1.0);
    }
}

void Button::hoverLeaveEvent(QHoverEvent *event)
{
    KDecoration2::DecorationButton::hoverLeaveEvent(event);

    if (!isHovered())
    {
        Q_EMIT buttonHoverStatus(type(), false, geometry().topLeft().toPoint());
        startHoverAnimation(0.0);
    }
}

qreal Button::hoverProgress() const
{
    return m_hoverProgress;
}

void Button::setHoverProgress(qreal hoverProgress)
{
    if (m_hoverProgress != hoverProgress)
    {
        m_hoverProgress = hoverProgress;

        if (qobject_cast<Decoration *>(decoration()))
        {
            update(geometry().adjusted(-32, -32, 32, 32));
        }
    }
}

void Button::startHoverAnimation(qreal endValue)
{
    QPropertyAnimation *hoverAnimation = m_hoverAnimation.data();

    if (hoverAnimation)
    {
        if (hoverAnimation->endValue() == endValue)
        {
            return;
        }

        hoverAnimation->stop();
    } else if (m_hoverProgress != endValue)
    {
        hoverAnimation = new QPropertyAnimation(this, "hoverProgress");
        m_hoverAnimation = hoverAnimation;
    } else {
        return;
    }

    hoverAnimation->setEasingCurve(QEasingCurve::OutQuad);
    hoverAnimation->setStartValue(m_hoverProgress);
    hoverAnimation->setEndValue(endValue);
    hoverAnimation->setDuration(1 + qRound(200 * qAbs(m_hoverProgress - endValue)));
    hoverAnimation->start();
}

}
