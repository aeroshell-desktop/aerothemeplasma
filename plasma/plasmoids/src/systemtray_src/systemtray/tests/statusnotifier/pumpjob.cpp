/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#include "pumpjob.h"

#include <QDebug>

#include <KIO/Global>
#include <KIO/JobTracker>
#include <KJobTrackerInterface>
#include <KLocalizedString>
#include <QStringList>
#include <QTimer>

static QTextStream cout(stdout);

class PumpJobPrivate
{
public:
    QString name;
    QString error;

    QTimer *timer;
    int interval = 200;

    int counter = 0;

    bool suspended = false;
};

PumpJob::PumpJob(int interval)
    : KIO::Job()
{
    d = new PumpJobPrivate;

    if (interval) {
        d->interval = d->interval * interval;
    }
    KIO::getJobTracker()->registerJob(this);

    d->timer = new QTimer(this);
    d->timer->setInterval(d->interval);
    qDebug() << "Starting job with interval: " << d->interval;

    connect(d->timer, &QTimer::timeout, this, &PumpJob::timeout);

    init();
}

void PumpJob::init()
{
    Q_EMIT description(this,
                       i18n("Pump Job"),
                       qMakePair(i18n("Source"), QStringLiteral("this is the source")),
                       qMakePair(i18n("Destination"), QStringLiteral("destination, baby")));
    d->timer->start();
}

PumpJob::~PumpJob()
{
    KIO::getJobTracker()->unregisterJob(this);
    qDebug() << "Bye bye";
    delete d;
}

void PumpJob::start()
{
    qDebug() << "Starting job / timer";
    d->timer->start();
}

bool PumpJob::doKill()
{
    qDebug() << "kill";
    emitResult();
    d->timer->stop();
    setError(KIO::ERR_USER_CANCELED);
    setErrorText(QStringLiteral("You killed the job."));
    return KJob::doKill();
}

bool PumpJob::doResume()
{
    d->suspended = false;
    qDebug() << "resume";
    d->timer->start();
    Q_EMIT resumed(this);
    return KJob::doResume();
}

bool PumpJob::isSuspended() const
{
    return d->suspended;
}

bool PumpJob::doSuspend()
{
    d->suspended = true;
    qDebug() << "suspend";
    d->timer->stop();
    Q_EMIT suspended(this);
    return KJob::doSuspend();
}

void PumpJob::timeout()
{
    d->counter++;
    setPercent(d->counter);
    emitSpeed(1024 * 1024 * d->counter / 70); // just something randomly changing
    int seconds = (int)((d->interval * 100) - (d->interval * percent())) / 1000;
    Q_EMIT infoMessage(this, i18n("Testing kuiserver (%1 seconds remaining)", seconds));

    qDebug() << "percent: " << percent() << "  Seconds: " << seconds;
    if (d->counter % 20 == 0) {
        // qDebug() << "percent: " << percent() << "  Seconds: " << seconds;
    }

    if (d->counter >= 100) {
        qDebug() << "Job done";
        emitResult();
    }
}

#include "moc_pumpjob.cpp"
