import QtQuick
import QtQuick.Shapes
import Quickshell

Item {
    id: root

    // public API
    property real radius: 25
    property real topLeftRadius:     root.radius
    property real topRightRadius:    root.radius
    property real bottomLeftRadius:  root.radius
    property real bottomRightRadius: root.radius
    property color color: "#000000"
    property color strokeColor: "black"
    property real strokeWidth: 1

    Shape {
        id: shape
        anchors.fill: parent
        fillMode: Shape.PreserveAspectFit
        ShapePath {
            fillColor: root.color
            strokeWidth: 0

            startX: radius
            startY: 0
            PathLine {
                x: shape.width - topRightRadius
                y: 0
            }
            PathCubic {
                control1X: shape.width
                control2X: shape.width
                control1Y: 0
                control2Y: 0
                x: shape.width
                y: topRightRadius
            }
            PathLine {
                x: shape.width
                y: shape.height - bottomRightRadius
            }
            PathCubic {
                control1X: shape.width
                control2X: shape.width
                control1Y: shape.height
                control2Y: shape.height
                x: shape.width - bottomRightRadius
                y: shape.height
            }
            PathLine {
                x: bottomLeftRadius
                y: shape.height
            }
            PathCubic {
                control1X: 0
                control2X: 0
                control1Y: shape.height
                control2Y: shape.height
                x: 0
                y: shape.height - bottomLeftRadius
            }
            PathLine {
                x: 0
                y: topLeftRadius
            }
            PathCubic {
                control1X: 0
                control2X: 0
                control1Y: 0
                control2Y: 0
                x: topLeftRadius
                y: 0
            }
        }
    }
}