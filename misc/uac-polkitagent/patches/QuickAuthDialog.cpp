/*  This file is part of the KDE project
    SPDX-FileCopyrightText: 2021 Aleix Pol Gonzalez <aleixpol@kde.org>
    SPDX-FileCopyrightText: 2023 Devin Lin <devin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "QuickAuthDialog.h"
#include "IdentitiesModel.h"

#include <PolkitQt1/Authority>

#include <KLocalizedQmlContext>
#include <KLocalizedString>
#include <KRuntimePlatform>
#include <KUser>

#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QTimer>
#include <KNotification>
#include <QPixmap>


QuickAuthDialog::QuickAuthDialog(const QString &actionId,
                                 const QString &message,
                                 [[maybe_unused]] const PolkitQt1::Details &details,
                                 const PolkitQt1::Identity::List &identities)
    : QObject(nullptr)
    , m_actionId(actionId)
{
    auto engine = new QQmlApplicationEngine(this);
    QVariantMap props = {
        {"mainText", message},
    };

    const auto actions = PolkitQt1::Authority::instance()->enumerateActionsSync();
    for (const PolkitQt1::ActionDescription &desc : actions) {
        if (actionId == desc.actionId()) {
            qDebug() << "Action description has been found";
            props.insert("descriptionString", desc.description());
            props.insert("descriptionActionId", desc.actionId());
            props.insert("descriptionVendorName", desc.vendorName());
            props.insert("descriptionVendorUrl", desc.vendorUrl());
            props.insert("descriptionIcon", desc.iconName());
            break;
        }
    }

    engine->setInitialProperties(props);
    engine->rootContext()->setContextObject(new KLocalizedQmlContext(engine));

    if (KRuntimePlatform::runtimePlatform().contains("phone")) {
        // If this is Plasma Mobile
        engine->load("qrc:/qml/MobileQuickAuthDialog.qml");
    } else {
        // If this is Plasma Desktop, or other platforms
        engine->load("qrc:/qml/QuickAuthDialog.qml");
    }

    m_theDialog = qobject_cast<QQuickWindow *>(engine->rootObjects().constFirst());

    auto idents = qobject_cast<IdentitiesModel *>(m_theDialog->property("identitiesModel").value<QObject *>());
    idents->setIdentities(identities, false);
    if (!identities.isEmpty()) {
        int initialIndex = std::max(0, idents->indexForUser(KUser().loginName()));
        m_theDialog->setProperty("identitiesCurrentIndex", initialIndex);
    }

    // listen for dialog accept/reject
    connect(m_theDialog, SIGNAL(accept()), this, SIGNAL(okClicked()));
    connect(m_theDialog, SIGNAL(reject()), this, SIGNAL(rejected()));
    connect(m_theDialog, SIGNAL(userSelected()), this, SIGNAL(userSelected()));


}

enum KirigamiInlineMessageTypes { Information = 0, Positive = 1, Warning = 2, Error = 3 };

QString QuickAuthDialog::actionId() const
{
    return m_actionId;
}

QString QuickAuthDialog::password() const
{
    return m_theDialog->property("password").toString();
}

void QuickAuthDialog::showError(const QString &message)
{
    m_theDialog->setProperty("inlineMessageType", Error);
    m_theDialog->setProperty("inlineMessageText", message);
}

void QuickAuthDialog::showInfo(const QString &message)
{
    m_theDialog->setProperty("inlineMessageType", Information);
    m_theDialog->setProperty("inlineMessageText", message);
}

PolkitQt1::Identity QuickAuthDialog::adminUserSelected() const
{
    return PolkitQt1::Identity::fromString(m_theDialog->property("selectedIdentity").toString());
}

void QuickAuthDialog::authenticationFailure()
{
    QTimer::singleShot(0, m_theDialog, SLOT(authenticationFailure()));
}

void QuickAuthDialog::show()
{
    KNotification *notification = new KNotification("authenticate");
    notification->setComponentName("policykit1-kde");
    //notification->setWindow(m_theDialog);
    //notification->setFlags(KNotification::CloseOnTimeout | KNotification::CloseWhenWindowActivated);
    notification->sendEvent();
    QTimer::singleShot(0, m_theDialog, SLOT(show()));
}

void QuickAuthDialog::hide()
{
    QTimer::singleShot(0, m_theDialog, SLOT(hide()));
}

void QuickAuthDialog::request([[maybe_unused]] const QString &request, [[maybe_unused]] bool echo)
{
    QTimer::singleShot(0, m_theDialog, SLOT(request()));
}

#include "moc_QuickAuthDialog.cpp"
