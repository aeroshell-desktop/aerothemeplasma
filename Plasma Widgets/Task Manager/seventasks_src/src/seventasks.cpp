/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "seventasks.h"

SevenTasks::SevenTasks(QObject *parent, const QVariantList &args)
    : Plasma::Applet(parent, args)
{
}

SevenTasks::~SevenTasks()
{
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
	QColor defaultHighlight(67, 160, 214, 170);
    QIcon ico = qvariant_cast<QIcon>(src);
    if(ico.isNull()) return QColor(255,255,255,170);
    //if(ico.name().isNull()) return QColor(255,255,255,170);
    //printf("ICON: %s\n", ico.name().toStdString().c_str());
    
    QList<QRgb> histogram[3][3][3];
    //QIcon ico = QIcon::fromTheme(src);
    QSize size;
    int dimensions = 32;
    
    while(!size.isValid())
    {
        size = ico.actualSize(QSize(dimensions, dimensions));
        dimensions *= 2;
    }
    QPixmap pixmap = ico.pixmap(size);
    QImage image = pixmap.toImage();
    for(int i = 0; i < image.height(); i++)
    {
        QRgb* line = (QRgb*)image.scanLine(i);
        for(int j = 0; j < image.width(); j++)
        {
            if(qAlpha(line[j]) < 128) continue;
            int x = mapColorChannel(qRed(line[j]));
            int y = mapColorChannel(qGreen(line[j]));
            int z = mapColorChannel(qBlue(line[j]));
            if((x == y && y == z)) continue;
            /*if(QColor(qRed(line[j]), qGreen(line[j]), qBlue(line[j])).value() < 32) continue;
            if(QColor(qRed(line[j]), qGreen(line[j]), qBlue(line[j])).hsvSaturation() < 32) continue;*/
            histogram[x][y][z].append(line[j]);
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
                if(i == j && j == k) continue;
                if(histogram[i][j][k].count() > count)
                {
                    maxX = i;
                    maxY = j;
                    maxZ = k;
                    count = histogram[i][j][k].count();
                }
            }
        }
    }
    if(maxX == maxY && maxY == maxZ)
    {
        return defaultHighlight;
    }
    QRgb minCol = qRgb(255, 255, 255);
    QRgb maxCol = qRgb(0, 0, 0);
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
	if(finalCol.hsvSaturation() < 32) return defaultHighlight;
	if(finalCol.value() < 85) return defaultHighlight;
    int saturation = finalCol.hsvSaturation() * 1.5;
    int value = finalCol.value() * 1.5;
    if(saturation > 255) saturation = 255;
    if(value > 255) value = 255;
    
    finalCol.setHsv(finalCol.hsvHue(), saturation, value, 170);
    return finalCol;
}

K_PLUGIN_CLASS_WITH_JSON(SevenTasks, "metadata.json")

#include "seventasks.moc"
