#include "colorwindow.h"

ColorWindow::ColorWindow(QString str, QColor col, QWidget* wnd, int i)
{
    name = str;
    color = col;
    parent = wnd;

    mainFrame = new QFrame(wnd);
    mainFrame->setMaximumSize(72, 72);
    mainFrame->setMinimumSize(72, 72);

    layout = new QGridLayout(mainFrame);
    layout->setContentsMargins(0, 0, 0, 0);

    frameButton = new ColorButton(mainFrame);
    frameButton->setMaximumSize(72, 72);
    frameButton->setMinimumSize(72, 72);
    frameButton->setObjectName("button_" + QString::number(i));

    backgroundColor = new QWidget(mainFrame);
    backgroundColor->setAttribute(Qt::WA_TransparentForMouseEvents);
    backgroundColor->setMaximumSize(56, 56);
    backgroundColor->setMinimumSize(56, 56);

    childFrame = new QPushButton(mainFrame);
    childFrame->setAttribute(Qt::WA_TransparentForMouseEvents);
    childFrame->setText("");
    childFrame->setMaximumSize(56, 56);
    childFrame->setMinimumSize(56, 56);

    frameButton->setGlassButton(childFrame);

    setStyle();
    layout->addWidget(frameButton, 0, 0, Qt::AlignHCenter | Qt::AlignVCenter);
    layout->addWidget(childFrame, 0, 0, Qt::AlignHCenter | Qt::AlignVCenter);
    layout->addWidget(backgroundColor, 0, 0, Qt::AlignHCenter | Qt::AlignVCenter);
    mainFrame->setToolTip(this->name);

}

void ColorWindow::setStyle()
{

    frameButton->setStyleSheet(QString("QPushButton {\n") +
        "border-image: url(\":/svgs/frame-select.svg\") 5 5 5 5;\n" +
        "border-top: 5px transparent;\n"   +
        "border-left: 5px transparent;\n"  +
        "border-bottom: 5px transparent;\n"+
        "border-right: 5px transparent;\n" +
    "}\n");
    childFrame->setStyleSheet(QString("QPushButton {\n") +
        "border-image: url(\":/svgs/frame.svg\") 3 3 3 3;\n" +
        "border-top: 3px transparent;\n"   +
        "border-left: 3px transparent;\n"  +
        "border-bottom: 3px transparent;\n"+
        "border-right: 3px transparent;\n" +
        //"margin: 8px;\n" +
    "}\n");
    backgroundColor->setStyleSheet(
    QString("QWidget {\n") +
        "background-color: "+ color.name(QColor::HexRgb) +";\n" +
        "margin: 1px;\n" +
    "}"
    );

}

void ColorWindow::setColor(QColor c)
{
    color = c;
    backgroundColor->setStyleSheet(
    QString("QWidget {\n") +
        "background-color: "+ color.name(QColor::HexRgb) +";\n" +
        "margin: 1px;\n" +
    "}"
    );
}

ColorButton* ColorWindow::getFrameButton()
{
    return frameButton;
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

void ColorWindow::clear()
{
    QLayoutItem *child;
    while((child = layout->takeAt(0)) != 0) delete child;
    delete layout;
    delete mainFrame;
}
