/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#pragma once

#include <KJob>

#include <KIO/Job>

class PumpJobPrivate;

class PumpJob : public KIO::Job
{
    Q_OBJECT

public:
    PumpJob(int interval = 0);
    ~PumpJob() override;

    void start() override;
    bool doKill() override;
    bool doSuspend() override;
    bool doResume() override;

    virtual bool isSuspended() const;

    void init();
Q_SIGNALS:
    void suspended(KJob *job);
    void resumed(KJob *job);

public Q_SLOTS:
    void timeout();

private:
    PumpJobPrivate *d;
};
