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
import qs.modules.settings
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
                    gray: modelData[3] ? false : true
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
        ScrollView {
            anchors.fill: parent
            
            ColumnLayout {
                id: column
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: 10
                    top: parent.top
                    topMargin: 10
                    bottom: parent.bottom
                }
                width: 450
                spacing: 10
                Rectangle {
                    color: Config.general.darkMode ? "#222" : "#f8f8f8"
                    radius: 15
                    id: sectionsP1
                    implicitHeight: 210
                    width: 430

                    Column {
                        anchors.fill: parent
                        anchors.topMargin: 10
                        anchors.leftMargin: 20
                        spacing: 10
                        Repeater {
                            id: sections
                            model: [
                                ["about", "About", 1, true],
                                ["softwareupdate", "Software Update", 2],
                                ["storage", "Storage", 3],
                                ["airdrop", "Airdrop", 4],
                                ["autostart", "Autostart", 5]
                            ]

                            delegate: SectionItem { model: sections.model }
                        }
                    }
                }
                Rectangle {
                    id: sectionsP2
                    implicitHeight: 50
                    width: 430
                    color: Config.general.darkMode ? "#222" : "#f8f8f8"
                    radius: 15

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
                Rectangle {
                    id: sectionsP3
                    implicitHeight: 90
                    width: 430
                    color: Config.general.darkMode ? "#222" : "#f8f8f8"
                    radius: 15

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
                Rectangle {
                    id: sectionsP4
                    implicitHeight: 170
                    width: 430
                    color: Config.general.darkMode ? "#222" : "#f8f8f8"
                    radius: 15

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
                                ["startvolume", "Start Volume", 12],
                            ]
                            delegate: SectionItem { model: sections4.model }
                        }
                    }
                }
                Item {
                    implicitHeight: 10
                    width: 430
                }
            }
        }
    }
    ScrollView {
        ColumnLayout {
            anchors.fill: parent
            anchors.topMargin: 10
            anchors.leftMargin: 10
            anchors.rightMargin: 10

            Item {
                height: 250
                Layout.fillWidth: true
                CFVI {
                    id: deviceImage
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: parent.top
                        topMargin: 50
                    }
                    size: 200
                    fillMode: VectorImage.PreserveAspectFit
                    icon: "devices/mbp14.svg"
                    colorized: false
                }
                CFText {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: deviceImage.bottom
                        topMargin: -50
                    }
                    text: Config.account.deviceName
                    font.weight: 500
                    font.pixelSize: 22
                }
                CFText {
                    anchors {
                        horizontalCenter: parent.horizontalCenter
                        top: deviceImage.bottom
                        topMargin: -28
                    }
                    text: Config.account.deviceDescription
                    gray: true
                    font.pixelSize: 14
                }
            }
            Section {
                height: (30*4)+20
                content: ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 0
                    Repeater {
                        model: [
                            { title: "Chip", value: SysInfo.cpuGHz + " " + SysInfo.cpuCores + " " + SysInfo.cpuName },
                            { title: "Memory", value: SysInfo.memory + " GB" },
                            { title: "Serial Number", value: Config.account.serialNumber }
                        ]
                        delegate: Item {
                            id: aboutModule
                            required property var modelData
                            height: 30
                            width: 430
                            CFText {
                                anchors.right: parent.right
                                anchors.rightMargin: 24
                                anchors.verticalCenter: parent.verticalCenter
                                text: aboutModule.modelData.value
                                font.weight: 200
                                font.pixelSize: 16
                            }
                            CFText {
                                anchors.left: parent.left
                                anchors.leftMargin: 8
                                anchors.verticalCenter: parent.verticalCenter
                                text: aboutModule.modelData.title
                                font.weight: 400
                                font.pixelSize: 16
                            }
                            Rectangle {
                                width: 390
                                height: 1
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                color: "#50555555"
                            }
                        }
                    }
                }
            }
            Item {
                width: 430
                height: 46
                Title {
                    anchors.bottom: parent.bottom
                    text: Config.general.appleNames ? Translation.tr("macOS") : Translation.tr("AureliOS")
                }
            }
            Section {
                height: 60
                content: Item {
                    anchors.fill: parent
                    CFVI {
                        anchors.left: parent.left
                        anchors.leftMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        icon: "logo.svg"
                        size: 30
                    }
                    CFText {
                        anchors.left: parent.left
                        anchors.leftMargin: 46
                        anchors.verticalCenter: parent.verticalCenter
                        text: Config.general.appleNames ? Translation.tr("macOS Tahoe") : Translation.tr("eqOS Tahiti")
                        font.weight: 400
                        font.pixelSize: 16
                    }
                    CFText {
                        anchors.right: parent.right
                        anchors.rightMargin: 24
                        anchors.verticalCenter: parent.verticalCenter
                        text: Config.general.appleNames ? Config.versionApple : Config.versionPretty
                        font.weight: 200
                        font.pixelSize: 16
                        gray: true
                    }
                }
            }
            Item {
                height: 50
                width: 430
            }
        }
    }
    Item {}
    Item {}
    Item {}
    Item {}
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