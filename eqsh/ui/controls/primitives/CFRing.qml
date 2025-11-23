import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property int size: 30
    property int lineWidth: 2
    property color color: "#aaa"

    width: size
    height: size

    property real centerX: width / 2
    property real centerY: height / 2
    property real radius: size / 2 - lineWidth

    Shape {
        anchors.fill: parent
        layer.enabled: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.color
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"

            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.radius
                radiusY: root.radius
                startAngle: 0
                sweepAngle: 360
            }
        }
    }
}
