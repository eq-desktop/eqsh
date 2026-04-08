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
    property var contentItem: null
    property bool new_Focus_Method: false
    property int  new_Focus_Method_X: 0
    property int  new_Focus_Method_Y: 0
    property bool blur: true
    property var keyboardFocus: WlrKeyboardFocus.None
    property var windows: []
    property alias screen: panelWindow.screen
    property alias mask: panelWindow.mask
    property int animationDuration: 100
    property string namespace: root.blur ? "eqsh:blur" : "eqsh"
    default property alias content: background.children
    signal clearing()
    signal cleared()
    function clear() {
        root.clearing();
        hideAnim.start();
    }

    signal escapePressed()
    PanelWindow {
        id: panelWindow
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: root.namespace
        WlrLayershell.keyboardFocus: root.keyboardFocus
        focusable: true
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
        Timer {
            id: hideAnim
            running: false
            interval: root.animationDuration
            onTriggered: {
                root.cleared();
            }
        }
        MouseArea {
            anchors.fill: parent
            visible: parent.visible
            onClicked: {
                root.clearing();
                hideAnim.start();
            }
        }
        WrapperRectangle {
            id: background
            color: "transparent"
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: {
                root.escapePressed();
            }
        }
    }
}