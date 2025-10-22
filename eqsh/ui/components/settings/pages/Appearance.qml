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

ScrollView {
    ColumnLayout {
        anchors.fill: parent
        anchors.topMargin: 10
        anchors.leftMargin: 10
        anchors.rightMargin: 20
        Rectangle {
            id: container1
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: 0
            color: "transparent"

            ColumnLayout {
                id: col
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                }
                spacing: 10

                Rectangle {
                    height: 120
                    radius: 20
                    color: Config.general.darkMode ? "#222" : "#ffffff"
                    Layout.fillWidth: true

                    RectangularShadow {
                        anchors.fill: parent
                        color: "#20000000"
                        radius: 20
                        blur: 10
                        spread: 5
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        CFText {
                            text: Translation.tr("Appearance")
                            font.pixelSize: 20
                            Layout.alignment: Qt.AlignTop
                        }

                        Item { Layout.fillWidth: true } // spacer

                        MouseArea {
                            width: 80
                            Layout.fillHeight: true
                            onClicked: {
                                Config.general.darkMode = false
                                Config.general.autoDarkMode = false
                            }
                            Rectangle {
                                anchors {
                                    top: parent.top
                                    topMargin: 10
                                    horizontalCenter: parent.horizontalCenter
                                }
                                width: 70
                                height: 50
                                radius: 10
                                border {
                                    width: Config.general.darkMode || Config.general.autoDarkMode ? 0 : 4
                                    color: AccentColor.color
                                }
                                color: "#ddd"
                            }
                            CFText {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Translation.tr("Light")
                                gray: Config.general.darkMode
                            }
                        }
                        MouseArea {
                            width: 80
                            Layout.fillHeight: true
                            onClicked: {
                                Config.general.darkMode = true
                                Config.general.autoDarkMode = false
                            }
                            Rectangle {
                                anchors {
                                    top: parent.top
                                    topMargin: 10
                                    horizontalCenter: parent.horizontalCenter
                                }
                                width: 70
                                height: 50
                                radius: 10
                                border {
                                    width: Config.general.darkMode && !Config.general.autoDarkMode ? 4 : 0
                                    color: AccentColor.color
                                }
                                color: "#333"
                            }
                            CFText {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Translation.tr("Dark")
                                gray: !Config.general.darkMode
                            }
                        }
                        MouseArea {
                            width: 80
                            Layout.fillHeight: true
                            onClicked: {
                                Config.general.darkMode = false
                                Config.general.autoDarkMode = true
                            }
                            Rectangle {
                                anchors {
                                    top: parent.top
                                    topMargin: 10
                                    horizontalCenter: parent.horizontalCenter
                                }
                                width: 70
                                height: 50
                                radius: 10
                                border {
                                    width: Config.general.autoDarkMode ? 4 : 0
                                    color: AccentColor.color
                                }
                                color: "#555"
                            }
                            CFText {
                                anchors.bottom: parent.bottom
                                anchors.bottomMargin: 10
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: Translation.tr("Auto")
                                gray: true
                            }
                        }
                    }
                }
                
                CFText { text: Translation.tr("Theme"); font.pixelSize: 20 }

                Rectangle {
                    height: 120
                    radius: 20
                    color: Config.general.darkMode ? "#222" : "#ffffff"
                    Layout.fillWidth: true

                    RectangularShadow {
                        anchors.fill: parent
                        color: "#20000000"
                        radius: 20
                        blur: 20
                        spread: 5
                    }

                    RowLayout {
                        id: row1
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 10
                        spacing: 10

                        CFText {
                            text: Translation.tr("Color")
                            font.pixelSize: 20
                            Layout.alignment: Qt.AlignTop
                        }

                        Item { Layout.fillWidth: true } // spacer

                        component ColorCircle: MouseArea {
                            id: colorCircle
                            Layout.alignment: Qt.AlignTop
                            width: 25
                            height: 25
                            required property var modelData
                            required property int index
                            property color color: modelData
                            property bool selected: (Config.appearance.dynamicAccentColor && colorCircle.color == "#00000000") || Config.appearance.accentColor == colorCircle.color
                            onClicked: {
                                if (colorCircle.color == "#00000000") {
                                    Config.appearance.dynamicAccentColor = true
                                    Config.appearance.accentColor = AccentColor.dynamicColor
                                    return;
                                } else {
                                    Config.appearance.dynamicAccentColor = false
                                    Config.appearance.accentColor = colorCircle.color
                                }
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: 99
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -3
                                    radius: 99
                                    color: "transparent"
                                    border {
                                        width: 2
                                        color: colorCircle.selected ? Config.appearance.accentColor : "transparent"
                                    }
                                }
                                color: colorCircle.color == "#00000000" ? AccentColor.dynamicColor : colorCircle.color
                                CFText {
                                    anchors {
                                        top: parent.bottom
                                        topMargin: 10
                                        horizontalCenter: parent.horizontalCenter
                                    }
                                    text: row1.colorNames[index]
                                    opacity: colorCircle.selected ? 0.5 : 0
                                }
                            }
                        }
                        property list<string> colorNames: [Translation.tr("Dynamic"), Translation.tr("Blue"), Translation.tr("Purple"), Translation.tr("Pink"), Translation.tr("Red"), Translation.tr("Orange"), Translation.tr("Yellow"), Translation.tr("Green"), Translation.tr("Granite")]
                        Repeater {
                            model: ["#00000000", "#007bfd", "#97399a", "#F5529D", "#E43838", "#FC7E12", "#FEC531", "#63B947", "#969696"]
                            delegate: ColorCircle {}
                        }
                    }

                    Rectangle {
                        height: 1
                        width: parent.width * 0.95
                        anchors.bottom: row2.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: "#333"
                    }

                    RowLayout {
                        id: row2
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 10
                        spacing: 10

                        CFText {
                            text: Translation.tr("Use Appearance of Application")
                            Layout.alignment: Qt.AlignVCenter
                        }

                        Item { Layout.fillWidth: true } // spacer

                        CFSwitch {
                            Layout.alignment: Qt.AlignVCenter;
                            checked: Config.appearance.multiAccentColor
                            onClicked: {
                                Config.appearance.multiAccentColor = checked
                            }
                        }
                    }
                }
                Rectangle {
                    height: 120
                    radius: 20
                    color: Config.general.darkMode ? "#222" : "#ffffff"
                    Layout.fillWidth: true

                    RectangularShadow {
                        anchors.fill: parent
                        color: "#20000000"
                        radius: 20
                        blur: 20
                        spread: 5
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 10

                        CFText {
                            text: Translation.tr("Icon & widget style")
                            Layout.alignment: Qt.AlignTop
                        }

                        Item { Layout.fillWidth: true } // spacer

                        component IconStyle: MouseArea {
                            id: colorCircle
                            Layout.alignment: Qt.AlignTop
                            width: 50
                            height: 50
                            required property var modelData
                            required property int index
                            onClicked: {
                                Config.appearance.iconColorType = index
                            }
                            Rectangle {
                                anchors.fill: parent
                                radius: 10
                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: -3
                                    radius: 13
                                    color: "transparent"
                                    border {
                                        width: 2
                                        color: AccentColor.color
                                    }
                                }
                                color: "#555"
                            }
                        }
                        Repeater {
                            model: [Translation.tr("Default"), Translation.tr("Dark"), Translation.tr("Clear"), Translation.tr("Tinted")]
                            delegate: IconStyle {}
                        }
                    }
                }
            }
        }
    }
}