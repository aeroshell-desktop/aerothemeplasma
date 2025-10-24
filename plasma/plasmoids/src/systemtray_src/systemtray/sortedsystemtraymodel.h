/*
    SPDX-FileCopyrightText: 2019 Konrad Materka <materka@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include <QSortFilterProxyModel>

class SortedSystemTrayModel : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    enum class SortingType {
        ConfigurationPage,
        SystemTray,
    };

    explicit SortedSystemTrayModel(SortingType sorting, QObject *parent = nullptr);

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    bool lessThanConfigurationPage(const QModelIndex &left, const QModelIndex &right) const;
    bool lessThanSystemTray(const QModelIndex &left, const QModelIndex &right) const;

    int compareCategoriesAlphabetically(const QModelIndex &left, const QModelIndex &right) const;
    int compareCategoriesOrderly(const QModelIndex &left, const QModelIndex &right) const;

    SortingType m_sorting;
};
