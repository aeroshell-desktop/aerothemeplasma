/*
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#pragma once

#include <QObject>
#include <QQmlParserStatus>
#include <qqmlregistration.h>

#include <QPixmap>
#include <QSize>
#include <QUrl>

class Thumbnailer : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    QML_ELEMENT
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QSize size READ size WRITE setSize NOTIFY sizeChanged)

    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(bool hasPreview READ hasPreview NOTIFY pixmapChanged)
    Q_PROPERTY(QPixmap pixmap READ pixmap NOTIFY pixmapChanged)
    Q_PROPERTY(QSize pixmapSize READ pixmapSize NOTIFY pixmapChanged)

    Q_PROPERTY(QString iconName READ iconName NOTIFY iconNameChanged)

    Q_PROPERTY(bool menuVisible READ menuVisible NOTIFY menuVisibleChanged)

public:
    explicit Thumbnailer(QObject *parent = nullptr);
    ~Thumbnailer() override;

    QUrl url() const;
    void setUrl(const QUrl &url);

    QSize size() const;
    void setSize(const QSize &size);

    bool busy() const;
    bool hasPreview() const;
    QPixmap pixmap() const;
    QSize pixmapSize() const;

    QString iconName() const;

    bool menuVisible() const;

    void classBegin() override;
    void componentComplete() override;

Q_SIGNALS:
    void menuVisibleChanged();

    void urlChanged();
    void sizeChanged();
    void busyChanged();
    void pixmapChanged();
    void iconNameChanged();

private:
    void generatePreview();

    bool m_inited = false;

    bool m_menuVisible = false;

    QUrl m_url;
    QSize m_size;

    bool m_busy = false;

    QPixmap m_pixmap;

    QString m_iconName;
};
