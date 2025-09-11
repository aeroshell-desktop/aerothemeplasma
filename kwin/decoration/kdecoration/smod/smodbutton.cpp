#include "../breezebutton.h"
#include "../frametexture.h"
#include "../sizingmargins.h"

//#include "../breezedecoration.h"

#include <QPainter>
#include <QGraphicsColorizeEffect>
#include <KDecoration3/DecorationButtonGroup>

#include <KIconLoader>

namespace Breeze
{
    using KDecoration3::DecorationButtonType;

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

    void Button::smodPaint(QPainter *painter, const QRectF &repaintRegion)
    {
        Q_UNUSED(repaintRegion)

        if (!decoration()) {
            return;
        }

        painter->save();
        auto deco = qobject_cast<Decoration *>(decoration());
        int titlebarHeight = deco->titlebarHeight();

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
            const auto c = deco->window();
            QRectF iconRect(geometry().topLeft(), m_iconSize);

            const int vPadding = c->isMaximized() ? 1 : (decoration()->settings()->smallSpacing() * Metrics::TitleBar_TopMargin)-1;
            const int hPadding = c->isMaximized() ? -2 : 0;

            painter->save();
            painter->translate(QPointF(hPadding, vPadding));

            iconRect.translate(0, (titlebarHeight - m_iconSize.height())/2);
            c->icon().paint(painter, iconRect.toRect());

            painter->restore();

            return;
        }
        else if (type() == DecorationButtonType::Close
              || type() == DecorationButtonType::Maximize
              || type() == DecorationButtonType::Minimize
              || type() == DecorationButtonType::ContextHelp
              || type() == DecorationButtonType::Shade
              || type() == DecorationButtonType::KeepAbove
              || type() == DecorationButtonType::KeepBelow
              || type() == DecorationButtonType::OnAllDesktops
              || type() == DecorationButtonType::ApplicationMenu)
        {
            QRectF g = geometry();
            qreal w = g.width();
            qreal h = g.height();

            // sizing margins
            int l = 0;
            int t = 0;
            int r = 0;
            int b = 0;

            // content margins
            int c_l = 0;
            int c_t = 0;
            int c_r = 0;
            int c_b = 0;

            bool buttonBefore{false};
            bool buttonAfter{false};

            // cast the parent class
            const KDecoration3::DecorationButtonGroup *btnGroup = (KDecoration3::DecorationButtonGroup*)(this->parent());

            // just in case
            if(btnGroup == nullptr) {
                qWarning() << "kdecorationbutton parent is nullptr, returning";
                return;
            };

            index = btnGroup->buttons().indexOf(this);

            QString btnGroupPos = "right";
            if(btnGroup->pos().x() < deco->captionWidth()/2) btnGroupPos = "left";

            const auto internalSettingsButtons = btnGroupPos == "left"
                                                        ? decoration()->settings()->decorationButtonsLeft()
                                                        : decoration()->settings()->decorationButtonsRight();

            const auto c = decoration()->window();

            painter->translate(g.topLeft());

            if(c->isMaximized()) painter->translate(QPoint(-2, 0));

            auto d = qobject_cast<Decoration *>(decoration());
            auto margins = d->sizingMargins();
            ButtonSizingMargins minimizeMargins, maximizeMargins, buttonMargins;

            // pswin was here
            QPixmap glyph, glyphHover, glyphActive;
            QPixmap normal, hover, active;
            QPixmap normalL, hoverL, activeL;
            QPixmap normalR, hoverR, activeR;

            QImage normalImg, hoverImg, activeImg;

            QPoint glyphOffset;

            QString glyphType, dpiScale = "";

            if(titlebarHeight >= 22 && titlebarHeight < 25) dpiScale = "@1.25x";
            else if(titlebarHeight >= 25 && titlebarHeight < 27) dpiScale = "@1.5x";
            else if(titlebarHeight >= 27) dpiScale = "@2x";

            int leftoverwidth = 0;
            int leftoverheight = 0;

            if(btnGroup->buttons().length() > 1)
            {
                if(index > 0) {
                    const auto button = internalSettingsButtons.at(index-1);

                    buttonBefore = !(button == DecorationButtonType::Spacer || button == DecorationButtonType::Menu) && btnGroup->buttons().at(index-1)->isVisible();
                }
                if(index != btnGroup->buttons().length() - 1) {
                    const auto button = internalSettingsButtons.at(index+1);

                    buttonAfter = !(button == DecorationButtonType::Spacer || button == DecorationButtonType::Menu) && btnGroup->buttons().at(index+1)->isVisible();
                }
            }

            bool isSingleClose = !(c->isMinimizeable() || c->isMaximizeable() || c->providesContextHelp()) || (!buttonAfter && !buttonBefore);

            // BEGIN BUTTON

            minimizeMargins = margins.minimizeSizing();
            maximizeMargins = margins.maximizeSizing();

            switch (type())
            {
                case DecorationButtonType::Maximize: {
                    buttonMargins = maximizeMargins;

                    glyphType = c->isMaximized() ? "restore" : "maximize";
                    m_textureType = "maximize";

                    break;
                }
                case DecorationButtonType::Close: {
                    buttonMargins = isSingleClose ? margins.closeLoneSizing() : margins.closeSizing();

                    glyphType = "close";

                    if(isSingleClose) m_textureType = "close-single";
                    else m_textureType = "close";

                    break;
                }
                default: {
                    switch(type()) {
                        case DecorationButtonType::ApplicationMenu:
                            m_isToggled = d->window()->isApplicationMenuActive();
                            buttonMargins = margins.menuSizing();
                            glyphType = "menu";
                            break;

                        case DecorationButtonType::OnAllDesktops:
                            m_isToggled = d->window()->isOnAllDesktops();
                            buttonMargins = margins.pinSizing();
                            glyphType = "pin";
                            break;

                        case DecorationButtonType::Shade:
                            m_isToggled = d->window()->isShaded();
                            buttonMargins = margins.shadeSizing();
                            glyphType = "shade";
                            break;

                        case DecorationButtonType::KeepAbove:
                            m_isToggled = d->window()->isKeepAbove();
                            buttonMargins = margins.overlapSizing();
                            glyphType = "overlap";
                            break;

                        case DecorationButtonType::KeepBelow:
                            m_isToggled = d->window()->isKeepBelow();
                            buttonMargins = margins.underlapSizing();
                            glyphType = "underlap";
                            break;

                        case DecorationButtonType::ContextHelp:
                            buttonMargins = margins.helpSizing();
                            glyphType = "help";
                            break;

                        case DecorationButtonType::Minimize:
                            buttonMargins = margins.minimizeSizing();
                            glyphType = "minimize";
                            break;

                        default:
                            break;
                    }

                    buttonMargins = minimizeMargins;

                    m_textureType = "minimize";

                    break;
                }
            }
            // END BUTTON

            // WARNING: this part of the code is definitely not pretty.

            // load the textures normally first
            {
                if(!c->isActive()) m_textureType += "-unfocus";

                normal      = QPixmap(":/smod/decoration/" + m_textureType);
                hover       = QPixmap(":/smod/decoration/" + m_textureType + "-hover");
                active      = QPixmap(":/smod/decoration/" + m_textureType + "-active");
            }

            // BEGIN FLIPPING AND MIRRORING LOGIC
            if(margins.commonSizing().group_buttons) {
                QImage copy;

                // if there's a button before this button and after this button
                if(buttonBefore && buttonAfter)
                {
                    if(type() != DecorationButtonType::Close && type() != DecorationButtonType::Maximize) {
                        m_textureType = "maximize";
                        if(!c->isActive()) m_textureType += "-unfocus";

                        normal      = QPixmap(":/smod/decoration/" + m_textureType);
                        hover       = QPixmap(":/smod/decoration/" + m_textureType + "-hover");
                        active      = QPixmap(":/smod/decoration/" + m_textureType + "-active");

                    }

                    else if(type() == DecorationButtonType::Close) {
                        // get left parts of each image
                        normalL = normal.copy(0, 0,
                                              round(normal.width()/2), normal.height());
                        hoverL  =  hover.copy(0, 0,
                                              round(hover.width()/2), hover.height());
                        activeL = active.copy(0, 0,
                                              round(active.width()/2), active.height());

                        // flip the copied images to mirror the close image
                        copy = normalL.toImage();
                        copy.flip(Qt::Horizontal);
                        normalR = QPixmap::fromImage(copy);

                        copy = hoverL.toImage();
                        copy.flip(Qt::Horizontal);
                        hoverR  = QPixmap::fromImage(copy);

                        copy = activeL.toImage();
                        copy.flip(Qt::Horizontal);
                        activeR = QPixmap::fromImage(copy);

                        m_isMirrored = true;
                    }
                }

                // if there's a button before this button but not after this button
                else if(buttonBefore && !buttonAfter)
                {
                    if(type() != DecorationButtonType::Close)
                    {
                        m_textureType = "minimize";
                        if(!c->isActive()) m_textureType += "-unfocus";

                        normal      = QPixmap(":/smod/decoration/" + m_textureType);
                        hover       = QPixmap(":/smod/decoration/" + m_textureType + "-hover");
                        active      = QPixmap(":/smod/decoration/" + m_textureType + "-active");

                        normalImg = normal.toImage();
                        hoverImg  = hover.toImage();
                        activeImg = active.toImage();

                        normalImg.flip(Qt::Horizontal);
                        hoverImg.flip(Qt::Horizontal);
                        activeImg.flip(Qt::Horizontal);

                        normal = QPixmap::fromImage(normalImg);
                        hover  = QPixmap::fromImage(hoverImg);
                        active = QPixmap::fromImage(activeImg);

                        m_isFlipped = true;
                    }
                }

                // if there's a button after this button but not before this button
                else if(!buttonBefore && buttonAfter)
                {
                    if(type() != DecorationButtonType::Close && type() != DecorationButtonType::Minimize)
                    {
                        m_textureType = "minimize";
                        if(!c->isActive()) m_textureType += "-unfocus";

                        normal      = QPixmap(":/smod/decoration/" + m_textureType);
                        hover       = QPixmap(":/smod/decoration/" + m_textureType + "-hover");
                        active      = QPixmap(":/smod/decoration/" + m_textureType + "-active");
                    }

                    else if(type() == DecorationButtonType::Close) {
                        normalImg = normal.toImage();
                        hoverImg  = hover.toImage();
                        activeImg = active.toImage();

                        normalImg.flip(Qt::Horizontal);
                        hoverImg.flip(Qt::Horizontal);
                        activeImg.flip(Qt::Horizontal);

                        normal = QPixmap::fromImage(normalImg);
                        hover  = QPixmap::fromImage(hoverImg);
                        active = QPixmap::fromImage(activeImg);

                        m_isFlipped = true;
                    }
                }

                // if the button is alone
                else if(!buttonBefore && !buttonAfter && type() != DecorationButtonType::Close)
                {
                    m_textureType = "minimize";
                    if(!c->isActive()) m_textureType += "-unfocus";

                    normal      = QPixmap(":/smod/decoration/" + m_textureType);
                    hover       = QPixmap(":/smod/decoration/" + m_textureType + "-hover");
                    active      = QPixmap(":/smod/decoration/" + m_textureType + "-active");

                    // get left parts of each image
                    normalL = normal.copy(0, 0,
                                          round(normal.width()/2), normal.height());
                    hoverL  =  hover.copy(0, 0,
                                          round(hover.width()/2), hover.height());
                    activeL = active.copy(0, 0,
                                          round(active.width()/2), active.height());

                    // flip the copied images to mirror the close image
                    copy = normalL.toImage();
                    copy.flip(Qt::Horizontal);
                    normalR = QPixmap::fromImage(copy);

                    copy = hoverL.toImage();
                    copy.flip(Qt::Horizontal);
                    hoverR  = QPixmap::fromImage(copy);

                    copy = activeL.toImage();
                    copy.flip(Qt::Horizontal);
                    activeR = QPixmap::fromImage(copy);

                    m_isMirrored = true;
                }
            }
            // END FLIPPING AND MIRRORING LOGIC

            // BEGIN MARGINS
            {
                if(m_textureType == "minimize") {
                    if(type() == DecorationButtonType::Maximize) {
                        buttonMargins.margin_left = minimizeMargins.margin_left;
                        buttonMargins.margin_top = minimizeMargins.margin_top;
                        buttonMargins.margin_right = minimizeMargins.margin_right;
                        buttonMargins.margin_bottom = minimizeMargins.margin_bottom;
                    }
                }
                else if(m_textureType == "maximize") {
                    if(type() != DecorationButtonType::Maximize) {
                        buttonMargins.margin_left = maximizeMargins.margin_left;
                        buttonMargins.margin_top = maximizeMargins.margin_top;
                        buttonMargins.margin_right = maximizeMargins.margin_right;
                        buttonMargins.margin_bottom = maximizeMargins.margin_bottom;
                    }
                }

                l = buttonMargins.margin_left;
                t = buttonMargins.margin_top;
                r = buttonMargins.margin_right;
                b = buttonMargins.margin_bottom;

                c_l = buttonMargins.content_left;
                c_t = buttonMargins.content_top;
                c_r = buttonMargins.content_right;
                c_b = buttonMargins.content_bottom;

                if(m_isFlipped) {
                    l = buttonMargins.margin_right;
                    r = buttonMargins.margin_left;

                    c_l = buttonMargins.content_right;
                    c_r = buttonMargins.content_left;
                }

                if(m_isMirrored) {
                    l = buttonMargins.margin_left;
                    r = buttonMargins.margin_left;

                    c_l = buttonMargins.content_left;
                    c_r = buttonMargins.content_left;
                }
            }

            leftoverwidth = w - c_l - c_r;
            if(leftoverwidth < 0) leftoverwidth = 0;
            leftoverheight = (titlebarHeight-1) - c_t - c_b;
            if(leftoverheight < 0) leftoverheight = 0;

            if(m_textureType == "maximize") {
                if(titlebarHeight == 18) l--;
                if(titlebarHeight == 17) l -= 2;
            }
            else if(m_textureType == "minimize") {
                if(titlebarHeight == 18 || titlebarHeight == 17) l--;
            }
            // END MARGINS

            // BEGIN GLYPHS
            {
                if(!isEnabled()) glyphType += "-inactive";

                glyph       = QPixmap(":/smod/decoration/" + glyphType + "-glyph" + dpiScale);
                glyphHover  = QPixmap(":/smod/decoration/" + glyphType + "-hover-glyph" + dpiScale);
                glyphActive = QPixmap(":/smod/decoration/" + glyphType + "-active-glyph" + dpiScale);
            }

            switch (type())
            {
                case DecorationButtonType::Maximize:
                    if(d && d->isMaximized()) {
                        glyphOffset = QPoint(
                            c_l + ceil((leftoverwidth - glyph.width()) / 2.0),
                            c_t  + ceil((leftoverheight - glyph.height()) / 2.0)
                        );

                    } else {
                        glyphOffset = QPoint(
                            c_l + ceil((leftoverwidth - glyph.width()) / 2.0),
                            c_t  + ceil((leftoverheight - glyph.height()) / 2.0)
                        );

                    }
                    break;

                case DecorationButtonType::Close:
                    glyphOffset = QPoint(
                        c_l + ceil((leftoverwidth - glyph.width()) / 2.0),
                        c_t  + ceil((leftoverheight - glyph.height()) / 2.0)
                    );
                    break;

                default:
                    glyphOffset = QPoint(
                        c_l + ceil((leftoverwidth - glyph.width()) / 2.0),
                        c_t  + ceil((leftoverheight - glyph.height()) / 2.0)
                    );
                    break;
            }
            // END GLYPHS

            QImage image, hImage, aImage;
            QImage imageL, hImageL, aImageL;
            QImage imageR, hImageR, aImageR;

            image = normal.toImage();
            hImage = hover.toImage();
            aImage = active.toImage();

            imageL = normalL.toImage();
            hImageL = hoverL.toImage();
            aImageL = activeL.toImage();

            imageR = normalR.toImage();
            hImageR = hoverR.toImage();
            aImageR = activeR.toImage();

            FrameTexture btn(l, r, t, b, w, h, &normal);
            FrameTexture btnL(l, 0, t, b, round(w/2), h, &normalL);
            FrameTexture btnR(0, r, t, b, round(w/2), h, &normalR);
            painter->setRenderHint(QPainter::Antialiasing, true);
            painter->setRenderHint(QPainter::SmoothPixmapTransform, true);
            if (!isPressed() && !m_isToggled)
            {
                if(!imageL.isNull() && !imageR.isNull()) {
                    imageL = hoverImage(imageL, hImageL, m_hoverProgress);
                    imageR = hoverImage(imageR, hImageR, m_hoverProgress);
                    normalL.convertFromImage(imageL);
                    normalR.convertFromImage(imageR);

                    btnL.render(painter);
                    btnR.translate(round(w/2), 0);
                    btnR.render(painter);
                } else {
                    image = hoverImage(image, hImage, m_hoverProgress);
                    normal.convertFromImage(image);

                    btn.render(painter);
                }
                painter->drawPixmap(glyphOffset.x(), glyphOffset.y(), glyph.width(), glyph.height(), isHovered() ? glyphHover : glyph);
            }
            else
            {
                if(!imageL.isNull() && !imageR.isNull()) {
                    normalL.convertFromImage(aImageL);
                    normalR.convertFromImage(aImageR);

                    btnL.render(painter);
                    btnR.translate(round(w/2), 0);
                    btnR.render(painter);
                } else {
                    normal.convertFromImage(aImage);

                    btn.render(painter);
                }
                painter->drawPixmap(glyphOffset.x(), glyphOffset.y(), glyph.width(), glyph.height(), glyphActive);
            }

            painter->restore();
            return;
        }

        drawIcon(painter);

        painter->restore();
    }
    void Button::hoverEnterEvent(QHoverEvent *event)
    {
        KDecoration3::DecorationButton::hoverEnterEvent(event);

        if (isHovered())
        {
            Q_EMIT buttonHoverStatus(type(), m_isFlipped, m_textureType,  true, geometry().topLeft().toPoint());
            startHoverAnimation(1.0);
        }
    }

    void Button::hoverLeaveEvent(QHoverEvent *event)
    {
        KDecoration3::DecorationButton::hoverLeaveEvent(event);

        if (!isHovered())
        {
            Q_EMIT buttonHoverStatus(type(), m_isFlipped, m_textureType, false, geometry().topLeft().toPoint());
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
