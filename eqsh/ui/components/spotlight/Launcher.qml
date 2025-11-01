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
import qs.ui.controls.primitives
import qs.ui.controls.windows

Scope {
    id: root

    FollowingPanelWindow {
        id: launcher
        implicitWidth: 600
        implicitHeight: 600
        color: "transparent"
        WlrLayershell.namespace: "eqsh:blur"

        mask: Region {
            item: Runtime.spotlightOpen ? background : null
        }

        HyprlandFocusGrab {
            id: grab
            windows: [ launcher ]
            active: Runtime.spotlightOpen
            onCleared: {
                Runtime.spotlightOpen = false
            }
        }

        BoxGlass {
            id: background
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            visible: Runtime.spotlightOpen
            width: parent.width * 0.85
            implicitHeight: results.height + search.height + 8
            radius: 25

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 4
                spacing: 10

                TextField {
                    id: search
                    Layout.fillWidth: true
                    Layout.preferredHeight: 40
                    leftPadding: 34
                    font.pixelSize: 26
                    color: "white"
                    CFVI {
                        id: sicon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 12
                        size: 20
                        opacity: 0.5
                        icon: "search.svg"
                    }
                    background: Text {
                        anchors.fill: parent
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        anchors.leftMargin: 34
                        font.pixelSize: 20
                        color: "#fff"
                        opacity: 0.5
                        visible: search.text == ""
                        text: Translation.tr("Search...")
                    }
                    focus: true
                    Keys.onPressed: (event) => {
                        if (event.key === Qt.Key_Escape) {
                            root.toggle();
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
                            width: 24
                            height: 24
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
                            anchors.leftMargin: 40
                            text: modelData.name
                            color: Config.general.darkMode ? "#fff" : hovered ? AccentColor.textColor : "#222"
                            font.pixelSize: 15
                            elide: Text.ElideRight
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: parent.hovered = true
                            onExited: parent.hovered = false
                            onClicked: {modelData.execute(); root.toggle();}
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