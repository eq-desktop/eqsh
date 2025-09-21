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
    property bool hiding: false
    property int animationDuration: 100
    required property Component content
    PanelWindow {
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "eqsh:blur"
        id: panelWindow
        color: "transparent"
        visible: root.opened
        exclusiveZone: -1
        anchors {
            top: true
            right: true
            bottom: true
            left: true
        }
        Timer {
            id: hideAnim
            running: false
            interval: root.animationDuration
            onTriggered: {
                root.opened = false;
                root.hiding = false;
            }
        }
        MouseArea {
            anchors.fill: parent
            visible: parent.visible
            onClicked: {
                root.hiding = true
                hideAnim.start();
            }
        }
        WrapperRectangle {
            id: background
            color: "transparent"
            anchors.fill: parent
            Loader {
                anchors.fill: parent
                active: true
                sourceComponent: content
            }
        }
    }
}