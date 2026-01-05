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

StackLayout {
    width: 450
    Layout.fillWidth: true
    Layout.fillHeight: true
    id: root
    currentIndex: 0
    Connections {
        target: root.contentViewO
        function onPageChanged(index) {
            root.currentIndex = index.subindex || 0
        }
    }
    component ShadowRectangle: RectangularShadow {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        color: "#20000000"
        radius: 20
        blur: 20
        spread: 5
        Rectangle {
            anchors.fill: parent
            radius: 20
            color: Config.general.darkMode ? "#222" : "#ffffff"
        }
    }
    component SectionItem: Item {
        id: sectionItem
        required property var model
        required property var modelData
        required property int index
        width: parent.width-20
        Layout.alignment: Qt.AlignHCenter
        height: 30
        Rectangle {
            anchors.fill: parent
            radius: 20
            color: "transparent"
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    root.history.push({ index: root.contentViewO.currentIndex, subindex: root.currentIndex })
                    root.currentIndex = modelData[2]
                }
                Rectangle {
                    width: parent.width
                    height: 1
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: -5
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: "#50555555"
                    visible: index < sectionItem.model.length-1
                }

                CFVI {
                    id: sectionIcon
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 5
                    size: 25
                    icon: "settings/general/" + modelData[0] + ".svg"
                    colorized: false
                }

                CFText {
                    anchors.left: sectionIcon.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 10
                    text: modelData[1]
                    font.pixelSize: 16
                }

                CFVI {
                    id: sectionChevron
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: 5
                    size: 15
                    icon: "chevron-right.svg"
                }
            }
        }
    }
    Item {
        width: parent.width
        height: parent.height
        Layout.fillWidth: true
        Layout.fillHeight: true
        Rectangle {
            z: 2
            anchors.fill: parent
            color: "#a0000000"
            CFText {
                id: comingsoonText
                anchors.fill: parent
                color: "#fff"
                width: 200
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                height: 20
                font.pixelSize: 32
                text: "Coming Soon..."
                layer.enabled: true
                layer.samples: 8
                layer.effect: MultiEffect {
                    shadowEnabled: true
                    shadowOpacity: 1
                    shadowBlur: 1
                    blurMax: 64
                    shadowColor: "#fff"
                }
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {}
            }
        }
        ScrollView {
            anchors.fill: parent
            
            ColumnLayout {
                id: column
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: 10
                    bottom: parent.bottom
                }
                width: 450
                spacing: 10
                Item {
                    id: sectionsP1
                    implicitHeight: 210
                    width: 450

                    ShadowRectangle {}

                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.leftMargin: 20
                        spacing: 10
                        Repeater {
                            id: sections
                            model: [
                                ["about", "About", 1],
                                ["softwareupdate", "Softwareupdate", 2],
                                ["storage", "Storage", 3],
                                ["airdrop", "Airdrop", 4],
                                ["autostart", "Autostart", 5]
                            ]

                            delegate: SectionItem { model: sections.model }
                        }
                    }
                }
                Item {
                    id: sectionsP2
                    implicitHeight: 50
                    width: 450

                    ShadowRectangle {}

                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.leftMargin: 20
                        spacing: 10
                        Repeater {
                            id: sections2
                            model: [
                                ["equoracare", "EquoraCare & Support", 6]
                            ]
                            delegate: SectionItem { model: sections2.model }
                        }

                    }
                }
                Item {
                    id: sectionsP3
                    implicitHeight: 90
                    width: 450

                    ShadowRectangle {}

                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.leftMargin: 20
                        spacing: 10
                        Repeater {
                            id: sections3
                            model: [
                                ["language", "Language & Region", 7],
                                ["datetime", "Date & Time", 8]
                            ]
                            delegate: SectionItem { model: sections3.model }
                        }

                    }
                }
                Item {
                    id: sectionsP4
                    implicitHeight: 170
                    width: 450

                    ShadowRectangle {}

                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.leftMargin: 20
                        spacing: 10
                        Repeater {
                            id: sections4
                            model: [
                                ["share", "Share", 9],
                                ["timemachine", "Time Machine", 10],
                                ["restore", "Restore", 11],
                                ["startvolume", "Startvolume", 12],
                            ]
                            delegate: SectionItem { model: sections4.model }
                        }
                    }
                }
                Item {
                    implicitHeight: 10
                    width: 450
                }
            }
        }
    }
    ScrollView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        Item {
            implicitHeight: 220
            anchors.margins: 10
            anchors.fill: parent
            anchors.horizontalCenter: parent.horizontalCenter

            RectangularShadow {
                anchors.fill: parent
                color: "#20000000"
                radius: 20
                blur: 20
                spread: 5
            }
            Rectangle {
                anchors.fill: parent
                radius: 20
                color: Config.general.darkMode ? "#222" : "#ffffff"
            }

            CFText {
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: 15
                text: Translation.tr("About")
                font.pixelSize: 16
                Layout.alignment: Qt.AlignTop
            }
        }
    }
}