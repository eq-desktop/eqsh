//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
import QtQuick
import QtQuick.Controls
import qs.config
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.VectorImage
import Quickshell
import qs
import qs.ui.components.settings.pages
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.ui.controls.primitives
import Quickshell.Io
import Quickshell.Widgets

FloatingWindow {
    id: settingsApp
    visible: Runtime.settingsOpen
    title: Translation.tr("Equora Settings")
    minimumSize: "675x540"
    maximumSize: Qt.size(675, screen.height-Config.bar.height)
    
    onClosed: {
        Runtime.settingsOpen = false
    }

    IpcHandler {
        id: ipcHandler
        target: "settings"
        function toggle() {
            Runtime.settingsOpen = !Runtime.settingsOpen;
        }
    }

    CustomShortcut {
        name: "settings"
        description: "Toggle Settings"
        onPressed: {
            Runtime.settingsOpen = !Runtime.settingsOpen;
        }
    }

    color: "transparent"

    component UILabel: Text {
        color: Config.general.darkMode ? "#fff" : "#000"
        font.pixelSize: 16
    }

    component UITextField: TextField {
        color: Config.general.darkMode ? "#fff" : "#000"
        font.pixelSize: 16
        Layout.minimumWidth: 250
        background: Rectangle {
            anchors.fill: parent
            color: Config.general.darkMode ? "#2a2a2a" : "#fefefe"
            border {
                width: 1
                color: "#aaa"
            }
            radius: 10
        }
    }

    component UICheckBox: CFCheckBox {
    }

    RowLayout {
        anchors.fill: parent

        Item {
            id: sidebarView
            Layout.fillHeight: true
            height: parent.height
            width: 250
            Layout.margins: -10

            RoundedCorner {
                anchors {
                    right: parent.right
                    top: parent.top
                    topMargin: 10
                }
                corner: RoundedCorner.CornerEnum.TopRight
                color: Config.general.darkMode ? "#1e1e1e": "#ffffff"
                implicitSize: 40
            }

            RoundedCorner {
                anchors {
                    right: parent.right
                    bottom: parent.bottom
                    bottomMargin: 10
                }
                corner: RoundedCorner.CornerEnum.BottomRight
                color: Config.general.darkMode ? "#1e1e1e": "#ffffff"
                implicitSize: 40
            }

            Rectangle {
                id: sidebarBackgroundBorder
                anchors.fill: parent
                anchors.margins: 5
                clip: true
                radius: 30
                color: Config.general.darkMode ? "#a0111111" : "#a0ffffff"
                border {
                    width: 10
                    color: Config.general.darkMode ? "#1e1e1e": "#ffffff"
                }
            }
            
            Rectangle {
                id: sidebarBackground
                anchors.fill: parent
                anchors.margins: 15
                clip: true
                radius: 20
                color: Config.general.darkMode ? "#ee2a2a2a" : "#ccfefefe"
                border {
                    width: 1
                    color: Config.general.darkMode ? "#ee3a3a3a" : "#ccffffff"
                }

                Item {
                    id: searchBar
                    height: 25
                    width: 220
                    z: 2
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.topMargin: 20
                    UITextField {
                        id: searchField
                        width: 200
                        anchors.left: parent.left
                        anchors.leftMargin: 10
                        anchors.top: parent.top
                        background: Rectangle {
                            anchors.fill: parent
                            color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
                            radius: 20
                            border {
                                width: 1
                                color: "#55aaaaaa"
                            }
                            Text {
                                anchors.fill: parent
                                text: searchField.text == "" ? Translation.tr("Search") : ""
                                color: Config.general.darkMode ? "#aaa" : "#555"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                anchors.leftMargin: 10
                            }
                        }
                    }
                }

                // Sidebar
                ListView {
                    id: sidebar
                    width: 220
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: searchBar.bottom
                    anchors.topMargin: 20
                    height: parent.height - 75
                    model: [
                        "_Account",
                        "",
                        Translation.tr("General"),
                        Translation.tr("Appearance"),
                        Translation.tr("Menu Bar"),
                        Translation.tr("Wallpaper"),
                        Translation.tr("Notifications"),
                        Translation.tr("Dialogs"),
                        Translation.tr("Notch"),
                        Translation.tr("Launchpad"),
                        Translation.tr("Lockscreen"),
                        Translation.tr("Widgets"),
                        Translation.tr("Osd")
                    ]
                    component SidebarItem: Button {
                        text: ""
                        height: 35
                        anchors.topMargin: 20
                        background: Rectangle {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            color: contentView.currentIndex == index ? (modelData == "_Account" ? "transparent" : AccentColor.color) : "transparent"
                            radius: 10
                            ClippingRectangle {
                                id: imageContainer
                                width: modelData == "_Account" ? 28 : 24
                                height: modelData == "_Account" ? 28 : 24
                                radius: modelData == "_Account" ? 50 : 0
                                color: "transparent"
                                clip: true
                                anchors.left: parent.left
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.leftMargin: modelData == "_Account" ? 5 : 10

                                property list<string> svgs: [
                                    "",
                                    "general",
                                    "appearance",
                                    "menu bar",
                                    "wallpaper",
                                    "notifications",
                                    "dialogs",
                                    "notch",
                                    "launchpad",
                                    "lockscreen",
                                    "widgets",
                                    "osd"
                                ]

                                Image {
                                    anchors.fill: parent
                                    source: modelData == "" ? "" : modelData == "_Account" ? Config.account.avatarPath : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/settings/" + imageContainer.svgs[index-1] + ".svg")
                                    fillMode: Image.PreserveAspectCrop
                                }
                            }
                            Text {
                                anchors.fill: parent
                                text: modelData == "_Account" ? Config.account.name : modelData
                                color: Config.general.darkMode ? (contentView.currentIndex == index && modelData != "_Account" ? AccentColor.textColor : "#fff") : (contentView.currentIndex == index && modelData != "_Account" ? AccentColor.textColor : "#000")
                                font.pixelSize: 14
                                font.weight: modelData == "_Account" ? 500 : Font.Normal
                                verticalAlignment: modelData == "_Account" ? Text.AlignTop : Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                anchors.leftMargin: modelData == "_Account" ? 50 : 45
                            }
                            Text {
                                anchors.fill: parent
                                visible: modelData == "_Account"
                                text: Translation.tr("Equora Account")
                                color: Config.general.darkMode ? "#ddd" :"#000"
                                font.pixelSize: 12
                                font.weight: 400
                                verticalAlignment: Text.AlignBottom
                                horizontalAlignment: Text.AlignLeft
                                anchors.leftMargin: modelData == "_Account" ? 50 : 45
                            }
                        }
                        onClicked: {
                            if (modelData == "") return
                            contentView.currentIndex = index
                        }
                    }
                    delegate: SidebarItem {
                        width: parent.width
                    }
                } 
            }
        }

        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                anchors.fill: parent
                color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
            }

            Rectangle {
                id: pageTitle
                height: 50
                width: parent.width
                color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
                radius: 0
                RectangularShadow {
                    anchors.fill: pageControl
                    color: "#20000000"
                    radius: 20
                    blur: 20
                    spread: 5
                }
                Rectangle {
                    id: pageControl
                    height: 38
                    width: 80
                    radius: 20
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
                    Rectangle {
                        width: 1
                        height: 20
                        anchors.centerIn: parent
                        color: "#10000000"
                    }
                    VectorImage {
                        source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-left-bold.svg")
                        anchors.left: parent.left
                        anchors.leftMargin: 5
                        width: 30
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: 1
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1
                            colorizationColor: Config.general.darkMode ? "#fff" : "#333"
                        }
                    }
                    VectorImage {
                        source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-right-bold.svg")
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        width: 30
                        height: 30
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: 0.2
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            colorization: 1
                            colorizationColor: Config.general.darkMode ? "#fff" : "#333"
                        }
                    }
                }
                Text {
                    anchors.left: pageControl.right
                    anchors.leftMargin: 15
                    anchors.verticalCenter: parent.verticalCenter
                    verticalAlignment: Text.AlignVCenter
                    text: contentView.currentIndex == 0 ? "Account" : sidebar.model[contentView.currentIndex]
                    color: Config.general.darkMode ? "#fff" : "#555"
                    font.weight: 700
                    font.pixelSize: 14
                }
                Rectangle {
                    height: 0.5
                    width: parent.width+10
                    anchors.left: parent.left
                    anchors.leftMargin: -10
                    anchors.bottom: parent.bottom
                    color: "#55aaaaaa"
                }
            }

            // Content area
            StackLayout {
                id: contentView
                anchors.top: pageTitle.bottom
                anchors.left: parent.left
                anchors.leftMargin: -10
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 0
                width: parent.width
                height: parent.height - 75
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                Account {}
                // Space
                ScrollView {}
                General {}
                Appearance {}

                MenuBar {}

                // Wallpaper
                Wallpaper {}

                // Notifications
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UILabel { text: Translation.tr("Nothing here yet :(") }
                    }
                }

                // Dialogs
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: Translation.tr("Enable Dialogs")
                            checked: Config.dialogs.enable
                            onToggled: Config.dialogs.enable = checked
                        }
                        UILabel { text: Translation.tr("Width") }
                        SpinBox {
                            value: Config.dialogs.width
                            onValueModified: Config.dialogs.width = value
                            from: 100; to: 600
                        }
                        UILabel { text: Translation.tr("Height") }
                        SpinBox {
                            value: Config.dialogs.height
                            onValueModified: Config.dialogs.height = value
                            from: 100; to: 600
                        }
                    }
                }

                // Notch
                ScrollView {
                    ColumnLayout {
                        id: notchView
                        anchors.fill: parent
                        UICheckBox {
                            textVal: Translation.tr("Enable Notch")
                            checked: Config.notch.enable
                            onToggled: Config.notch.enable = checked
                        }
                        //UILabel { text: Translation.tr("Island mode") }
                        //property var notchOptions: ["Dynamic Island", "Notch"]
                        //ComboBox {
                        //    model: notchView.notchOptions.map(Translation.tr)
                        //    Component.onCompleted: {
                        //        currentIndex = Config.notch.islandMode ? 0 : 1
                        //    }
                        //    onCurrentIndexChanged: {
                        //        Config.notch.islandMode = (currentIndex == 0)
                        //    }
                        //}
                        UILabel { text: Translation.tr("Background color") }
                        Button {
                            text: Translation.tr("Set Color")
                            onClicked: colorDialog.open()
                        }
                        ColorDialog {
                            id: colorDialog
                            selectedColor: Config.notch.backgroundColor
                            onAccepted: Config.notch.backgroundColor = selectedColor
                        }
                        UILabel { text: Translation.tr("Visual-Only mode") }
                        ComboBox {
                            model: [Translation.tr("No"), Translation.tr("Yes")]
                            currentIndex: Config.notch.onlyVisual ? 1 : 0
                            onCurrentIndexChanged: Config.notch.onlyVisual = currentIndex == 1
                        }
                        UILabel { text: Translation.tr("Signature") }
                        UITextField {
                            text: Config.notch.signature
                            onEditingFinished: Config.notch.signature = text
                        }
                        UILabel { text: Translation.tr("Auto hide") }
                        ComboBox {
                            model: [Translation.tr("No"), Translation.tr("Yes")]
                            currentIndex: Config.notch.autohide ? 1 : 0
                            onCurrentIndexChanged: Config.notch.autohide = currentIndex == 1
                        }
                    }
                }

                // Launchpad
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: Translation.tr("Enable Launchpad")
                            checked: Config.launchpad.enable
                            onToggled: Config.launchpad.enable = checked
                        }
                    }
                }

                // Lockscreen
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: Translation.tr("Enable Lockscreen")
                            checked: Config.lockScreen.enable
                            onToggled: Config.lockScreen.enable = checked
                        }
                        UILabel { text: Translation.tr("Date Format") }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.lockScreen.dateFormat
                            onEditingFinished: Config.lockScreen.dateFormat = text
                        }
                        UILabel { text: Translation.tr("Time Format") }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.lockScreen.timeFormat
                            onEditingFinished: Config.lockScreen.timeFormat = text
                        }
                        UILabel { text: Translation.tr("Blur Lockscreen") }
                        ComboBox {
                            model: [Translation.tr("No"), Translation.tr("Yes")]
                            currentIndex: Config.lockScreen.blur ? 1 : 0
                            onCurrentIndexChanged: Config.lockScreen.blur = currentIndex == 1
                        }
                        UILabel { text: Translation.tr("Avatar Size") }
                        SpinBox {
                            value: Config.lockScreen.avatarSize
                            onValueModified: Config.lockScreen.avatarSize = value
                            from: 0; to: 100
                        }
                        UILabel { text: Translation.tr("User Note") }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.lockScreen.userNote
                            onEditingFinished: Config.lockScreen.userNote = text
                        }
                        UICheckBox {
                            textVal: Translation.tr("Custom Background")
                            checked: Config.lockScreen.useCustomWallpaper
                            onToggled: Config.lockScreen.useCustomWallpaper = checked
                        }
                        UITextField {
                            visible: Config.lockScreen.useCustomWallpaper
                            Layout.fillWidth: true
                            text: Config.lockScreen.customWallpaperPath
                            onEditingFinished: Config.lockScreen.customWallpaperPath = text
                        }
                    }
                }

                // Widgets
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: Translation.tr("Enable Widgets")
                            checked: Config.widgets.enable
                            onToggled: Config.widgets.enable = checked
                        }
                        UILabel { text: Translation.tr("Location") }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.widgets.location
                            onEditingFinished: Config.widgets.location = text
                        }
                        CFButton {
                            text: Translation.tr("Edit Widgets")
                            onClicked: {
                                Runtime.widgetEditMode = true
                                Runtime.settingsOpen = false
                            }
                        }
                    }
                }

                // Osd
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: Translation.tr("Enable OSD")
                            checked: Config.osd.enable
                            onToggled: Config.osd.enable = checked
                        }
                        UILabel { text: Translation.tr("Animation") }
                        ComboBox {
                            model: [Translation.tr("Scale"), Translation.tr("Fade"), Translation.tr("Bubble")]
                            currentIndex: Config.osd.animation - 1
                            onCurrentIndexChanged: Config.osd.animation = currentIndex + 1
                        }
                        UILabel { text: Config.osd.animation }
                    }
                }
            }
        }
    }
}
