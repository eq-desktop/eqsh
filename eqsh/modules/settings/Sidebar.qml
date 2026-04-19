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
import qs.modules.settings.pages
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.ui.controls.primitives
import Quickshell.Io
import Quickshell.Widgets

Item {
    id: sidebarView
    Layout.fillHeight: true
    height: parent.height
    width: 250
    Layout.margins: -10

    property alias sb: sidebar

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
    
    BoxGlass {
        id: sidebarBackground
        anchors.fill: parent
        anchors.margins: 15
        clip: true
        radius: 20
        rimStrength: 1.8
        color: Config.general.darkMode ? "#aa2a2a2a" : "#ccfefefe"

        Item {
            id: searchBar
            height: 25
            width: 220
            z: 2
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: 50
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

        UIControls {
            id: windowControls
            showBox: false
            focused: true
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.topMargin: 10
            anchors.leftMargin: 10
            _rimStrength: 0.4
            _lightDir: Qt.point(1, 1)
            _glassShader: false
            actionClose: () => {
                Runtime.settingsOpen = false
            }
            actionMaximize: () => {
                settingsApp.implicitHeight = screen.height-Config.bar.height
            }
            active: [true, false, true]
        }

        // Sidebar
        ListView {
            id: sidebar
            width: 220
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: searchBar.bottom
            anchors.topMargin: 20
            height: parent.height - 110
            model: [
                "_Account",
                "",
                Translation.tr("Wi-Fi"),
                Translation.tr("Bluetooth"),
                Translation.tr("Network"),
                Translation.tr("Energy"),
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
                required property var modelData
                required property int index
                id: sidebarItem
                text: ""
                height: modelData == "" ? 20 : 35
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
                            "",
                            "wifi",
                            "bluetooth",
                            "network",
                            "energy",
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

                        CFVI {
                            id: svgS
                            anchors.fill: parent
                            source: sidebarItem.modelData == "" ? "" : (modelData == "_Account" ? "" : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/settings/" + imageContainer.svgs[sidebarItem.index] + ".svg"))
                            fillMode: Image.PreserveAspectCrop
                            colorized: false
                            color: Config.general.darkMode ? "#fff" : "#333"
                        }

                        CFI {
                            id: imageS
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            colorized: false
                            source: modelData == "_Account" ? Config.account.avatarPath : ""
                            onStatusChanged: {
                                if (imageS.status == Image.Error) {
                                    svgS.source = Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/user.svg")
                                    svgS.colorized = true
                                } else {
                                    svgS.colorized = false
                                }
                            }
                        }
                    }
                    Text {
                        anchors.fill: parent
                        text: modelData == "_Account" ? Config.account.name == "" ? Translation.tr("Sign in") : Config.account.name  : modelData
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
                        text: Config.account.name == "" ? Translation.tr("with your Equora Account") : Translation.tr("Equora Account")
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
                    contentView.setIndex(index)
                }
            }
            delegate: SidebarItem {
                width: parent.width
            }
        } 
    }
}