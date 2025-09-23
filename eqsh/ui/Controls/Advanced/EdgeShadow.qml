import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland

Scope {
    id: root
    enum Edge { Left, Top, Right, Bottom }
    property int edge: EdgeShadow.Edge.Left
    property int blurPower: 64
    property int strength: 200
    property bool visible: true
    property color color: "#ff000000"
    property var layer: WlrLayer.Top
    Variants {
        model: Quickshell.screens
        PanelWindow {
            id: panelWindow
            WlrLayershell.layer: root.layer
            exclusiveZone: -1
            required property var modelData
            screen: modelData
            WlrLayershell.namespace: "eqsh:shadow"
            anchors {
                top: true
                left: true
                right: true
                bottom: true
            }
            visible: shadow.opacity != 0
            mask: Region {}
            color: "transparent"
            Rectangle {
                id: shadow
                anchors {
                    top: [EdgeShadow.Edge.Top, EdgeShadow.Edge.Left, EdgeShadow.Edge.Right].includes(root.edge) ? parent.top : undefined
                    left: [EdgeShadow.Edge.Left, EdgeShadow.Edge.Top, EdgeShadow.Edge.Bottom].includes(root.edge) ? parent.left : undefined
                    right: [EdgeShadow.Edge.Right, EdgeShadow.Edge.Top, EdgeShadow.Edge.Bottom].includes(root.edge) ? parent.right : undefined
                    bottom: [EdgeShadow.Edge.Bottom, EdgeShadow.Edge.Left, EdgeShadow.Edge.Right].includes(root.edge) ? parent.bottom : undefined
                    margins: -(root.strength/2)
                }
                opacity: root.visible ? 1 : 0
                Behavior on opacity {
                    NumberAnimation {
                        duration: 200
                    }
                }
                radius: 0
                implicitWidth: [EdgeShadow.Edge.Left, EdgeShadow.Edge.Right].includes(root.edge) ? root.strength : null
                implicitHeight: [EdgeShadow.Edge.Top, EdgeShadow.Edge.Bottom].includes(root.edge) ? root.strength : null
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