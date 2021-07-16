/*
 * shadowengine.cpp - Emerald window decoration for KDE
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

#include "shadowengine.h"

#include <QImage>

#include <cmath>

namespace Smaragd
{

QImage createShadowImage(const ShadowSettings &settings)
{
    const int radius = settings.radius + 32;
    const int size = 2 * radius + 1;

    QImage shadowImage(size, size, QImage::Format_ARGB32_Premultiplied);
    shadowImage.fill(0);

    QRadialGradient gradient(radius + 0.5, radius + 0.5, radius + 0.5);
    for (qreal v = 0.0; v <= 1.0; v += 1.0 / 64) {
        qreal k;
        QColor color = settings.color;
        if (v * radius < radius - (32.0 + settings.size)) {
            k = 0.0;
        } else {
            qreal x = (radius - 32.0) / radius;
            k = (v - x) / (1.0 - x);
            k = pow(1.0 - k, settings.linearDecay) * exp(-settings.exponentialDecay * k);
        }
        color.setAlpha(qBound(0, qRound(color.alpha() * k), 255));
        gradient.setColorAt(v, color);
    }

    QPainter p(&shadowImage);
    p.setCompositionMode(QPainter::CompositionMode_Source);
    p.setRenderHint(QPainter::Antialiasing, true);
    p.setBrush(gradient);
    p.setPen(Qt::NoPen);
    p.drawEllipse(0, 0, size, size);
    p.end();

    return shadowImage;
}

void paintShadow(QPainter *p, const QRect &r, const ShadowSettings &settings, const QImage &shadowImage)
{
    const int s = -settings.size;
    QRect rect = r.adjusted(s - 32, s - 32, 32 - s, 32 - s);
    rect.adjust(settings.offsetX, settings.offsetY, settings.offsetX, settings.offsetY);
    int radius = shadowImage.width() / 2;

    // corners
    for (int i = 0; i < 4; ++i) {
        const int x = i & 1 ? rect.x() : rect.x() + rect.width() - radius;
        const int y = i & 2 ? rect.y() : rect.y() + rect.height() - radius;
        p->drawImage(x, y, shadowImage,
            i & 1 ? 0 : radius + 1, i & 2 ? 0 : radius + 1, radius, radius);
    }

    // sides
    for (int i = 0; i < 2; ++i) {
        const int x = rect.x() + radius;
        const int y = i & 1 ? rect.y() : rect.y() + rect.height() - radius;
        p->drawTiledPixmap(x, y, rect.width() - 2 * radius, radius,
            QPixmap::fromImage(shadowImage.copy(radius, i & 1 ? 0 : radius + 1, 1, radius)));
    }
    for (int i = 0; i < 2; ++i) {
        const int x = i & 1 ? rect.x() : rect.x() + rect.width() - radius;
        const int y = rect.y() + radius;
        p->drawTiledPixmap(x, y, radius, rect.height() - 2 * radius,
            QPixmap::fromImage(shadowImage.copy(i & 1 ? 0 : radius + 1, radius, radius, 1)));
    }

    // center
    QRgb pixel = shadowImage.pixel(radius, radius);
    if (shadowImage.format() == QImage::Format_ARGB32_Premultiplied) {
        const int alpha = qAlpha(pixel);
        if (alpha != 0 && alpha != 255) {
            pixel = qRgba(qBound(0, qRed(pixel) * 255 / alpha, 255),
                qBound(0, qGreen(pixel) * 255 / alpha, 255),
                qBound(0, qBlue(pixel) * 255 / alpha, 255),
                alpha);
        }
    }
    p->fillRect(rect.adjusted(radius, radius, -radius, -radius), QColor::fromRgba(pixel));
}

}; // namespace Smaragd

