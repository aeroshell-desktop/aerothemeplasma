//////////////////////////////////////////////////////////////////////////////
// breezeconfigurationui.cpp
// -------------------
//
// SPDX-FileCopyrightText: 2009 Hugo Pereira Da Costa <hugo.pereira@free.fr>
//
// SPDX-License-Identifier: MIT
//////////////////////////////////////////////////////////////////////////////

#include "breezeconfigwidget.h"
#include "breezeexceptionlist.h"

#include <KLocalizedString>

#include <QDBusConnection>
#include <QDBusMessage>
#include <QFontDatabase>

namespace Breeze
{
//_________________________________________________________
ConfigWidget::ConfigWidget(QObject *parent, const KPluginMetaData &data, const QVariantList & /*args*/)
    : KCModule(parent, data)
    , m_configuration(KSharedConfig::openConfig(QStringLiteral("smodrc")))
    , m_changed(false)
{
    // configuration
    m_ui.setupUi(widget());

    // track ui changes
    connect(m_ui.titleAlignment, SIGNAL(currentIndexChanged(int)), SLOT(updateChanged()));
    connect(m_ui.buttonSize, SIGNAL(currentIndexChanged(int)), SLOT(updateChanged()));
    connect(m_ui.titlebarSize, SIGNAL(valueChanged(int)), SLOT(updateChanged()));
    connect(m_ui.outlineCloseButton, &QAbstractButton::clicked, this, &ConfigWidget::updateChanged);
    connect(m_ui.alternativeButtonSizing, &QAbstractButton::clicked, this, &ConfigWidget::updateChanged);
    connect(m_ui.enableShadow, &QAbstractButton::clicked, this, &ConfigWidget::updateChanged);
    connect(m_ui.invertTextColor, &QAbstractButton::clicked, this, &ConfigWidget::updateChanged);
    connect(m_ui.drawBorderOnMaximizedWindows, &QAbstractButton::clicked, this, &ConfigWidget::updateChanged);
    connect(m_ui.drawBackgroundGradient, &QAbstractButton::clicked, this, &ConfigWidget::updateChanged);

    // track exception changes
    connect(m_ui.exceptions, &ExceptionListWidget::changed, this, &ConfigWidget::updateChanged);

    // set formatting
    //m_ui.drawBorderOnMaximizedWindowsHelpLabel->setFont(QFontDatabase::systemFont(QFontDatabase::SmallestReadableFont));
}

//_________________________________________________________
void ConfigWidget::load()
{
    // create internal settings and load from rc files
    m_internalSettings = InternalSettingsPtr(new InternalSettings());
    m_internalSettings->load();

    // assign to ui
    m_ui.titleAlignment->setCurrentIndex(m_internalSettings->titleAlignment());
    m_ui.buttonSize->setCurrentIndex(m_internalSettings->buttonSize());
    m_ui.titlebarSize->setValue(m_internalSettings->titlebarSize());
    m_ui.drawBorderOnMaximizedWindows->setChecked(m_internalSettings->drawBorderOnMaximizedWindows());
    m_ui.outlineCloseButton->setChecked(m_internalSettings->outlineCloseButton());
    m_ui.alternativeButtonSizing->setChecked(m_internalSettings->alternativeButtonSizing());
    m_ui.enableShadow->setChecked(m_internalSettings->enableShadow());
    m_ui.invertTextColor->setChecked(m_internalSettings->invertTextColor());
    m_ui.drawBackgroundGradient->setChecked(m_internalSettings->drawBackgroundGradient());

    // load exceptions
    ExceptionList exceptions;
    exceptions.readConfig(m_configuration);
    m_ui.exceptions->setExceptions(exceptions.get());
    setNeedsSave(false);

    m_ui.hideWidget->setVisible(false);
}

//_________________________________________________________
void ConfigWidget::save()
{
    // create internal settings and load from rc files
    m_internalSettings = InternalSettingsPtr(new InternalSettings());
    m_internalSettings->load();

    // apply modifications from ui
    m_internalSettings->setTitleAlignment(m_ui.titleAlignment->currentIndex());
    m_internalSettings->setButtonSize(m_ui.buttonSize->currentIndex());
    m_internalSettings->setTitlebarSize(m_ui.titlebarSize->value());
    m_internalSettings->setOutlineCloseButton(m_ui.outlineCloseButton->isChecked());
    m_internalSettings->setAlternativeButtonSizing(m_ui.alternativeButtonSizing->isChecked());
    m_internalSettings->setEnableShadow(m_ui.enableShadow->isChecked());
    m_internalSettings->setInvertTextColor(m_ui.invertTextColor->isChecked());
    m_internalSettings->setDrawBorderOnMaximizedWindows(m_ui.drawBorderOnMaximizedWindows->isChecked());
    m_internalSettings->setDrawBackgroundGradient(m_ui.drawBackgroundGradient->isChecked());

    // save configuration
    m_internalSettings->save();

    // get list of exceptions and write
    InternalSettingsList exceptions(m_ui.exceptions->exceptions());
    ExceptionList(exceptions).writeConfig(m_configuration);

    // sync configuration
    m_configuration->sync();
    setNeedsSave(false);

    // needed to tell kwin to reload when running from external kcmshell
    {
        QDBusMessage message = QDBusMessage::createSignal("/KWin", "org.kde.KWin", "reloadConfig");
        QDBusConnection::sessionBus().send(message);
    }

    // needed for breeze style to reload shadows
    {
        QDBusMessage message(QDBusMessage::createSignal("/BreezeDecoration", "org.kde.Breeze.Style", "reparseConfiguration"));
        QDBusConnection::sessionBus().send(message);
    }
}

//_________________________________________________________
void ConfigWidget::defaults()
{
    // create internal settings and load from rc files
    m_internalSettings = InternalSettingsPtr(new InternalSettings());
    m_internalSettings->setDefaults();

    // assign to ui
    m_ui.titleAlignment->setCurrentIndex(m_internalSettings->titleAlignment());
    m_ui.buttonSize->setCurrentIndex(m_internalSettings->buttonSize());
    m_ui.titlebarSize->setValue(m_internalSettings->titlebarSize());
    m_ui.outlineCloseButton->setChecked(m_internalSettings->outlineCloseButton());
    m_ui.alternativeButtonSizing->setChecked(m_internalSettings->alternativeButtonSizing());
    m_ui.enableShadow->setChecked(m_internalSettings->enableShadow());
    m_ui.invertTextColor->setChecked(m_internalSettings->invertTextColor());
    m_ui.drawBorderOnMaximizedWindows->setChecked(m_internalSettings->drawBorderOnMaximizedWindows());
    m_ui.drawBackgroundGradient->setChecked(m_internalSettings->drawBackgroundGradient());
}

//_______________________________________________
void ConfigWidget::updateChanged()
{
    // check configuration
    if (!m_internalSettings) {
        return;
    }

    // track modifications
    bool modified(false);

    if (m_ui.titleAlignment->currentIndex() != m_internalSettings->titleAlignment()) {
        modified = true;
    } else if (m_ui.buttonSize->currentIndex() != m_internalSettings->buttonSize()) {
        modified = true;
    } else if (m_ui.titlebarSize->value() != m_internalSettings->titlebarSize()) {
        modified = true;
    } else if (m_ui.outlineCloseButton->isChecked() != m_internalSettings->outlineCloseButton()) {
        modified = true;
    } else if (m_ui.alternativeButtonSizing->isChecked() != m_internalSettings->alternativeButtonSizing()) {
        modified = true;
    } else if (m_ui.enableShadow->isChecked() != m_internalSettings->enableShadow()) {
        modified = true;
    } else if (m_ui.invertTextColor->isChecked() != m_internalSettings->invertTextColor()) {
        modified = true;
    } else if (m_ui.drawBorderOnMaximizedWindows->isChecked() != m_internalSettings->drawBorderOnMaximizedWindows()) {
        modified = true;
    } else if (m_ui.drawBackgroundGradient->isChecked() != m_internalSettings->drawBackgroundGradient()) {
        modified = true;
        // exceptions
    } else if (m_ui.exceptions->isChanged()) {
        modified = true;
    }

    setNeedsSave(modified);
}

}
