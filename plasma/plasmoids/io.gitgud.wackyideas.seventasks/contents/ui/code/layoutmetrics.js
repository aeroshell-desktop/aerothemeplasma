/*
    SPDX-FileCopyrightText: 2012-2013 Eike Hein <hein@kde.org>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

.import org.kde.kirigami 2.20 as Kirigami

const iconMargin = Math.round(Kirigami.Units.smallSpacing / 4);
const labelMargin = Kirigami.Units.smallSpacing;

function horizontalMargins() {
    const spacingAdjustment = (tasks.plasmoid.pluginName === "org.kde.plasma.icontasks") ? (Kirigami.Settings.tabletMode ? 3 : tasks.plasmoid.configuration.iconSpacing) : 1
    return (taskFrame.margins.left + taskFrame.margins.right) * (tasks.vertical ? 1 : spacingAdjustment);
}

function verticalMargins() {
    const spacingAdjustment = (tasks.plasmoid.pluginName === "org.kde.plasma.icontasks") ? (Kirigami.Settings.tabletMode ? 3 : tasks.plasmoid.configuration.iconSpacing) : 1
    return (taskFrame.margins.top + taskFrame.margins.bottom) * (tasks.vertical ? spacingAdjustment : 1);
}

function adjustMargin(height, margin) {
    const available = height - verticalMargins();

    if (available < Kirigami.Units.iconSizes.small) {
        return Math.floor((margin * (Kirigami.Units.iconSizes.small / available)) / 3);
    }

    return margin;
}

function maxStripes() {
    const length = tasks.vertical ? tasks.width : tasks.height;
    const minimum = tasks.vertical ? preferredMinWidth() : preferredMinHeight();

    return Math.min(tasks.plasmoid.configuration.maxStripes, Math.max(1, Math.floor(length / minimum)));
}

function optimumCapacity(width, height) {
    const length = tasks.vertical ? height : width;
    const maximum = tasks.vertical ? preferredMaxHeight() : preferredMaxWidth();

    if (!tasks.vertical) {
        //  Fit more tasks in this case, that is possible to cut text, before combining tasks.
        return Math.ceil(length / maximum) * maxStripes() + 1;
    }

    return Math.floor(length / maximum) * maxStripes();
}

function preferredMinWidth() {
    let width = preferredMinLauncherWidth();

    if (!tasks.vertical && !tasks.iconsOnly) {
      width = tasks.height;
    }

    return width;
}

function preferredMaxWidth() {
    if (tasks.iconsOnly) {
        if (tasks.vertical) {
            return tasks.width + verticalMargins();
        } else {
            return preferredMinLauncherWidth();//tasks.height + horizontalMargins();
        }
    }

    if (tasks.plasmoid.configuration.groupingStrategy != 0 && !tasks.plasmoid.configuration.groupPopups && !tasks.iconsOnly) {
        return 160;
    }

    return 160;
}

function preferredTaskHeight() {
    if(tasks.vertical) return preferredMaxHeight();
    else {
        return tasks.height > 30 ? preferredMaxHeight() : preferredMinHeight();
    }
}

function preferredMinHeight() {
    // TODO FIXME UPSTREAM: Port to proper font metrics for descenders once we have access to them.
    return 30;
}

function preferredMaxHeight() {
    return 40;
    if (tasks.vertical) {
        let taskPreferredSize = 0;
        if (tasks.iconsOnly) {
            taskPreferredSize = tasks.width / maxStripes();
        } else {
            taskPreferredSize = Math.max(Kirigami.Units.iconSizes.sizeForLabels,
                                         Kirigami.Units.iconSizes.medium);
        }
        return verticalMargins() +
            Math.min(
                // Do not allow the preferred icon size to exceed the width of
                // the vertical task manager.
                tasks.width / maxStripes(),
                taskPreferredSize);
    } else {
        return verticalMargins() +
            Math.min(
                Kirigami.Units.iconSizes.small * 3,
                Kirigami.Units.iconSizes.sizeForLabels * 3);
    }
}

function preferredHeightInPopup() {
    return verticalMargins() + Math.max(Kirigami.Units.iconSizes.sizeForLabels,
                                        Kirigami.Units.iconSizes.medium);
}

function spaceRequiredToShowText() {
    // gridUnit is the height of the default font, but only one isn't enough to
    // show anything but the elision character. 2 is too high and results in
    // text appearing only at excessively high widths.
    return Math.round(Kirigami.Units.gridUnit * 1.5);
}

function preferredMinLauncherWidth() {
    const baseWidth = tasks.vertical ? preferredMinHeight() : (tasks.height > 30 ? 60 : 44);
    return baseWidth; //Math.min(tasks.height, Kirigami.Units.iconSizes.small * 3);

    //return (baseWidth + horizontalMargins())
        //- (adjustMargin(baseWidth, taskFrame.margins.top) + adjustMargin(baseWidth, taskFrame.margins.bottom));
}

function maximumContextMenuTextWidth() {
    return (Kirigami.Units.iconSizes.sizeForLabels * 28);
}

