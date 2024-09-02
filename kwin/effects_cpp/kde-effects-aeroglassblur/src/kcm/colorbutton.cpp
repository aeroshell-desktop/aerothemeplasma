#include "colorbutton.h"

ColorButton::ColorButton(QWidget* parent) : QPushButton(parent)
{
    parentEffect = new QGraphicsOpacityEffect(this);
    parentEffect->setOpacity(0.0);
    this->setGraphicsEffect(parentEffect);
}

void ColorButton::setGlassButton(QPushButton* btn)
{
    glassButton = btn;
}
void ColorButton::setSelected(bool selected)
{
    if(selected)
    {
        m_currentState = (ButtonState)((int)m_currentState | ButtonState::Selected);
    }
    else
    {
        m_currentState = (ButtonState)((int)m_currentState & ~ButtonState::Selected);
    }
    setOpacity();
}
void ColorButton::setHovered(bool hovered)
{
    if(hovered)
    {
        m_currentState = (ButtonState)((int)m_currentState | ButtonState::Hover);
    }
    else
    {
        m_currentState = (ButtonState)((int)m_currentState & ~ButtonState::Hover);
    }
}

void ColorButton::setOpacity()
{
    float opacity = 1.0f;
    switch(m_currentState)
    {
        case Default:
            opacity = 0.0f;
            break;
        case Hover:
            opacity = 0.5f;
            break;
        case Selected:
            opacity = 0.75f;
            break;
        case Hover | Selected:
            opacity = 1.0f;
            break;
    }
    parentEffect->setOpacity(opacity);
}
void ColorButton::enterEvent(QEnterEvent* ev)
{
    setHovered(true);
    setOpacity();
}
void ColorButton::leaveEvent(QEvent* ev)
{
    setHovered(false);
    setOpacity();
}
