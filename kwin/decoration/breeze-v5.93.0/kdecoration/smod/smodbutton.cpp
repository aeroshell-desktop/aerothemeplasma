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

    // translate from offset
    if (m_flag == FlagFirstInList) {
        painter->translate(m_offset);
    } else {
        painter->translate(0, m_offset.y());
    }

    if (!m_iconSize.isValid() || isStandAlone()) {
        m_iconSize = geometry().size().toSize();
    }

    // menu button
    if (type() == DecorationButtonType::Menu) {
        const auto c = decoration()->client();
        auto deco = qobject_cast<Decoration *>(decoration());
        QRectF iconRect(geometry().topLeft(), m_iconSize);
        int titlebarHeight = deco->internalSettings()->titlebarSize();

        iconRect.translate(0, (titlebarHeight - m_iconSize.height())/2);
        c->icon().paint(painter, iconRect.toRect());
        /*if (auto deco = qobject_cast<Decoration *>(decoration())) {
            const QPalette activePalette = KIconLoader::global()->customPalette();
            QPalette palette = c->palette();
            palette.setColor(QPalette::WindowText, deco->fontColor());
            KIconLoader::global()->setCustomPalette(palette);
            c->icon().paint(painter, iconRect.toRect());
            if (activePalette == QPalette()) {
                KIconLoader::global()->resetPalette();
            } else {
                KIconLoader::global()->setCustomPalette(palette);
            }
        } else {
            c->icon().paint(painter, iconRect.toRect());
        }*/

    } else if (type() == DecorationButtonType::Close || type() == DecorationButtonType::Maximize || type() == DecorationButtonType::Minimize) {
        QRectF g = geometry();
        qreal w = g.width();
        qreal h = g.height();
        const auto c = decoration()->client();

        painter->translate(g.topLeft());

        if(c->isMaximized()) painter->translate(QPoint(-2, 0));

        auto d = qobject_cast<Decoration *>(decoration());

        QPixmap normal, hover, active, glyph, glyphHover, glyphActive;

        QPoint glyphOffset;

        switch (type())
        {
            case DecorationButtonType::Minimize:
                glyphOffset = QPoint(10, 9);

                if (c->isActive())
                {
                    glyph       = QPixmap(":/smod/decoration/minimize-glyph");
                    glyphHover  = QPixmap(":/smod/decoration/minimize-hover-glyph");
                    glyphActive = QPixmap(":/smod/decoration/minimize-active-glyph");

                    normal      = QPixmap(":/smod/decoration/minimize");
                    hover       = QPixmap(":/smod/decoration/minimize-hover");
                    active      = QPixmap(":/smod/decoration/minimize-active");
                }
                else
                {
                    glyph       = QPixmap(":/smod/decoration/minimize-glyph");
                    glyphHover  = QPixmap(":/smod/decoration/minimize-hover-glyph");
                    glyphActive = QPixmap(":/smod/decoration/minimize-active-glyph");

                    normal      = QPixmap(":/smod/decoration/minimize-unfocus");
                    hover       = QPixmap(":/smod/decoration/minimize-unfocus-hover");
                    active      = QPixmap(":/smod/decoration/minimize-unfocus-active");
                }

                if (!isEnabled())
                {
                    glyph = QPixmap(":/smod/decoration/minimize-inactive-glyph");
                }
                break;
            case DecorationButtonType::Maximize:
                if (d && d->isMaximized())
                {
                    glyphOffset = QPoint(7, 3);

                    if (c->isActive())
                    {
                        glyph       = QPixmap(":/smod/decoration/restore-glyph");
                        glyphHover  = QPixmap(":/smod/decoration/restore-hover-glyph");
                        glyphActive = QPixmap(":/smod/decoration/restore-active-glyph");

                        normal      = QPixmap(":/smod/decoration/maximize");
                        hover       = QPixmap(":/smod/decoration/maximize-hover");
                        active      = QPixmap(":/smod/decoration/maximize-active");
                    }
                    else
                    {
                        glyph       = QPixmap(":/smod/decoration/restore-glyph");
                        glyphHover  = QPixmap(":/smod/decoration/restore-hover-glyph");
                        glyphActive = QPixmap(":/smod/decoration/restore-active-glyph");

                        normal      = QPixmap(":/smod/decoration/maximize-unfocus");
                        hover       = QPixmap(":/smod/decoration/maximize-unfocus-hover");
                        active      = QPixmap(":/smod/decoration/maximize-unfocus-active");
                    }
                }
                else
                {
                    glyphOffset = QPoint(8, 4);

                    if (c->isActive())
                    {
                        glyph       = QPixmap(":/smod/decoration/maximize-glyph");
                        glyphHover  = QPixmap(":/smod/decoration/maximize-hover-glyph");
                        glyphActive = QPixmap(":/smod/decoration/maximize-active-glyph");

                        normal      = QPixmap(":/smod/decoration/maximize");
                        hover       = QPixmap(":/smod/decoration/maximize-hover");
                        active      = QPixmap(":/smod/decoration/maximize-active");
                    }
                    else
                    {
                        glyph       = QPixmap(":/smod/decoration/maximize-glyph");
                        glyphHover  = QPixmap(":/smod/decoration/maximize-hover-glyph");
                        glyphActive = QPixmap(":/smod/decoration/maximize-active-glyph");

                        normal      = QPixmap(":/smod/decoration/maximize-unfocus");
                        hover       = QPixmap(":/smod/decoration/maximize-unfocus-hover");
                        active      = QPixmap(":/smod/decoration/maximize-unfocus-active");
                    }
                }

                if (!isEnabled())
                {
                    glyph = QPixmap(":/smod/decoration/maximize-inactive-glyph");
                }
                break;
            case DecorationButtonType::Close:
                glyphOffset = QPoint(19, 4);

                if (c->isActive())
                {
                    glyph       = QPixmap(":/smod/decoration/close-glyph");
                    glyphHover  = QPixmap(":/smod/decoration/close-hover-glyph");
                    glyphActive = QPixmap(":/smod/decoration/close-active-glyph");

                    normal      = QPixmap(":/smod/decoration/close");
                    hover       = QPixmap(":/smod/decoration/close-hover");
                    active      = QPixmap(":/smod/decoration/close-active");
                }
                else
                {
                    glyph       = QPixmap(":/smod/decoration/close-glyph");
                    glyphHover  = QPixmap(":/smod/decoration/close-hover-glyph");
                    glyphActive = QPixmap(":/smod/decoration/close-active-glyph");

                    normal      = QPixmap(":/smod/decoration/close-unfocus");
                    hover       = QPixmap(":/smod/decoration/close-unfocus-hover");
                    active      = QPixmap(":/smod/decoration/close-unfocus-active");
                }

                if (!isEnabled())
                {
                    glyph = QPixmap(":/smod/decoration/close-inactive-glyph");
                }
                break;
            default:
                break;
        }

        QImage image, hImage, aImage;
        image = normal.toImage();
        hImage = hover.toImage();
        aImage = active.toImage();

        if (!isPressed())
        {
            image = hoverImage(image, hImage, m_hoverProgress);

            painter->drawImage(QRectF(0, 0, w, h), image);
            painter->drawPixmap(glyphOffset, glyph);
        }
        else
        {
            painter->drawImage(QRectF(0, 0, w, h), aImage);
            painter->drawPixmap(glyphOffset, glyphActive);
        }
    } else {
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
