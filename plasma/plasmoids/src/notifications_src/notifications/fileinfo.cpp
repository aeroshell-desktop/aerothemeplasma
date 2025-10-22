/*
    SPDX-FileCopyrightText: 2021 Kai Uwe Broulik <kde@broulik.de>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "fileinfo.h"
#include "notifications_debug.h"

#include <QAction>
#include <QMimeDatabase>

#include <KApplicationTrader>
#include <KAuthorized>
#include <KIO/ApplicationLauncherJob>
#include <KIO/JobUiDelegateFactory>
#include <KIO/MimeTypeFinderJob>
#include <KIO/OpenUrlJob>
#include <KLocalizedString>
#include <KNotificationJobUiDelegate>

FileInfo::FileInfo(QObject *parent)
    : QObject(parent)
{
}

FileInfo::~FileInfo() = default;

QUrl FileInfo::url() const
{
    return m_url;
}

void FileInfo::setUrl(const QUrl &url)
{
    if (m_url != url) {
        m_url = url;
        reload();
        Q_EMIT urlChanged(url);
    }
}

bool FileInfo::busy() const
{
    return m_busy;
}

void FileInfo::setBusy(bool busy)
{
    if (m_busy != busy) {
        m_busy = busy;
        Q_EMIT busyChanged(busy);
    }
}

int FileInfo::error() const
{
    return m_error;
}

void FileInfo::setError(int error)
{
    if (m_error != error) {
        m_error = error;
        Q_EMIT errorChanged(error);
    }
}

QString FileInfo::mimeType() const
{
    return m_mimeType;
}

QString FileInfo::iconName() const
{
    return m_iconName;
}

QAction *FileInfo::openAction() const
{
    return m_openAction;
}

QString FileInfo::openActionIconName() const
{
    return m_openAction ? m_openAction->icon().name() : QString();
}

void FileInfo::reload()
{
    if (!m_url.isValid()) {
        return;
    }

    if (m_job) {
        m_job->kill();
    }

    setError(0);

    // Do a quick guess by file name while we wait for the job to find the mime type
    QString guessedMimeType;

    // NOTE using QUrl::path() for API that accepts local files is usually wrong
    // but here we really only care about the file name and its extension.
    const auto type = QMimeDatabase().mimeTypeForFile(m_url.path(), QMimeDatabase::MatchExtension);
    if (!type.isDefault()) {
        guessedMimeType = type.name();
    }

    mimeTypeFound(guessedMimeType);

    m_job = new KIO::MimeTypeFinderJob(m_url);
    m_job->setAuthenticationPromptEnabled(false);

    const QUrl url = m_url;
    connect(m_job, &KIO::MimeTypeFinderJob::result, this, [this, url] {
        setError(m_job->error());
        if (m_job->error()) {
            qCWarning(PLASMA_APPLET_NOTIFICATIONS_DEBUG) << "Failed to determine mime type for" << url << m_job->errorString();
        } else {
            mimeTypeFound(m_job->mimeType());
        }
        setBusy(false);
    });

    setBusy(true);
    m_job->start();
}

void FileInfo::mimeTypeFound(const QString &mimeType)
{
    if (m_mimeType == mimeType) {
        return;
    }

    const QString oldOpenActionIconName = openActionIconName();

    bool emitOpenActionChanged = false;
    if (!m_openAction) {
        m_openAction = new QAction(this);
        connect(m_openAction, &QAction::triggered, this, [this] {
            auto *job = new KIO::ApplicationLauncherJob(m_preferredApplication);
            if (m_preferredApplication) {
                job->setUiDelegate(new KNotificationJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled));
            } else {
                // needs KIO::JobUiDelegate for open with handler
                job->setUiDelegate(KIO::createDefaultJobUiDelegate(KJobUiDelegate::AutoErrorHandlingEnabled, nullptr /*widget*/));
            }
            job->setUrls({m_url});
            job->start();
        });
        emitOpenActionChanged = true;
    }

    m_mimeType = mimeType;

    m_preferredApplication.reset();

    if (!mimeType.isEmpty()) {
        const auto type = QMimeDatabase().mimeTypeForName(mimeType);
        m_iconName = type.iconName();

        m_preferredApplication = KApplicationTrader::preferredService(mimeType);
    } else {
        m_iconName.clear();
    }

    if (m_preferredApplication) {
        m_openAction->setText(i18n("Open with %1", m_preferredApplication->name()));
        m_openAction->setIcon(QIcon::fromTheme(m_preferredApplication->icon()));
        m_openAction->setEnabled(true);
    } else {
        m_openAction->setText(i18n("Open with…"));
        m_openAction->setIcon(QIcon::fromTheme(QStringLiteral("system-run")));
        m_openAction->setEnabled(KAuthorized::authorizeAction(KAuthorized::OPEN_WITH));
    }

    Q_EMIT mimeTypeChanged();

    if (emitOpenActionChanged) {
        Q_EMIT openActionChanged();
    }
    if (oldOpenActionIconName != openActionIconName()) {
        Q_EMIT openActionIconNameChanged();
    }
}

#include "moc_fileinfo.cpp"
