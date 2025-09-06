import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

Scope {
    id: root
    property alias implicitHeight: panelWindow.implicitHeight
    property alias implicitWidth: panelWindow.implicitWidth
    property alias visible: panelWindow.visible
    property alias margins: panelWindow.margins
    property bool opened: false
    property int animationDuration: 200
    required property Component content
    PanelWindow {
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "eqsh-blur"
        id: panelWindow
        color: "transparent"
        visible: false
        exclusiveZone: -1
        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }
        MouseArea {
            anchors.fill: parent
            visible: parent.visible
            onClicked: {
                root.opened = false;
            }
        }
        WrapperRectangle {
            id: background
            color: "transparent"
            anchors.fill: parent
            opacity: 0
            Behavior on opacity {
                NumberAnimation {
                    duration: root.animationDuration
                }
            }

            states: State {
                name: "opened"
                when: root.opened
                PropertyChanges {
                    background {
                        opacity: 1
                    }
                }
            }

            transitions: [
                Transition {
                    from: ""
                    to: "opened"
                    ScriptAction {
                        script: root.visible = true
                    }
                },
                Transition {
                    from: "opened"
                    to: ""
                    SequentialAnimation {
                        PauseAnimation {
                            duration: root.animationDuration
                        }
                        ScriptAction {
                            script: root.visible = false
                        }
                    }
                }
            ]
            Loader {
                anchors.fill: parent
                active: true
                sourceComponent: content
            }
        }
    }
}