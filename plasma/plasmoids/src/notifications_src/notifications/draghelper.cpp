/*
 * SPDX-FileCopyrightText: 2022, 2024 Kai Uwe Broulik <kde@broulik.de>
 *
 * SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

#include "draghelper.h"

#include <KUrlMimeData>

#include <QDrag>
#include <QGuiApplication>
#include <QMetaObject>
#include <QMimeData>
#include <QQuickWindow>

DragHelper::DragHelper(QObject *parent)
    : QObject(parent)
{
}

DragHelper::~DragHelper() = default;

bool DragHelper::dragActive() const
{
    return m_dragActive;
}

int DragHelper::dragPixmapSize() const
{
    return m_dragPixmapSize;
}

void DragHelper::setDragPixmapSize(int dragPixmapSize)
{
    if (m_dragPixmapSize != dragPixmapSize) {
        m_dragPixmapSize = dragPixmapSize;
        Q_EMIT dragPixmapSizeChanged();
    }
}

void DragHelper::startDrag(QQuickItem *item, const QUrl &url, const QString &iconName)
{
    startDrag(item, url, QIcon::fromTheme(iconName).pixmap(m_dragPixmapSize, m_dragPixmapSize));
}

void DragHelper::startDrag(QQuickItem *item, const QUrl &url, const QPixmap &pixmap)
{
    // This allows the caller to return, making sure we don't crash if
    // the caller is destroyed mid-drag.
    QMetaObject::invokeMethod(
        this,
        [this, item, url, pixmap] {
            if (item && item->window() && item->window()->mouseGrabberItem()) {
                item->window()->mouseGrabberItem()->ungrabMouse();
            }

            // NOTE Do not use "item" as parent/source since it will be destroyed
            // when the notification history closes and the model is unloaded!
            QDrag *drag = new QDrag(this);

            QMimeData *mimeData = new QMimeData();

            if (!url.isEmpty()) {
                mimeData->setUrls(QList<QUrl>{url});
                KUrlMimeData::exportUrlsToPortal(mimeData);
            }

            drag->setMimeData(mimeData);

            if (!pixmap.isNull()) {
                drag->setPixmap(pixmap);
            }

            m_dragActive = true;
            Q_EMIT dragActiveChanged();

            drag->exec(Qt::CopyAction);

            m_dragActive = false;
            Q_EMIT dragActiveChanged();
        },
        Qt::QueuedConnection);
}

#include "moc_draghelper.cpp"
