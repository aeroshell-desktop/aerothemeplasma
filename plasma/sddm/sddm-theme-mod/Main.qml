import QtQuick 2.15
import SddmComponents 2.0
import QtQuick.Layouts 1.15
import Qt5Compat.GraphicalEffects 1.0
import QtQuick.Controls as QQC2
import "SMOD" as SMOD
//import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support
import org.kde.kitemmodels as KItemModels

//import org.kde.plasma.workspace.components 2.0 as PW
//import org.kde.plasma.private.keyboardindicator as KeyboardIndicator
import QtMultimedia

Item
{
    id: root

    LayoutMirroring.enabled : Qt.locale().textDirection == Qt.RightToLeft
    LayoutMirroring.childrenInherit : true

    property bool m_forceUserSelect: config.boolValue("forceUserSelect")
    property bool m_biggerUserFrame: config.boolValue("biggerUserFrame")
    property bool m_biggerMultiUserFrame: config.boolValue("biggerMultiUserFrame")

    enum LoginPage
    {
        Startup,
        SelectUser,
        Login,
        LoginFailed
    }

    // copied from sddm/src/greeter/UserModel.h because
    // it doesn't seem accessible via e.g. SDDM.UserModel.NameRole
    enum UserRoles
    {
        NameRole = 257,
        RealNameRole,
        HomeDirRole,
        IconRole,
        NeedsPasswordRole
    }

    Connections
    {
        target: sddm

        function onLoginFailed()
        {
            password.text = ""
            pages.currentIndex = Main.LoginPage.LoginFailed
        }
    }

    Keys.onEscapePressed:
    {
        if (pages.currentIndex === Main.LoginPage.Login && switchuser.enabled)
        {
            password.text = ""
            pages.currentIndex = Main.LoginPage.SelectUser
        }
        else if (pages.currentIndex === Main.LoginPage.LoginFailed)
        {
            pages.currentIndex = Main.LoginPage.Login
        }
    }

    Background
    {
        id: background
        anchors.fill: parent
        fillMode: Image.Stretch
        source: Qt.resolvedUrl(config.stringValue("background"))
    }
    Timer {
        id: startupSoundDelay
        interval: config.boolValue("enableStartup") ? 250 : 20
        running: startupSound.playSound
        onTriggered: {
            startupSound.play()
        }
    }

    MediaPlayer {
        id: startupSound
        property bool playSound: !executable.fileExists && config.boolValue("playSound")
        audioOutput: AudioOutput {
            volume: 1.0
        }
        source: "Assets/session-start.wav"
    }
    Component
    {
        id: userDelegate

        Column
        {
            id: delegateColumn
            width: listView.cellWidth
            height: listView.cellHeight

            Item
            {
                id: avatarparent
                width: m_biggerMultiUserFrame ? 100 : 80
                height: width

                anchors.centerIn: parent

                Item
                {
                    width: m_biggerMultiUserFrame ? 60 : 48
                    height: width

                    anchors.centerIn: parent

                    Rectangle
                    {
                        id: maskmini

                        anchors.fill: parent
                        anchors.centerIn: parent
                        radius: 2
                        visible: false
                    }

                    LinearGradient {
                        id: gradient
                        anchors.fill: parent
                        anchors.centerIn: parent
                        z: -1
                        start: Qt.point(0,0)
                        end: Qt.point(gradient.width, gradient.height)
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#eeecee" }
                            GradientStop { position: 1.0; color: "#a39ea3" }
                        }
                    }
                    Image
                    {
                        id: avatarmini

                        property string m_fallbackPicture: "Assets/user.png"

                        onStatusChanged:
                        {
                            if (avatarmini.status == Image.Error)
                            {
                                avatarmini.source = avatarmini.m_fallbackPicture;
                            }
                        }

                        source: model.icon

                        fillMode: Image.PreserveAspectCrop

                        anchors.fill: parent
                        anchors.centerIn: parent

                        layer.enabled: true
                        layer.effect: OpacityMask
                        {
                            maskSource: maskmini
                        }
                    }
                }

                Image
                {
                    id: avatarminiframe

                    property bool m_hovered: false

                    source:
                    {
                        if (m_biggerMultiUserFrame)
                        {
                            if (m_hovered && delegateColumn.focus)   return "Assets/12235.png"
                            if (m_hovered && !delegateColumn.focus)  return "Assets/12233.png"
                            if (!m_hovered && delegateColumn.focus)  return "Assets/12234.png"
                            if (!m_hovered && !delegateColumn.focus) return "Assets/12237.png"
                        }
                        else
                        {
                            if (m_hovered && delegateColumn.focus)   return "Assets/12220.png"
                            if (m_hovered && !delegateColumn.focus)  return "Assets/12218.png"
                            if (!m_hovered && delegateColumn.focus)  return "Assets/12219.png"
                            if (!m_hovered && !delegateColumn.focus) return "Assets/12222.png"
                        }
                    }
                    anchors.fill: parent
                    anchors.centerIn: parent
                }
            }

            Text
            {
                text: (model.realName === "") ? model.name : model.realName
                color: "white"
                font.pixelSize: 12
                //font.family: mainfont.name

                renderType: Text.NativeRendering
                font.hintingPreference: Font.PreferFullHinting
                font.kerning: false
                anchors.top: avatarparent.bottom
                //anchors.topMargin: -3
                anchors.horizontalCenter: avatarparent.horizontalCenter

                layer.enabled: true
                layer.effect: DropShadow
                {
                    verticalOffset: 1
                    color: "#000"
                    radius: 7
                    samples: 20
                }
            }

            MouseArea
            {
                anchors.fill: delegateColumn
                hoverEnabled: true

                onEntered:
                {
                    avatarminiframe.m_hovered = true
                }
                onExited:
                {
                    avatarminiframe.m_hovered = false
                }
            }

            Keys.onReturnPressed:
            {
                if (focus)
                {
                    let username = model.name

                    if (username != null)
                    {
                        let realname = model.realName
                        let pic = model.icon
                        let needspassword = model.needsPassword

                        if (needspassword)
                        {
                            userNameLabel.text = realname
                            avatar.source = pic

                            listView.currentIndex = index
                            pages.currentIndex = Main.LoginPage.Login
                        }
                        else
                        {
                            sddm.login(username, password.text, session.index)
                        }
                    }
                }
            }
        }
    }
    Loader {
        id: inputPanel
        state: "hidden"
        property bool active: false
        readonly property bool keyboardActive: item ? item.active : false
        anchors {
            left: parent.left
            right: parent.right
            bottom: background.bottom
            leftMargin: Kirigami.Units.gridUnit*12
            rightMargin: Kirigami.Units.gridUnit*12
        }
        function showHide() {
            active = !active;
            inputPanel.item.activated = Qt.binding(() => { return active });
        }
        Component.onCompleted: {
            inputPanel.source = Qt.platform.pluginName.includes("wayland") ? "SMOD/VirtualKeyboard_wayland.qml" : "SMOD/VirtualKeyboard.qml"

            if(inputPanel.status === Loader.Ready) {
                var menuitem = session.createMenuSeparator();

                session.addItem(menuitem);
                menuitem = session.createMenuItem();
                menuitem.text = "On-Screen Keyboard"
                menuitem.checkable = false;
                menuitem.icon.source = Qt.resolvedUrl("Assets/keyboard.png");
                menuitem.triggered.connect(() => {
                    password.forceActiveFocus();
                    inputPanel.showHide();
                });
                session.addAction(menuitem);
            }
        }
        onKeyboardActiveChanged: {
            if (keyboardActive) {
                inputPanel.z = 99;
                Qt.inputMethod.show();
                active = true;
            } else {
                //inputPanel.item.activated = false;
                Qt.inputMethod.hide();
                active = false;
            }
        }

    }

    StackLayout
    {
        id: pages
        anchors.fill: parent
        anchors.bottomMargin: inputPanel.active ? inputPanel.height : 0

        onCurrentIndexChanged:
        {
            if (currentIndex == Main.LoginPage.SelectUser)
            {
                listView.forceActiveFocus()
            }
            else if (currentIndex == Main.LoginPage.Login)
            {
                password.forceActiveFocus()
            }
            else if (currentIndex == Main.LoginPage.LoginFailed)
            {
                dismissButton.forceActiveFocus()
            }
        }

    Plasma5Support.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        property bool read: false
        property bool startupEnabled: !fileExists && config.boolValue("enableStartup");
        property bool fileExists: false
        onNewData: (sourceName, data) => {
            var stdout = data["stdout"]
            exited(stdout)
            disconnectSource(sourceName) // cmd finished
        }
        function exec(cmd, r) {
            executable.read = r;
            if (cmd) {
                connectSource(cmd)
            }
        }
        signal exited(string stdout)
    }

    Connections {
        target: executable
        function onExited(stdout) {
            if(executable.read) {
                if(stdout.trim() !== "") { // If the file exists, do not play Vista boot animation
                    executable.fileExists = true;
                } else {
                    executable.exec("touch /tmp/sddm.startup", false); // Create it to prevent multiple boot animations from happening
                    if(startupSound.playSound) {
                        startupSoundDelay.start()
                    }
                    if(executable.startupEnabled) seqanimation.start();

                }
            }
        }
    }

        // for testing failed login
        currentIndex: {
            return executable.startupEnabled ? Main.LoginPage.Startup : Main.LoginPage.SelectUser
        }

        function startSingleUserMode() {

            let singleusermode = userModel.count < 2 && !m_forceUserSelect

            if (singleusermode)
            {
                let index = 0;
                let username = userModel.data(userModel.index(index, 0), Main.UserRoles.NameRole)

                if (username != null)
                {
                    let userDisplayName = userModel.data(userModel.index(index, 0), Main.UserRoles.RealNameRole)
                    let userPicture = userModel.data(userModel.index(index, 0), Main.UserRoles.IconRole)

                    userNameLabel.text = userDisplayName
                    avatar.source = userPicture

                    pages.currentIndex = Main.LoginPage.Login
                    return true;
                }
            }
            pages.currentIndex = Main.LoginPage.SelectUser;
            return false;
        }

        Component.onCompleted:
        {
            executable.exec("ls /tmp/sddm.startup", true); // Check if sddm.startup exists
            startSingleUserMode();
        }
        Item
        {
            id: startupPage
        }

        Item
        {
            id: userlistpage
            anchors.fill: parent

            GridView
            {
                id: listView
                anchors.centerIn: parent

                anchors.verticalCenterOffset:
                {
                    if (count < 5)
                    {
                        return 72
                    }
                    else
                    {
                        return 0
                    }
                }

                width:
                {
                    if (count < 5)
                    {
                        return cellWidth * count
                    }
                    else
                    {
                        return cellWidth * 5
                    }
                }

                height:
                {
                    if (count > 5)
                    {
                        return 200 * 2
                    }
                    else
                    {
                        return 200
                    }
                }

                clip: true
                interactive: true
                keyNavigationEnabled: true
                keyNavigationWraps: false
                focus: true
                boundsBehavior: Flickable.StopAtBounds

                QQC2.ScrollBar.vertical: QQC2.ScrollBar {}

                cellWidth: 200
                cellHeight: 200

                model: userModel
                delegate: userDelegate
                currentIndex: userModel.lastIndex

                KeyNavigation.backtab: rebootButton
                KeyNavigation.tab: accessbutton

                MouseArea
                {
                    anchors.fill: parent

                    onClicked: (mouse) =>
                    {
                        let posInGridView = Qt.point(mouse.x, mouse.y)
                        let posInContentItem = mapToItem(listView.contentItem, posInGridView)
                        let index = listView.indexAt(posInContentItem.x, posInContentItem.y)

                        let username = userModel.data(userModel.index(index, 0), Main.UserRoles.NameRole)

                        if (username != null)
                        {
                            let realname = userModel.data(userModel.index(index, 0), Main.UserRoles.RealNameRole)
                            let pic = userModel.data(userModel.index(index, 0), Main.UserRoles.IconRole)
                            let needspassword = userModel.data(userModel.index(index, 0), Main.UserRoles.NeedsPasswordRole)

                            if (needspassword)
                            {
                                userNameLabel.text = realname == "" ? username : realname;
                                avatar.source = pic

                                listView.currentIndex = index
                                pages.currentIndex = Main.LoginPage.Login
                            }
                            else
                            {
                                sddm.login(username, password.text, session.index)
                            }
                        }
                    }
                }
            }
        }

        Item
        {
            id: loginpage

            Column
            {
                id: mainColumn
                anchors.centerIn: parent

                Item
                {
                    id: userpic

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: -1
                    anchors.bottom: parent.verticalCenter
                    anchors.bottomMargin: m_biggerUserFrame ? -64 : -56

                    width: m_biggerUserFrame ? 238 : 190
                    height: width

                    Item
                    {
                        width: m_biggerUserFrame ? 158 : 126
                        height: width

                        anchors.centerIn: parent

                        Rectangle
                        {
                            id: mask

                            anchors.fill: parent
                            anchors.centerIn: parent
                            radius: 2
                            visible: false
                        }

                        LinearGradient {
                            id: gradient
                            anchors.fill: parent
                            anchors.centerIn: parent
                            z: -1
                            start: Qt.point(0,0)
                            end: Qt.point(gradient.width, gradient.height)
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: "#eeecee" }
                                GradientStop { position: 1.0; color: "#a39ea3" }
                            }
                        }
                        Image
                        {
                            id: avatar

                            fillMode: Image.PreserveAspectCrop

                            source: ""

                            property string defaultPic: "Assets/user.png"

                            onStatusChanged:
                            {
                                if (avatar.status == Image.Error)
                                {
                                    avatar.source = avatar.defaultPic;
                                }
                            }

                            anchors.fill: parent
                            anchors.centerIn: parent

                            layer.enabled: true
                            layer.effect: OpacityMask
                            {
                                maskSource: mask
                            }
                        }
                    }

                    Image
                    {
                        source: m_biggerUserFrame ? "Assets/12238.png" : "Assets/12223.png"
                        anchors.fill: parent
                        anchors.centerIn: parent
                    }
                }
                
                QQC2.Label
                {
                    id: userNameLabel

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: userpic.bottom

                    text: ""
                    color: "white"

                    font.pixelSize: 23
                    font.kerning: false
                    renderType: Text.NativeRendering
                    font.hintingPreference: Font.PreferVerticalHinting
                    font.weight: Font.Medium

                    layer.enabled: true
                    layer.effect: DropShadow
                    {
                        verticalOffset: 1
                        color: "#ef000000"
                        radius: 9
                        samples: 80
                    }
                }

                Item
                {
                    id: loginbox

                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: userNameLabel.bottom
                    anchors.topMargin: 8
                    
                    width: 225
                    height: 24


                    QQC2.TextField {
                        id: password

                        anchors.fill: parent

                        bottomPadding: 0
                        topPadding: 0
                        
                        font.pointSize: 9

                        placeholderTextColor: "#555"
                        background: Image {
                            source:
                            {
                                if (password.focus) return "Assets/input-focus.png"
                                if (password.hovered) return "Assets/input-hover.png"
                                return "Assets/input.png"
                            }
                        }

                        placeholderText: "Password"
                        selectByMouse: true
                        echoMode : TextInput.Password
                        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText

                        KeyNavigation.backtab: switchLayoutButton
                        KeyNavigation.tab: loginButton
                        KeyNavigation.down:
                        {
                            if (switchuser.enabled)
                            {
                                return switchuser
                            }
                            else
                            {
                                return accessbutton
                            }
                        }

                        Keys.onPressed : (event) => {
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                            {
                                let index = listView.currentIndex
                                let username = userModel.data(userModel.index(index, 0), Main.UserRoles.NameRole)

                                if (username != null)
                                {
                                    sddm.login(username, password.text, session.index)
                                }

                                event.accepted = true
                            }
                            else if (
                                event.matches(StandardKey.Undo) ||
                                event.matches(StandardKey.Redo) ||
                                event.matches(StandardKey.Cut) ||
                                event.matches(StandardKey.Copy) ||
                                event.matches(StandardKey.Paste)
                                )
                            {
                                // disable these events
                                event.accepted = true
                            }
                        }
                    }
                    RowLayout {
                        spacing: 2
                        anchors.top: password.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 2
                        visible: keyboard.capsLock && password.visible
                        Image {
                            id: iconSmall
                            width: Kirigami.Units.iconSizes.small;
                            height: Kirigami.Units.iconSizes.small;

                            source: "./Assets/dialog-warning.png"
                            sourceSize.width: iconSmall.width
                            sourceSize.height: iconSmall.height
                        }
                        QQC2.Label {
                            id: notificationsLabel
                            font.pointSize: 9
                            text: i18nd("plasma_lookandfeel_org.kde.lookandfeel", "Caps Lock is on");
                            width: implicitWidth
                            renderType: Text.NativeRendering
                            color: "white"
                        }
                    }

                    QQC2.Button
                    {
                        id: loginButton

                        anchors.left: password.right
                        anchors.verticalCenter: password.verticalCenter
                        anchors.verticalCenterOffset: -1
                        anchors.leftMargin: 4

                        width: 30
                        height: 30

                        background: Image
                        {
                            source: loginButton.pressed ? "Assets/gopressed.png" : (loginButton.focus || loginButton.hovered ? "Assets/gohover.png" : "Assets/go.png")
                        }

                        onClicked:
                        {
                            let index = listView.currentIndex
                            let username = userModel.data(userModel.index(index, 0), Main.UserRoles.NameRole)

                            if (username != null)
                            {
                                sddm.login(username, password.text, session.index)
                            }
                        }

                        KeyNavigation.backtab: password
                        KeyNavigation.tab:
                        {
                            if (switchuser.enabled)
                            {
                                return switchuser
                            }
                            else
                            {
                                return accessbutton
                            }
                        }

                        KeyNavigation.down:
                        {
                            if (switchuser.enabled)
                            {
                                return switchuser
                            }
                            else
                            {
                                return accessbutton
                            }
                        }
                    }
                }
                QQC2.Button
            {
                id: switchuser

                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: userpic.bottom
                anchors.topMargin: 124
                //anchors.bottom: parent.bottom

                //anchors.bottomMargin: 332

                width: 108
                height: 28

                background: Image
                {
                    source:
                    {
                        if (switchuser.pressed) return "Assets/switch-user-button-active.png"
                        if (switchuser.hovered && switchuser.focus) return "Assets/switch-user-button-hover-focus.png"
                        if (switchuser.hovered && !switchuser.focus) return "Assets/switch-user-button-hover.png"
                        if (!switchuser.hovered && switchuser.focus) return "Assets/switch-user-button-focus.png"
                        return "Assets/switch-user-button.png"
                    }
                }

                contentItem: Text
                {
                    text: "Switch User"
                    color: "white"

                    //font.family: mainfont.name
                    font.pointSize: 11
                    font.kerning: false
                    renderType: Text.NativeRendering
                    font.hintingPreference: Font.PreferFullHinting


                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter

                    bottomPadding: 3
                }

                KeyNavigation.backtab: password
                KeyNavigation.up: password
                KeyNavigation.tab: accessbutton
                KeyNavigation.down: accessbutton

                onClicked:
                {
                    password.text = ""
                    pages.currentIndex = Main.LoginPage.SelectUser
                }

                Keys.onReturnPressed:
                {
                    clicked()
                    event.accepted = true
                }
            }
            }


        }


        Item
        {
            id: loginfailedpage

            Keys.onEscapePressed:
            {
                pages.currentIndex = Main.LoginPage.Login
            }

            Image
            {
                id: currentMessageIcon

                anchors.right: currentMessage.left
                anchors.verticalCenter: currentMessage.verticalCenter

                anchors.verticalCenterOffset: -2
                anchors.rightMargin: 11

                source: "Assets/dialog-error.png"
                width: 32
                height: 32

                focus: false

                smooth: false
            }

            QQC2.Label
            {
                id: currentMessage

                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                anchors.verticalCenterOffset: 126
                anchors.horizontalCenterOffset: 14

                text: "The user name or password is incorrect."
                renderType: Text.NativeRendering
                Layout.alignment: Qt.AlignHCenter
                font.pointSize: 9

                focus: false

                width: implicitWidth
                color: "white"
                horizontalAlignment: Text.AlignCenter
                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 1
                    radius: 6
                    samples: 14
                    spread: 0.0001
                    color: "#bf000000"
                }
            }

            QQC2.Button
            {
                id: dismissButton

                anchors.top: currentMessage.bottom
                anchors.horizontalCenter: parent.horizontalCenter

                anchors.topMargin: 46

                width: 93
                height: 28

                background: Image
                {
                    source:
                    {
                        if (dismissButton.pressed) return "Assets/button-active.png"
                        if (dismissButton.hovered && dismissButton.focus) return "Assets/button-hover-focus.png"
                        if (dismissButton.hovered && !dismissButton.focus) return "Assets/button-hover.png"
                        if (!dismissButton.hovered && dismissButton.focus) return "Assets/button-focus.png"
                        return "Assets/button.png"
                    }
                }

                contentItem: Text
                {
                    text: "OK"
                    color: "white"

                    //font.family: mainfont.name
                    font.pointSize: 11

                    horizontalAlignment : Text.AlignHCenter
                    verticalAlignment : Text.AlignVCenter
                    renderType: Text.NativeRendering

                    bottomPadding: 3
                    rightPadding: 1
                }

                onClicked:
                {
                    pages.currentIndex = Main.LoginPage.Login
                }

                Keys.onReturnPressed:
                {
                    clicked()
                    event.accepted = true
                }
            }
        }
    }

    Image
    {
        id: branding
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 23
        anchors.horizontalCenter: parent.horizontalCenter
        source: config.stringValue("branding")
        visible: pages.currentIndex != Main.LoginPage.Startup
    }
    SMOD.GenericButton {
            id: switchLayoutButton

            property int currentIndex: keyboard.currentLayout
            onCurrentIndexChanged: keyboard.currentLayout = currentIndex

            anchors {
                top: parent.top
                topMargin: 5
                left: parent.left
                leftMargin: 7
            }
            implicitWidth: 35
            implicitHeight: 28
            label.font.pointSize: 9
            label.font.capitalization: Font.AllUppercase
            //focusPolicy: Qt.TabFocus
            Accessible.description: i18ndc("plasma_lookandfeel_org.kde.lookandfeel", "Button to change keyboard layout", "Switch layout")
            KeyNavigation.backtab: rebootButton
            KeyNavigation.tab: pages.currentIndex === Main.LoginPage.SelectUser ? listView : password
            KeyNavigation.down: pages.currentIndex === Main.LoginPage.SelectUser ? listView : password
            /*PW.KeyboardLayoutSwitcher {
                id: keyboardLayoutSwitcher

                anchors.fill: parent
                acceptedButtons: Qt.NoButton
            }*/

            text: keyboard.layouts[currentIndex].shortName
            onClicked: currentIndex = (currentIndex + 1) % keyboard.layouts.length

            visible: keyboard.layouts.length > 1 && pages.currentIndex != Main.LoginPage.Startup
        }
    QQC2.CheckBox
    {
        id: accessbutton

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.bottomMargin: 34
        anchors.leftMargin: 34

        width: 38
        height: 28

        visible: pages.currentIndex != Main.LoginPage.LoginFailed && pages.currentIndex != Main.LoginPage.Startup

        indicator.width: 0
        indicator.height: 0

        background: Image
        {
            source:
            {
                if (accessbutton.pressed) return "Assets/access-button-active.png"
                if (accessbutton.hovered && accessbutton.focus) return "Assets/access-button-hover-focus.png"
                if (accessbutton.hovered && !accessbutton.focus) return "Assets/access-button-hover.png"
                if (!accessbutton.hovered && accessbutton.focus) return "Assets/access-button-focus.png"
                return "Assets/access-button.png"
            }
        }

        contentItem: Item
        {
            anchors.centerIn: parent

            width: 24
            height: 24

            Image
            {
                anchors.centerIn: parent
                width: 24
                height: 24
                source: "Assets/12213.png"
                smooth: false
            }
        }

        enabled: !session.visible
        onToggled:
        {
            if(session.visible) session.close();
            else session.open();
            //session.visible = !session.visible
            //session.enabled = session.visible
        }

        Keys.onReturnPressed:
        {
            clicked()
            event.accepted = true
        }

        KeyNavigation.backtab:
        {
            if (pages.currentIndex === Main.LoginPage.SelectUser)
            {
                return listView
            }
            else if (switchuser.enabled)
            {
                return switchuser
            }

            return password
        }

        KeyNavigation.up:
        {
            if (pages.currentIndex === Main.LoginPage.Login && switchuser.enabled)
            {
                return switchuser
            }

            return accessbutton
        }

        KeyNavigation.tab: shutdownButton
        KeyNavigation.right: shutdownButton
        Item
    {
        anchors.bottom: parent.top
        anchors.left: parent.left
        //anchors.bottom: parent.bottom
        anchors.bottomMargin: -32
        //anchors.leftMargin: 94

        visible: pages.currentIndex != Main.LoginPage.LoginFailed
        enabled: visible

        width: 128
        height: 64

        SMOD.Menu {
            id: session
            x: 0
            y: -session.height + accessbutton.height + session.verticalPadding
            index: sessionModel.lastIndex

            function changeVal() {
                session.valueChanged(this.index);
                session.index = this.index;
            }
            function isIndex() {
                return session.index === this.index
            }
            Component.onCompleted: {
                for(var i = 0; i < sessionModel.count; i++) {
                    const NameRole = sessionModel.KItemModels.KRoleNames.role("name");
                    const name = sessionModel.data(sessionModel.index(i, 0), NameRole);
                    var menuitem = createMenuItem();
                    menuitem.text = name;
                    menuitem.index = i;
                    var func = isIndex.bind({index: i});
                    menuitem.checkable = true;
                    menuitem.checked = Qt.binding(func);
                    menuitem.triggered.connect(changeVal.bind({index: i}));
                    session.addAction(menuitem);
                }
            }

        }
    }
    }

    Item
    {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.bottomMargin: 34
        anchors.rightMargin: 30

        visible: pages.currentIndex != Main.LoginPage.LoginFailed && pages.currentIndex != Main.LoginPage.Startup
        enabled: pages.currentIndex != Main.LoginPage.Startup

        width: 62
        height: 28

        QQC2.Button
        {
            id: shutdownButton

            anchors.bottom: parent.bottom
            anchors.left: parent.left

            width: 38
            height: 28

            background: Image
            {
                source:
                {
                    if (shutdownButton.pressed) return "Assets/power-active.png"
                    if (shutdownButton.hovered && shutdownButton.focus) return "Assets/power-hover-focus.png"
                    if (shutdownButton.hovered && !shutdownButton.focus) return "Assets/power-hover.png"
                    if (!shutdownButton.hovered && shutdownButton.focus) return "Assets/power-focus.png"
                    return "Assets/power.png"
                }
            }

            contentItem: Item
            {
                anchors.centerIn: parent

                width: 24
                height: 24

                Image
                {
                    anchors.centerIn: parent
                    width: 24
                    height: 24
                    source: "Assets/power-glyph.png"
                    smooth: false
                }
            }

            onClicked : sddm.powerOff()

            Keys.onReturnPressed:
            {
                clicked()
                event.accepted = true
            }

            KeyNavigation.backtab: accessbutton
            KeyNavigation.left: accessbutton
            KeyNavigation.tab: rebootButton
            KeyNavigation.right: rebootButton
            KeyNavigation.up:
            {
                if (pages.currentIndex === Main.LoginPage.Login && switchuser.enabled)
                {
                    return switchuser
                }

                return shutdownButton
            }

            QQC2.ToolTip.visible: hovered
            QQC2.ToolTip.delay: Qt.styleHints.mousePressAndHoldInterval
            QQC2.ToolTip.text: qsTr("Shut down")
        }

        QQC2.Button
        {
            id: rebootButton

            anchors.bottom: parent.bottom
            anchors.left: shutdownButton.right

            visible: pages.currentIndex != Main.LoginPage.Startup

            width: 20
            height: 28

            background: Image
            {
                source:
                {
                    if (rebootButton.pressed) return "Assets/12301.png"
                    if (rebootButton.hovered && rebootButton.focus) return "Assets/12298.png"
                    if (rebootButton.hovered && !rebootButton.focus) return "Assets/12300.png"
                    if (!rebootButton.hovered && rebootButton.focus) return "Assets/12299.png"
                    return "Assets/12302.png"
                }
            }

            contentItem: Item
            {
                anchors.centerIn: parent

                width: 9
                height: 6

                Image
                {
                    anchors.centerIn: parent
                    width: 9
                    height: 6
                    source: "Assets/power-glyph-arrow.png"
                    smooth: false
                }
            }
            enabled: !powerMenu.visible
            onClicked: {
                if(powerMenu.visible) powerMenu.close();
                else powerMenu.open();

            }

            SMOD.Menu {
                id: powerMenu
                x: -powerMenu.width + parent.width //-parent.width + powerMenu.horizontalPadding
                y: -powerMenu.height //-powerMenu.height + rebootButton.height //+ powerMenu.verticalPadding

                Component.onCompleted: {
                    var menuitem = powerMenu.createMenuItem();
                    menuitem.text = "Restart";
                    menuitem.triggered.connect(() => { sddm.reboot() });
                    powerMenu.addAction(menuitem);
                    powerMenu.addItem(powerMenu.createMenuSeparator());

                    if(sddm.canSuspend) {
                        menuitem = powerMenu.createMenuItem();
                        menuitem.text = "Sleep";
                        menuitem.triggered.connect(() => { sddm.suspend() });
                        powerMenu.addAction(menuitem);
                    }
                    if(sddm.canHibernate) {
                        menuitem = powerMenu.createMenuItem();
                        menuitem.text = "Hibernate";
                        menuitem.triggered.connect(() => { sddm.hibernate() });
                        powerMenu.addAction(menuitem);
                    }
                    if(sddm.canHybridSleep) {
                        menuitem = powerMenu.createMenuItem();
                        menuitem.text = "Hybrid Sleep";
                        menuitem.triggered.connect(() => { sddm.hybridSleep() });
                        powerMenu.addAction(menuitem);
                    }
                    menuitem = powerMenu.createMenuItem();
                    menuitem.text = "Shut down";
                    menuitem.triggered.connect(() => { sddm.powerOff() });
                    powerMenu.addAction(menuitem);
                }

            }
            Keys.onReturnPressed: event => {
                clicked()
                event.accepted = true
            }

            KeyNavigation.backtab: shutdownButton
            KeyNavigation.left: shutdownButton
            KeyNavigation.up:
            {
                if (pages.currentIndex === Main.LoginPage.Login && switchuser.enabled)
                {
                    return switchuser
                }

                return rebootButton
            }

            KeyNavigation.tab: switchLayoutButton
        }
    }
    Item
    {
        id: startuppage

        z: 99
        anchors.fill: parent
        SequentialAnimation {
            id: seqanimation
            NumberAnimation { target: startuppage; property: "opacity"; to: 1;   duration: 220; easing.type: Easing.Linear }
            NumberAnimation { target: startupimage; property: "opacity"; to: 1;  duration: 650; easing.type: Easing.Linear }
            NumberAnimation { target: startupimage; property: "opacity"; to: 1;  duration: 200; easing.type: Easing.Linear }
            NumberAnimation { target: startupimage2; property: "opacity"; to: 1; duration: 650; easing.type: Easing.Linear }
            NumberAnimation { target: startupimage3; property: "opacity"; to: 1; duration: 650; easing.type: Easing.Linear }
            NumberAnimation { target: startupimage4; property: "opacity"; to: 1; duration: 650; easing.type: Easing.Linear }
            NumberAnimation { target: startupimage4; property: "opacity"; to: 1; duration: 200; easing.type: Easing.Linear }
            ParallelAnimation {
                NumberAnimation { target: startupimage2; property: "opacity"; to: 0;  duration: 650; easing.type: Easing.OutQuad }
                NumberAnimation { target: startupimage3; property: "opacity"; to: 0;  duration: 650; easing.type: Easing.OutQuad }
                NumberAnimation { target: startupimage4; property: "opacity"; to: 0;  duration: 650; easing.type: Easing.OutQuad }
                NumberAnimation { target: startupimage; property: "opacity"; to: 0;  duration: 950; easing.type:  Easing.OutQuad }
            }
            ScriptAction { script: { pages.startSingleUserMode(); } }
            NumberAnimation { target: startuppage; property: "opacity"; to: 0; duration: 650; easing.type: Easing.Linear }
            NumberAnimation { target: startupanimation; property: "opacity"; to: 0; duration: 650; easing.type: Easing.OutQuad }
            PropertyAction { target: executable; property: "startupEnabled"; value: false }
        }
        visible: executable.startupEnabled
        opacity: 1
        Rectangle
        {
            color: "black"
            anchors.fill: parent
        }

        Item
        {
            id: startupanimation
            property int progress: 0
            anchors.centerIn: parent

            Image
            {
                id: startupimage
                anchors.centerIn: parent
                source: Qt.resolvedUrl("./Assets/17000")
                opacity: 0
            }

            Image
            {
                id: startupimage2
                anchors.centerIn: parent
                source: Qt.resolvedUrl("./Assets/17001")
                opacity: 0
            }

            Image
            {
                id: startupimage3
                anchors.centerIn: parent
                source: Qt.resolvedUrl("./Assets/17002")
                opacity: 0
            }

            Image
            {
                id: startupimage4
                anchors.centerIn: parent
                source: Qt.resolvedUrl("./Assets/17003")
                opacity: 0
            }

        }

        // to hide the cursor
        MouseArea
        {
            anchors.fill: parent
            cursorShape: Qt.BlankCursor
        }
    }

}
