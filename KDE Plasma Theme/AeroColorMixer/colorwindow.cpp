#include "colorwindow.h"

ColorWindow::ColorWindow(QString str, QColor col, QWidget* wnd, int i)
{
    name = str;
    color = col;
    parent = wnd;
    mainFrame = new QFrame(wnd);
    mainFrame->setMaximumSize(64, 64);
    mainFrame->setMinimumSize(64, 64);
    layout = new QGridLayout(mainFrame);
    layout->setContentsMargins(5, 5, 5, 5);
    childFrame = new QPushButton(mainFrame);
    childFrame->setText("");
    childFrame->setMaximumSize(50, 50);
    childFrame->setMinimumSize(50, 50);
    childFrame->setObjectName("button_" + QString::number(i));
    setStyle();
    layout->addWidget(childFrame);

}

void ColorWindow::setStyle()
{
    QColor desatColor = color;
    QColor brightColor = color;
    desatColor.setRgb(255, 255, 255);
    brightColor.setRgb(200, 200, 200);
    mainFrame->setStyleSheet("QFrame { background-color: " + desatColor.name(QColor::HexRgb) +
                             ";border: 1px solid black; border-radius: 3px; } QFrame:hover { background-color:" +
                             QColor(brightColor.red(), brightColor.green(), brightColor.blue()).name(QColor::HexRgb) + "; }");
    childFrame->setStyleSheet("QPushButton { background-color: " + color.name(QColor::HexArgb) + "; border: 2px solid black; border-radius: 3px; }");

}

void ColorWindow::setColor(QColor c)
{
    color = c;
    setStyle();
}

QString ColorWindow::getName()
{
    return name;
}

QColor ColorWindow::getColor()
{
    return color;
}

QFrame* ColorWindow::getFrame()
{
    return mainFrame;
}

QPushButton* ColorWindow::getButton()
{
    return childFrame;
}
