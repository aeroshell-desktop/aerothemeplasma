/*
    KWin - the KDE window manager
    This file is part of the KDE project.

    SPDX-FileCopyrightText: 2010 Martin Gräßlin <mgraesslin@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

#pragma once
#include <kwin/effect/effect.h>
#include <KConfigWatcher>
#include <kwin/cursor.h>
#include <kwin/cursorsource.h>
#include <kwin/scene/cursoritem.h>
#include <kwin/scene/imageitem.h>
#include <kwin/scene/scene.h>
#include <kwin/scene/itemrenderer.h>
#include <kwin/scene/workspacescene.h>

#if KWIN_BUILD_X11
#include <KStartupInfo>
#endif
#include <QIcon>
#include <QObject>

#include <chrono>

class KSelectionOwner;
namespace KWin
{

class GLShader;
class GLTexture;

class ShakeCursorItem : public Item
{
    Q_OBJECT

public:
    ShakeCursorItem(const CursorTheme &theme, Item *parent);
    void refresh();

private:

    std::unique_ptr<ImageItem> m_imageItem;
    std::unique_ptr<ShapeCursorSource> m_source;
};

class StartupFeedbackEffect
    : public Effect
{
    Q_OBJECT
    Q_PROPERTY(int type READ type)
public:
    StartupFeedbackEffect();
    ~StartupFeedbackEffect() override;

    void reconfigure(ReconfigureFlags flags) override;
    void prePaintScreen(ScreenPrePaintData &data, std::chrono::milliseconds presentTime) override;
    void paintScreen(const RenderTarget &renderTarget, const RenderViewport &viewport, int mask, const QRegion &region, Output *screen) override;
    void postPaintScreen() override;
    bool isActive() const override;

    int requestedEffectChainPosition() const override
    {
        return 100;
    }

    int type() const
    {
        return int(m_type);
    }

    static bool supported();

private Q_SLOTS:
    void gotNewStartup(const QString &id, const QIcon &icon);
    void gotRemoveStartup(const QString &id);
    void gotStartupChange(const QString &id, const QIcon &icon);
    void slotMouseChanged(const QPointF &pos, const QPointF &oldpos, Qt::MouseButtons buttons, Qt::MouseButtons oldbuttons, Qt::KeyboardModifiers modifiers, Qt::KeyboardModifiers oldmodifiers);


private:
    enum FeedbackType {
        NoFeedback,
        BouncingFeedback,
        BlinkingFeedback,
        PassiveFeedback
    };

    struct Startup
    {
        QIcon icon;
        std::shared_ptr<QTimer> expiredTimer;
    };

    void start(const Startup &startup);
    void stop();
    QImage scalePixmap(const QPixmap &pm, const QSize &size, qreal devicePixelRatio) const;
    void prepareTextures(const QPixmap &pix, qreal devicePixelRatio);
    QRect feedbackRect() const;
    QSize feedbackIconSize() const;


    std::unique_ptr<ShakeCursorItem> m_cursorItem;
    CursorTheme m_cursorTheme;
    Cursor *m_mouseCur;
    ShapeCursorSource m_defaultShape;
    bool m_showBusyCursor;
    void toggleBusyCursor();

    qreal m_bounceSizesRatio;
#if KWIN_BUILD_X11
    KStartupInfo *m_startupInfo;
    KSelectionOwner *m_selection;
#endif
    QString m_currentStartup;
    QMap<QString, Startup> m_startups;
    bool m_active;
    int m_frame;
    int m_progress;
    std::chrono::milliseconds m_lastPresentTime;
    std::unique_ptr<GLTexture> m_bouncingTextures[5];
    std::unique_ptr<GLTexture> m_texture; // for passive and blinking
    FeedbackType m_type;
    QRect m_currentGeometry, m_dirtyRect;
    std::unique_ptr<GLShader> m_blinkingShader;
    int m_cursorSize;
    KConfigWatcher::Ptr m_configWatcher;
    bool m_splashVisible;
    std::chrono::seconds m_timeout;
};
} // namespace
