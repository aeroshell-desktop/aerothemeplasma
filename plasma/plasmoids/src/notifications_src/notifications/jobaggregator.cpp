/*
    SPDX-FileCopyrightText: 2022 Kai Uwe Broulik <kde@broulik.de>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "jobaggregator.h"

#include <notificationmanager/notifications.h>

JobAggregator::JobAggregator(QObject *parent)
    : QObject(parent)
{
}

JobAggregator::~JobAggregator() = default;

QAbstractItemModel *JobAggregator::sourceModel() const
{
    return m_model.data();
}

void JobAggregator::setSourceModel(QAbstractItemModel *sourceModel)
{
    if (m_model == sourceModel) {
        return;
    }

    if (m_model) {
        disconnect(m_model, nullptr, this, nullptr);
    }
    m_model = sourceModel;
    if (m_model) {
        connect(m_model.data(), &QAbstractItemModel::modelReset, this, &JobAggregator::update);
        connect(m_model.data(), &QAbstractItemModel::rowsInserted, this, &JobAggregator::update);
        connect(m_model.data(), &QAbstractItemModel::rowsRemoved, this, &JobAggregator::update);

        connect(m_model.data(),
                &QAbstractItemModel::dataChanged,
                this,
                [this](const QModelIndex &topLeft, const QModelIndex &bottomRight, const QList<int> &roles) {
                    Q_UNUSED(topLeft);
                    Q_UNUSED(bottomRight);

                    if (roles.isEmpty() || roles.contains(NotificationManager::Notifications::SummaryRole)
                        || roles.contains(NotificationManager::Notifications::PercentageRole)
                        || roles.contains(NotificationManager::Notifications::JobStateRole)) {
                        update();
                    }
                });
    }
    Q_EMIT sourceModelChanged();

    update();
}

int JobAggregator::count() const
{
    return m_count;
}

QString JobAggregator::summary() const
{
    return m_summary;
}

int JobAggregator::percentage() const
{
    return m_percentage;
}

void JobAggregator::update()
{
    if (!m_model) {
        return;
    }

    int count = 0;
    QString combinedSummary;
    int totalPercentage = 0;

    for (int i = 0; i < m_model->rowCount(); ++i) {
        const QModelIndex idx = m_model->index(i, 0);

        if (idx.data(NotificationManager::Notifications::JobStateRole).toInt() == NotificationManager::Notifications::JobStateStopped
            || idx.data(NotificationManager::Notifications::TypeRole).toInt() != NotificationManager::Notifications::JobType) {
            continue;
        }

        const QString summary = idx.data(NotificationManager::Notifications::SummaryRole).toString();

        // Include summary only if it's the same for all jobs
        if (i == 0) {
            combinedSummary = summary;
        } else if (combinedSummary != summary) {
            combinedSummary.clear();
        }

        const int percentage = idx.data(NotificationManager::Notifications::PercentageRole).toInt();
        totalPercentage += percentage;

        ++count;
    }

    if (m_count != count) {
        m_count = count;
        Q_EMIT countChanged();
    }

    if (m_summary != combinedSummary) {
        m_summary = combinedSummary;
        Q_EMIT summaryChanged();
    }

    const int percentage = (count > 0 ? totalPercentage / count : 0);
    if (m_percentage != percentage) {
        m_percentage = percentage;
        Q_EMIT percentageChanged();
    }
}

#include "moc_jobaggregator.cpp"
