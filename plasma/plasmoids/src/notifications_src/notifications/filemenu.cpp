/*
    SPDX-FileCopyrightText: 2016, 2019 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: LGPL-2.1-or-later
*/

#include "filemenu.h"

#include <QApplication>
#include <QClipboard>
#include <QIcon>
#include <QMenu>
#include <QMimeData>
#include <QQuickWindow>
#include <QTimer>

#include <KConfigGroup>
#include <KFileItemActions>
#include <KFileItemListProperties>
#include <KLocalizedString>
#include <KPropertiesDialog>
#include <KProtocolManager>
#include <KSharedConfig>
#include <KStandardActions>
#include <KUrlMimeData>

#include <KIO/CopyJob> // for KIO::trash
#include <KIO/DeleteJob>
#include <KIO/FileUndoManager>
#include <KIO/JobUiDelegate>
#include <KIO/OpenFileManagerWindowJob>
#include <KIO/WidgetsAskUserActionHandler>

using namespace Qt::StringLiterals;

FileMenu::FileMenu(QObject *parent)
    : QObject(parent)
{
}

FileMenu::~FileMenu() = default;

QUrl FileMenu::url() const
{
    return m_url;
}

void FileMenu::setUrl(const QUrl &url)
{
    if (m_url != url) {
        m_url = url;
        Q_EMIT urlChanged();
    }
}

QQuickItem *FileMenu::visualParent() const
{
    return m_visualParent.data();
}

void FileMenu::setVisualParent(QQuickItem *visualParent)
{
    if (m_visualParent.data() == visualParent) {
        return;
    }

    if (m_visualParent) {
        disconnect(m_visualParent.data(), nullptr, this, nullptr);
    }
    m_visualParent = visualParent;
    if (m_visualParent) {
        connect(m_visualParent.data(), &QObject::destroyed, this, &FileMenu::visualParentChanged);
    }
    Q_EMIT visualParentChanged();
}

bool FileMenu::visible() const
{
    return m_visible;
}

void FileMenu::setVisible(bool visible)
{
    if (m_visible == visible) {
        return;
    }

    if (visible) {
        open(0, 0);
    } else {
        // TODO warning or close?
    }
}

void FileMenu::open(int x, int y)
{
    if (!m_visualParent || !m_visualParent->window()) {
        return;
    }

    if (!m_url.isValid()) {
        return;
    }

    KFileItem fileItem(m_url);

    QMenu *menu = new QMenu();
    menu->setAttribute(Qt::WA_DeleteOnClose, true);
    connect(menu, &QMenu::triggered, this, &FileMenu::actionTriggered);

    connect(menu, &QMenu::aboutToHide, this, [this] {
        m_visible = false;
        Q_EMIT visibleChanged();
    });

    if (KProtocolManager::supportsListing(m_url)) {
        QAction *openContainingFolderAction = menu->addAction(QIcon::fromTheme(QStringLiteral("folder-open")), i18n("Open Containing Folder"));
        connect(openContainingFolderAction, &QAction::triggered, [this] {
            KIO::highlightInFileManager({m_url});
        });
    }

    KFileItemActions *actions = new KFileItemActions(menu);
    KFileItemListProperties itemProperties(KFileItemList({fileItem}));
    actions->setItemListProperties(itemProperties);
    actions->setParentWidget(menu);

    actions->insertOpenWithActionsTo(nullptr, menu, QStringList());

    // KStandardAction? But then the Ctrl+C shortcut makes no sense in this context
    QAction *copyAction = menu->addAction(QIcon::fromTheme(QStringLiteral("edit-copy")), i18n("&Copy"));
    connect(copyAction, &QAction::triggered, this, [fileItem] {
        // inspired by KDirModel::mimeData()
        QMimeData *data = new QMimeData(); // who cleans it up?
        KUrlMimeData::setUrls({fileItem.url()}, {fileItem.mostLocalUrl()}, data);
        KUrlMimeData::exportUrlsToPortal(data);
        QApplication::clipboard()->setMimeData(data);
    });

    QAction *copyPathAction = menu->addAction(QIcon::fromTheme(QStringLiteral("edit-copy-path")), i18nc("@action:incontextmenu", "Copy Location"));
    connect(copyPathAction, &QAction::triggered, this, [fileItem] {
        QString path = fileItem.localPath();
        if (path.isEmpty()) {
            path = fileItem.url().toDisplayString();
        }
        QApplication::clipboard()->setText(path);
    });

    menu->addSeparator();

    const bool canTrash = itemProperties.isLocal() && itemProperties.supportsMoving();
    if (canTrash) {
        auto moveToTrashLambda = [this] {
            // No parent since the FileMenu will be destroyed as soon as the user clicked the menu item.
            auto handler = new KIO::WidgetsAskUserActionHandler();
            connect(handler, &KIO::WidgetsAskUserActionHandler::askUserDeleteResult, [handler](bool allow, const QList<QUrl> &urls) {
                if (allow) {
                    auto job = KIO::trash(urls);
                    job->uiDelegate()->setAutoErrorHandlingEnabled(true);
                    KIO::FileUndoManager::self()->recordJob(KIO::FileUndoManager::Trash, urls, QUrl(QStringLiteral("trash:/")), job);
                }
                handler->deleteLater();
            });
            handler->askUserDelete({m_url}, KIO::AskUserActionInterface::Trash, KIO::AskUserActionInterface::DefaultConfirmation);
        };
        QAction *moveToTrashAction = KStandardActions::moveToTrash(this, moveToTrashLambda, menu);
        moveToTrashAction->setShortcut({}); // Can't focus notification to press Delete
        menu->addAction(moveToTrashAction);
    }

    KConfigGroup cg(KSharedConfig::openConfig(), u"KDE"_s);
    const bool showDeleteCommand = cg.readEntry("ShowDeleteCommand", false);

    if (itemProperties.supportsDeleting() && (!canTrash || showDeleteCommand)) {
        auto deleteLambda = [this] {
            // No parent since the FileMenu will be destroyed as soon as the user clicked the menu item.
            auto handler = new KIO::WidgetsAskUserActionHandler();
            connect(handler, &KIO::WidgetsAskUserActionHandler::askUserDeleteResult, [handler](bool allow, const QList<QUrl> &urls) {
                if (allow) {
                    auto job = KIO::del(urls);
                    job->uiDelegate()->setAutoErrorHandlingEnabled(true);
                }
                handler->deleteLater();
            });
            handler->askUserDelete({m_url}, KIO::AskUserActionInterface::Delete, KIO::AskUserActionInterface::DefaultConfirmation);
        };
        QAction *deleteAction = KStandardActions::deleteFile(this, deleteLambda, menu);
        deleteAction->setShortcut({});
        menu->addAction(deleteAction);
    }

    menu->addSeparator();

    actions->addActionsTo(menu);

    menu->addSeparator();

    QAction *propertiesAction = menu->addAction(QIcon::fromTheme(QStringLiteral("document-properties")), i18n("Properties"));
    connect(propertiesAction, &QAction::triggered, [fileItem] {
        KPropertiesDialog *dialog = new KPropertiesDialog(fileItem.url());
        dialog->setAttribute(Qt::WA_DeleteOnClose);
        dialog->show();
    });

    // this is a workaround where Qt will fail to realize a mouse has been released
    // this happens if a window which does not accept focus spawns a new window that takes focus and X grab
    // whilst the mouse is depressed
    // https://bugreports.qt.io/browse/QTBUG-59044
    // this causes the next click to go missing

    // by releasing manually we avoid that situation
    auto ungrabMouseHack = [this]() {
        if (m_visualParent && m_visualParent->window() && m_visualParent->window()->mouseGrabberItem()) {
            m_visualParent->window()->mouseGrabberItem()->ungrabMouse();
        }
    };

    QTimer::singleShot(0, m_visualParent, ungrabMouseHack);
    // end workaround

    QPoint pos;
    if (x == -1 && y == -1) { // align "bottom left of visualParent"
        menu->adjustSize();

        pos = m_visualParent->mapToGlobal(QPointF(0, m_visualParent->height())).toPoint();

        if (!qApp->isRightToLeft()) {
            pos.rx() += m_visualParent->width();
            pos.rx() -= menu->width();
        }
    } else {
        pos = m_visualParent->mapToGlobal(QPointF(x, y)).toPoint();
    }

    menu->setAttribute(Qt::WA_TranslucentBackground);
    menu->winId();
    menu->windowHandle()->setTransientParent(m_visualParent->window());
    menu->popup(pos);

    m_visible = true;
    Q_EMIT visibleChanged();
}

#include "moc_filemenu.cpp"
