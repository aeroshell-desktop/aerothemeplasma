/*
    SPDX-FileCopyrightText: 2021 Kai Uwe Broulik <kde@broulik.de>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#pragma once

#include <QObject>
#include <QPointer>
#include <QString>
#include <QUrl>
#include <qqmlregistration.h>

#include <KService>

class QAction;

namespace KIO
{
class MimeTypeFinderJob;
}

class FileInfo : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(int error READ error NOTIFY errorChanged)

    Q_PROPERTY(QString mimeType READ mimeType NOTIFY mimeTypeChanged)
    Q_PROPERTY(QString iconName READ iconName NOTIFY mimeTypeChanged)

    Q_PROPERTY(QAction *openAction READ openAction NOTIFY openActionChanged)
    // QML can't deal with QIcon...
    Q_PROPERTY(QString openActionIconName READ openActionIconName NOTIFY openActionIconNameChanged)

public:
    explicit FileInfo(QObject *parent = nullptr);
    ~FileInfo() override;

    QUrl url() const;
    void setUrl(const QUrl &url);
    Q_SIGNAL void urlChanged(const QUrl &url);

    bool busy() const;
    Q_SIGNAL void busyChanged(bool busy);

    int error() const;
    Q_SIGNAL void errorChanged(bool error);

    QString mimeType() const;
    Q_SIGNAL void mimeTypeChanged();

    QString iconName() const;
    Q_SIGNAL void iconNameChanged(const QString &iconName);

    QAction *openAction() const;
    Q_SIGNAL void openActionChanged();

    QString openActionIconName() const;
    Q_SIGNAL void openActionIconNameChanged();

private:
    void reload();
    void mimeTypeFound(const QString &mimeType);

    void setBusy(bool busy);
    void setError(int error);

    QUrl m_url;

    QPointer<KIO::MimeTypeFinderJob> m_job;
    bool m_busy = false;
    int m_error = 0;

    QString m_mimeType;
    QString m_iconName;

    KService::Ptr m_preferredApplication;
    QAction *m_openAction = nullptr;
};
