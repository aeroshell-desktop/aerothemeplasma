/*
 * shadowengine.h - Emerald window decoration for KDE
 *
 * Copyright (c) 2010 Christoph Feck <christoph@maxiom.de>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 */

#ifndef SMARAGD_SHADOWENGINE_H
#define SMARAGD_SHADOWENGINE_H 1

#include <QPainter>

namespace Smaragd
{

class ShadowSettings
{
public:
    int radius;
    QColor color;
    int offsetX;
    int offsetY;
    int size;
    qreal linearDecay;
    qreal exponentialDecay;
};

QImage createShadowImage(const ShadowSettings &settings);
void paintShadow(QPainter *p, const QRect &rect, const ShadowSettings &settings, const QImage &shadowImage);

}; // namespace Smaragd

#endif

