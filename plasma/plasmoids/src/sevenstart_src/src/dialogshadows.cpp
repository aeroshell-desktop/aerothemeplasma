/*
    SPDX-FileCopyrightText: 2011 Aaron Seigo <aseigo@kde.org>
    SPDX-FileCopyrightText: 2020 Vlad Zahorodnii <vlad.zahorodnii@kde.org>

    SPDX-License-Identifier: LGPL-2.0-or-later
*/

//#include "debug_p.h"
#include "dialogshadows_p.h"

#include <KWindowShadow>

class DialogShadows::Private
{
public:
    Private(DialogShadows *shadows)
        : q(shadows)
    {
    }

    ~Private()
    {
    }

    void clearTiles();
    void setupTiles();
    void initTile(const QString &element);
    void updateShadow(QWindow *window, KSvg::FrameSvg::EnabledBorders);
    void clearShadow(QWindow *window);
    void updateShadows();
    void windowDestroyed(QObject *deletedObject);

    DialogShadows *q;

    QHash<QWindow *, KSvg::FrameSvg::EnabledBorders> m_windows;
    QHash<QWindow *, KWindowShadow *> m_shadows;
    QList<KWindowShadowTile::Ptr> m_tiles;
};

DialogShadows::DialogShadows(QObject *parent, const QString &prefix)
    : KSvg::Svg(parent)
    , d(new Private(this))
{
    setImagePath(prefix);
    connect(this, SIGNAL(repaintNeeded()), this, SLOT(updateShadows()));
}

DialogShadows::~DialogShadows()
{
    delete d;
}

DialogShadows *DialogShadows::self()
{
    // KF6 port to Q_APPLICATION_STATIC
    static DialogShadows *s_privateDialogShadowsSelf = nullptr;
    if (!s_privateDialogShadowsSelf) {
        s_privateDialogShadowsSelf = new DialogShadows(qApp);
    }
    return s_privateDialogShadowsSelf;
}

void DialogShadows::addWindow(QWindow *window, KSvg::FrameSvg::EnabledBorders enabledBorders)
{
    if (!window) {
        return;
    }

    d->m_windows[window] = enabledBorders;
    d->updateShadow(window, enabledBorders);
    connect(window, SIGNAL(destroyed(QObject *)), this, SLOT(windowDestroyed(QObject *)), Qt::UniqueConnection);
}

void DialogShadows::removeWindow(QWindow *window)
{
    if (!d->m_windows.contains(window)) {
        return;
    }

    d->m_windows.remove(window);
    disconnect(window, nullptr, this, nullptr);
    d->clearShadow(window);

    if (d->m_windows.isEmpty()) {
        d->clearTiles();
    }
}

void DialogShadows::setEnabledBorders(QWindow *window, KSvg::FrameSvg::EnabledBorders enabledBorders)
{
    if (!window || !d->m_windows.contains(window)) {
        return;
    }

    d->updateShadow(window, enabledBorders);
}

void DialogShadows::Private::windowDestroyed(QObject *deletedObject)
{
    QWindow *window = static_cast<QWindow *>(deletedObject);

    m_windows.remove(window);
    clearShadow(window);

    if (m_windows.isEmpty()) {
        clearTiles();
    }
}

void DialogShadows::Private::updateShadows()
{
    setupTiles();
    QHash<QWindow *, KSvg::FrameSvg::EnabledBorders>::const_iterator i;
    for (i = m_windows.constBegin(); i != m_windows.constEnd(); ++i) {
        updateShadow(i.key(), i.value());
    }
}

void DialogShadows::Private::initTile(const QString &element)
{
    const QImage image = q->pixmap(element).toImage();

    KWindowShadowTile::Ptr tile = KWindowShadowTile::Ptr::create();
    tile->setImage(image);

    m_tiles << tile;
}

void DialogShadows::Private::setupTiles()
{
    clearTiles();

    initTile(QStringLiteral("shadow-top"));
    initTile(QStringLiteral("shadow-topright"));
    initTile(QStringLiteral("shadow-right"));
    initTile(QStringLiteral("shadow-bottomright"));
    initTile(QStringLiteral("shadow-bottom"));
    initTile(QStringLiteral("shadow-bottomleft"));
    initTile(QStringLiteral("shadow-left"));
    initTile(QStringLiteral("shadow-topleft"));
}

void DialogShadows::Private::clearTiles()
{
    m_tiles.clear();
}

void DialogShadows::Private::updateShadow(QWindow *window, KSvg::FrameSvg::EnabledBorders enabledBorders)
{
    if (m_tiles.isEmpty()) {
        setupTiles();
    }

    KWindowShadow *&shadow = m_shadows[window];

    if (!shadow) {
        shadow = new KWindowShadow(q);
    }

    if (shadow->isCreated()) {
        shadow->destroy();
    }

    if (enabledBorders & KSvg::FrameSvg::TopBorder) {
        shadow->setTopTile(m_tiles.at(0));
    } else {
        shadow->setTopTile(nullptr);
    }

    if (enabledBorders & KSvg::FrameSvg::TopBorder && enabledBorders & KSvg::FrameSvg::RightBorder) {
        shadow->setTopRightTile(m_tiles.at(1));
    } else {
        shadow->setTopRightTile(nullptr);
    }

    if (enabledBorders & KSvg::FrameSvg::RightBorder) {
        shadow->setRightTile(m_tiles.at(2));
    } else {
        shadow->setRightTile(nullptr);
    }

    if (enabledBorders & KSvg::FrameSvg::BottomBorder && enabledBorders & KSvg::FrameSvg::RightBorder) {
        shadow->setBottomRightTile(m_tiles.at(3));
    } else {
        shadow->setBottomRightTile(nullptr);
    }

    if (enabledBorders & KSvg::FrameSvg::BottomBorder) {
        shadow->setBottomTile(m_tiles.at(4));
    } else {
        shadow->setBottomTile(nullptr);
    }

    if (enabledBorders & KSvg::FrameSvg::BottomBorder && enabledBorders & KSvg::FrameSvg::LeftBorder) {
        shadow->setBottomLeftTile(m_tiles.at(5));
    } else {
        shadow->setBottomLeftTile(nullptr);
    }

    if (enabledBorders & KSvg::FrameSvg::LeftBorder) {
        shadow->setLeftTile(m_tiles.at(6));
    } else {
        shadow->setLeftTile(nullptr);
    }

    if (enabledBorders & KSvg::FrameSvg::TopBorder && enabledBorders & KSvg::FrameSvg::LeftBorder) {
        shadow->setTopLeftTile(m_tiles.at(7));
    } else {
        shadow->setTopLeftTile(nullptr);
    }

    QMargins padding;

    if (enabledBorders & KSvg::FrameSvg::TopBorder) {
        const QSize marginHint = q->elementSize(QStringLiteral("shadow-hint-top-margin")).toSize();
        if (marginHint.isValid()) {
            padding.setTop(marginHint.height());
        } else {
            padding.setTop(m_tiles[0]->image().height());
        }
    }

    if (enabledBorders & KSvg::FrameSvg::RightBorder) {
        const QSize marginHint = q->elementSize(QStringLiteral("shadow-hint-right-margin")).toSize();
        if (marginHint.isValid()) {
            padding.setRight(marginHint.width());
        } else {
            padding.setRight(m_tiles[2]->image().width());
        }
    }

    if (enabledBorders & KSvg::FrameSvg::BottomBorder) {
        const QSize marginHint = q->elementSize(QStringLiteral("shadow-hint-bottom-margin")).toSize();
        if (marginHint.isValid()) {
            padding.setBottom(marginHint.height());
        } else {
            padding.setBottom(m_tiles[4]->image().height());
        }
    }

    if (enabledBorders & KSvg::FrameSvg::LeftBorder) {
        const QSize marginHint = q->elementSize(QStringLiteral("shadow-hint-left-margin")).toSize();
        if (marginHint.isValid()) {
            padding.setLeft(marginHint.width());
        } else {
            padding.setLeft(m_tiles[6]->image().width());
        }
    }

    shadow->setPadding(padding);
    shadow->setWindow(window);

    if (!shadow->create()) {
        qDebug() << "Couldn't create KWindowShadow for" << window;
    }
}

void DialogShadows::Private::clearShadow(QWindow *window)
{
    delete m_shadows.take(window);
}

bool DialogShadows::enabled() const
{
    return hasElement(QStringLiteral("shadow-left"));
}

#include "moc_dialogshadows_p.cpp"
