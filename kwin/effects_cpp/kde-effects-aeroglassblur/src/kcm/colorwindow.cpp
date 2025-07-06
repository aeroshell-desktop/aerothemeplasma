#include "colorwindow.h"

ColorWindow::ColorWindow(QString str, QColor col, QWidget* wnd, int i, int group)
{
    name = str;
    color = col;
    parent = wnd;
    m_colorGroup = group;

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
    backgroundColor->setMaximumSize(64, 64);
    backgroundColor->setMinimumSize(64, 64);

    childFrame = new QPushButton(mainFrame);
    childFrame->setAttribute(Qt::WA_TransparentForMouseEvents);
    childFrame->setText("");
    childFrame->setMaximumSize(64, 64);
    childFrame->setMinimumSize(64, 64);

    frameButton->setGlassButton(childFrame);

    setStyle();
    layout->addWidget(frameButton, 0, 0, Qt::AlignHCenter | Qt::AlignVCenter);
    layout->addWidget(childFrame, 0, 0, Qt::AlignHCenter | Qt::AlignVCenter);
    layout->addWidget(backgroundColor, 0, 0, Qt::AlignHCenter | Qt::AlignVCenter);
    mainFrame->setToolTip(this->name);


}
void ColorWindow::setVisible(bool visible)
{
    mainFrame->setVisible(visible);
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
        "border-image: url(\":/svgs/frame.svg\") 9 9 9 9;\n" +
        "border-top: 9px transparent;\n"   +
        "border-left: 9px transparent;\n"  +
        "border-bottom: 9px transparent;\n"+
        "border-right: 9px transparent;\n" +
        //"margin: 8px;\n" +
    "}\n");

    float alpha = color.alphaF() * 1.1f;
    if(alpha > 1.0f) alpha = 1.0f;
    if(alpha < 0.1f) alpha = 0.1f;

    QColor newCol = color;
    /*float sat = newCol.hsvSaturationF() * 1.05f;
    if(sat > 1.0) sat = 1.0f;
    newCol.setHsvF(newCol.hsvHueF(), sat, newCol.valueF());*/
    newCol.setAlphaF(alpha);
    QColor endCol = color;
    alpha = endCol.alphaF() * 0.65f;
    endCol.setAlphaF(alpha);

    backgroundColor->setStyleSheet(
    QString("QWidget {\n") +
        "background: qlineargradient(x1: 0, y1:0, x2: 0, y2: 1, stop: 0"+ endCol.name(QColor::HexArgb)
                                                            +", stop: 0.55 " + newCol.name(QColor::HexArgb)
                                                            +", stop: 0.65 " + newCol.name(QColor::HexArgb)
                                                            +", stop: 0.70 " + newCol.name(QColor::HexArgb)
                                                            +", stop: 1 "+ endCol.name(QColor::HexArgb) + ");\n" +
        "margin: 5px;\n" +
        "border-radius: 3px;"
    "}"
    );

}

int ColorWindow::colorGroup() const
{
    return m_colorGroup;
}

void ColorWindow::setColor(QColor c)
{
    color = c;
    float alpha = color.alphaF() * 1.1f;
    if(alpha > 1.0f) alpha = 1.0f;
    if(alpha < 0.1f) alpha = 0.1f;

    QColor newCol = color;
    newCol.setAlphaF(alpha);
    QColor endCol = color;
    alpha = endCol.alphaF() * 0.65f;
    endCol.setAlphaF(alpha);

    backgroundColor->setStyleSheet(
        QString("QWidget {\n") +
        "background: qlineargradient(x1: 0, y1:0, x2: 0, y2: 1, stop: 0"+ endCol.name(QColor::HexArgb)
        +", stop: 0.65 " + newCol.name(QColor::HexArgb)
        +", stop: 1 "+ endCol.name(QColor::HexArgb) + ");\n" +
        "margin: 5px;\n" +
        "border-radius: 3px;"
        "}"
    );
    /*backgroundColor->setStyleSheet(
    QString("QWidget {\n") +
        "background-color: "+ color.name(QColor::HexRgb) +";\n" +
        "margin: 1px;\n" +
    "}"
    );*/
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
