/*
    SPDX-FileCopyrightText: 2021 Vlad Zahorodnii <vlad.zahorodnii@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#include "startupfeedback.h"

namespace KWin
{

KWIN_EFFECT_FACTORY_SUPPORTED(StartupFeedbackEffect,
                              "metadata.json",
                              return StartupFeedbackEffect::supported();)

} // namespace KWin

#include "main.moc"
