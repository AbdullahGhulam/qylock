import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Templates 2.15 as T
import QtQuick.Window 2.15
import Qt5Compat.GraphicalEffects
import Qt.labs.folderlistmodel
import SddmComponents 2.0

Rectangle {
    id: root

    // Settings
    QtObject {
        id: settings
        property int key1: Qt.Key_Z
        property int key2: Qt.Key_X
        property bool use12HourTime: false
        property int requiredHits: 20
        property real osuSpeed:   1.5
        property real osuDensity: 0.8
        property real sliderChance: 0.6
    }

    readonly property real s: Screen.height / 768
    width: Screen.width
    color: "#0a0a0c"

    // gameMode: true = rhythm gate, false = direct login
    readonly property bool gameMode: config.gameMode !== "menu"

    // Menu Item
    component OsuMenuItem: Item {
        id: menuItem
        property string label: ""
        property color iconColor: "#9B59B6"
        property real s: root.s
        signal activated()

        width:  380 * s
        height: 64  * s

        Rectangle {
            anchors.fill: parent
            radius: 8 * s
            gradient: menuMa.containsMouse ? whiteGrad : mainGrad
            opacity: menuMa.containsMouse ? 1.0 : 0.95
            border.color: menuMa.containsMouse ? "#ffffff" : Qt.rgba(1,1,1,0.2)
            border.width: 1.5 * s

            Gradient { id: mainGrad; orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#662D91" }
                GradientStop { position: 1.0; color: "#913BBD" }
            }
            Gradient { id: whiteGrad; orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "#ffffff" }
                GradientStop { position: 1.0; color: "#e8e8e8" }
            }

            Behavior on opacity { NumberAnimation { duration: 150 } }

            layer.enabled: true
            layer.effect: DropShadow {
                color: "#66000000"; radius: 12.0; samples: 25; spread: 0.1; verticalOffset: 4*s
            }

            transform: Matrix4x4 {
                matrix: Qt.matrix4x4(1, -0.4, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.leftMargin: menuMa.containsMouse ? 60*s : 40*s
            text: menuItem.label; color: menuMa.containsMouse ? menuItem.iconColor : "white"
            font.family: mainFont.name; font.pixelSize: 34*s; font.weight: Font.Black; font.italic: true
            Behavior on anchors.leftMargin { NumberAnimation { duration: 350; easing.type: Easing.OutQuint } }
        }

        MouseArea {
            id: menuMa
            anchors.fill: parent
            hoverEnabled: true; cursorShape: Qt.PointingHandCursor
            onClicked: menuItem.activated()
        }
    }

    // App State
    property int sessionIndex: (sessionModel && sessionModel.lastIndex >= 0) ? sessionModel.lastIndex : 0
    property int userIndex:    (userModel    && userModel.lastIndex    >= 0) ? userModel.lastIndex    : 0
    property bool gameActive:    false
    property bool loginPending:  false
    property bool loginSuccess:  false

    // Game State
    property int  osuScore:    0
    property int  osuCombo:    0
    property int  osuMaxCombo: 0
    property int  osuHits:     0
    property int  osuMisses:   0
    property real osuAccuracy: 100.0
    property real osuHealth:   1.0
    property bool osuFailed:   false
    property int  osuCircleCount: 0
    property var  activeCircles: []

    // Background
    property int bgIndex: Math.floor(Math.random() * 7)

    readonly property var bgFiles: [
        "background/A Glow.jpg",
        "background/B Glow.jpg",
        "background/C Glow.jpg",
        "background/D Glow.jpg",
        "background/E Glow.jpg",
        "background/F Glow.jpg",
        "background/G Glow.jpg"
    ]

    // Color Schemes
    readonly property var bgSchemes: [
        { accent: "#ff4499", secondary: "#cc0066", glow: "#ff66bb", dark: "#1a0011", text: "#ffe0ef" },
        { accent: "#00ccff", secondary: "#0088cc", glow: "#44eeff", dark: "#001122", text: "#ddf6ff" },
        { accent: "#ff8800", secondary: "#cc5500", glow: "#ffbb44", dark: "#1a0e00", text: "#fff0dd" },
        { accent: "#88ff00", secondary: "#55bb00", glow: "#bbff55", dark: "#0a1400", text: "#f0ffe0" },
        { accent: "#aa44ff", secondary: "#7700cc", glow: "#cc88ff", dark: "#110022", text: "#f0e8ff" },
        { accent: "#00ffbb", secondary: "#00aa80", glow: "#55ffdd", dark: "#001a14", text: "#dffff7" },
        { accent: "#ff3355", secondary: "#cc1133", glow: "#ff7788", dark: "#1a0008", text: "#ffe8ec" }
    ]

    readonly property var scheme: bgSchemes[bgIndex]
    readonly property color accentColor:    scheme.accent
    readonly property color secondaryColor: scheme.secondary
    readonly property color glowColor:      scheme.glow
    readonly property color darkColor:      scheme.dark
    readonly property color textColor:      scheme.text

    // Assets
    FolderListModel {
        id: fontFolder
        folder: Qt.resolvedUrl("font")
        nameFilters: ["*.ttf", "*.otf"]
    }
    FontLoader {
        id: mainFont
        source: fontFolder.count > 0 ? "font/" + fontFolder.get(0, "fileName") : ""
    }
    TextConstants { id: textConstants }

    // SDDM Bridges
    ListView {
        id: userHelper; model: userModel; currentIndex: root.userIndex
        width: 1; height: 1; opacity: 0
        delegate: Item {
            property string uName:  model.realName || model.name || ""
            property string uLogin: model.name || ""
        }
    }
    ListView {
        id: sessionHelper; model: sessionModel; currentIndex: root.sessionIndex
        width: 1; height: 1; opacity: 0
        delegate: Item { property string sName: model.name || "" }
    }

    // Autofocus
    Timer { interval: 300; running: true; onTriggered: passField.forceActiveFocus() }

    // Fade In
    property real uiOpacity: 0
    Component.onCompleted: {
        fadeIn.start()
    }
    NumberAnimation {
        id: fadeIn; target: root; property: "uiOpacity"
        from: 0; to: 1; duration: 300; easing.type: Easing.OutCubic
    }

    // Background Image
    Image {
        id: bgImage
        anchors.fill: parent
        source: root.bgFiles[root.bgIndex]
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        opacity: root.loginSuccess ? 0.15 : (root.gameActive ? 0.3 : 0.65)
        Behavior on opacity { NumberAnimation { duration: 800; easing.type: Easing.OutCubic } }
    }

    // Dark Tint
    Rectangle {
        anchors.fill: parent
        color: root.darkColor
        opacity: root.gameActive ? 0.85 : 0.45
        Behavior on opacity { NumberAnimation { duration: 800 } }
    }

    // Vignette
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 1.0; color: "#aa000000" }
        }
    }

    // Login Screen
    Item {
        id: loginScreen
        anchors.fill: parent
        opacity: root.gameActive ? 0 : root.uiOpacity
        visible: opacity > 0.01
        Behavior on opacity { NumberAnimation { duration: 600; easing.type: Easing.OutQuint } }

        // Top HUD
        Item {
            anchors.left: parent.left; anchors.top: parent.top; anchors.right: parent.right; height: 120*s
            z: 50

            Rectangle {
                anchors.left: parent.left; anchors.top: parent.top; anchors.right: parent.right; height: 80*s
                color: "#aa000000"
                Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 1*s; color: "#22ffffff" }
            }

            // User Profile
            Item {
                id: userProfileWidget
                anchors.left: parent.left; anchors.top: parent.top
                width: 400*s; height: 100*s

                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    onClicked: root.userIndex = (root.userIndex + 1) % Math.max(1, userModel.count)
                }

                Text {
                    id: rankWatermark
                    anchors.left: userAvatar.right; anchors.leftMargin: 15*s
                    anchors.top: parent.top; anchors.topMargin: -8*s
                    text: "22171"
                    color: "#1affffff"
                    font.family: mainFont.name; font.pixelSize: 84*s; font.weight: Font.Black
                }

                Image {
                    id: userAvatar
                    anchors.left: parent.left; anchors.top: parent.top
                    width: 76*s; height: 76*s
                    source: "pfp.png"
                    fillMode: Image.PreserveAspectCrop
                }

                Column {
                    anchors.left: userAvatar.right; anchors.leftMargin: 12*s
                    anchors.top: parent.top; anchors.topMargin: 4*s
                    spacing: -2*s

                    Text {
                        text: userHelper.currentItem ? userHelper.currentItem.uName : "Player"
                        color: "white"
                        font.family: mainFont.name; font.pixelSize: 20*s; font.weight: Font.Normal
                        layer.enabled: true; layer.effect: DropShadow { color: "#aa000000"; radius: 4; samples: 9 }
                    }
                    Text { text: "Performance: 6,048pp"; color: "#bbbbbb"; font.family: mainFont.name; font.pixelSize: 11*s }
                    Text { text: "Accuracy: 98.48%"; color: "#bbbbbb"; font.family: mainFont.name; font.pixelSize: 11*s }

                    Row {
                        spacing: 8*s; anchors.topMargin: 4*s
                        Text { text: "Lv100"; color: "white"; font.family: mainFont.name; font.pixelSize: 11*s; font.weight: Font.Bold; anchors.verticalCenter: parent.verticalCenter }
                        Rectangle {
                            width: 150*s; height: 6*s; radius: 3*s; color: "#66000000"; border.color: "#33ffffff"; border.width: 1*s
                            anchors.verticalCenter: parent.verticalCenter
                            Rectangle { anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: parent.width * 0.45; radius: 3*s; color: "#FFC231" }
                        }
                    }
                }
            }

            // Session Widget
            Item {
                id: sessionWidget
                anchors.left: userProfileWidget.right; anchors.leftMargin: 40*s; anchors.top: parent.top; anchors.topMargin: 15*s
                width: 200*s; height: 100*s

                Column {
                    spacing: 2*s
                    Text {
                        text: "ENVIRONMENT"; color: "#99bbbbbb"; font.family: mainFont.name; font.pixelSize: 9*s; font.weight: Font.Black; font.letterSpacing: 2*s
                    }
                    Text {
                        text: sessionHelper.currentItem ? sessionHelper.currentItem.sName : "Default"
                        color: "white"
                        font.family: mainFont.name; font.pixelSize: 22*s; font.weight: Font.DemiBold
                        layer.enabled: true; layer.effect: DropShadow { color: "#aa000000"; radius: 4; samples: 9 }
                    }
                }
            }

            // Clock
            Item {
                anchors.top: parent.top; anchors.topMargin: 12*s
                anchors.right: parent.right; anchors.rightMargin: 25*s
                width: 250*s; height: 60*s

                Column {
                    anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter
                    spacing: 4*s

                    Row {
                        anchors.right: parent.right; spacing: 14*s
                        Column {
                            anchors.verticalCenter: parent.verticalCenter
                            Text { text: "CURRENT"; color: "#99bbbbbb"; font.family: mainFont.name; font.pixelSize: 9*s; anchors.right: parent.right; font.weight: Font.Black; font.letterSpacing: 1.5*s }
                            Text { text: "TIME"; color: "#99bbbbbb"; font.family: mainFont.name; font.pixelSize: 9*s; anchors.right: parent.right; font.weight: Font.Black; font.letterSpacing: 1.5*s }
                        }
                        Text {
                            property string timeStr: Qt.formatTime(new Date(), "HH:mm")
                            Timer { interval: 1000; running: true; repeat: true; onTriggered: parent.timeStr = Qt.formatTime(new Date(), "HH:mm") }
                            text: timeStr
                            color: "white"; font.family: mainFont.name; font.pixelSize: 32*s; font.weight: Font.Bold
                            anchors.verticalCenter: parent.verticalCenter
                            layer.enabled: true; layer.effect: DropShadow { color: "#88000000"; radius: 4 }
                        }
                    }
                }
            }
        }

        // Main Menu
        Item {
            id: mainMenuWrapper
            anchors.fill: parent
            property bool menuExpanded: false

            MouseArea {
                anchors.fill: parent
                enabled: mainMenuWrapper.menuExpanded
                onClicked: mainMenuWrapper.menuExpanded = false
            }

            // Osu Button
            Item {
                id: osuBtnArea
                z: 10
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: mainMenuWrapper.menuExpanded ? -220*s : 0
                Behavior on anchors.horizontalCenterOffset { NumberAnimation { duration: 500; easing.type: Easing.OutElastic; easing.amplitude: 1.0; easing.period: 0.9 } }
                width:  340 * s
                height: 340 * s

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width; height: parent.height; radius: width/2

                    gradient: Gradient {
                        GradientStop { position: 0.0; color: "#FF73B3" }
                        GradientStop { position: 1.0; color: "#E03F8A" }
                    }

                    border.color: "white"
                    border.width: 13 * s

                    Rectangle {
                        anchors.fill: parent; radius: width/2
                        color: "transparent"
                        border.color: "#33ffffff"; border.width: 6 * s
                    }

                    layer.enabled: true
                    layer.effect: DropShadow { color: "#66000000"; radius: 14; samples: 21; spread: 0.1; verticalOffset: 6*s; horizontalOffset: 2*s }

                    scale: menuMa_global.containsMouse ? 1.05 : 1.0
                    Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack } }

                    Rectangle {
                        anchors.fill: parent; radius: width/2
                        gradient: Gradient {
                            GradientStop { position: 0.0; color: "#66ffffff" }
                            GradientStop { position: 0.3; color: "transparent" }
                        }
                        anchors.margins: 10*s; rotation: -45
                    }

                    Text {
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: -4 * s
                        anchors.horizontalCenterOffset: -4 * s
                        text: "osu!"
                        color: "white"
                        font.family: mainFont.name
                        font.pixelSize: 135 * s
                        font.weight: Font.Black
                        font.italic: true

                        layer.enabled: true
                        layer.effect: DropShadow { color: "#66000000"; radius: 10; samples: 17; verticalOffset: 6*s; horizontalOffset: 4*s }
                    }
                }

                // Ripple Rings
                Repeater {
                    model: 2
                    Rectangle {
                        anchors.centerIn: parent; width: parent.width; height: parent.height; radius: width/2
                        color: "transparent"; border.color: "white"; border.width: 4*s
                        SequentialAnimation on scale { loops: Animation.Infinite
                            PauseAnimation { duration: index * 600 }
                            NumberAnimation { from: 0.95; to: 1.5; duration: 1200; easing.type: Easing.OutQuad } }
                        SequentialAnimation on opacity { loops: Animation.Infinite
                            PauseAnimation { duration: index * 600 }
                            NumberAnimation { from: 0.6; to: 0.0; duration: 1200; easing.type: Easing.OutQuad } }
                    }
                }

                MouseArea {
                    id: menuMa_global
                    anchors.centerIn: parent
                    width: parent.width; height: parent.height
                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (!mainMenuWrapper.menuExpanded) {
                            mainMenuWrapper.menuExpanded = true
                        } else {
                            if (passField.text.length > 0) doAction(); else passField.forceActiveFocus()
                        }
                    }
                }
            }

            // Sliding Menu
            Column {
                anchors.left: osuBtnArea.horizontalCenter
                anchors.leftMargin: mainMenuWrapper.menuExpanded ? 150*s : 0*s
                anchors.verticalCenter: osuBtnArea.verticalCenter
                spacing: 6*s
                z: 5
                opacity: mainMenuWrapper.menuExpanded ? 1 : 0
                visible: opacity > 0.01
                Behavior on opacity { NumberAnimation { duration: 150 } }
                Behavior on anchors.leftMargin { NumberAnimation { duration: 450; easing.type: Easing.OutElastic; easing.amplitude: 1.0; easing.period: 0.8 } }

                OsuMenuItem { s: root.s; label: "Play"; iconColor: "#662D91"; onActivated: { if (passField.text.length > 0) doAction(); else passField.forceActiveFocus() } }
                OsuMenuItem { s: root.s; label: "Session"; iconColor: "#662D91"; onActivated: root.sessionIndex = (root.sessionIndex + 1) % Math.max(1, sessionModel.count) }
                OsuMenuItem { s: root.s; label: "Reboot"; iconColor: "#662D91"; onActivated: sddm.reboot() }
                OsuMenuItem { s: root.s; label: "Poweroff"; iconColor: "#662D91"; onActivated: sddm.powerOff() }
            }
        }

        // Password Input
        Item {
            anchors.bottom: parent.bottom; anchors.right: parent.right
            width: 320*s; height: 50*s

            Rectangle {
                anchors.fill: parent
                color: "#aa111111"
                border.color: "#33ffffff"; border.width: 1*s
            }

            Rectangle {
                anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top
                height: 4*s; color: passField.activeFocus ? "#FF73B3" : "#555555"
            }

            Rectangle {
                anchors.right: parent.right; anchors.bottom: parent.top
                width: 120*s; height: 28*s; color: "#aa111111"; border.color: "#33ffffff"; border.width: 1*s
                visible: !passField.activeFocus
                Text { anchors.centerIn: parent; text: "SHOW CHAT ▲"; color: "white"; font.family: mainFont.name; font.pixelSize: 10*s; font.weight: Font.Bold }
            }

            Row {
                anchors.fill: parent; anchors.leftMargin: 15*s; anchors.rightMargin: 15*s
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12*s

                Item {
                    width: 14*s; height: 16*s; anchors.verticalCenter: parent.verticalCenter
                    Rectangle { anchors.bottom: parent.bottom; width: 14*s; height: 10*s; radius: 2*s; color: "#FF73B3" }
                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter; anchors.top: parent.top; width: 8*s; height: 8*s; radius: 4*s
                        color: "transparent"; border.color: "#FF73B3"; border.width: 2*s
                    }
                    opacity: passField.activeFocus ? 1 : 0.6
                }

                Rectangle { width: 1*s; height: 24*s; color: "#33ffffff"; anchors.verticalCenter: parent.verticalCenter }

                TextInput {
                    id: passField
                    width: parent.width - 60*s
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"
                    font.family: mainFont.name; font.pixelSize: 18*s; font.weight: Font.Bold; font.letterSpacing: 4*s
                    echoMode: TextInput.Password; passwordCharacter: "○"
                    focus: true; Keys.onReturnPressed: if (text.length > 0) doAction()

                    Text {
                        anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter
                        text: "Enter password..."
                        color: "#66ffffff"; font.family: mainFont.name; font.pixelSize: 15*s
                        visible: passField.text.length === 0
                    }
                }
            }

            Text {
                id: errorMsg
                anchors.bottom: parent.top; anchors.bottomMargin: 40*s
                anchors.right: parent.right; anchors.rightMargin: 10*s
                text: ""
                color: "#ff4455"
                font.family: mainFont.name; font.pixelSize: 14*s; font.weight: Font.Black; font.italic: true
                layer.enabled: true; layer.effect: DropShadow { color: "#aa000000"; radius: 4; samples: 9 }
            }
        }
    }

    // Game Screen
    FocusScope {
        id: gameScreen
        anchors.fill: parent
        visible: root.gameActive
        focus: root.gameActive
        opacity: root.gameActive ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 500 } }

        // Progress Bar
        Item {
            id: progressBarArea
            anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
            height: 6 * s

            Rectangle {
                anchors.fill: parent; color: "#22ffffff"
            }
            Rectangle {
                width: parent.width * Math.min(1.0, root.osuHits / settings.requiredHits)
                height: parent.height; color: root.accentColor
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }
                layer.enabled: true
                layer.effect: DropShadow {
                    color: root.glowColor; radius: 8; samples: 13; spread: 0.3
                    horizontalOffset: 0; verticalOffset: 0
                }
            }
        }

        // HP Bar
        Item {
            id: hpBarArea
            anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right
            height: 8 * s

            Rectangle {
                anchors.fill: parent; color: "#44000000"
            }
            Rectangle {
                width: parent.width * root.osuHealth
                height: parent.height; color: root.osuHealth > 0.3 ? "#fff" : "#ff4444"
                Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutCubic } }

                layer.enabled: true
                layer.effect: DropShadow { color: color; radius: 12; samples: 17; opacity: 0.8 }
            }
        }

        // Score HUD
        Column {
            anchors.top: progressBarArea.bottom; anchors.topMargin: 16*s
            anchors.right: parent.right; anchors.rightMargin: 40*s
            spacing: 2*s

            Text {
                anchors.right: parent.right
                text: String(root.osuScore).padStart(8, "0")
                color: "white"; font.family: mainFont.name
                font.pixelSize: 32*s; font.weight: Font.Black; font.letterSpacing: -1*s
                layer.enabled: true
                layer.effect: DropShadow { color: "#88000000"; radius: 4; samples: 9; horizontalOffset: 1*s; verticalOffset: 1*s }
            }
            Text {
                anchors.right: parent.right
                text: root.osuAccuracy.toFixed(2) + "%"
                color: "#ccffffff"; font.family: mainFont.name; font.pixelSize: 14*s
            }
        }

        // Combo
        Column {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 50*s
            anchors.left: parent.left; anchors.leftMargin: 40*s
            spacing: 0

            Text {
                id: comboText
                text: root.osuCombo + "x"
                color: comboBreakAnim.running ? "#ff4444" : "white"; font.family: mainFont.name
                font.pixelSize: 52*s + Math.min(20*s, root.osuCombo * 0.5); font.weight: Font.Black

                NumberAnimation on scale { id: comboPopAnim; from: 1.35; to: 1.0; duration: 150; easing.type: Easing.OutBack }

                SequentialAnimation {
                    id: comboBreakAnim
                    NumberAnimation { target: comboText; property: "anchors.horizontalCenterOffset"; from: -10*s; to: 10*s; duration: 50 }
                    NumberAnimation { target: comboText; property: "anchors.horizontalCenterOffset"; from: 10*s; to: -8*s; duration: 50 }
                    NumberAnimation { target: comboText; property: "anchors.horizontalCenterOffset"; to: 0; duration: 50 }
                }

                layer.enabled: true
                layer.effect: DropShadow {
                    color: root.osuCombo > 10 ? root.accentColor : root.glowColor
                    radius: Math.min(20, 8 + root.osuCombo * 0.2); samples: 17; horizontalOffset: 0; verticalOffset: 0
                }
            }
        }

        // Hit Progress
        Text {
            anchors.bottom: parent.bottom; anchors.bottomMargin: 50*s
            anchors.right: parent.right; anchors.rightMargin: 40*s
            text: root.osuHits + " / " + settings.requiredHits + " HITS"
            color: "#aaffffff"; font.family: mainFont.name; font.pixelSize: 13*s; font.letterSpacing: 2*s
        }

        // Game Area
        Item {
            id: gameArea
            anchors.fill: parent

            property bool isActionHeld: false
            property real mouseXPos: 0
            property real mouseYPos: 0

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onPositionChanged: {
                    gameArea.mouseXPos = mouseX;
                    gameArea.mouseYPos = mouseY;
                }
                onPressed: (mouse) => {
                    gameArea.isActionHeld = true;
                    root.tryHitAt(mouseX, mouseY);
                    mouse.accepted = true;
                }
                onReleased: {
                    gameArea.isActionHeld = false;
                }
            }
        }

        // Ready Text
        Text {
            id: readyText
            anchors.centerIn: parent
            text: "CLICK THE CIRCLES!"
            color: "white"; font.family: mainFont.name
            font.pixelSize: 28*s; font.weight: Font.Black; font.letterSpacing: 6*s
            opacity: root.osuCircleCount === 0 ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 400 } }
            layer.enabled: true
            layer.effect: DropShadow { color: root.glowColor; radius: 16; samples: 21; spread: 0.2 }
        }

        // Key Controls
        Keys.onPressed: function(event) {
            if (event.key === settings.key1 || event.key === settings.key2) {
                event.accepted = true;
                gameArea.isActionHeld = true;
                root.tryHitAt(gameArea.mouseXPos, gameArea.mouseYPos);
            }
        }
        Keys.onReleased: function(event) {
            if (event.key === settings.key1 || event.key === settings.key2) {
                if (!event.isAutoRepeat) {
                    event.accepted = true;
                    gameArea.isActionHeld = false;
                }
            }
        }
    }

    // Hit Circle
    Component {
        id: hitCircleComp

        Item {
            id: hc
            property int circleNum: 1
            property bool hit: false
            property bool missed: false
            property real lifetime: 2000
            property real approachDuration: lifetime

            width: 80*s; height: 80*s

            signal hitSignal(real hitAccuracy)
            signal missSignal()

            // Approach Ring
            Rectangle {
                id: approachRing
                anchors.centerIn: parent
                width: parent.width * 3.0; height: parent.width * 3.0; radius: width / 2
                color: "transparent"
                border.color: root.accentColor; border.width: 3 * s
                opacity: hc.hit || hc.missed ? 0 : 1

                NumberAnimation on width {
                    from: hc.width * 3.0; to: hc.width * 1.05
                    duration: hc.approachDuration; easing.type: Easing.Linear
                    running: true
                }
                NumberAnimation on height {
                    from: hc.width * 3.0; to: hc.width * 1.05
                    duration: hc.approachDuration; easing.type: Easing.Linear
                    running: true
                }
                Behavior on opacity { NumberAnimation { duration: 80 } }
            }

            // Circle Body
            Rectangle {
                id: circleBody
                anchors.fill: parent; radius: width / 2
                color: Qt.rgba(
                    parseInt(root.accentColor.toString().slice(1,3), 16)/255,
                    parseInt(root.accentColor.toString().slice(3,5), 16)/255,
                    parseInt(root.accentColor.toString().slice(5,7), 16)/255,
                    0.22
                )
                border.color: root.accentColor; border.width: 4 * s

                Rectangle {
                    anchors.centerIn: parent
                    width: parent.width - 14*s; height: parent.width - 14*s; radius: width/2
                    color: "transparent"
                    border.color: "#aaffffff"; border.width: 2*s
                }

                Text {
                    anchors.centerIn: parent
                    text: hc.circleNum
                    color: "white"; font.family: mainFont.name
                    font.pixelSize: 28*s; font.weight: Font.Black
                    layer.enabled: true
                    layer.effect: DropShadow { color: "#88000000"; radius: 4; samples: 9 }
                }
            }

            // Glow
            Rectangle {
                anchors.centerIn: parent
                width: parent.width + 20*s; height: parent.width + 20*s; radius: width/2
                color: root.glowColor; opacity: 0.12
            }

            // Hit Burst
            Rectangle {
                id: hitBurst
                anchors.centerIn: parent
                width: parent.width; height: parent.width; radius: width/2
                color: "transparent"; border.color: root.glowColor; border.width: 5*s
                opacity: 0

                NumberAnimation on scale {
                    id: burstScale; from: 1.0; to: 2.2; duration: 350; easing.type: Easing.OutQuad
                }
                NumberAnimation on opacity {
                    id: burstOpacity; from: 1.0; to: 0.0; duration: 350; easing.type: Easing.OutQuad
                }
            }

            // Miss Fade
            NumberAnimation on opacity {
                id: missAnim; to: 0.0; duration: 300
                running: false
            }

            // Life Timer
            Timer {
                id: lifeTimer
                interval: hc.lifetime
                running: true
                onTriggered: {
                    if (!hc.hit) {
                        hc.missed = true
                        hc.missSignal()
                        missAnim.start()
                        Qt.callLater(function() { hc.destroy() })
                    }
                }
            }

            function tryHit() {
                if (!hc.hit && !hc.missed) {
                    hc.hit = true
                    lifeTimer.stop()
                    var remainRatio = approachRing.width / (hc.width * 3.0)
                    var acc = Math.max(0, 1.0 - remainRatio)
                    hc.hitSignal(acc)
                    circleBody.opacity = 0
                    approachRing.opacity = 0
                    burstScale.restart()
                    burstOpacity.restart()
                    Qt.callLater(function() { hc.destroy() })
                }
            }
        }
    }

    // Slider Component
    Component {
        id: sliderComp
        Item {
            id: sliderRoot
            property int circleNum: 1
            property real lifetime: 2000
            property real approachDuration: lifetime
            property real sx: 0; property real sy: 0
            property real ex: 0; property real ey: 0
            property real slideDuration: 1000

            property bool hit: false
            property bool missed: false
            property bool sliding: false
            property bool completed: false

            signal hitSignal(real hitAccuracy)
            signal missSignal()
            signal sliderCompleted()

            width: 80 * s; height: 80 * s
            x: sx - 40*s; y: sy - 40*s

            property real destX: ex - sx
            property real destY: ey - sy

            Rectangle {
                id: track
                x: 40*s; y: 40*s - height/2
                height: 60*s; width: Math.sqrt(destX*destX + destY*destY)
                radius: height/2; color: "#44ffffff"; border.color: root.accentColor; border.width: 4*s
                transformOrigin: Item.Left; rotation: Math.atan2(destY, destX) * 180 / Math.PI
                opacity: (!completed && !missed) ? 0.6 : 0
                Behavior on opacity { NumberAnimation { duration: 150 } }
                Rectangle { anchors.centerIn: parent; width: parent.width - 20*s; height: parent.height - 20*s; radius: height/2; color: "black"; opacity: 0.5 }
            }

            Rectangle {
                id: sliderApproach
                anchors.centerIn: sBody
                width: 240*s; height: 240*s; radius: 120*s; color: "transparent"; border.color: root.accentColor; border.width: 3*s
                opacity: (hit || missed) ? 0 : 1
                NumberAnimation on width { from: 240*s; to: 82*s; duration: approachDuration; easing.type: Easing.Linear; running: true }
                NumberAnimation on height { from: 240*s; to: 82*s; duration: approachDuration; easing.type: Easing.Linear; running: true }
            }

            Item {
                id: sBody
                anchors.fill: parent; opacity: (hit || missed) ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 150 } }
                Rectangle { anchors.fill: parent; radius: 40*s; color: Qt.rgba(root.accentColor.r, root.accentColor.g, root.accentColor.b, 0.4); border.color: root.accentColor; border.width: 4*s }
                Text { anchors.centerIn: parent; text: circleNum; color: "white"; font.family: mainFont.name; font.pixelSize: 28*s; font.weight: Font.Bold }
            }

            Item {
                id: eBody
                x: destX; y: destY; width: 80*s; height: 80*s; opacity: (completed || missed) ? 0 : 0.6
                Rectangle { anchors.fill: parent; radius: 40*s; color: "transparent"; border.color: root.accentColor; border.width: 4*s }
            }

            Rectangle {
                id: sBall
                width: 80*s; height: 80*s; radius: 40*s; color: root.accentColor; opacity: sliding ? 1 : 0
                x: 0; y: 0
                Rectangle { anchors.centerIn: parent; width: 120*s; height: 120*s; radius: 60*s; color: "transparent"; border.color: "white"; border.width: 4*s; opacity: 0.8
                    RotationAnimation on rotation { loops: Animation.Infinite; from: 0; to: 360; duration: 400; running: sliding }
                }
            }

            Timer { id: lT; interval: lifetime; running: true; onTriggered: { if(!hit){ missed=true; missSignal(); Qt.callLater(destroy) } } }

            // Slider Follow
            Timer {
                id: holdCheck
                interval: 16; repeat: true; running: sliding
                onTriggered: {
                    if (!gameArea.isActionHeld) { fail(); return }

                    var magSq = destX*destX + destY*destY
                    if (magSq < 1) { finish(); return }

                    var mx = gameArea.mouseXPos - (sliderRoot.x + 40*s)
                    var my = gameArea.mouseYPos - (sliderRoot.y + 40*s)

                    var t = (mx * destX + my * destY) / magSq
                    t = Math.max(0, Math.min(1.0, t))

                    var projX = t * destX
                    var projY = t * destY

                    var distToLineSq = (mx - projX)*(mx - projX) + (my - projY)*(my - projY)

                    if (distToLineSq > 14400*s*s) {
                        fail(); return
                    }

                    if (t > ballProgress) {
                        ballProgress = t
                        sBall.x = projX
                        sBall.y = projY
                    }

                    if (ballProgress >= 0.99) {
                        finish()
                    }
                }
            }

            property real ballProgress: 0

            function tryHit() {
                if (!hit && !missed) {
                    hit = true; lT.stop();
                    sliding = true
                    ballProgress = 0
                }
            }
            function fail() { sliding = false; missed = true; missSignal(); Qt.callLater(destroy) }
            function finish() { if(!missed && sliding) { sliding=false; completed=true; sliderCompleted(); Qt.callLater(destroy) } }
        }
    }

    // Feedback Text
    Component {
        id: feedbackComp
        Text {
            id: fbText
            property string msg: "300"
            property color col: "white"
            text: msg; color: col
            font.family: mainFont.name; font.pixelSize: 36*s; font.weight: Font.Black
            layer.enabled: true
            layer.effect: DropShadow { color: Qt.rgba(col.r, col.g, col.b, 0.6); radius: 10; samples: 15 }

            NumberAnimation on y   { from: y;       to: y - 60*s; duration: 700; easing.type: Easing.OutCubic }
            NumberAnimation on opacity { from: 1.0; to: 0.0;      duration: 700; easing.type: Easing.InCubic }
            onOpacityChanged: if (opacity <= 0.01) fbText.destroy()
        }
    }

    // Ripple Effect
    Component {
        id: rippleComp
        Rectangle {
            id: rip
            width: 80*s; height: 80*s; radius: 40*s
            color: "transparent"; border.color: root.glowColor; border.width: 5*s
            NumberAnimation on scale   { from: 1.0; to: 2.5; duration: 400; easing.type: Easing.OutQuad }
            NumberAnimation on opacity { from: 0.9; to: 0.0; duration: 400; easing.type: Easing.OutQuad }
            onOpacityChanged: if (opacity <= 0.01) rip.destroy()
        }
    }

    // Game Logic
    readonly property real margin: 100 * s

    property int patternStep: 0
    readonly property var spawnPattern: [450, 350, 600, 250, 450, 800, 300, 500, 200, 400, 350, 700, 400, 300, 500, 750]

    // Screen Shake
    SequentialAnimation {
        id: gameShake
        property real intensity: 5*s
        NumberAnimation { target: gameArea; property: "anchors.horizontalCenterOffset"; from: -intensity; to: intensity; duration: 30 }
        NumberAnimation { target: gameArea; property: "anchors.horizontalCenterOffset"; from: intensity; to: -intensity; duration: 30 }
        NumberAnimation { target: gameArea; property: "anchors.horizontalCenterOffset"; to: 0; duration: 30 }
    }

    // HP Drain
    Timer {
        id: hpDrainTimer
        interval: 100; repeat: true; running: root.gameActive && !root.osuFailed
        onTriggered: {
            var drainRate = 0.0025 + (Math.min(100, root.osuCombo) * 0.0001)
            root.osuHealth = Math.max(0, root.osuHealth - drainRate)
            if (root.osuHealth <= 0.001) failSequence.start()
        }
    }

    Timer {
        id: circleSpawnTimer
        interval: 1000
        repeat: true
        running: false
        onTriggered: {
            if (!root.gameActive) { stop(); return }
            if (root.osuHits >= settings.requiredHits) { stop(); return }
            spawnCircle()

            var comboDensityBonus = 1.0 + Math.min(0.4, root.osuCombo * 0.015)
            var baseInterval = root.spawnPattern[root.patternStep % root.spawnPattern.length]
            var nextInterval = baseInterval / (settings.osuDensity * comboDensityBonus)

            root.patternStep++
            interval = Math.max(150, nextInterval)
            restart()
        }
    }

    Timer {
        id: gameStartDelay
        interval: 600
        onTriggered: {
            patternStep = 0
            circleSpawnTimer.interval = 1000
            circleSpawnTimer.start()
            spawnCircle()
        }
    }

    // Win Check
    Timer {
        id: winCheckTimer
        interval: 200; repeat: true; running: false
        onTriggered: {
            if (root.osuHits >= settings.requiredHits) {
                stop()
                circleSpawnTimer.stop()
                winSequence.start()
            }
        }
    }

    SequentialAnimation {
        id: winSequence
        PauseAnimation { duration: 500 }
        ScriptAction {
            script: {
                root.loginSuccess = true
                loginTransition.start()
            }
        }
        PauseAnimation { duration: 600 }
        ScriptAction {
            script: {
                var uname = (userHelper.currentItem && userHelper.currentItem.uLogin)
                            ? userHelper.currentItem.uLogin : userModel.lastUser
                sddm.login(uname, passField.text, root.sessionIndex)
            }
        }
    }

    // Win Flash
    Rectangle {
        id: winFlash
        anchors.fill: parent; color: root.accentColor; z: 9999
        opacity: 0
        NumberAnimation { id: loginTransition; target: winFlash; property: "opacity"; from: 0; to: 1; duration: 600; easing.type: Easing.OutQuad }
    }

    function spawnCircle() {
        if (!root.gameActive) return
        root.osuCircleCount++
        if (root.osuCircleCount > 12) root.osuCircleCount = 1

        var margin = 120 * s
        var cx = 0, cy = 0
        var foundPos = false
        var attempts = 0

        while (!foundPos && attempts < 15) {
            cx = margin + Math.random() * (root.width - margin * 2)
            cy = margin + Math.random() * (root.height - margin * 2)
            cy = Math.max(120*s, Math.min(root.height - 150*s, cy))

            var collision = false
            for (var i = 0; i < root.activeCircles.length; i++) {
                var other = root.activeCircles[i]
                var ox = other.x + 40*s
                var oy = other.y + 40*s
                var distSq = (cx - ox)*(cx - ox) + (cy - oy)*(cy - oy)
                if (distSq < (150*s * 150*s)) {
                    collision = true
                    break
                }
            }
            if (!collision) foundPos = true
            attempts++
        }

        var comboSpeedBonus = 1.0 + Math.min(0.5, root.osuCombo * 0.02)
        var densityBonus = 1.0 + (root.activeCircles.length * 0.12)
        var lifetime = (2100 + Math.random() * 700) / (settings.osuSpeed * comboSpeedBonus) * densityBonus

        var isSlider = Math.random() < settings.sliderChance
        var circle;

        if (isSlider) {
            var dist = 80*s + Math.random() * 320*s
            var ang = Math.random() * Math.PI * 2
            var sdx = Math.cos(ang) * dist
            var sdy = Math.sin(ang) * dist
            var ex = Math.max(margin, Math.min(root.width - margin, cx + sdx))
            var ey = Math.max(80*s, Math.min(root.height - 100*s, cy + sdy))

            circle = sliderComp.createObject(gameArea, {
                sx: cx, sy: cy, ex: ex, ey: ey,
                circleNum: root.osuCircleCount,
                lifetime: lifetime, approachDuration: lifetime,
                slideDuration: 1000 / settings.osuSpeed
            })
        } else {
            circle = hitCircleComp.createObject(gameArea, { x: cx - 40*s, y: cy - 40*s, circleNum: root.osuCircleCount, lifetime: lifetime, approachDuration: lifetime });
        }

        if (circle) {
            root.activeCircles.push(circle)

            circle.hitSignal.connect(function(acc) {
                onCircleHit(acc, circle.x + 40*s, circle.y + 40*s)
                var idx = root.activeCircles.indexOf(circle)
                if (idx >= 0) root.activeCircles.splice(idx, 1)
            })

            circle.missSignal.connect(function() {
                onCircleMiss(circle.x + 40*s, circle.y + 40*s)
                var idx = root.activeCircles.indexOf(circle)
                if (idx >= 0) root.activeCircles.splice(idx, 1)
            })

            if (isSlider) {
                circle.sliderCompleted.connect(function() {
                    onCircleHit(1.0, circle.sx + circle.destX, circle.sy + circle.destY)
                })
            }
        }
    }

    function onCircleHit(acc, cx, cy) {
        root.osuHits++
        root.osuCombo++
        root.osuHealth = Math.min(1.0, root.osuHealth + 0.06)
        if (root.osuCombo > root.osuMaxCombo) root.osuMaxCombo = root.osuCombo

        gameShake.intensity = Math.min(12, 4 + root.osuCombo * 0.15)
        gameShake.restart()

        var pts = 0
        var label = ""

        if (acc > 0.8) {
            pts = 300; label = "300"
        } else if (acc > 0.5) {
            pts = 100; label = "100"
        } else {
            pts = 50;  label = "50"
        }

        root.osuScore += pts * root.osuCombo
        updateAccuracy()
        comboPopAnim.restart()

        rippleComp.createObject(gameArea, { x: cx - 40*s, y: cy - 40*s })

        var col = pts === 300 ? root.accentColor : (pts === 100 ? root.glowColor : "#aaaaaa")
        feedbackComp.createObject(gameArea, {
            x: cx - 30*s,
            y: cy - 40*s,
            msg: label,
            col: col
        })
    }

    function onCircleMiss(cx, cy) {
        root.osuCombo = 0
        root.osuMisses++
        root.osuHealth = Math.max(0, root.osuHealth - 0.18)
        updateAccuracy()
        comboBreakAnim.restart()

        gameShake.intensity = 15*s
        gameShake.restart()

        if (root.osuHealth <= 0.01 && !root.osuFailed) {
            failSequence.start()
        }

        feedbackComp.createObject(gameArea, {
            x: cx - 30*s,
            y: cy - 40*s,
            msg: "✕",
            col: "#ff4455"
        })
    }

    SequentialAnimation {
        id: failSequence
        ScriptAction { script: { root.osuFailed = true; circleSpawnTimer.stop() } }
        ParallelAnimation {
            NumberAnimation { target: gameScreen; property: "opacity"; to: 0; duration: 500 }
            NumberAnimation { target: failOverlay; property: "opacity"; to: 1; duration: 200 }
        }
        PauseAnimation { duration: 1000 }
        ScriptAction { script: { resetGame() } }
        NumberAnimation { target: failOverlay; property: "opacity"; to: 0; duration: 300 }
    }

    Rectangle {
        id: failOverlay
        anchors.fill: parent; color: "#aa000000"; opacity: 0; z: 10000
        Text {
            anchors.centerIn: parent; text: "FAILED"; color: "#ff4444"
            font.family: mainFont.name; font.pixelSize: 80*s; font.weight: Font.Black; font.italic: true
        }
    }

    function resetGame() {
        root.gameActive = false
        root.osuFailed = false
        root.osuHealth = 1.0
        root.osuHits = 0
        root.osuMisses = 0
        root.osuCombo = 0
        root.osuScore = 0
        root.osuAccuracy = 100.0
        root.osuCircleCount = 0
        root.activeCircles = []
        passField.text = ""
        passField.forceActiveFocus()
    }

    function updateAccuracy() {
        var total = root.osuHits + root.osuMisses
        if (total === 0) { root.osuAccuracy = 100.0; return }
        root.osuAccuracy = (root.osuHits / total) * 100.0
    }

    function tryHitAt(hx, hy) {
        var hitTolerance = 52 * s;
        for (var i = 0; i < root.activeCircles.length; i++) {
            var c = root.activeCircles[i];
            if (!c.hit && !c.missed) {
                var dx = (c.x + 40*s) - hx;
                var dy = (c.y + 40*s) - hy;
                if (dx*dx + dy*dy < hitTolerance * hitTolerance) {
                    if (typeof c.tryHit === "function") {
                        c.tryHit();
                    } else {
                        c.hit = true;
                        onCircleHit(0.9, c.x + 40*s, c.y + 40*s);
                        c.opacity = 0;
                        Qt.callLater(function() { c.destroy(); });
                    }
                    var idx = root.activeCircles.indexOf(c);
                    if (idx >= 0) root.activeCircles.splice(idx, 1);
                    return;
                }
            }
        }
    }

    function doAction() {
        if (root.gameMode) {
            startGame()
        } else {
            doLogin()
        }
    }

    function doLogin() {
        errorMsg.text = ""
        root.loginPending = true
        var uname = (userHelper.currentItem && userHelper.currentItem.uLogin)
                    ? userHelper.currentItem.uLogin : userModel.lastUser
        sddm.login(uname, passField.text, root.sessionIndex)
    }

    function startGame() {
        errorMsg.text = ""
        root.osuScore = 0
        root.osuCombo = 0
        root.osuMaxCombo = 0
        root.osuHits = 0
        root.osuMisses = 0
        root.osuAccuracy = 100.0
        root.osuCircleCount = 0
        root.activeCircles = []
        root.patternStep = 0
        root.gameActive = true
        gameStartDelay.start()
        winCheckTimer.start()
    }

    // Login Failed
    Connections {
        target: sddm
        function onLoginFailed() {
            root.gameActive = false
            root.loginSuccess = false
            circleSpawnTimer.stop()
            gameStartDelay.stop()
            winCheckTimer.stop()
            winSequence.stop()

            winFlash.opacity = 0
            root.activeCircles = []

            errorMsg.text = "✖  WRONG PASSWORD — TRY AGAIN"
            passField.text = ""
            passField.forceActiveFocus()

            errorShake.restart()
        }
    }

    SequentialAnimation {
        id: errorShake
        NumberAnimation { target: errorMsg; property: "anchors.rightMargin"; from: -8*s; to: 8*s; duration: 60 }
        NumberAnimation { target: errorMsg; property: "anchors.rightMargin"; from: 8*s; to: -6*s; duration: 60 }
        NumberAnimation { target: errorMsg; property: "anchors.rightMargin"; from: -6*s; to: 4*s; duration: 60 }
        NumberAnimation { target: errorMsg; property: "anchors.rightMargin"; to: 0;          duration: 60 }
    }

}