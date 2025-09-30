import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland

Scope {
    id: root
    property int width: -1
    property int height: -1
    property int blurPower: 64
    property int rounding: 20
    property bool visible: true
    property color color: "#ff000000"
    property var layer: WlrLayer.Top
    property list<bool> anchors: [false, false, false, false]
    property list<int>  margins: [0, 0, 0, 0]
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panelWindow
            WlrLayershell.layer: root.layer
            exclusiveZone: -1
            required property var modelData
            property int swidth: root.width == -1 ? modelData.width : root.width
            property int sheight: root.height == -1 ? modelData.height : root.height
            screen: modelData
            WlrLayershell.namespace: "eqsh:shadow"
            anchors {
                top: root.anchors[0]
                left: root.anchors[1]
                right: root.anchors[2]
                bottom: root.anchors[3]
            }
            margins {
                top: root.margins[0]
                left: root.margins[1]
                right: root.margins[2]
                bottom: root.margins[3]
            }
            visible: shadow.opacity != 0
            mask: Region {}
            color: "transparent"
            implicitWidth: panelWindow.swidth
            implicitHeight: panelWindow.sheight
            Rectangle {
                id: shadow
                anchors {
                    centerIn: parent
                    top: root.anchors[0] ? parent.top : undefined
                    left: root.anchors[1] ? parent.left : undefined
                    right: root.anchors[2] ? parent.right : undefined
                    bottom: root.anchors[3] ? parent.bottom : undefined
                }
                opacity: root.visible ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
                radius: root.rounding
                implicitWidth: root.anchors[1] && root.anchors[2] ? panelWindow.swidth - root.blurPower*2 : panelWindow.swidth / 2
                implicitHeight: root.anchors[0] && root.anchors[3] ? panelWindow.sheight : panelWindow.sheight / 2
                color: root.color
                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    autoPaddingEnabled: true
                    blurMax: root.blurPower
                    blur: 1.0
                }
            }
        }
    }
}