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
    const int radius = isMaximized() ? 0 : 6;

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

    int SIDEBAR_HEIGHT = qMax(50, (size().height() / 4));

    painter->setOpacity(0.75);

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
            painter->drawPixmap(0, 0, 7, SIDEBAR_HEIGHT, sidehighlight);
            painter->drawPixmap(size().width() - 7, 0, 7, SIDEBAR_HEIGHT, sidehighlight);
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
            painter->drawPixmap(0, 0, 7, SIDEBAR_HEIGHT, sidehighlight);
            painter->drawPixmap(size().width() - 7, 0, 7, SIDEBAR_HEIGHT, sidehighlight);
        }
    }

    painter->setOpacity(1.0);
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

        QRect captionRect(m_leftButtons->geometry().right() + 4 + (c->isMaximized() ? 5 : 0), 0, m_rightButtons->geometry().left() - m_leftButtons->geometry().right() - 4, borderTop());
        QString caption = settings()->fontMetrics().elidedText(c->caption(), Qt::ElideMiddle, captionRect.width());
        QStringList programname = caption.split(" — ");
        caption.remove(" — " + programname.at(programname.size()-1));
        caption.prepend(" ");
        caption.append(" ");
        int blurWidth = settings()->fontMetrics().horizontalAdvance(caption + "..JO");
        int blurHeight = settings()->fontMetrics().height();
        //factory()->setTitleTextWidth(blurWidth);
        //factory()->setTitleTextHeight(blurHeight);
        //factory()->setMaximized(c->isMaximized());

        //if (drawTitle)
        //{
        QColor shadowColor = QColor(0, 0, 0, 255);
        QColor textColor = c->color(active ? KDecoration2::ColorGroup::Active : KDecoration2::ColorGroup::Inactive, KDecoration2::ColorRole::Foreground);
        int textHaloXOffset = 1;
        int textHaloYOffset = 1;
        int textHaloSize = 2;
        //if (!config->useKWinTextColors) {
        //    alpha_color &c = fs->text_halo;
        //    shadowColor = QColor::fromRgbF(c.color.r, c.color.g, c.color.b, c.alpha);
        //    c = fs->text;
        //    textColor = QColor::fromRgbF(c.color.r, c.color.g, c.color.b, c.alpha);
        //}
        captionRect.setHeight(captionRect.height() & -2);
        painter->setFont(settings()->font());
        painter->setPen(shadowColor);
    //    painter->drawText(captionRect.adjusted(1, 1, 1, 1), Qt::AlignVCenter, caption);
        painter->setPen(textColor);
        //Qt::Alignment alignment = Qt::AlignHCenter;
        Qt::Alignment alignment = Qt::AlignLeft;
        //if (ws->tobj_layout) {
        //    alignment = parseTitleAlignment(ws->tobj_layout);
        //}
        QLabel temp_label(caption);
        QGraphicsGlowEffect temp_effect;
        temp_effect.setColor(QColor::fromRgb(255, 255, 255, 0));
        temp_effect.setBlurRadius(7);
        temp_label.setGraphicsEffect(&temp_effect);

        int captionHeight = captionRect.height() * 0.8;
        QPixmap final_label(blurWidth, captionHeight);
        final_label.fill(QColor::fromRgb(0,0,0,0));
        QPainter *ptr = new QPainter(&final_label);
        QPainterPath path;
        path.addRoundedRect(0, 0, blurWidth, captionHeight, 12,12);
        ptr->fillPath(path, QColor::fromRgb(255,255,255, active ? 186 : 148));
        delete ptr;

        if(!caption.trimmed().isEmpty())
        {
            QPixmap blur_effect = temp_effect.drawBlur(final_label);
            painter->drawPixmap(QRect(captionRect.x()*0.7,captionRect.y(),blurWidth,captionRect.height()), blur_effect);
            painter->drawText(captionRect, alignment | Qt::AlignVCenter | Qt::TextSingleLine, caption);
        }
    }

    m_leftButtons->paint(painter, repaintRegion);
    m_rightButtons->paint(painter, repaintRegion);

    foreach (QPointer<KDecoration2::DecorationButton> button, m_rightButtons->buttons()) {
        static_cast<Button *>(button.data())->smodPaintGlow(painter, repaintRegion);
    }
}

}
