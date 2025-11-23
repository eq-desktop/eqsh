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
    property var gradient: undefined
    property color strokeColor: "black"
    property real strokeWidth: 1

    Shape {
        id: shape
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        fillMode: Shape.PreserveAspectFit

        ShapePath {
            fillColor: root.gradient ? "transparent" : root.color
            fillGradient: root.gradient
            strokeColor: root.strokeColor
            strokeWidth: root.strokeWidth

            // Start at top-left corner arc end
            startX: topLeftRadius
            startY: 0

            // Top edge → until before top-right corner
            PathLine {
                x: shape.width - topRightRadius
                y: 0
            }

            // Top-right corner (quadratic arc)
            PathQuad {
                controlX: shape.width
                controlY: 0
                x: shape.width
                y: topRightRadius
            }

            // Right edge
            PathLine {
                x: shape.width
                y: shape.height - bottomRightRadius
            }

            // Bottom-right corner
            PathQuad {
                controlX: shape.width
                controlY: shape.height
                x: shape.width - bottomRightRadius
                y: shape.height
            }

            // Bottom edge
            PathLine {
                x: bottomLeftRadius
                y: shape.height
            }

            // Bottom-left corner
            PathQuad {
                controlX: 0
                controlY: shape.height
                x: 0
                y: shape.height - bottomLeftRadius
            }

            // Left edge
            PathLine {
                x: 0
                y: topLeftRadius
            }

            // Top-left corner
            PathQuad {
                controlX: 0
                controlY: 0
                x: topLeftRadius
                y: 0
            }
        }
    }
}
