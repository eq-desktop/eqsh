import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import qs.ui.controls.providers

Scope {
    id: root

    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: launcher
            implicitWidth: 500
            implicitHeight: 600
            required property var modelData
            screen: modelData
            color: "transparent"
            focusable: true
            WlrLayershell.namespace: "eqsh:blur"

            property bool focusedScreen: (modelData.name == (Hyprland.focusedMonitor?.name ?? ""))

            mask: Region {
                item: Runtime.spotlightOpen && focusedScreen ? background : null
            }

            BoxExperimental {
                id: background
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                visible: Runtime.spotlightOpen && focusedScreen
                width: parent.width * 0.85
                implicitHeight: results.height + search.height + 32
                radius: 25
                highlight: AccentColor.color

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    TextField {
                        id: search
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        font.pixelSize: 16
                        color: "white"
                        background: Text {
                            anchors.fill: parent
                            verticalAlignment: Text.AlignVCenter
                            horizontalAlignment: Text.AlignLeft
                            anchors.leftMargin: 12
                            color: "#fff"
                            visible: search.text == ""
                            text: "Search..."
                        }
                        focus: true
                        Keys.onPressed: (event) => {
                            if (event.key === Qt.Key_Escape) {
                                launcher.toggle();
                            }
                        }
                    }

                    ListView {
                        id: results
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        height: search.text == "" ? 0 : 400
                        spacing: 4

                        model: ScriptModel {
                            values: search.text == "" ? [] : DesktopEntries.applications.values.filter(a => a.name.toLowerCase().includes(search.text.toLowerCase()))
                        }

                        delegate: Rectangle {
                            required property DesktopEntry modelData
                            width: parent ? parent.width : 0
                            height: 40
                            radius: 15
                            color: hovered ? AccentColor.color : "transparent"

                            property bool hovered: false

                            Image {
                                id: icon
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                source: Quickshell.iconPath(modelData.icon)
                                width: 32
                                height: 32
                                smooth: true
                                mipmap: true
                                layer.enabled: true
                                scale: 0
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: 200
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 1
                                    }
                                }
                                Component.onCompleted: {
                                    scale = 1
                                }
                            }

                            Text {
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 56
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
                                onClicked: {modelData.execute(); launcher.toggle();}
                            }
                        }
                    }
                }
            }
            property bool spotlightOpen: Runtime.spotlightOpen
            onSpotlightOpenChanged: {
                if (spotlightOpen) {
                    search.focus = true;
                } else {
                    search.text = "";
                }
            }
        }
    }

    function toggle() {
        Runtime.spotlightOpen = !Runtime.spotlightOpen;
    }
    IpcHandler {
        target: "spotlight"
        function toggle() {
            root.toggle();
        }
    }
    CustomShortcut {
        name: "spotlight"
        description: "Toggle Spotlight"
        onPressed: {
            root.toggle();
        }
    }
}