/*
 * SPDX-FileCopyrightText: 2022, 2024 Kai Uwe Broulik <kde@broulik.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#pragma once

#include <QObject>
#include <QPixmap>
#include <QQuickItem>
#include <QString>
#include <QUrl>
#include <QWindow>
#include <qqmlregistration.h>

class DragHelper : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool dragActive READ dragActive NOTIFY dragActiveChanged)
    Q_PROPERTY(int dragPixmapSize READ dragPixmapSize WRITE setDragPixmapSize NOTIFY dragPixmapSizeChanged)

public:
    explicit DragHelper(QObject *parent = nullptr);
    ~DragHelper() override;

    bool dragActive() const;

    int dragPixmapSize() const;
    void setDragPixmapSize(int dragPixmapSize);

    Q_INVOKABLE void startDrag(QQuickItem *item, const QUrl &url, const QString &iconName);
    Q_INVOKABLE void startDrag(QQuickItem *item, const QUrl &url, const QPixmap &pixmap);

Q_SIGNALS:
    void dragActiveChanged();
    void dragPixmapSizeChanged();

private:
    bool m_dragActive = false;
    int m_dragPixmapSize = 48; // set to units.iconSizes.large in DraggableFileArea
};
