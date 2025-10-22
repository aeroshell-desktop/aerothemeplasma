/*
    SPDX-FileCopyrightText: 2022 Kai Uwe Broulik <kde@broulik.de>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#pragma once

#include <QAbstractItemModel>
#include <QObject>
#include <QPointer>
#include <qqmlregistration.h>

class JobAggregator : public QObject
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QAbstractItemModel *sourceModel READ sourceModel WRITE setSourceModel NOTIFY sourceModelChanged)

    Q_PROPERTY(int count READ count NOTIFY countChanged)

    Q_PROPERTY(QString summary READ summary NOTIFY summaryChanged)
    Q_PROPERTY(int percentage READ percentage NOTIFY percentageChanged)

public:
    explicit JobAggregator(QObject *parent = nullptr);
    ~JobAggregator() override;

    QAbstractItemModel *sourceModel() const;
    void setSourceModel(QAbstractItemModel *sourceModel);
    Q_SIGNAL void sourceModelChanged();

    int count() const;
    Q_SIGNAL void countChanged();

    QString summary() const;
    Q_SIGNAL void summaryChanged();

    int percentage() const;
    Q_SIGNAL void percentageChanged();

private:
    void update();

    QPointer<QAbstractItemModel> m_model;

    int m_count = 0;
    QString m_summary;
    int m_percentage = 0;
};
