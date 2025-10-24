/*
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

#pragma once

#include <QDialog>
#include <QWidget>

#include <KJob>

#include "ui_statusnotifiertest.h"

class StatusNotifierTestPrivate;

class StatusNotifierTest : public QDialog, public Ui_StatusNotifierTest
{
    Q_OBJECT

public:
    StatusNotifierTest(QWidget *parent = nullptr);
    ~StatusNotifierTest() override;

    void init();
    void log(const QString &msg);

public Q_SLOTS:
    int runMain();
    void timeout();
    void updateUi();
    void updateNotifier();

    void activateRequested(bool active, const QPoint &pos);
    void scrollRequested(int delta, Qt::Orientation orientation);
    void secondaryActivateRequested(const QPoint &pos);

    void enableJob(bool enable = true);
    void setJobProgress(KJob *j, unsigned long v);
    void result(KJob *job);

private:
    StatusNotifierTestPrivate *d;
};
