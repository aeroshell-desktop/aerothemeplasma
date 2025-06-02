/*
    SPDX-FileCopyrightText: 2011 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2011 Artur Duque de Souza <asouza@kde.org>
    SPDX-FileCopyrightText: 2013 Sebastian Kügler <sebas@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#ifndef TOOLTIPOBJECT_H
#define TOOLTIPOBJECT_H

#include <Plasma/Plasma>
#include <QPointer>
#include <QQuickItem>
#include <QTimer>
#include <QVariant>

#include "plasmawindow.h"

class QQuickItem;
class ToolTipDialog;

/**
 * An Item managing a Plasma-themed tooltip. It is rendered in its own window.
 * You can either specify icon, mainText and subText, or a custom Component
 * that will be put inside the tooltip. By default the tooltip will be
 * rendered when hovering over the parent item.
 *
 * The item inside the ToolTipArea is loaded on demand and will be destroyed when the
 * tooltip is being hidden.
 *
 * Example usage:
 * @code
 * import org.kde.plasma.core as PlasmaCore
 * import org.kde.kirigami 2.20 as Kirigami
 *
 * Kirigami.Icon {
 *     PlasmaCore.ToolTipArea {
 *         mainText: i18n("Tooltip Title")
 *         subText: i18n("Some explanation.")
 *         icon: "plasma"
 *         // alternatively, you can specify your own component
 *         // to be loaded when the tooltip shows
 *         mainItem: YourCustomItem { }
 *     }
 * }
 * @endcode
 *
 * <b>Import Statement</b>
 * @code import org.kde.plasma.core @endcode
 * @version 2.0
 */
class ToolTipArea : public QQuickItem
{
    Q_OBJECT
    QML_ELEMENT

    /**
     * The item shown inside the tooltip.
     */
    Q_PROPERTY(QQuickItem *mainItem READ mainItem WRITE setMainItem NOTIFY mainItemChanged)

    /**
     * The main text of this tooltip
     */
    Q_PROPERTY(QString mainText READ mainText WRITE setMainText NOTIFY mainTextChanged)

    /**
     * The description of this tooltip
     */
    Q_PROPERTY(QString subText READ subText WRITE setSubText NOTIFY subTextChanged)

    /**
     * how to handle the text format of the tooltip subtext:
     * * Text.AutoText (default)
     * * Text.PlainText
     * * Text.StyledText
     * * Text.RichText
     * Note: in the default implementation the main text is always plain text
     */
    Q_PROPERTY(int textFormat READ textFormat WRITE setTextFormat NOTIFY textFormatChanged)

    /**
     * An icon for this tooltip, accepted values are an icon name, a QIcon, QImage or QPixmap
     */
    Q_PROPERTY(QVariant icon READ icon WRITE setIcon NOTIFY iconChanged)

    /**
     * Returns whether the mouse is inside the item
     */
    Q_PROPERTY(bool containsMouse READ containsMouse NOTIFY containsMouseChanged)

    /**
     * Plasma Location of the dialog window. Useful if this dialog is a popup for a panel
     */
    Q_PROPERTY(Plasma::Types::Location location READ location WRITE setLocation NOTIFY locationChanged)

    /**
     * TODO: single property for images?
     * An image for this tooltip, accepted values are an icon name, a QIcon, QImage or QPixmap
     */
    Q_PROPERTY(QVariant image READ image WRITE setImage NOTIFY imageChanged)

    /**
     * Property that controls if a tooltips will show on mouse over.
     * The default is true.
     */
    Q_PROPERTY(bool active MEMBER m_active WRITE setActive NOTIFY activeChanged)

    /**
     * If interactive is false (default), the tooltip will automatically hide
     * itself as soon as the mouse leaves the tooltiparea, if is true, if the
     * mouse leaves tooltiparea and goes over the tooltip itself, the tooltip
     * won't hide, so it will be possible to interact with tooltip contents.
     */
    Q_PROPERTY(bool interactive MEMBER m_interactive WRITE setInteractive NOTIFY interactiveChanged)

    /**
     * Timeout in milliseconds after which the tooltip will hide itself.
     * Set this value to -1 to never hide the tooltip automatically.
     */
    Q_PROPERTY(int timeout MEMBER m_timeout WRITE setTimeout)

    /**
     * Set the background for the tooltip.
     * By default, the solid version of the tooltip background is used.
     */
    Q_PROPERTY(PlasmaQuick::PlasmaWindow::BackgroundHints backgroundHints MEMBER m_backgroundHints WRITE setBackgroundHints)

    /**
     * Set the window title for the tooltip.
     * This is used for window detection by other components such as KWin effects.
     */
    Q_PROPERTY(QString windowTitle MEMBER m_windowTitle WRITE setWindowTitle)

public:
    /// @cond INTERNAL_DOCS
    explicit ToolTipArea(QQuickItem *parent = nullptr);
    ~ToolTipArea() override;

    QQuickItem *mainItem() const;
    void setMainItem(QQuickItem *mainItem);

    QString mainText() const;
    void setMainText(const QString &mainText);

    QString subText() const;
    void setSubText(const QString &subText);

    int textFormat() const;
    void setTextFormat(int format);

    QVariant icon() const;
    void setIcon(const QVariant &icon);

    QVariant image() const;
    void setImage(const QVariant &image);

    Plasma::Types::Location location() const;
    void setLocation(Plasma::Types::Location location);

    bool containsMouse() const;
    void setContainsMouse(bool contains);

    void setActive(bool active);

    void setInteractive(bool interactive);

    void setTimeout(int timeout);

    void setBackgroundHints(PlasmaQuick::PlasmaWindow::BackgroundHints backgroundHints);

    void setWindowTitle(QString windowTitle);
    /// @endcond

public Q_SLOTS:

    /**
     * Shows the tooltip.
     * @since 5.73
     */
    void showToolTip();

    /**
     * Hides the tooltip after a grace period if shown. Does not affect whether the tooltip area is active.
     */
    void hideToolTip();

    /**
     * Hides the tooltip immediately, in comparison to hideToolTip.
     * @since 5.84
     */
    void hideImmediately();

protected:
    /// @cond INTERNAL_DOCS
    bool childMouseEventFilter(QQuickItem *item, QEvent *event) override;
    void hoverEnterEvent(QHoverEvent *event) override;
    void hoverLeaveEvent(QHoverEvent *event) override;

    ToolTipDialog *tooltipDialogInstance();
    /// @endcond

Q_SIGNALS:
    void mainItemChanged();
    void mainTextChanged();
    void subTextChanged();
    void textFormatChanged();
    void iconChanged();
    void imageChanged();
    void containsMouseChanged();
    void locationChanged();
    void activeChanged();
    void interactiveChanged();
    /**
     * Emitted just before the tooltip dialog is shown.
     *
     * @since 5.45
     */
    void aboutToShow();
    /**
     * Emitted when the tooltip's visibility changes.
     *
     * @since 5.88
     */
    void toolTipVisibleChanged(bool toolTipVisible);

private Q_SLOTS:
    void settingsChanged(const QString &file);

private:
    bool isValid() const;

    void loadSettings();
    bool m_tooltipsEnabledGlobally;
    bool m_containsMouse;
    Plasma::Types::Location m_location;
    QPointer<QQuickItem> m_mainItem;
    QTimer m_showTimer;
    QString m_mainText;
    QString m_subText;
    int m_textFormat;
    QVariant m_image;
    QVariant m_icon;
    bool m_active;
    bool m_interactive;
    int m_interval;
    int m_timeout;
    PlasmaQuick::PlasmaWindow::BackgroundHints m_backgroundHints;
    QString m_windowTitle;

    // ToolTipDialog is not a Q_GLOBAL_STATIC because QQuickwindows as global static
    // are deleted too late after some stuff in the qml runtime has already been deleted,
    // causing a crash on exit
    bool m_usingDialog : 1;
    static ToolTipDialog *s_dialog;
    static int s_dialogUsers;
};

#endif
