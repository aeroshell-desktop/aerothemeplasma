/*
    SPDX-FileCopyrightText: 2010 Fredrik Höglund <fredrik@kde.org>
    SPDX-FileCopyrightText: 2010 Alexandre Pereira <pereira.alex@gmail.com>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once

#include "ui_glide_config.h"
#include <KCModule>

namespace KWin
{

class GlideEffectConfig : public KCModule
{
    Q_OBJECT

public:
    explicit GlideEffectConfig(QObject *parent, const KPluginMetaData &data);
    ~GlideEffectConfig() override;

    void save() override;

private:
    ::Ui::GlideEffectConfig ui;
};

} // namespace KWin
