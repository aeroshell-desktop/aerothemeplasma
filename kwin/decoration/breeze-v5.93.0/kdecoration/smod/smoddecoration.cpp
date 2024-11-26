#include "../breezedecoration.h"
#include "../breezebutton.h"
#include "qgraphicsgloweffect.h"

#include <QPainter>
#include <QPainterPath>

#include <KDecoration2/DecorationButtonGroup>

namespace Breeze
{

void Decoration::updateBlur()
{
    const int radius = isMaximized() ? 0 : 7;

    QPainterPath path;
    path.addRoundedRect(rect(), radius, radius);

    setBlurRegion(QRegion(path.toFillPolygon().toPolygon()));

    updateShadow();
}

void Decoration::smodPaint(QPainter *painter, const QRect &repaintRegion)
{
    painter->fillRect(rect(), Qt::transparent);

    smodPaintGlow(painter, repaintRegion);
    smodPaintOuterBorder(painter, repaintRegion);
    smodPaintInnerBorder(painter, repaintRegion);
    smodPaintTitleBar(painter, repaintRegion);
}

void Decoration::smodPaintGlow(QPainter *painter, const QRect &repaintRegion)
{
    const auto c = client();

    int titlebarHeight = internalSettings()->titlebarSize();
    int SIDEBAR_HEIGHT = qMax(25, (size().height() / 4));

    painter->setOpacity(0.75);
    painter->setClipRegion(blurRegion());
    painter->setClipping(true);

    if(internalSettings()->invertTextColor() && isMaximized()) return;
    if (c->isActive())
    {
        if (isMaximized())
        {
            QPixmap nwCorner(":/smod/decoration/framecornereffect");
            painter->drawPixmap(0, 0, nwCorner, 4, 4, nwCorner.width() - 4, nwCorner.height() - 4);

            QPixmap neCorner = nwCorner.transformed(QTransform().scale(-1, 1));
            //QPixmap neCorner(":/smod/decoration/ne-corner");
            painter->drawPixmap(size().width() - (neCorner.width() - 4), 0, neCorner, 0, 4, neCorner.width() - 4, neCorner.height() - 4);
        }
        else
        {
            QPixmap nwCorner(":/smod/decoration/framecornereffect");
            painter->drawPixmap(0, 0, nwCorner);

            QPixmap neCorner = nwCorner.transformed(QTransform().scale(-1, 1));
            //QPixmap neCorner(":/smod/decoration/ne-corner");
            painter->drawPixmap(size().width() - neCorner.width(), 0, neCorner);

            painter->setOpacity(1.0);

            // 7x116
            QPixmap sidehighlight(":/smod/decoration/sidehighlight");
            painter->drawPixmap(0, borderTop(), 7, SIDEBAR_HEIGHT, sidehighlight);
            painter->drawPixmap(size().width() - 7, borderTop(), 7, SIDEBAR_HEIGHT, sidehighlight);
        }
    }
    else
    {
        if (isMaximized())
        {
            QPixmap nwCorner(":/smod/decoration/framecornereffect-unfocus");
            painter->drawPixmap(0, 0, nwCorner, 4, 4, nwCorner.width() - 4, nwCorner.height() - 4);

            QPixmap neCorner = nwCorner.transformed(QTransform().scale(-1, 1));
            //QPixmap neCorner(":/smod/decoration/ne-corner");
            painter->drawPixmap(size().width() - (neCorner.width() - 4), 0, neCorner, 0, 4, neCorner.width() - 4, neCorner.height() - 4);
        }
        else
        {
            QPixmap nwCorner(":/smod/decoration/framecornereffect-unfocus");
            painter->drawPixmap(0, 0, nwCorner);

            QPixmap neCorner = nwCorner.transformed(QTransform().scale(-1, 1));
            //QPixmap neCorner(":/smod/decoration/ne-corner");
            painter->drawPixmap(size().width() - neCorner.width(), 0, neCorner);

            painter->setOpacity(1.0);

            // 7x116
            QPixmap sidehighlight(":/smod/decoration/sidehighlight-unfocus");
            painter->drawPixmap(0, borderTop(), 7, SIDEBAR_HEIGHT, sidehighlight);
            painter->drawPixmap(size().width() - 7, borderTop(), 7, SIDEBAR_HEIGHT, sidehighlight);
        }
    }

    painter->setOpacity(1.0);
    painter->setClipping(false);
}

void Decoration::smodPaintOuterBorder(QPainter *painter, const QRect &repaintRegion)
{
    if (isMaximized())
    {
        return;
    }

    const auto c = client();

    QPixmap nw, n, ne, e, se, s, sw, w;

    if (c->isActive())
    {
        nw = QPixmap(":/smod/decoration/nw");
        n = QPixmap(":/smod/decoration/n");
        ne = QPixmap(":/smod/decoration/ne");
        e = QPixmap(":/smod/decoration/e");
        se = QPixmap(":/smod/decoration/se");
        s = QPixmap(":/smod/decoration/s");
        sw = QPixmap(":/smod/decoration/sw");
        w = QPixmap(":/smod/decoration/w");
    }
    else
    {
        nw = QPixmap(":/smod/decoration/nw-unfocus");
        n = QPixmap(":/smod/decoration/n-unfocus");
        ne = QPixmap(":/smod/decoration/ne-unfocus");
        e = QPixmap(":/smod/decoration/e-unfocus");
        se = QPixmap(":/smod/decoration/se-unfocus");
        s = QPixmap(":/smod/decoration/s-unfocus");
        sw = QPixmap(":/smod/decoration/sw-unfocus");
        w = QPixmap(":/smod/decoration/w-unfocus");
    }

#if 0
    if (c->isActive())
    {
        painter->save();
        QPen pen(Qt::white, 0);
        painter->setPen(pen);
        painter->drawRoundedRect(rect().x() + 1, rect().y() + 1, rect().width() - 2, rect().height() - 2, 6, 6);
        painter->restore();
    }
#endif
    int PIX_RIGHT = size().width() - 9;
    int PIX_BOTTOM = size().height() - 9;

    painter->drawPixmap(0, 0, nw);

    painter->drawTiledPixmap(9, 0, PIX_RIGHT - 9, 9, n);

    painter->drawPixmap(PIX_RIGHT, 0, ne);

    painter->drawTiledPixmap(PIX_RIGHT, 9, 9, PIX_BOTTOM - 9, e);

    painter->drawPixmap(PIX_RIGHT, PIX_BOTTOM, se);

    painter->drawTiledPixmap(9, PIX_BOTTOM, PIX_RIGHT - 9, 9, s);

    painter->drawPixmap(0, PIX_BOTTOM, sw);

    painter->drawTiledPixmap(0, 9, 9, PIX_BOTTOM - 9, w);
}

void Decoration::smodPaintInnerBorder(QPainter *painter, const QRect &repaintRegion)
{
    if (hideInnerBorder())
    {
        return;
    }

    const auto c = client();

    QPixmap nw, n, ne, e, se, s, sw, w;

    if (c->isActive())
    {
        nw = QPixmap(":/smod/decoration/nw-inner");
        n = QPixmap(":/smod/decoration/n-inner");
        ne = QPixmap(":/smod/decoration/ne-inner");
        e = QPixmap(":/smod/decoration/e-inner");
        se = QPixmap(":/smod/decoration/se-inner");
        s = QPixmap(":/smod/decoration/s-inner");
        sw = QPixmap(":/smod/decoration/sw-inner");
        w = QPixmap(":/smod/decoration/w-inner");
    }
    else
    {
        nw = QPixmap(":/smod/decoration/nw-unfocus-inner");
        n = QPixmap(":/smod/decoration/n-unfocus-inner");
        ne = QPixmap(":/smod/decoration/ne-unfocus-inner");
        e = QPixmap(":/smod/decoration/e-unfocus-inner");
        se = QPixmap(":/smod/decoration/se-unfocus-inner");
        s = QPixmap(":/smod/decoration/s-unfocus-inner");
        sw = QPixmap(":/smod/decoration/sw-unfocus-inner");
        w = QPixmap(":/smod/decoration/w-unfocus-inner");
    }

    // left
    painter->drawTiledPixmap(
        borderLeft() - INNER_BORDER_SIZE,
        borderTop(),
        INNER_BORDER_SIZE,
        size().height() - borderBottom() - borderTop(),
        w);

    // right
    painter->drawTiledPixmap(
        size().width() - borderRight(),
        borderTop(),
        INNER_BORDER_SIZE,
        size().height() - borderBottom() - borderTop(),
        e);

    // bottom
    painter->drawTiledPixmap(
        borderLeft(),
        size().height() - borderBottom(),
        size().width() - borderLeft() - borderRight(),
        INNER_BORDER_SIZE,
        s);

    // top
    painter->drawTiledPixmap(
        borderLeft(),
        borderTop() - INNER_BORDER_SIZE,
        size().width() - borderLeft() - borderRight(),
        INNER_BORDER_SIZE,
        n);

    painter->drawPixmap(borderLeft() - INNER_BORDER_SIZE, borderTop() - INNER_BORDER_SIZE, nw);
    painter->drawPixmap(size().width() - borderRight(), borderTop() - INNER_BORDER_SIZE, ne);
    painter->drawPixmap(size().width() - borderRight(), size().height() - borderBottom(), se);
    painter->drawPixmap(borderLeft() - INNER_BORDER_SIZE, size().height() - borderBottom(), sw);
}

void Decoration::smodPaintTitleBar(QPainter *painter, const QRect &repaintRegion)
{
    if (hideTitleBar())
    {
        return;
    }

    if (!hideCaption())
    {
        const auto c = client();
        const bool active = c->isActive();
        int titleAlignment = internalSettings()->titleAlignment();
        bool invertText = internalSettings()->invertTextColor() && c->isMaximized();

        QRect captionRect(m_leftButtons->geometry().right() /*+ 4 + (c->isMaximized() ? 5 : 0)*/, 0, m_rightButtons->geometry().left() - m_leftButtons->geometry().right() - 4, borderTop());
        QString caption = settings()->fontMetrics().elidedText(c->caption(), Qt::ElideMiddle, captionRect.width());
        QStringList programname = caption.split(" — ");
        caption.remove(" — " + programname.at(programname.size()-1));
        //caption.prepend(" ");
        caption.append(" ");
        int blurWidth = settings()->fontMetrics().horizontalAdvance(caption + "..JO  ");
        int blurHeight = settings()->fontMetrics().height();
        QColor shadowColor = QColor(0, 0, 0, 255);
        QColor textColor = c->color(c->isActive() ? KDecoration2::ColorGroup::Active : KDecoration2::ColorGroup::Inactive, KDecoration2::ColorRole::Foreground);
        if(invertText)
        {
            textColor.setRed(255-textColor.red());
            textColor.setGreen(255-textColor.green());
            textColor.setBlue(255-textColor.blue());
        }
        int textHaloXOffset = 1;
        int textHaloYOffset = 1;
        int textHaloSize = 2;
        captionRect.setHeight(captionRect.height() & -2);
        painter->setFont(settings()->font());
        painter->setPen(shadowColor);
        painter->setPen(textColor);
        Qt::Alignment alignment = Qt::AlignLeft;

        QLabel temp_label(caption);
        QPalette palette = temp_label.palette();
        palette.setColor(temp_label.backgroundRole(), textColor);
        palette.setColor(temp_label.foregroundRole(), textColor);
        temp_label.setPalette(palette);
        temp_label.setFont(settings()->font());
        temp_label.setFixedWidth(captionRect.width());
        temp_label.setFixedHeight(blurHeight*1.2);
        QGraphicsGlowEffect temp_effect;
        temp_effect.setColor(QColor::fromRgb(255, 255, 255, 0));
        temp_effect.setBlurRadius(10);
        temp_label.setGraphicsEffect(&temp_effect);
        QLabel real_label(caption);
        palette = real_label.palette();
        palette.setColor(real_label.backgroundRole(), textColor);
        palette.setColor(real_label.foregroundRole(), textColor);
        real_label.setPalette(palette);
        real_label.setFont(settings()->font());
        real_label.setStyleSheet("QLabel { background: #00ffffff; }");
        real_label.setFixedWidth(captionRect.width());
        real_label.setFixedHeight(captionRect.height());

        if(titleAlignment == InternalSettings::AlignRight)
            real_label.setAlignment(Qt::AlignRight);
        else if(titleAlignment == InternalSettings::AlignCenter)
            real_label.setAlignment(Qt::AlignHCenter);
        else if(titleAlignment == InternalSettings::AlignCenterFullWidth)
        {
            real_label.setFixedWidth(size().width());
            real_label.setAlignment(Qt::AlignHCenter);
        }


        int captionHeight = captionRect.height() * 0.8;
        QPixmap final_label(blurWidth, blurHeight*2);
        final_label.fill(QColor::fromRgb(0,0,0,0));
        QPainter *ptr = new QPainter(&final_label);
        QPainterPath path;
        path.addRoundedRect(0, 0, blurWidth, blurHeight, 12,12);
        ptr->fillPath(path, QColor::fromRgb(255,255,255, active ? 186 : 148));
        delete ptr;

        if(!caption.trimmed().isEmpty())
        {
            QPixmap blur_effect = temp_effect.drawBlur(final_label);
            float offset = isMaximized() ? -0.1 : 0.05;
            float offsetHeight = 3;//isMaximized() ? 2.5 : 3;//isMaximized() ? 1.2 : 1;

            if(titleAlignment == InternalSettings::AlignCenterFullWidth)
            {
                captionRect.setX(0);
                captionRect.setWidth(size().width());
            }
            float xpos = captionRect.x();

            if(titleAlignment == InternalSettings::AlignRight)
            {
                xpos += captionRect.width() - blurWidth;
            }
            else if(titleAlignment == InternalSettings::AlignCenter || titleAlignment == InternalSettings::AlignCenterFullWidth)
            {
                xpos += captionRect.width()/2 - blurWidth/2;
            }
            else
            {
                xpos *= 0.65;
            }

            if(!invertText) painter->drawPixmap(QRect(xpos,(borderTop() - blurHeight*(offsetHeight/1.5)) / 2,blurWidth,blurHeight*offsetHeight), blur_effect);
            QPixmap text_pixmap = real_label.grab();

            if(titleAlignment == InternalSettings::AlignRight)
            {
                captionRect.translate(-12, -1);
            }
            else if(titleAlignment == InternalSettings::AlignLeft)
            {
                captionRect.translate(5, -1);
            }
            else if(titleAlignment == InternalSettings::AlignCenterFullWidth || titleAlignment == InternalSettings::AlignCenter)
            {
                captionRect.translate(1, -1);
            }
            painter->drawPixmap(captionRect, text_pixmap);
        }
    }

    m_leftButtons->paint(painter, repaintRegion);
    m_rightButtons->paint(painter, repaintRegion);

    foreach (QPointer<KDecoration2::DecorationButton> button, m_rightButtons->buttons()) {
        static_cast<Button *>(button.data())->smodPaintGlow(painter, repaintRegion);
    }
}

}
