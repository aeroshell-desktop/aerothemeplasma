/*
    SPDX-FileCopyrightText: 2016 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "thumbnailer.h"

#include <KIO/PreviewJob>

#include <QApplication>
#include <QClipboard>
#include <QIcon>
#include <QMenu>
#include <QMimeData>
#include <QQuickItem>
#include <QQuickWindow>
#include <QTimer>

#include <KConfigGroup>
#include <KFileItemListProperties>
#include <KLocalizedString>
#include <KPropertiesDialog>
#include <KSharedConfig>
#include <KUrlMimeData>

#include <KIO/OpenFileManagerWindowJob>

using namespace Qt::StringLiterals;

Thumbnailer::Thumbnailer(QObject *parent)
    : QObject(parent)
{
}

Thumbnailer::~Thumbnailer() = default;

void Thumbnailer::classBegin()
{
}

void Thumbnailer::componentComplete()
{
    m_inited = true;
    generatePreview();
}

QUrl Thumbnailer::url() const
{
    return m_url;
}

void Thumbnailer::setUrl(const QUrl &url)
{
    if (m_url != url) {
        m_url = url;
        Q_EMIT urlChanged();

        generatePreview();
    }
}

QSize Thumbnailer::size() const
{
    return m_size;
}

void Thumbnailer::setSize(const QSize &size)
{
    if (m_size != size) {
        m_size = size;
        Q_EMIT sizeChanged();

        generatePreview();
    }
}

bool Thumbnailer::busy() const
{
    return m_busy;
}

bool Thumbnailer::hasPreview() const
{
    return !m_pixmap.isNull();
}

QPixmap Thumbnailer::pixmap() const
{
    return m_pixmap;
}

QSize Thumbnailer::pixmapSize() const
{
    return m_pixmap.size();
}

QString Thumbnailer::iconName() const
{
    return m_iconName;
}

bool Thumbnailer::menuVisible() const
{
    return m_menuVisible;
}

void Thumbnailer::generatePreview()
{
    if (!m_inited) {
        return;
    }

    if (!m_url.isValid() || !m_url.isLocalFile() || !m_size.isValid() || m_size.isEmpty()) {
        return;
    }

    auto maxSize = qMax(m_size.width(), m_size.height());

    KConfigGroup previewSettings(KSharedConfig::openConfig(QStringLiteral("dolphinrc")), u"PreviewSettings"_s);
    const QStringList enabledPlugins = previewSettings.readEntry("Plugins", KIO::PreviewJob::defaultPlugins());

    KIO::PreviewJob *job = KIO::filePreview(KFileItemList({KFileItem(m_url)}), QSize(maxSize, maxSize), &enabledPlugins);
    job->setScaleType(KIO::PreviewJob::Scaled);
    job->setIgnoreMaximumSize(true);

    connect(job, &KIO::PreviewJob::gotPreview, this, [this](const KFileItem &item, const QPixmap &preview) {
        Q_UNUSED(item);
        m_pixmap = preview;
        Q_EMIT pixmapChanged();

        if (!m_iconName.isEmpty()) {
            m_iconName.clear();
            Q_EMIT iconNameChanged();
        }
    });

    connect(job, &KIO::PreviewJob::failed, this, [this](const KFileItem &item) {
        m_pixmap = QPixmap();
        Q_EMIT pixmapChanged();

        const QString &iconName = item.determineMimeType().iconName();
        if (m_iconName != iconName) {
            m_iconName = iconName;
            Q_EMIT iconNameChanged();
        }
    });

    connect(job, &KJob::result, this, [this] {
        m_busy = false;
        Q_EMIT busyChanged();
    });

    m_busy = true;
    Q_EMIT busyChanged();

    job->start();
}

#include "moc_thumbnailer.cpp"
