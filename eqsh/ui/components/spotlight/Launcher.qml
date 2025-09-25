import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs.ui.Controls.Advanced
import qs.ui.Controls.providers

PanelWindow {
    id: launcher
    implicitWidth: 500
    implicitHeight: 600
    color: "transparent"
    focusable: true
    visible: false
    WlrLayershell.namespace: "eqsh:blur"

    BoxExperimental {
        id: background
        anchors.centerIn: parent
        width: parent.width * 0.85
        height: parent.height * 0.85
        radius: 16
        highlight: AccentColor.color

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 16
            spacing: 10

            TextField {
                id: search
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                placeholderText: "Search apps…"
                font.pixelSize: 16
                color: "white"
                background: Rectangle {
                    radius: 8
                    color: "#333"
                }
                focus: true
            }

            ListView {
                id: results
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4

                model: DesktopEntries.applications.values.filter(a => a.name.toLowerCase().includes(search.text.toLowerCase()))

                delegate: Rectangle {
                    required property DesktopEntry modelData
                    width: parent.width
                    height: 40
                    radius: 6
                    color: hovered ? "#444" : "transparent"

                    property bool hovered: false

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        text: modelData.name
                        color: "white"
                        font.pixelSize: 15
                        elide: Text.ElideRight
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: parent.hovered = true
                        onExited: parent.hovered = false
                        onClicked: modelData.execute()
                    }
                }
            }
        }
    }
}
