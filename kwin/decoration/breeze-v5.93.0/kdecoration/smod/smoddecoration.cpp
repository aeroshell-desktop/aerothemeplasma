#include "../breezedecoration.h"
#include "../breezebutton.h"
#include "../frametexture.h"
#include "qgraphicsgloweffect.h"

#include <QPainter>
#include <QPainterPath>
#include <QString>

#include <KDecoration2/DecorationButtonGroup>

namespace Breeze
{
static int g_sDecoCount = 0;
static std::shared_ptr<KDecoration2::DecorationShadow> g_smod_shadow, g_smod_shadow_unfocus;


Decoration::Decoration(QObject *parent, const QVariantList &args)
: KDecoration2::Decoration(parent, args)
, m_animation(new QVariantAnimation(this))
, m_shadowAnimation(new QVariantAnimation(this))
{
    g_sDecoCount++;
}

Decoration::~Decoration()
{
    g_sDecoCount--;
    if (g_sDecoCount == 0) {
        // last deco destroyed, clean up shadow
        g_smod_shadow.reset();
        g_smod_shadow_unfocus.reset();
    }
}
int Decoration::decorationCount()
{
    return g_sDecoCount;
}
void Decoration::updateShadow()
{
    if(!internalSettings()->enableShadow())
    {
        setShadow(std::shared_ptr<KDecoration2::DecorationShadow>(nullptr));
        return;
    }
    if (client()->isActive())
    {
        g_smod_shadow = g_smod_shadow ? g_smod_shadow : smodCreateShadow(true);
        setShadow(g_smod_shadow);
    }
    else
    {
        g_smod_shadow_unfocus = g_smod_shadow_unfocus ? g_smod_shadow_unfocus : smodCreateShadow(false);
        setShadow(g_smod_shadow_unfocus);
    }

}
std::shared_ptr<KDecoration2::DecorationShadow> Decoration::smodCreateShadow(bool active)
{
    QImage shadowTexture = QImage(active ? ":/smod/decoration/shadow" : ":/smod/decoration/shadow-unfocus");
    auto margins = sizingMargins().shadowSizing();
    QMargins texMargins(margins.margin_left, margins.margin_top, margins.margin_right, margins.margin_bottom);
    QMargins padding(margins.padding_left, margins.padding_top, margins.padding_right, margins.padding_bottom);
    QRect innerShadowRect = shadowTexture.rect() - texMargins;

    auto shadow = std::make_shared<KDecoration2::DecorationShadow>();
    shadow->setPadding(padding);
    shadow->setInnerShadowRect(innerShadowRect);
    shadow->setShadow(shadowTexture);
    return shadow;
}

void Decoration::updateBlur()
{
    auto margins = sizingMargins().commonSizing();
    const int radius = isMaximized() ? 0 : margins.corner_radius+1;

    QPainterPath path;
    path.addRoundedRect(rect(), radius, radius);

    setBlurRegion(QRegion(path.toFillPolygon().toPolygon()));

    updateShadow();
}

void Decoration::smodPaint(QPainter *painter, const QRect &repaintRegion)
{
    painter->fillRect(rect(), Qt::transparent);

    smodPaintOuterBorder(painter, repaintRegion);
    smodPaintInnerBorder(painter, repaintRegion);
    smodPaintGlow(painter, repaintRegion);
    smodPaintTitleBar(painter, repaintRegion);
}

void Decoration::smodPaintGlow(QPainter *painter, const QRect &repaintRegion)
{
    const auto c = client();

    int SIDEBAR_HEIGHT = qMax(25, (size().height() / 4));

    if(internalSettings()->invertTextColor() && isMaximized()) return;
    //painter->setOpacity(0.75);
    painter->setClipRegion(blurRegion());
    painter->setClipping(true);

        if(!isMaximized() && !hideInnerBorder())
        {

            //painter->setOpacity(1.0);
                // 7x116
            auto margins_left = sizingMargins().frameLeftSizing();
            auto margins_right = sizingMargins().frameRightSizing();
            QPixmap sidehighlight(":/smod/decoration/sidehighlight" + (!c->isActive() ? QString("-unfocus") : QString("")));
            painter->drawPixmap(margins_left.outer_inset, borderTop(), borderLeft() - margins_left.inner_inset - margins_left.outer_inset, SIDEBAR_HEIGHT, sidehighlight);
            painter->drawPixmap(size().width() - borderRight() + margins_right.inner_inset, borderTop(), borderRight() - margins_right.inner_inset - margins_right.outer_inset, SIDEBAR_HEIGHT, sidehighlight);

        }

    //painter->setOpacity(1.0);
    painter->setClipping(false);
}
void Decoration::smodPaintOuterBorder(QPainter *painter, const QRect &repaintRegion)
{
    Q_UNUSED(repaintRegion)

    bool active = client()->isActive();
    QString n_s ;
    auto margins_top = sizingMargins().frameTopSizing();
    auto margins_left = sizingMargins().frameLeftSizing();
    auto margins_right = sizingMargins().frameRightSizing();
    auto margins_bottom = sizingMargins().frameBottomSizing();

    int outerBorderSize = 9;
    int right  = size().width()  - outerBorderSize;
    int bottom = size().height() - outerBorderSize;

    if (isMaximized())
    {

        if(internalSettings()->enableShadow())
        {
            n_s = active ? ":/smod/decoration/frame-focus-n"  : ":/smod/decoration/frame-unfocus-n";
        }
        else
        {
            n_s = active ? ":/smod/decoration/n"  : ":/smod/decoration/n-unfocus";
        }
        QPixmap n (n_s);
        QPixmap fill_n = n.copy(0, margins_top.outer_inset, n.width(), n.height() - margins_top.outer_inset).scaled(n.width(), borderTop() - margins_top.outer_inset - margins_top.inner_inset);
        QSize fillSizeN(size().width(), fill_n.height() + margins_top.outer_inset);
        painter->drawTiledPixmap(QRect(QPoint(0, 0), fillSizeN), fill_n);
        return;
    }

    QString s_s ;
    QString e_s ;
    QString w_s ;
    QString nw_s;
    QString sw_s;
    QString ne_s;
    QString se_s;
    if(internalSettings()->enableShadow())
    {
        n_s = active ? ":/smod/decoration/frame-focus-n"  : ":/smod/decoration/frame-unfocus-n";
        s_s = active ? ":/smod/decoration/frame-focus-s"  : ":/smod/decoration/frame-unfocus-s";
        e_s = active ? ":/smod/decoration/frame-focus-e"  : ":/smod/decoration/frame-unfocus-e";
        w_s = active ? ":/smod/decoration/frame-focus-w"  : ":/smod/decoration/frame-unfocus-w";
        nw_s = active ? ":/smod/decoration/frame-focus-nw" : ":/smod/decoration/frame-unfocus-nw";
        sw_s = active ? ":/smod/decoration/frame-focus-sw" : ":/smod/decoration/frame-unfocus-sw";
        ne_s = active ? ":/smod/decoration/frame-focus-ne" : ":/smod/decoration/frame-unfocus-ne";
        se_s = active ? ":/smod/decoration/frame-focus-se" : ":/smod/decoration/frame-unfocus-se";

    }
    else
    {
        n_s = active ? ":/smod/decoration/n"  : ":/smod/decoration/n-unfocus";
        s_s = active ? ":/smod/decoration/s"  : ":/smod/decoration/s-unfocus";
        e_s = active ? ":/smod/decoration/e"  : ":/smod/decoration/e-unfocus";
        w_s = active ? ":/smod/decoration/w"  : ":/smod/decoration/w-unfocus";
        nw_s = active ? ":/smod/decoration/nw" : ":/smod/decoration/nw-unfocus";
        sw_s = active ? ":/smod/decoration/sw" : ":/smod/decoration/sw-unfocus";
        ne_s = active ? ":/smod/decoration/ne" : ":/smod/decoration/ne-unfocus";
        se_s = active ? ":/smod/decoration/se" : ":/smod/decoration/se-unfocus";
    }

    QPixmap n (n_s);
    QPixmap s (s_s);
    QPixmap e (e_s);
    QPixmap w (w_s);
    QPixmap nw(nw_s);
    QPixmap sw(sw_s);
    QPixmap ne(ne_s);
    QPixmap se(se_s);


    QPoint pointN(outerBorderSize, 0);
    QPoint pointS(outerBorderSize, size().height()-margins_bottom.outer_inset);
    QPoint pointE(size().width() - margins_right.outer_inset, outerBorderSize);
    QPoint pointW(0, outerBorderSize);
    QPoint pointNW(0, 0);
    QPoint pointSW(0, bottom);
    QPoint pointNE(right, 0);
    QPoint pointSE(right, bottom);

    QSize sizeNW(outerBorderSize, outerBorderSize);
    QSize sizeSW(outerBorderSize, outerBorderSize);
    QSize sizeNE(outerBorderSize, outerBorderSize);
    QSize sizeSE(outerBorderSize, outerBorderSize);

    QPixmap fill_n = n.copy(0, margins_top.outer_inset, n.width(), n.height() - margins_top.outer_inset).scaled(n.width(), borderTop() - margins_top.outer_inset - margins_top.inner_inset);
    QPixmap fill_s = s.copy(0, 0, s.width(), s.height() - margins_bottom.outer_inset).scaled(s.width(), borderBottom() - margins_bottom.outer_inset - margins_bottom.inner_inset);
    QPixmap fill_e = e.copy(0, 0, e.width() - margins_right.outer_inset, e.height()).scaled(borderRight() - margins_right.outer_inset - margins_right.inner_inset, e.height());
    QPixmap fill_w = w.copy(margins_left.outer_inset, 0, w.width() - margins_right.outer_inset , w.height()).scaled(borderLeft() - margins_left.outer_inset - margins_left.inner_inset, w.height());

    QPoint fillN(outerBorderSize-margins_left.inner_inset-1, margins_top.outer_inset);
    QPoint fillS(outerBorderSize, size().height() - borderBottom() + margins_bottom.inner_inset);
    QPoint fillW(margins_left.outer_inset, outerBorderSize);
    QPoint fillE(size().width() - borderRight() + margins_right.inner_inset, outerBorderSize);

    QSize fillSizeN(size().width() - outerBorderSize*2 + margins_left.inner_inset+1 + margins_right.inner_inset+1, fill_n.height());
    QSize fillSizeS(size().width() - outerBorderSize*2 + margins_left.inner_inset+1, fill_s.height());
    QSize fillSizeE(fill_e.width(), size().height() - outerBorderSize*2);
    QSize fillSizeW(fill_w.width(), size().height() - outerBorderSize*2);

    QRegion clippingMask(QRect(pointNW, sizeNW));
    clippingMask += QRect(pointNE, sizeNE);
    painter->setClipRegion(blurRegion() ^ clippingMask);
    painter->setClipping(true);
    painter->drawTiledPixmap(QRect(fillN, fillSizeN), fill_n);
    painter->setClipping(false);
    painter->setClipRegion(blurRegion());

    painter->drawTiledPixmap(QRect(fillS, fillSizeS), fill_s);
    painter->drawTiledPixmap(QRect(fillE, fillSizeE), fill_e);
    painter->drawTiledPixmap(QRect(fillW, fillSizeW), fill_w);

    QSize sizeN(right - outerBorderSize, margins_top.outer_inset);
    QSize sizeS(right - outerBorderSize, margins_bottom.outer_inset);
    QSize sizeE(margins_right.outer_inset, bottom - outerBorderSize);
    QSize sizeW(margins_left.outer_inset, bottom - outerBorderSize);

    painter->drawTiledPixmap(QRect(pointN, sizeN), n);
    painter->drawTiledPixmap(QRect(pointS, sizeS), s, QPoint(0, outerBorderSize - margins_bottom.outer_inset));
    painter->drawTiledPixmap(QRect(pointE, sizeE), e, QPoint(outerBorderSize - margins_right.outer_inset, 0));
    painter->drawTiledPixmap(QRect(pointW, sizeW), w);

    painter->drawPixmap(QRect(pointNW, sizeNW), nw);
    painter->drawPixmap(QRect(pointNE, sizeNE), ne);
    painter->drawPixmap(QRect(pointSE, sizeSE), se);
    painter->drawPixmap(QRect(pointSW, sizeSW), sw);
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

    auto margins_top = sizingMargins().frameTopSizing();
    auto margins_left = sizingMargins().frameLeftSizing();
    auto margins_right = sizingMargins().frameRightSizing();
    auto margins_bottom = sizingMargins().frameBottomSizing();
    // left
    painter->drawTiledPixmap(
        borderLeft() - margins_left.inner_inset,
        borderTop(),
        margins_left.inner_inset,
        size().height() - borderBottom() - borderTop(),
        w);

    // right
    painter->drawTiledPixmap(
        size().width() - borderRight(),
        borderTop(),
        margins_right.inner_inset,
        size().height() - borderBottom() - borderTop(),
        e);

    // bottom
    painter->drawTiledPixmap(
        borderLeft(),
        size().height() - borderBottom(),
        size().width() - borderLeft() - borderRight(),
        margins_bottom.inner_inset,
        s);

    // top
    painter->drawTiledPixmap(
        borderLeft(),
        borderTop() - margins_top.inner_inset,
        size().width() - borderLeft() - borderRight(),
        margins_top.inner_inset,
        n);

    painter->drawPixmap(borderLeft() - margins_left.inner_inset, borderTop() - margins_top.inner_inset, nw);
    painter->drawPixmap(size().width() - borderRight(), borderTop() - margins_top.inner_inset, ne);
    painter->drawPixmap(size().width() - borderRight(), size().height() - borderBottom(), se);
    painter->drawPixmap(borderLeft() - margins_left.inner_inset, size().height() - borderBottom(), sw);
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
        int titleAlignment = internalSettings()->titleAlignment();
        bool invertText = internalSettings()->invertTextColor() && c->isMaximized();

        QRect captionRect(m_leftButtons->geometry().right(), 0, m_rightButtons->geometry().left() - m_leftButtons->geometry().right() - 4, borderTop());
        QString caption = settings()->fontMetrics().elidedText(c->caption(), Qt::ElideMiddle, captionRect.width());
        QStringList programname = caption.split(" — ");
        caption.remove(" — " + programname.at(programname.size()-1));
        caption.append(" ");
        int blurWidth = settings()->fontMetrics().horizontalAdvance(caption + "..JO  ");
        int blurHeight = settings()->fontMetrics().height();
        QColor shadowColor = QColor(0, 0, 0, 255);
        QColor textColor = c->color(c->isActive() ? KDecoration2::ColorGroup::Active : KDecoration2::ColorGroup::Inactive, KDecoration2::ColorRole::Foreground);

        captionRect.setHeight(captionRect.height() & -2);
        painter->setFont(settings()->font());
        painter->setPen(shadowColor);
        painter->setPen(textColor);

        QLabel real_label(caption);
        QPalette palette = real_label.palette();
        if(invertText)
        {
            textColor.setRed(255-textColor.red());
            textColor.setGreen(255-textColor.green());
            textColor.setBlue(255-textColor.blue());
        }
        palette.setColor(real_label.backgroundRole(), textColor);
        palette.setColor(real_label.foregroundRole(), textColor);
        //if(invertText) real_label.setStyleSheet("QLabel { background: #00303030; }");
        //else
        real_label.setStyleSheet("QLabel { background: #00aaaaaa; }");
        real_label.setPalette(palette);
        auto f = settings()->font();
        f.setKerning(false);
        if(invertText) f.setWeight(QFont::DemiBold);
        //f.setBold()
        real_label.setFont(f);
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

        QPixmap glow(":/smod/decoration/glow");
        auto margins = sizingMargins().glowSizing();
        int l = margins.margin_left;
        int r = margins.margin_right;
        int t = margins.margin_top;
        int b = margins.margin_bottom;
        painter->setRenderHint(QPainter::Antialiasing, true);
        painter->setRenderHint(QPainter::SmoothPixmapTransform, true);

        int glowHeight = blurHeight*2+3;
        int glowWidth = blurWidth + 8;
        if(glowWidth < l+r)
        {
            glowWidth = l+r;
            //l -= (l+r) - glowWidth;
        }
        if(glowHeight < t+b)
        {
            glowHeight = t+b;
            //t -= (t+b) - glowHeight;
        }

        FrameTexture gl(l, r, t, b, glowWidth, glowHeight, &glow, c->isActive() ? margins.active_opacity : margins.inactive_opacity);

        if(!caption.trimmed().isEmpty())
        {
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
                xpos = m_leftButtons->geometry().x() + 2;
            }

            if(!invertText)
            {
                int alignmentOffset = 0;
                if(titleAlignment == InternalSettings::AlignCenter || titleAlignment == InternalSettings::AlignCenterFullWidth)
                {
                    alignmentOffset = -4;
                }
                else if(titleAlignment == InternalSettings::AlignRight)
                {
                    alignmentOffset = -8;
                }
                if(m_rightButtons->geometry().intersects(QRect(xpos + alignmentOffset, captionRect.height() / 2 - blurHeight - 2, glowWidth, glowHeight)))
                {

                    captionRect.setX(m_leftButtons->pos().x());
                    captionRect.setWidth(size().width() - m_rightButtons->geometry().width());
                    real_label.setFixedWidth(captionRect.width());
                    xpos = captionRect.x();
                    xpos += captionRect.width()/2 - blurWidth/2;

                }
                painter->translate(xpos + alignmentOffset, captionRect.height() / 2 - blurHeight - 2);
                gl.render(painter);
                painter->translate(-xpos - alignmentOffset, -captionRect.height() / 2 + blurHeight + 2);
            }

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
            if(invertText)
            {
                painter->setOpacity(0.7);
                painter->drawPixmap(captionRect, text_pixmap);
                painter->setOpacity(1.0);
                //painter->drawPixmap(captionRect, text_pixmap);
            }
        }
    }


    m_leftButtons->paint(painter, repaintRegion);
    m_rightButtons->paint(painter, repaintRegion);

    /*foreach (QPointer<KDecoration2::DecorationButton> button, m_rightButtons->buttons()) {
        static_cast<Button *>(button.data())->smodPaintGlow(painter, repaintRegion);
    }*/
}

}
