/*
    SPDX-FileCopyrightText: 2021  <>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#ifndef SEVENTASKS_H
#define SEVENTASKS_H


#include <Plasma/Applet>
#include <QColor>
#include <QPixmap>
#include <QImage>
#include <QRgb>
#include <QIcon>
#include <QVariant>
#include <QtQuick/QQuickItem>
#include <QtQuick/QQuickItemGrabResult>
#include <QWindow>
#include <QCursor>
#include <QKeySequence>
#include <QVariantList>
#include <kwindoweffects.h>

class SevenTasks : public Plasma::Applet
{
    Q_OBJECT

public:
    SevenTasks( QObject *parent, const QVariantList &args );
    ~SevenTasks();
    Q_INVOKABLE QColor getDominantColor(QVariant src);
    Q_INVOKABLE bool isActiveWindow(int wid);
    // Used to disable the blur behind the context menu when it's closing. I thought it'd look just a tad bit more nice like that.
    Q_INVOKABLE void disableBlurBehind(QWindow* w)
    {
        KWindowEffects::enableBlurBehind(w, false, QRegion(0,0, w->width(), w->height()));
    }

    /*
     * Makes a QWindow object grab all mouse events from the system.
     * This is generally not advised unless there exists a safe way to
     * ungrab the mouse from the object, otherwise the mouse will become
     * "stuck" and unable to do anything for the remaining session.
     *
     * This method is used for TasksMenu, which is based on PlasmaCore.Dialog,
     * which inherits QWindow. By making a TasksMenu instance grab mouse events,
     * we can make it act like a context menu.
     *
     * Additionally, in order to make sure that the user can safely click away
     * from the context menu after it has grabbed the mouse, this class installs
     * itself onto the QWindow as an event filter. When filtering mouse clicks
     * of any kind, we can send a signal which gets picked up by TasksMenu,
     * which will notify it to close gracefully.
     *
     * One thing to note about this method:
     * When the user right clicks on a task in the taskbar, during the press
     * event a TasksMenu instance is created and shown, and calling this
     * method during the same press event won't have an effect. The method
     * will actually affect the instance only after the press event.
     * Practically speaking, this means the method should be called when
     * the mouse has been released.
     *
     * https://stackoverflow.com/questions/29777230/qml-steal-events-from-dynamic-mousearea
     * https://stackoverflow.com/questions/46173105/how-can-i-reset-a-timer-every-time-i-receive-a-touch-event-from-a-qml-page/46173896#46173896
     *
     */
    Q_INVOKABLE void setMouseGrab(bool arg, QWindow* w)
    {
        if(arg)
        {
            w->installEventFilter(this);
        }
        else
        {
            w->removeEventFilter(this);
        }
        w->setMouseGrabEnabled(arg);
    }
    Q_INVOKABLE QPoint getPosition(QWindow* w)
    {
        return w->mapFromGlobal(QCursor::pos());
    }
protected:
    bool eventFilter(QObject* watched, QEvent* event) override
    {
        QEvent::Type t = event->type();
        if (t == QEvent::MouseButtonDblClick || t == QEvent::MouseButtonPress || t == QEvent::MouseButtonRelease)
        {
            emit mouseEventDetected();
        }
        return QObject::eventFilter(watched, event);
    }
signals:
    void mouseEventDetected();
};

#endif
