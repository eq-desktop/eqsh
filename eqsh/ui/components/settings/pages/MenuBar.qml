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
import qs.ui.controls.auxiliary.settings
import Quickshell.Io
import Quickshell.Widgets
ScrollView {
    id: root
    Layout.fillWidth: true
    width: parent.width
    ColumnLayout {
        width: parent.width
        anchors.fill: parent
        anchors.margins: 0
        SettingsSection {
            id: barSettings
            title: ""
            z: 100
            SettingsColumn {
                CFSwitch {
                    id: barSwitch
                    checked: Config.bar.enable
                    onClicked: {
                        Config.bar.enable = checked
                    }
                    text: Translation.tr("Enable Menu Bar")
                }
                CFText { text: Translation.tr("Default App Name"); font.weight: 600 }
                Item {
                    id: editableName
                    Layout.minimumWidth: 100
                    Layout.maximumWidth: 200
                    Layout.preferredWidth: nameEdit.contentWidth + 20
                    Layout.alignment: Qt.AlignVCenter
                    implicitHeight: 30

                    property bool editing: false

                    CFTextField {
                        id: nameEdit
                        visible: true
                        text: Config.bar.defaultAppName
                        anchors.fill: parent
                        height: 39
                        anchors.margins: 0
                        font.pixelSize: 12
                        font.weight: 700
                        padding: 0
                        leftPadding: 10
                        rightPadding: 10
                        color: "#fff"
                        backgroundColor: "#2a2a2a"
                        horizontalAlignment: Text.AlignHCenter
                        focus: editableName.editing
                        onEditingFinished: {
                            Config.bar.defaultAppName = text
                            editableName.editing = false
                            focus = false
                        }
                        Keys.onReturnPressed: {
                            Config.bar.defaultAppName = text
                            editableName.editing = false
                            focus = false
                        }
                        onFocusChanged: if (!focus && editableName.editing) editableName.editing = false
                    }
                    Rectangle {
                        id: suggestionBox
                        visible: nameEdit.focus
                        width: 100
                        height: 150
                        anchors.top: nameEdit.bottom
                        anchors.horizontalCenter: nameEdit.horizontalCenter
                        anchors.topMargin: 10
                        color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
                        radius: 15
                        border.color: "#444"
                        border.width: 1
                        z: 1000

                        ScrollView {
                            id: scrollView
                            anchors.fill: parent
                            ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                            Column {
                                spacing: 0
                                anchors.fill: parent
                                anchors.margins: 0

                                Repeater {
                                    model: ["Finder", "Aureli", "Equora", "Arch", "NixOS", "Fedora", "Manjaro", "CentOS", "Debian", "Lubuntu", "Linux Mint", "Ubuntu", "Kali", "Windows", "Linux"]
                                    delegate: Item {
                                        width: parent.width
                                        height: 22
                                        Rectangle {
                                            id: item
                                            anchors.fill: parent
                                            anchors.topMargin: 2
                                            anchors.bottomMargin: 2
                                            anchors.leftMargin: 4
                                            anchors.rightMargin: 4
                                            radius: 15
                                            color: hovered ? AccentColor.color : "transparent"

                                            property bool hovered: false
                                            CFText {
                                                text: modelData
                                                anchors.verticalCenter: parent.verticalCenter
                                                anchors.left: parent.left
                                                anchors.leftMargin: 6
                                                font.pixelSize: 12
                                                noAnimate: true
                                                color: item.hovered ? AccentColor.textColor : (Config.general.darkMode ? "#fff" : "#000")
                                            }

                                            MouseArea {
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                onEntered: parent.hovered = true
                                                onExited: parent.hovered = false
                                                onClicked: {
                                                    nameEdit.text = modelData
                                                    nameEdit.focus = false
                                                    Config.bar.defaultAppName = modelData
                                                    editableName.editing = false
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                CFSwitch {
                    id: autohideSwitch
                    checked: Config.bar.autohide
                    onClicked: {
                        Config.bar.autohide = checked
                    }
                    text: Translation.tr("Enable Autohide")
                }
            }
        }

        SettingsSection {
            title: Translation.tr("Modules")
            SettingsColumn {
                component MenuBarModule: Item {
                    id: moduleSettings
                    property bool enabled: Config.bar.rightBarItems.indexOf(moduleSettings.modelData.id) !== -1
                    height: 40
                    width: 410
                    CFSwitch {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        checked: Config.bar.rightBarItems.indexOf(moduleSettings.modelData.id) !== -1
                        onToggled: {
                            const id = moduleSettings.modelData.id
                            const forcedIndex = moduleSettings.modelData.index
                            let list = [...Config.bar.rightBarItems]

                            const i = list.indexOf(id)

                            if (checked) {
                                if (i === -1) {
                                    if (forcedIndex !== undefined)
                                        list.splice(forcedIndex, 0, id)
                                    else
                                        list.push(id)
                                }
                            } else {
                                if (i !== -1)
                                    list.splice(i, 1)
                            }

                            Config.bar.rightBarItems = list
                        }
                    }
                    CFText {
                        anchors.left: iconLoader.right
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        text: moduleSettings.modelData.name
                        font.weight: 600
                    }
                    Component {
                        id: cI
                        CFI {
                            id: iconPng
                            visible: moduleSettings.modelData.icon.endsWith(".png")
                            icon: "../icons/settings/menubar/"+moduleSettings.modelData.icon
                            colorized: false
                        }
                    }
                    Component {
                        id: cVI
                        CFVI {
                            id: icon
                            visible: moduleSettings.modelData.icon.endsWith(".svg")
                            icon: "settings/menubar/"+moduleSettings.modelData.icon
                            colorized: false
                        }
                    }
                    Loader {
                        id: iconLoader
                        width: 30
                        height: 30
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        active: true
                        sourceComponent: moduleSettings.modelData.icon.endsWith(".svg") ? cVI : cI
                    }
                }
                Repeater {
                    model: [{
                        name: "System tray",
                        index: 0,
                        icon: "systemTray.svg",
                        id: "systemTray"
                    }, {
                        name: "Wifi",
                        index: -1,
                        icon: "wifi.svg",
                        id: "wifi"
                    }, {
                        name: "Battery",
                        index: -1,
                        icon: "battery.svg",
                        id: "battery"
                    }, {
                        name: "Spotlight",
                        index: -1,
                        icon: "search.svg",
                        id: "search"
                    }, {
                        name: "Bluetooth",
                        index: -1,
                        icon: "bluetooth.svg",
                        id: "bluetooth"
                    }, {
                        name: "Control Center",
                        index: -1,
                        icon: "controlCenter.svg",
                        id: "controlCenter"
                    }, {
                        name: "AI",
                        index: -1,
                        icon: "ai.png",
                        id: "ai"
                    }, {
                        name: "Clock",
                        icon: "clock.svg",
                        id: "clock"
                    }]
                    delegate: MenuBarModule {
                        id: moduleSettings
                        required property var modelData
                    }
                }
            }
        }

        //UILabel { text: Translation.tr("Auto hide") }
        //ComboBox {
        //    model: [Translation.tr("No"), Translation.tr("Yes")]
        //    currentIndex: Config.bar.autohide ? 1 : 0
        //    onCurrentIndexChanged: Config.bar.autohide = currentIndex == 1
        //}
    }
}