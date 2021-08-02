#ifndef COLORWINDOW_H
#define COLORWINDOW_H

#include <QObject>
#include <QWidget>
#include <QColor>
#include <QString>
#include <QFrame>
#include <QLayout>
#include <QGridLayout>
#include <QPushButton>


class ColorWindow
{
public:
    explicit ColorWindow(QString, QColor, QWidget*, int);
    void setColor(QColor);
    QString getName();
    QColor getColor();
    QFrame* getFrame();
    QPushButton* getButton();
private:
    void setStyle();
    QWidget* parent;
    QString name;
    QColor color;
    QFrame* mainFrame;
    QPushButton* childFrame;
    QGridLayout* layout;
};

#endif // COLORWINDOW_H
