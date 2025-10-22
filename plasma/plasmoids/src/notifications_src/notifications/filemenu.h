/*
    SPDX-FileCopyrightText: 2016, 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#pragma once

#include <QObject>
#include <QPointer>
#include <QQuickItem>
#include <QUrl>

class QAction;

class FileMenu : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)
    Q_PROPERTY(QQuickItem *visualParent READ visualParent WRITE setVisualParent NOTIFY visualParentChanged)
    Q_PROPERTY(bool visible READ visible WRITE setVisible NOTIFY visibleChanged)

public:
    explicit FileMenu(QObject *parent = nullptr);
    ~FileMenu() override;

    QUrl url() const;
    void setUrl(const QUrl &url);

    QQuickItem *visualParent() const;
    void setVisualParent(QQuickItem *visualParent);

    bool visible() const;
    void setVisible(bool visible);

    Q_INVOKABLE void open(int x, int y);

Q_SIGNALS:
    void actionTriggered(QAction *action);

    void urlChanged();
    void visualParentChanged();
    void visibleChanged();

private:
    QUrl m_url;
    QPointer<QQuickItem> m_visualParent;
    bool m_visible = false;
};
