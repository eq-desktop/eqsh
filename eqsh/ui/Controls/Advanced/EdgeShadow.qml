import Quickshell
import QtQuick
import QtQuick.Effects
import Quickshell.Wayland

Scope {
    id: root
    enum Edge { Left, Top, Right, Bottom }
    property int edge: Edge.Left
    property int width: -1
    property int height: -1
    property int strenght: 200
    property color color: "#ff000000"
    
    LayerShadow {
        id: shadow
        anchors: [
            root.edge == EdgeShadow.Edge.Top || ([EdgeShadow.Edge.Left, EdgeShadow.Edge.Right].includes(root.edge) && root.height == -1),
            root.edge == EdgeShadow.Edge.Left || ([EdgeShadow.Edge.Top, EdgeShadow.Edge.Bottom].includes(root.edge) && root.width == -1),
            root.edge == EdgeShadow.Edge.Right || ([EdgeShadow.Edge.Top, EdgeShadow.Edge.Bottom].includes(root.edge) && root.width == -1),
            root.edge == EdgeShadow.Edge.Bottom || ([EdgeShadow.Edge.Left, EdgeShadow.Edge.Right].includes(root.edge) && root.height == -1)
        ]
        margins: [
            shadow.anchors[0] == true ? -root.strenght / 2 : 0,
            shadow.anchors[1] == true ? -root.strenght / 2 : 0,
            shadow.anchors[2] == true ? -root.strenght / 2 : 0,
            shadow.anchors[3] == true ? -root.strenght / 2 : 0
        ]
        width: [EdgeShadow.Edge.Left, EdgeShadow.Edge.Right].includes(root.edge) ? root.strenght : -1
        height: [EdgeShadow.Edge.Top, EdgeShadow.Edge.Bottom].includes(root.edge) ? root.strenght : -1
    }
}