
import QtQuick 2.15
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents


PlasmaComponents.ContextMenu {
    id: menu

    placement: {
        if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
            return PlasmaCore.Types.RightPosedTopAlignedPopup;
        } else if (plasmoid.location === PlasmaCore.Types.TopEdge) {
            return PlasmaCore.Types.BottomPosedLeftAlignedPopup;
        } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
            return PlasmaCore.Types.LeftPosedTopAlignedPopup;
        } else {
            return PlasmaCore.Types.TopPosedLeftAlignedPopup;
        }
    }

    minimumWidth: root.width
    function show() {
        openRelative();
    }

    function newMenuItem(parent) {
        return Qt.createQmlObject(`
            import org.kde.plasma.components 2.0 as PlasmaComponents

            PlasmaComponents.MenuItem { }
        `, parent);
    }

    function newSeparator(parent) {
        return Qt.createQmlObject(`
            import org.kde.plasma.components 2.0 as PlasmaComponents

            PlasmaComponents.MenuItem { separator: true }
            `, parent);
    }
    function fillItem(item, action) {
        item.text = action.text;
        item.icon = action.icon;
        item.visible = action.visible;
        item.objectName = action.objectName;
        item.clicked.connect(function() {
            action.trigger();
        });
        addMenuItem(item);
    }
    function fillActions() {
        plasmoid.prepareContextualActions();
        for(var index = 0; index < plasmoid.contextualActions.length; index++) {
            var action = plasmoid.contextualActions[index];
            var item = newMenuItem(menu);
            fillItem(item, action);
        }
        var action = plasmoid.action("alternatives");
        if(action && action.enabled) {
            var item = newMenuItem(menu);
            fillItem(item, action);
        }

        item = newMenuItem(menu);
        action = plasmoid.action("configure");
        fillItem(item, action);

        item = newSeparator(menu);
        addMenuItem(item);

        action = containmentInterface.action("add widgets");
        if(action) {
            item = newMenuItem(menu);
            fillItem(item, action);
        };

        action = containmentInterface.action("configure");
        if(action) {
            item = newMenuItem(menu);
            fillItem(item, action);
        };

    }
    onStatusChanged: {
        if (status == PlasmaComponents.DialogStatus.Closed) {
            menu.destroy();
        }
    }
}
