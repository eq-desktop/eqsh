import Quickshell
import Quickshell.Hyprland
import QtQuick
import qs.ui.controls.primitives
import qs.ui.controls.providers
import qs.config
import qs

Scope {
    id: root
    FloatingWindow {
        id: about
        color: Config.general.darkMode ? "#a01e1e1e" : "#a0ffffff"
        title: "About this Mac"
        visible: Runtime.aboutOpen
        minimumSize: "335x550"
        maximumSize: "335x550"
    
        onClosed: {
            Runtime.aboutOpen = false
        }
        property bool focused: Hyprland.activeToplevel.title == "About this Mac"
        UIControls {
            id: controls
            focused: about.focused
            anchors {
                top: parent.top
                left: parent.left
            }
            actionClose: () => {
                Runtime.aboutOpen = false
            }
        }
        Rectangle {
            id: deviceImage
            anchors {
                horizontalCenter: parent.horizontalCenter
                top: parent.top
                topMargin: 75
            }
            width: 175
            height: 125
            color: "transparent"
            radius: 15
            CFI {
                icon: "devices/mbair.png"
                colorized: false
                anchors.fill: parent
            }
        }
        CFText {
            id: deviceTitle
            anchors {
                horizontalCenter: deviceImage.horizontalCenter
                top: deviceImage.bottom
                topMargin: 20
            }
            horizontalAlignment: Text.AlignHCenter
            text: Config.account.deviceName
            font.pixelSize: 26
            font.weight: 700
            color: Config.general.darkMode ? "#fefefe" : "#222"
            width: 175
            height: 30
        }
        CFText {
            id: deviceDescription
            anchors {
                horizontalCenter: deviceTitle.horizontalCenter
                top: deviceTitle.bottom
                topMargin: 0
            }
            horizontalAlignment: Text.AlignHCenter
            text: Config.account.deviceDescription
            font.pixelSize: 12
            font.weight: 500
            color: "#777"
            width: 175
            height: 40
        }
        Column {
            id: list
            anchors {
                top: deviceDescription.bottom
                horizontalCenter: parent.horizontalCenter
            }
            spacing: 5
            Row {
                id: row1
                spacing: 5
                CFText {
                    text: "Processor"
                    width: 120
                    horizontalAlignment: Text.AlignRight
                    color: "#555"
                    font.weight: 600
                }
                CFText {
                    text: SysInfo.cpuGHz + " " + SysInfo.cpuCores + " " + SysInfo.cpuName
                    width: 160
                    wrapMode: Text.WordWrap
                }
            }
            Row {
                id: row2
                spacing: 5
                CFText {
                    text: "Graphics-Card"
                    width: 120
                    horizontalAlignment: Text.AlignRight
                    color: "#555"
                    font.weight: 600
                }
                CFText {
                    text: SysInfo.gpuName
                    width: 160
                    wrapMode: Text.WordWrap
                }
            }
            Row {
                id: row3
                spacing: 5
                CFText {
                    text: "Memory"
                    width: 120
                    horizontalAlignment: Text.AlignRight
                    color: "#555"
                    font.weight: 600
                }
                CFText {
                    text: SysInfo.memory + " " + SysInfo.memoryMHz + " " + SysInfo.memoryDDR
                    width: 160
                    wrapMode: Text.WordWrap
                }
            }
            Row {
                id: row4
                spacing: 5
                CFText {
                    text: "Serial Number"
                    width: 120
                    horizontalAlignment: Text.AlignRight
                    color: "#555"
                    font.weight: 600
                }
                CFText {
                    text: Config.account.serialNumber
                    width: 160
                    wrapMode: Text.WordWrap
                }
            }
            Row {
                id: row5
                spacing: 5
                CFText {
                    text: "EqOS"
                    width: 120
                    horizontalAlignment: Text.AlignRight
                    color: "#555"
                    font.weight: 600
                }
                CFText {
                    text: Config.versionPretty
                    width: 160
                    wrapMode: Text.WordWrap
                }
            }
        }
        CFButton {
            id: minfo
            anchors {
                horizontalCenter: list.horizontalCenter
                top: list.bottom
                topMargin: 20
            }
            text: "More Info..."
            width: 100
            onClicked: {
                Qt.openUrlExternally("https://github.com/eq-desktop/eqsh")
            }
        }
        CFText {
            id: regulatory
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: copyright.top
                bottomMargin: 10
            }
            text: "<u>Regulatory Certification</u>"
            color: "#a0777777"
            horizontalAlignment: Text.AlignHCenter
            height: 10
        }
        CFText {
            id: copyright
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: rightsreserved.top
                bottomMargin: 8
            }
            text: "™ and © 2025-2026 The Eq Desktop"
            color: "#a0777777"
            horizontalAlignment: Text.AlignHCenter
            height: 10
        }
        CFText {
            id: rightsreserved
            anchors {
                horizontalCenter: parent.horizontalCenter
                bottom: parent.bottom
                bottomMargin: 20
            }
            text: "All rights reserved."
            color: "#a0777777"
            horizontalAlignment: Text.AlignHCenter
            height: 10
        }
    }
}