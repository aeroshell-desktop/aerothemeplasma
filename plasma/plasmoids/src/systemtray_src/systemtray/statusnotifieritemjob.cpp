/*
    SPDX-FileCopyrightText: 2008 Alain Boyer <alainboyer@gmail.com>
    SPDX-FileCopyrightText: 2009 Matthieu Gallien <matthieu_gallien@yahoo.fr>

    SPDX-License-Identifier: LGPL-2.0-only
*/

#include "statusnotifieritemjob.h"
#include <KWaylandExtras>
#include <KWindowSystem>
#include <memory>

StatusNotifierItemJob::StatusNotifierItemJob(StatusNotifierItemSource *source, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent)
    : ServiceJob(source->objectName(), operation, parameters, parent)
    , m_source(source)
{
    // Queue connection, so that all 'deleteLater' are performed before we use updated menu.
    connect(source, SIGNAL(contextMenuReady(QMenu *)), this, SLOT(contextMenuReady(QMenu *)), Qt::QueuedConnection);
    connect(source, &StatusNotifierItemSource::activateResult, this, &StatusNotifierItemJob::activateCallback);
}

StatusNotifierItemJob::~StatusNotifierItemJob()
{
}

void StatusNotifierItemJob::start()
{
    if (operationName() == QLatin1String("Scroll")) {
        performJob();
        return;
    }

    QWindow *window = nullptr;
    const quint32 launchedSerial = KWaylandExtras::lastInputSerial(window);
    auto conn = std::make_shared<QMetaObject::Connection>();
    *conn =
        connect(KWaylandExtras::self(), &KWaylandExtras::xdgActivationTokenArrived, this, [this, launchedSerial, conn](quint32 serial, const QString &token) {
            if (serial == launchedSerial) {
                disconnect(*conn);
                m_source->provideXdgActivationToken(token);
                performJob();
            }
        });
    KWaylandExtras::requestXdgActivationToken(window, launchedSerial, {});
}

void StatusNotifierItemJob::performJob()
{
    const QVariantMap params = parameters();
    if (operationName() == QString::fromLatin1("Activate")) {
        m_source->activate(params[QStringLiteral("x")].toInt(), params[QStringLiteral("y")].toInt());
    } else if (operationName() == QString::fromLatin1("SecondaryActivate")) {
        m_source->secondaryActivate(params[QStringLiteral("x")].toInt(), parameters()[QStringLiteral("y")].toInt());
        setResult(0);
    } else if (operationName() == QString::fromLatin1("ContextMenu")) {
        m_source->contextMenu(params[QStringLiteral("x")].toInt(), params[QStringLiteral("y")].toInt());
    } else if (operationName() == QString::fromLatin1("Scroll")) {
        m_source->scroll(params[QStringLiteral("delta")].toInt(), params[QStringLiteral("direction")].toString());
        setResult(0);
    }
}

void StatusNotifierItemJob::activateCallback(bool success)
{
    if (operationName() == QString::fromLatin1("Activate")) {
        setResult(QVariant(success));
    }
}

void StatusNotifierItemJob::contextMenuReady(QMenu *menu)
{
    if (operationName() == QString::fromLatin1("ContextMenu")) {
        setResult(QVariant::fromValue((QObject *)menu));
    }
}

#include "moc_statusnotifieritemjob.cpp"
