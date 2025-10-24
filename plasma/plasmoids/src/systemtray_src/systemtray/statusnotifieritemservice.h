/*
    SPDX-FileCopyrightText: 2008 Alain Boyer <alainboyer@gmail.com>
    SPDX-FileCopyrightText: 2009 Matthieu Gallien <matthieu_gallien@yahoo.fr>

    SPDX-License-Identifier: LGPL-2.0-only
*/

#pragma once

// own
#include "statusnotifieritemsource.h"

// plasma
#include <Plasma5Support/Service>
#include <Plasma5Support/ServiceJob>

/**
 * StatusNotifierItem Service
 */
class StatusNotifierItemService : public Plasma5Support::Service
{
    Q_OBJECT

public:
    explicit StatusNotifierItemService(StatusNotifierItemSource *source);
    ~StatusNotifierItemService() override;

protected:
    Plasma5Support::ServiceJob *createJob(const QString &operation, QMap<QString, QVariant> &parameters) override;

private:
    StatusNotifierItemSource *m_source;
};
