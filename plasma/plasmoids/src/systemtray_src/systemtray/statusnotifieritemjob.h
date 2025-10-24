/*
    SPDX-FileCopyrightText: 2008 Alain Boyer <alainboyer@gmail.com>
    SPDX-FileCopyrightText: 2009 Matthieu Gallien <matthieu_gallien@yahoo.fr>

    SPDX-License-Identifier: LGPL-2.0-only
*/

#pragma once

// Qt
#include <QMenu>

// own
#include "statusnotifieritemsource.h"

// plasma
#include <Plasma5Support/ServiceJob>

/**
 * Task Job
 */
class StatusNotifierItemJob : public Plasma5Support::ServiceJob
{
    Q_OBJECT

public:
    StatusNotifierItemJob(StatusNotifierItemSource *source, const QString &operation, QMap<QString, QVariant> &parameters, QObject *parent = nullptr);
    ~StatusNotifierItemJob() override;

protected:
    void start() override;

private Q_SLOTS:
    void activateCallback(bool success);
    void contextMenuReady(QMenu *menu);

private:
    void performJob();
    StatusNotifierItemSource *m_source;
};
