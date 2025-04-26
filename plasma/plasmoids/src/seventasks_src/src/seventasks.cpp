/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "seventasks.h"
#include <kwindowsystem.h>
#include <kwindowinfo.h>
#include <kx11extras.h>

SevenTasks::SevenTasks(QObject *parentObject, const KPluginMetaData &data, const QVariantList &args)
    : Plasma::Applet(parentObject, data, args)
{
}

SevenTasks::~SevenTasks()
{
}


bool SevenTasks::isActiveWindow(int wid)
{
    return wid == KX11Extras::activeWindow();
}
QRect SevenTasks::getWindowAspectRatio(int wid)
{
    KWindowInfo info(wid, NET::WMGeometry);
    if(info.valid()) return info.geometry();
    else return QRect();
}

unsigned int mapColorChannel(int channel)
{
    if(channel >= 0 && channel < 60)
        return 0;
    else if(channel >= 60 && channel < 200)
        return 1;
    else// if(channel >= 200 && channel <= 255)
        return 2;
    
}
unsigned char min(unsigned char a, unsigned char b)
{
    return a < b ? a : b;
}
unsigned char max(unsigned char a, unsigned char b)
{
    return a > b ? a : b;
}
QRgb averageColor(QRgb a, QRgb b)
{
    return qRgb((qRed(a) + qRed(b)) / 2, (qGreen(a) + qGreen(b)) / 2, (qBlue(a) + qBlue(b)) / 2);
}
QColor SevenTasks::getDominantColor(QVariant src)
{
	QColor defaultHighlight(55, 194, 255, 255); // This is the default blue color used for highlighting monochrome icons.
    QIcon ico = qvariant_cast<QIcon>(src);
    if(ico.isNull()) ico = QIcon::fromTheme("exec");
    
    QList<QRgb> histogram[3][3][3];
    QSize size;
    int dimensions = 32;
    
	// Iteratively goes through the closest available size to 32x32, doubling the size in case the current size isn't available.
    while(!size.isValid())
    {
        size = ico.actualSize(QSize(dimensions, dimensions));
        dimensions *= 2;
    }
    QPixmap pixmap = ico.pixmap(size);
    QImage image = pixmap.toImage();

	// Iteratively samples through every pixel.
    for(int i = 0; i < image.height(); i++)
    {
        QRgb* line = (QRgb*)image.scanLine(i);
        for(int j = 0; j < image.width(); j++)
        {
            if(qAlpha(line[j]) == 0/*< 128*/) continue; // Skip mostly transparent pixels.
            int x = mapColorChannel(qRed(line[j]));
            int y = mapColorChannel(qGreen(line[j]));
            int z = mapColorChannel(qBlue(line[j]));
            if((x == y && y == z)) continue; // Skip (mostly) monochrome pixels.
            QColor tempCol(qRed(line[j]), qGreen(line[j]), qBlue(line[j]));
            if(tempCol.hsvSaturation() < 32 || tempCol.value() < 32) continue;
            histogram[x][y][z].append(line[j]); // Add the sampled pixel to the histogram at its designated coordinates.
        }
    }
    
    unsigned char maxX = 0;
    unsigned char maxY = 0;
    unsigned char maxZ = 0;
    int count = 0;
    
    for(unsigned char i = 0; i < 3; i++)
    {
        for(unsigned char j = 0; j < 3; j++)
        {
            for(unsigned char k = 0; k < 3; k++)
            {
				// Skip the diagonal of the histogram as it is gonna result in monochrome/low saturation highlight colors. 
                if(i == j && j == k) continue; 
                if(histogram[i][j][k].count() > count)
                {
                    maxX = i;
                    maxY = j;
                    maxZ = k;
                    count = histogram[i][j][k].count(); // Picks the histogram bucket with the most colors.
                }
            }
        }
    }
    if(maxX == maxY && maxY == maxZ) // If it still ends up in a diagonal of the histogram, return the default highlight color. 
    {
        return defaultHighlight;
    }
    QRgb minCol = qRgb(255, 255, 255);
    QRgb maxCol = qRgb(0, 0, 0);
	// Get the minimum and maximum color components featured in our picked color bucket.
    for(int i = 0; i < histogram[maxX][maxY][maxZ].size(); i++)
    {
        unsigned char minred = min(qRed(histogram[maxX][maxY][maxZ].at(i)), qRed(minCol));
        unsigned char mingreen = min(qGreen(histogram[maxX][maxY][maxZ].at(i)), qGreen(minCol));
        unsigned char minblue = min(qBlue(histogram[maxX][maxY][maxZ].at(i)), qBlue(minCol));
        minCol = qRgb(minred, mingreen, minblue);
        unsigned char maxred = max(qRed(histogram[maxX][maxY][maxZ].at(i)), qRed(maxCol));
        unsigned char maxgreen = max(qGreen(histogram[maxX][maxY][maxZ].at(i)), qGreen(maxCol));
        unsigned char maxblue = max(qBlue(histogram[maxX][maxY][maxZ].at(i)), qBlue(maxCol));
        maxCol = qRgb(maxred, maxgreen, maxblue);
    }
    QRgb avg = averageColor(minCol, maxCol);
    QColor finalCol = QColor(avg);

	// Sanity checks, we don't want colors that are too dark or have low saturation.
	if(finalCol.hsvSaturation() < 32) return defaultHighlight;
	if(finalCol.value() < 85) return defaultHighlight;
    return finalCol;
}

K_PLUGIN_CLASS(SevenTasks)

#include "seventasks.moc"
