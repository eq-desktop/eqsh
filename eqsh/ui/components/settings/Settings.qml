import QtQuick
import QtQuick.Controls
import qs.Config
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects
import Quickshell
import qs
import qs.ui.Controls.providers
import Quickshell.Io
import Quickshell.Widgets

FloatingWindow {
    id: settingsApp
    visible: Runtime.settingsOpen
    title: "eqSh Settings"
    minimumSize: "675x540"
    
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

    color: Config.general.darkMode ? "#1a1a1a" : "#fefefe"

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

    component UICheckBox: CheckBox {
        property string textVal: ""
        text: `<font color=\"${Config.general.darkMode ? '#fff' : '#000'}\">${textVal}</font>`
        font.pixelSize: 16
    }

    RowLayout {
        anchors.fill: parent

        Item {
            id: sidebarView
            Layout.fillHeight: true
            height: parent.height
            width: 200
            scale: 0.99
            Behavior on scale {
                NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 4 }
            }
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: {
                    sidebarView.scale = 1
                }
                onExited: {
                    sidebarView.scale = 0.99
                }
                Rectangle {
                    id: sidebarBackground
                    anchors.fill: parent
                    anchors.margins: 5
                    clip: true
                    radius: 15
                    color: Config.general.darkMode ? "#111" : "#fff"
                    border {
                        width: 1
                        color: "#55333333"
                    }

                    Item {
                        id: searchBar
                        height: 30
                        width: 170
                        z: 2
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: 20
                        UITextField {
                            id: searchField
                            width: 170
                            anchors.left: parent.left
                            anchors.top: parent.top
                            background: Rectangle {
                                anchors.fill: parent
                                color: Config.general.darkMode ? "#ee1a1a1a" : "#eefefefe"
                                radius: 10
                                border {
                                    width: 1
                                    color: "#55aaaaaa"
                                }
                                Text {
                                    anchors.fill: parent
                                    text: searchField.text == "" ? "Search" : ""
                                    color: "#aaa"
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
                        width: 170
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: searchBar.bottom
                        anchors.topMargin: 20
                        height: parent.height - 75
                        model: [
                            "_Account",
                            "",
                            "General",
                            "Appearance",
                            "Menu Bar",
                            "Wallpaper",
                            "Notifications",
                            "Dialogs",
                            "Notch",
                            "Launchpad",
                            "Lockscreen",
                            "Widgets",
                            "Osd"
                        ]
                        component SidebarItem: Button {
                            text: ""
                            height: 35
                            anchors.topMargin: 20
                            background: Rectangle {
                                anchors.fill: parent
                                color: contentView.currentIndex == index ? (modelData == "_Account" ? "transparent" : AccentColor.color) : "transparent"
                                radius: 10
                                ClippingRectangle {
                                    id: imageContainer
                                    width: modelData == "_Account" ? 34 : 24
                                    height: modelData == "_Account" ? 34 : 24
                                    radius: modelData == "_Account" ? 50 : 0
                                    color: "transparent"
                                    clip: true
                                    anchors.left: parent.left
                                    anchors.verticalCenter: parent.verticalCenter
                                    anchors.leftMargin: modelData == "_Account" ? 0 : 5

                                    Image {
                                        anchors.fill: parent
                                        source: modelData == "" ? "" : modelData == "_Account" ? Config.account.avatarPath : Qt.resolvedUrl(Quickshell.shellDir + "/Media/icons/settings/" + modelData.toLowerCase() + ".svg")
                                        fillMode: Image.PreserveAspectCrop
                                    }
                                }
                                Text {
                                    anchors.fill: parent
                                    text: modelData == "_Account" ? Config.account.name : modelData
                                    color: Config.general.darkMode ? "#fff" : "#000"
                                    font.pixelSize: 14
                                    font.weight: modelData == "_Account" ? 500 : Font.Normal
                                    verticalAlignment: modelData == "_Account" ? Text.AlignTop : Text.AlignVCenter
                                    horizontalAlignment: Text.AlignLeft
                                    anchors.leftMargin: 40
                                }
                                Text {
                                    anchors.fill: parent
                                    visible: modelData == "_Account"
                                    text: "Equora Account"
                                    color: Config.general.darkMode ? "#ddd" :"#000"
                                    font.pixelSize: 12
                                    font.weight: 400
                                    verticalAlignment: Text.AlignBottom
                                    horizontalAlignment: Text.AlignLeft
                                    anchors.leftMargin: 40
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
        }

        Item {
            id: contentArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            Rectangle {
                id: pageTitle
                height: 50
                width: parent.width
                color: Config.general.darkMode ? "#1a1a1a" : "#fefefe"
                radius: 0
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    text: contentView.currentIndex == 0 ? "Account" : sidebar.model[contentView.currentIndex]
                    color: Config.general.darkMode ? "#fff" : "#444"
                    font.weight: 600
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
                anchors.topMargin: 10
                width: parent.width - 5
                height: parent.height - 75
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: 0

                // Account
                ScrollView {
                    Rectangle {
                        anchors.fill: parent
                        color: "transparent"
                    }  
                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 20
                        width: parent.width

                        // Profile Picture
                        ClippingRectangle {
                            id: imageContainer
                            width: 120
                            height: 120
                            radius: 99
                            color: "transparent"
                            clip: true
                            Layout.alignment: Qt.AlignHCenter

                            Image {
                                anchors.fill: parent
                                source: Config.account.avatarPath
                                fillMode: Image.PreserveAspectCrop
                            }
                        }
                        UITextField {
                            background: Rectangle { color: "transparent" }
                            text: Config.account.name
                            onEditingFinished: Config.account.name = text
                            Layout.alignment: Qt.AlignHCenter
                            horizontalAlignment: Text.AlignHCenter
                        }

                        // Editable Profile Picture Path
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 4

                            UILabel { text: "Profile Picture Path" }
                            UITextField {
                                text: Config.account.avatarPath
                                onEditingFinished: Config.account.avatarPath = text
                                Layout.preferredWidth: 300
                            }
                        }

                        // Activation Key
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 4

                            UILabel { text: "Activation Key" }
                            UITextField {
                                Layout.preferredWidth: 300
                                text: Config.account.activationKey
                                onEditingFinished: Config.account.activationKey = text
                                placeholderText: "Activation Key"
                            }
                        }
                    }
                }


                // Space
                ScrollView {}

                // General
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: "Dark Mode"
                            checked: Config.general.darkMode
                            onToggled: Config.general.darkMode = checked
                        }
                        UICheckBox {
                            textVal: "Reduce Motion"
                            checked: Config.general.reduceMotion
                            onToggled: Config.general.reduceMotion = checked
                        }
                    }
                }

                // Appearance
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UILabel { text: "Icon Color Type" }
                        ComboBox {
                            model: ["Original", "Monochrome", "Tinted"]
                            currentIndex: Config.appearance.iconColorType - 1
                            onCurrentIndexChanged: Config.appearance.iconColorType = currentIndex + 1
                        }
                        UICheckBox {
                            textVal: "Use Dynamic Accent Color"
                            checked: Config.appearance.dynamicAccentColor
                            onToggled: Config.appearance.dynamicAccentColor = checked
                        }
                        UILabel { text: "Accent Color" }
                        Button {
                            text: "Set Color"
                            onClicked: colorDialog2.open()
                        }
                        ColorDialog {
                            id: colorDialog2
                            selectedColor: Config.appearance.accentColor
                            onAccepted: Config.appearance.accentColor = selectedColor
                        }
                    }
                }

                // Bar
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: "Enable Bar"
                            checked: Config.bar.enable
                            onToggled: Config.bar.enable = checked
                        }
                        UILabel { text: "Default App" }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.bar.defaultAppName
                            onEditingFinished: Config.bar.defaultAppName = text
                        }
                        UILabel { text: "Date Format" }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.bar.dateFormat
                            onEditingFinished: Config.bar.dateFormat = text
                        }
                        UILabel { text: "Auto hide" }
                        ComboBox {
                            model: ["No", "Yes"]
                            currentIndex: Config.bar.autohide ? 1 : 0
                            onCurrentIndexChanged: Config.bar.autohide = currentIndex == 1
                        }
                    }
                }

                // Wallpaper
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: "Enable Wallpaper"
                            checked: Config.wallpaper.enable
                            onToggled: Config.wallpaper.enable = checked
                        }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.wallpaper.path
                            onEditingFinished: Config.wallpaper.path = text
                            placeholderText: "Wallpaper path"
                        }
                        ComboBox {
                            id: colorCombo
                            Layout.fillWidth: true

                            model: AccentColor.colors

                            // Display text as the color name
                            textRole: "name"

                            // Use a custom delegate so each option is shown with its color
                            delegate: ItemDelegate {
                                contentItem: RowLayout {
                                    spacing: 8
                                    Label {
                                        text: modelData
                                        color: "#fff"
                                        verticalAlignment: Text.AlignVCenter
                                        background: Rectangle {
                                            anchors.fill: parent
                                            color: modelData
                                        }
                                    }
                                }
                            }

                            // keep ComboBox selection in sync with AccentColor.color
                            Component.onCompleted: {
                                let index = AccentColor.colors.findIndex(c => c === AccentColor.color)
                                if (index >= 0) currentIndex = index
                            }

                            onActivated: (index) => {
                                Config.appearance.accentColor = AccentColor.colors[index]
                            }
                        }

                    }
                }

                // Notifications
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UILabel { text: "Nothing here yet :(" }
                    }
                }

                // Dialogs
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: "Enable Dialogs"
                            checked: Config.dialogs.enable
                            onToggled: Config.dialogs.enable = checked
                        }
                        UILabel { text: "Width" }
                        SpinBox {
                            value: Config.dialogs.width
                            onValueModified: Config.dialogs.width = value
                            from: 100; to: 600
                        }
                        UILabel { text: "Height" }
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
                        anchors.fill: parent
                        UICheckBox {
                            textVal: "Enable Notch"
                            checked: Config.notch.enable
                            onToggled: Config.notch.enable = checked
                        }
                        UILabel { text: "Island mode" }
                        ComboBox {
                            model: ["Dynamic Island", "Notch"]
                            currentIndex: Config.notch.islandMode ? 0 : 1
                            onCurrentIndexChanged: Config.notch.islandMode = currentIndex == 0
                        }
                        UILabel { text: "Background color" }
                        Button {
                            text: "Set Color"
                            onClicked: colorDialog.open()
                        }
                        ColorDialog {
                            id: colorDialog
                            selectedColor: Config.notch.backgroundColor
                            onAccepted: Config.notch.backgroundColor = selectedColor
                        }
                        UILabel { text: "Visual-Only mode" }
                        ComboBox {
                            model: ["No", "Yes"]
                            currentIndex: Config.notch.onlyVisual ? 1 : 0
                            onCurrentIndexChanged: Config.notch.onlyVisual = currentIndex == 1
                        }
                        UILabel { text: "Signature" }
                        UITextField {
                            text: Config.notch.signature
                            onEditingFinished: Config.notch.signature = text
                        }
                        UILabel { text: "Auto hide" }
                        ComboBox {
                            model: ["No", "Yes"]
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
                            textVal: "Enable Launchpad"
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
                            textVal: "Enable Lockscreen"
                            checked: Config.lockScreen.enable
                            onToggled: Config.lockScreen.enable = checked
                        }
                        UILabel { text: "Date Format" }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.lockScreen.dateFormat
                            onEditingFinished: Config.lockScreen.dateFormat = text
                        }
                        UILabel { text: "Time Format" }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.lockScreen.timeFormat
                            onEditingFinished: Config.lockScreen.timeFormat = text
                        }
                        UILabel { text: "Blur Lockscreen" }
                        ComboBox {
                            model: ["No", "Yes"]
                            currentIndex: Config.lockScreen.blur ? 1 : 0
                            onCurrentIndexChanged: Config.lockScreen.blur = currentIndex == 1
                        }
                        UILabel { text: "Avatar Size" }
                        SpinBox {
                            value: Config.lockScreen.avatarSize
                            onValueModified: Config.lockScreen.avatarSize = value
                            from: 0; to: 100
                        }
                        UILabel { text: "User Note" }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.lockScreen.userNote
                            onEditingFinished: Config.lockScreen.userNote = text
                        }
                        UICheckBox {
                            textVal: "Custom Background"
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
                            textVal: "Enable Widgets"
                            checked: Config.widgets.enable
                            onToggled: Config.widgets.enable = checked
                        }
                        UILabel { text: "Location" }
                        UITextField {
                            Layout.fillWidth: true
                            text: Config.widgets.location
                            onEditingFinished: Config.widgets.location = text
                        }
                    }
                }

                // Osd
                ScrollView {
                    ColumnLayout {
                        anchors.fill: parent
                        UICheckBox {
                            textVal: "Enable OSD"
                            checked: Config.osd.enable
                            onToggled: Config.osd.enable = checked
                        }
                        UILabel { text: "Animation" }
                        ComboBox {
                            model: ["Scale", "Fade", "Bubble"]
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
