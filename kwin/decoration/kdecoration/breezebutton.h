/*
 * SPDX-FileCopyrightText: 2014 Martin Gräßlin <mgraesslin@kde.org>
 * SPDX-FileCopyrightText: 2014 Hugo Pereira Da Costa <hugo.pereira@free.fr>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include "breezedecoration.h"
#include <KDecoration3/DecorationButton>

#include <QObject>
#include <QHash>
#include <QImage>
#include <QHoverEvent>
#include <QPropertyAnimation>
#include <QPixmap>
#include <QPainter>


class QVariantAnimation;

namespace Breeze
{

class Button : public KDecoration3::DecorationButton
{
    Q_OBJECT
    Q_PROPERTY(qreal hoverProgress READ hoverProgress WRITE setHoverProgress);

public:
    //* constructor
    explicit Button(QObject *parent, const QVariantList &args);

    //* destructor
    virtual ~Button() = default;

    //* button creation
    static Button *create(KDecoration3::DecorationButtonType type, KDecoration3::Decoration *decoration, QObject *parent);

    //* render
    virtual void paint(QPainter *painter, const QRectF &repaintRegion) override;

    //* flag
    enum Flag {
        FlagNone,
        FlagStandalone,
        FlagFirstInList,
        FlagLastInList,
    };

    //* flag
    void setFlag(Flag value)
    {
        m_flag = value;
    }

    //* standalone buttons
    bool isStandAlone() const
    {
        return m_flag == FlagStandalone;
    }

    //* offset
    void setOffset(const QPointF &value)
    {
        m_offset = value;
    }

    //* horizontal offset, for rendering
    void setHorizontalOffset(qreal value)
    {
        m_offset.setX(value);
    }

    //* vertical offset, for rendering
    void setVerticalOffset(qreal value)
    {
        m_offset.setY(value);
    }

    //* set icon size
    void setIconSize(const QSize &value)
    {
        m_iconSize = value;
    }

    //*@name active state change animation
    //@{
    void setOpacity(qreal value)
    {
        if (m_opacity == value) {
            return;
        }
        m_opacity = value;
        update();
    }

    qreal opacity() const
    {
        return m_opacity;
    }

    //@}

    qreal hoverProgress() const;
    void setHoverProgress(qreal hoverProgress);

    void smodPaintGlow(QPainter *painter, const QRectF &repaintArea);
    void updateGeometry();
Q_SIGNALS:
    void buttonHoverStatus(KDecoration3::DecorationButtonType button, bool isFlipped, QString textureType,  bool hovered, QPoint pos);

protected:
    void hoverEnterEvent(QHoverEvent *event) override;
    void hoverLeaveEvent(QHoverEvent *event) override;

private Q_SLOTS:

    //* apply configuration changes
    void reconfigure();

    //* animation state
    void updateAnimationState(bool);

private:
    //* private constructor
    explicit Button(KDecoration3::DecorationButtonType type, Decoration *decoration, QObject *parent = nullptr);

    //* draw button icon
    void drawIcon(QPainter *) const;

    void startHoverAnimation(qreal endValue);
    void smodPaint(QPainter *painter, const QRectF &repaintRegion);

    //*@name colors
    //@{
    QColor foregroundColor() const;
    QColor backgroundColor() const;
    //@}

    Flag m_flag = FlagNone;

    //* active state change animation
    QVariantAnimation *m_animation;

    //* vertical offset (for rendering)
    QPointF m_offset;

    //* icon size
    QSize m_iconSize;

    //* status or smthing idk
    bool m_isToggled{false};
    bool m_isMirrored{false};
    bool m_isFlipped{false};
    QString m_textureType{};

    //* active state change opacity
    qreal m_opacity = 0;
    int index = -1;

    QPointer<QPropertyAnimation> m_hoverAnimation;
    qreal m_hoverProgress;
};

} // namespace
