import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

Scope {
    id: root
    property alias implicitHeight: panelWindow.implicitHeight
    property alias implicitWidth: panelWindow.implicitWidth
    property alias visible: panelWindow.visible
    property alias margins: panelWindow.margins
    property bool opened: false
    property bool hiding: false
    property var contentItem: null
    property bool new_Focus_Method: false
    property int  new_Focus_Method_X: 0
    property int  new_Focus_Method_Y: 0
    property bool blur: true
    property var windows: []
    property alias screen: panelWindow.screen
    property int animationDuration: 100
    required property Component content
    signal loaded()
    signal cleared()
    PanelWindow {
        id: panelWindow
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: root.blur ? "eqsh:blur" : "eqsh"
        color: "transparent"
        visible: root.opened
        exclusiveZone: -1
        anchors {
            top: true
            right: !root.new_Focus_Method
            bottom: !root.new_Focus_Method
            left: true
        }
        margins {
            top: root.new_Focus_Method ? root.new_Focus_Method_Y : 0
            left: root.new_Focus_Method ? root.new_Focus_Method_X : 0
        }
        HyprlandFocusGrab {
            id: grab
            windows: [ panelWindow, ...root.windows ]
            active: root.opened
            onCleared: {
                root.hiding = true
                hideAnim.start();
                root.cleared();
            }
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
                root.cleared();
            }
        }
        WrapperRectangle {
            id: background
            color: "transparent"
            anchors.fill: parent
            Loader {
                anchors.fill: parent
                active: root.opened
                sourceComponent: content
                onLoaded: {
                    root.contentItem = item
                    root.loaded()
                }
            }
        }
    }
}