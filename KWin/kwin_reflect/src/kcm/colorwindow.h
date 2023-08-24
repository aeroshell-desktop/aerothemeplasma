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

/*
 * This class represents the selectable colors found in the FlowLayout of the main window.
 * They're made up of a QFrame and a QPushButton, managed by a QGridLayout. the QPushButton
 * shows the actual color while the QFrame holding it is just there for the visuals.
 */

class ColorWindow
{
public:
    explicit ColorWindow(QString, QColor, QWidget*, int);
    void setColor(QColor);
    QString getName();
    QColor getColor();
    QFrame* getFrame();
    QPushButton* getButton();
    void clear();
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
