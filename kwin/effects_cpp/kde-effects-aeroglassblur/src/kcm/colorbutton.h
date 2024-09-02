#ifndef COLORBUTTON_H
#define COLORBUTTON_H

#include <QObject>
#include <QWidget>
#include <QPainter>
#include <QPushButton>
#include <QEnterEvent>
#include <QEvent>
#include <QGraphicsOpacityEffect>

class ColorButton : public QPushButton
{
    Q_OBJECT
public:

    ColorButton(QWidget* parent = nullptr);
    enum ButtonState
    {
        Default = 0,
        Hover = 1,
        Selected = 2
    };
    void setSelected(bool selected);
    void setOpacity();
    void setGlassButton(QPushButton* btn);
    void setHovered(bool hovered);
protected:
    void enterEvent(QEnterEvent*) override;
    void leaveEvent(QEvent*) override;
    ButtonState m_currentState = Default;
    QGraphicsOpacityEffect* parentEffect = nullptr;
    QPushButton* glassButton = nullptr;
};

#endif // COLORBUTTON_H
