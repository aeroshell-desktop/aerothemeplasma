/*
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */
#include "breezebutton.h"

#include <KColorUtils>
#include <KDecoration2/DecoratedClient>
#include <KIconLoader>

#include <QPainter>
#include <QPainterPath>
#include <QVariantAnimation>

namespace Breeze
{
using KDecoration2::ColorGroup;
using KDecoration2::ColorRole;
using KDecoration2::DecorationButtonType;

//__________________________________________________________________
Button::Button(DecorationButtonType type, Decoration *decoration, QObject *parent)
    : DecorationButton(type, decoration, parent)
    , m_animation(new QVariantAnimation(this))
    , m_hoverProgress(0.0)
{
    // setup animation
    // It is important start and end value are of the same type, hence 0.0 and not just 0
    m_animation->setStartValue(0.0);
    m_animation->setEndValue(1.0);
    m_animation->setEasingCurve(QEasingCurve::InOutQuad);
    connect(m_animation, &QVariantAnimation::valueChanged, this, [this](const QVariant &value) {
        setOpacity(value.toReal());
    });

    int width = 27;
    int height = 20;

    switch (type)
    {
        case DecorationButtonType::Minimize:
            width = 29;
            break;
        case DecorationButtonType::Maximize:
            width = 27;
            break;
        case DecorationButtonType::Close:
            width = 49;
            break;
        case DecorationButtonType::Menu:
            width = 16;
            height = 20;
            break;
        default:
            break;
    }

    // setup default geometry
    //const int height = decoration->buttonHeight();
    setGeometry(QRect(0, 0, width, height));
    setIconSize(QSize(width, height));

    const auto c = decoration->client().toStrongRef();

    // connections
    connect(c.data(), SIGNAL(iconChanged(QIcon)), this, SLOT(update()));
    connect(decoration->settings().data(), &KDecoration2::DecorationSettings::reconfigured, this, &Button::reconfigure);
    connect(this, &KDecoration2::DecorationButton::hoveredChanged, this, &Button::updateAnimationState);

    connect(this, &Button::buttonHoverStatus, decoration, &Decoration::buttonHoverStatus);

    reconfigure();
}

//__________________________________________________________________
Button::Button(QObject *parent, const QVariantList &args)
    : Button(args.at(0).value<DecorationButtonType>(), args.at(1).value<Decoration *>(), parent)
{
    m_flag = FlagStandalone;
    //! icon size must return to !valid because it was altered from the default constructor,
    //! in Standalone mode the button is not using the decoration metrics but its geometry
    m_iconSize = QSize(-1, -1);
}

//__________________________________________________________________
Button *Button::create(DecorationButtonType type, KDecoration2::Decoration *decoration, QObject *parent)
{
    if (auto d = qobject_cast<Decoration *>(decoration)) {
        Button *b = new Button(type, d, parent);
        const auto c = d->client().toStrongRef();
        switch (type) {
        case DecorationButtonType::Close:
            b->setVisible(true);
            //b->setVisible(c->isCloseable());
            //QObject::connect(c.data(), &KDecoration2::DecoratedClient::closeableChanged, b, &Breeze::Button::setVisible);
            break;

        case DecorationButtonType::Maximize:
            b->setVisible(c->isMaximizeable() || c->isMinimizeable());
            b->setEnabled(c->isMaximizeable());
            QObject::connect(c.data(), &KDecoration2::DecoratedClient::maximizeableChanged, b,
            [b](bool maximizeable) {
                auto d = qobject_cast<Decoration *>(b->decoration());
                const auto c = d->client().toStrongRef();

                if (!c)
                {
                    return;
                }

                b->setVisible(c->isMaximizeable() || c->isMinimizeable());
                b->setEnabled(maximizeable);
            });
            break;

        case DecorationButtonType::Minimize:
            b->setVisible(c->isMinimizeable() || c->isMaximizeable());
            b->setEnabled(c->isMinimizeable());
            QObject::connect(c.data(), &KDecoration2::DecoratedClient::minimizeableChanged, b,
            [b](bool minimizeable) {
                auto d = qobject_cast<Decoration *>(b->decoration());
                const auto c = d->client().toStrongRef();

                if (!c)
                {
                    return;
                }

                b->setVisible(c->isMinimizeable() || c->isMaximizeable());
                b->setEnabled(minimizeable);
            });
            break;

        case DecorationButtonType::ContextHelp:
            b->setVisible(c->providesContextHelp());
            QObject::connect(c.data(), &KDecoration2::DecoratedClient::providesContextHelpChanged, b, &Breeze::Button::setVisible);
            break;

        case DecorationButtonType::Shade:
            b->setVisible(c->isShadeable());
            QObject::connect(c.data(), &KDecoration2::DecoratedClient::shadeableChanged, b, &Breeze::Button::setVisible);
            break;

        case DecorationButtonType::Menu:
            QObject::connect(c.data(), &KDecoration2::DecoratedClient::iconChanged, b, [b]() {
                b->update();
            });
            break;

        default:
            break;
        }

        return b;
    }

    return nullptr;
}

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
        const QRectF iconRect(geometry().topLeft(), m_iconSize);
        const auto c = decoration()->client().toStrongRef();
        if (auto deco = qobject_cast<Decoration *>(decoration())) {
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
        }

    } else if (type() == DecorationButtonType::Close || type() == DecorationButtonType::Maximize || type() == DecorationButtonType::Minimize) {
        QRectF g = geometry();
        qreal w = g.width();
        qreal h = g.height();
        const auto c = decoration()->client().toStrongRef();

        painter->translate(g.topLeft());

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

void Button::smodPaintGlow(QPainter *painter, const QRect &repaintArea)
{
    return;

    if (m_hoverProgress > 0.0 && isVisible() && type() != KDecoration2::DecorationButtonType::Menu) {
        //Decoration *decoration = static_cast<Decoration *>(KDecoration2::DecorationButton::decoration().data());
        //KDecoration2::DecoratedClient *client = decoration->client().data();
        //DecorationFactory *decorationFactory =decoration->factory();
        //window_settings *ws = decorationFactory->windowSettings();
        //const bool active = client->isActive();

        QRect rect = geometry().toRect();
        //int glyph = decoration->buttonGlyph(type());
        //if (glyph == -1) {
        //    return;
        //}
        QImage image;
        QPoint xy;

        switch (type())
        {
            case DecorationButtonType::Minimize:
                image = QImage(":/smod/decoration/minimize-glow");
                xy = QPoint(-10, -9);
                break;
            case DecorationButtonType::Maximize:
                image = QImage(":/smod/decoration/maximize-glow");
                xy = QPoint(-10, -9);
                break;
            case DecorationButtonType::Close:
                image = QImage(":/smod/decoration/close-glow");
                xy = QPoint(-10, -9);
                break;
            default:
                return;
        }

        //if (active && ws->use_button_glow) {
        //    image = ws->ButtonGlowPix[glyph]->image;
        //} else if (!active && ws->use_button_inactive_glow) {
        //    image = ws->ButtonInactiveGlowPix[glyph]->image;
        //}
        if (!image.isNull()) { // && ws->use_pixmap_buttons) {
            QImage buttonImage = image;
            //QImage buttonImage = ws->ButtonPix[glyph * S_COUNT]->image;
            painter->setOpacity(m_hoverProgress);
            const int xp = rect.x(); //rect.x() + (buttonImage.width() - ws->c_glow_size.w) / 2;
            const int yp = rect.y(); //rect.y() + (buttonImage.height() - ws->c_glow_size.h) / 2;
            painter->drawImage(QPoint(xp, yp) + xy, image);
        }
    }
}

//__________________________________________________________________
void Button::paint(QPainter *painter, const QRect &repaintRegion)
{
    smodPaint(painter, repaintRegion);

    return;

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
        const QRectF iconRect(geometry().topLeft(), m_iconSize);
        const auto c = decoration()->client().toStrongRef();
        if (auto deco = qobject_cast<Decoration *>(decoration())) {
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
        }

    } else {
        drawIcon(painter);
    }

    painter->restore();
}

//__________________________________________________________________
void Button::drawIcon(QPainter *painter) const
{
    painter->setRenderHints(QPainter::Antialiasing);

    /*
    scale painter so that its window matches QRect( -1, -1, 20, 20 )
    this makes all further rendering and scaling simpler
    all further rendering is preformed inside QRect( 0, 0, 18, 18 )
    */
    painter->translate(geometry().topLeft());

    const qreal width(m_iconSize.width());
    painter->scale(width / 20, width / 20);
    painter->translate(1, 1);

    // render background
    const QColor backgroundColor(this->backgroundColor());
    if (backgroundColor.isValid()) {
        painter->setPen(Qt::NoPen);
        painter->setBrush(backgroundColor);
        painter->drawEllipse(QRectF(0, 0, 18, 18));
    }

    // render mark
    const QColor foregroundColor(this->foregroundColor());
    if (foregroundColor.isValid()) {
        // setup painter
        QPen pen(foregroundColor);
        pen.setCapStyle(Qt::RoundCap);
        pen.setJoinStyle(Qt::MiterJoin);
        pen.setWidthF(PenWidth::Symbol * qMax((qreal)1.0, 20 / width));

        painter->setPen(pen);
        painter->setBrush(Qt::NoBrush);

        switch (type()) {
        case DecorationButtonType::Close: {
            painter->drawLine(QPointF(5, 5), QPointF(13, 13));
            painter->drawLine(13, 5, 5, 13);
            break;
        }

        case DecorationButtonType::Maximize: {
            if (isChecked()) {
                pen.setJoinStyle(Qt::RoundJoin);
                painter->setPen(pen);

                painter->drawPolygon(QVector<QPointF>{QPointF(4, 9), QPointF(9, 4), QPointF(14, 9), QPointF(9, 14)});

            } else {
                painter->drawPolyline(QVector<QPointF>{QPointF(4, 11), QPointF(9, 6), QPointF(14, 11)});
            }
            break;
        }

        case DecorationButtonType::Minimize: {
            painter->drawPolyline(QVector<QPointF>{QPointF(4, 7), QPointF(9, 12), QPointF(14, 7)});
            break;
        }

        case DecorationButtonType::OnAllDesktops: {
            painter->setPen(Qt::NoPen);
            painter->setBrush(foregroundColor);

            if (isChecked()) {
                // outer ring
                painter->drawEllipse(QRectF(3, 3, 12, 12));

                // center dot
                QColor backgroundColor(this->backgroundColor());
                auto d = qobject_cast<Decoration *>(decoration());
                if (!backgroundColor.isValid() && d) {
                    backgroundColor = d->titleBarColor();
                }

                if (backgroundColor.isValid()) {
                    painter->setBrush(backgroundColor);
                    painter->drawEllipse(QRectF(8, 8, 2, 2));
                }

            } else {
                painter->drawPolygon(QVector<QPointF>{QPointF(6.5, 8.5), QPointF(12, 3), QPointF(15, 6), QPointF(9.5, 11.5)});

                painter->setPen(pen);
                painter->drawLine(QPointF(5.5, 7.5), QPointF(10.5, 12.5));
                painter->drawLine(QPointF(12, 6), QPointF(4.5, 13.5));
            }
            break;
        }

        case DecorationButtonType::Shade: {
            if (isChecked()) {
                painter->drawLine(QPointF(4, 5.5), QPointF(14, 5.5));
                painter->drawPolyline(QVector<QPointF>{QPointF(4, 8), QPointF(9, 13), QPointF(14, 8)});

            } else {
                painter->drawLine(QPointF(4, 5.5), QPointF(14, 5.5));
                painter->drawPolyline(QVector<QPointF>{QPointF(4, 13), QPointF(9, 8), QPointF(14, 13)});
            }

            break;
        }

        case DecorationButtonType::KeepBelow: {
            painter->drawPolyline(QVector<QPointF>{QPointF(4, 5), QPointF(9, 10), QPointF(14, 5)});

            painter->drawPolyline(QVector<QPointF>{QPointF(4, 9), QPointF(9, 14), QPointF(14, 9)});
            break;
        }

        case DecorationButtonType::KeepAbove: {
            painter->drawPolyline(QVector<QPointF>{QPointF(4, 9), QPointF(9, 4), QPointF(14, 9)});

            painter->drawPolyline(QVector<QPointF>{QPointF(4, 13), QPointF(9, 8), QPointF(14, 13)});
            break;
        }

        case DecorationButtonType::ApplicationMenu: {
            painter->drawRect(QRectF(3.5, 4.5, 11, 1));
            painter->drawRect(QRectF(3.5, 8.5, 11, 1));
            painter->drawRect(QRectF(3.5, 12.5, 11, 1));
            break;
        }

        case DecorationButtonType::ContextHelp: {
            QPainterPath path;
            path.moveTo(5, 6);
            path.arcTo(QRectF(5, 3.5, 8, 5), 180, -180);
            path.cubicTo(QPointF(12.5, 9.5), QPointF(9, 7.5), QPointF(9, 11.5));
            painter->drawPath(path);

            painter->drawRect(QRectF(9, 15, 0.5, 0.5));

            break;
        }

        default:
            break;
        }
    }
}

//__________________________________________________________________
QColor Button::foregroundColor() const
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d) {
        return QColor();

    } else if (isPressed()) {
        return d->titleBarColor();

    } else if (type() == DecorationButtonType::Close && d->internalSettings()->outlineCloseButton()) {
        return d->titleBarColor();

    } else if ((type() == DecorationButtonType::KeepBelow || type() == DecorationButtonType::KeepAbove || type() == DecorationButtonType::Shade)
               && isChecked()) {
        return d->titleBarColor();

    } else if (m_animation->state() == QAbstractAnimation::Running) {
        return KColorUtils::mix(d->fontColor(), d->titleBarColor(), m_opacity);

    } else if (isHovered()) {
        return d->titleBarColor();

    } else {
        return d->fontColor();
    }
}

//__________________________________________________________________
QColor Button::backgroundColor() const
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!d) {
        return QColor();
    }

    auto c = d->client().toStrongRef();
    QColor redColor(c->color(ColorGroup::Warning, ColorRole::Foreground));

    if (isPressed()) {
        if (type() == DecorationButtonType::Close) {
            return redColor.darker();
        } else {
            return KColorUtils::mix(d->titleBarColor(), d->fontColor(), 0.3);
        }

    } else if ((type() == DecorationButtonType::KeepBelow || type() == DecorationButtonType::KeepAbove || type() == DecorationButtonType::Shade)
               && isChecked()) {
        return d->fontColor();

    } else if (m_animation->state() == QAbstractAnimation::Running) {
        if (type() == DecorationButtonType::Close) {
            if (d->internalSettings()->outlineCloseButton()) {
                return c->isActive() ? KColorUtils::mix(redColor, redColor.lighter(), m_opacity) : KColorUtils::mix(redColor.lighter(), redColor, m_opacity);

            } else {
                QColor color(redColor.lighter());
                color.setAlpha(color.alpha() * m_opacity);
                return color;
            }

        } else {
            QColor color(d->fontColor());
            color.setAlpha(color.alpha() * m_opacity);
            return color;
        }

    } else if (isHovered()) {
        if (type() == DecorationButtonType::Close) {
            return c->isActive() ? redColor.lighter() : redColor;
        } else {
            return d->fontColor();
        }

    } else if (type() == DecorationButtonType::Close && d->internalSettings()->outlineCloseButton()) {
        return c->isActive() ? redColor : d->fontColor();

    } else {
        return QColor();
    }
}

//________________________________________________________________
void Button::reconfigure()
{
    // animation
    auto d = qobject_cast<Decoration *>(decoration());
    if (d) {
        m_animation->setDuration(d->animationsDuration());
    }

    if (type() == DecorationButtonType::Menu)
    {
        setVisible(!d->hideIcon());
    }
}

//__________________________________________________________________
void Button::updateAnimationState(bool hovered)
{
    auto d = qobject_cast<Decoration *>(decoration());
    if (!(d && d->animationsDuration() > 0)) {
        return;
    }

    m_animation->setDirection(hovered ? QAbstractAnimation::Forward : QAbstractAnimation::Backward);
    if (m_animation->state() != QAbstractAnimation::Running) {
        m_animation->start();
    }
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

} // namespace
