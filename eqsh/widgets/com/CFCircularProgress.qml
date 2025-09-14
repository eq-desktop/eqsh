import QtQuick
import QtQuick.Shapes

Item {
    id: root

    property int implicitSize: 30
    property int lineWidth: 2
    property real value: 0
    property color colPrimary: "#33bb55"
    property color colSecondary: "#444444"
    property real gapAngle: 360 / 18
    property bool fill: false
    property int fillOverflow: 2
    property bool enableAnimation: true
    property int animationDuration: 800
    property var easingType: Easing.OutCubic

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    property real degree: value * 360
    property real centerX: root.width / 2
    property real centerY: root.height / 2
    property real arcRadius: root.implicitSize / 2 - root.lineWidth
    property real startAngle: -90

    Behavior on degree {
        enabled: root.enableAnimation
        NumberAnimation {
            duration: root.animationDuration
            easing.type: root.easingType
        }

    }

    Loader {
        active: root.fill
        anchors.fill: parent
        
        sourceComponent: Rectangle {
            radius: 9999
            color: root.colSecondary
        }
    }

    Shape {
        anchors.fill: parent
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            id: secondaryPath
            strokeColor: root.colSecondary
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.startAngle - root.gapAngle
                sweepAngle: -(360 - root.degree - 2 * root.gapAngle)
            }
        }
        ShapePath {
            id: primaryPath
            strokeColor: root.colPrimary
            strokeWidth: root.lineWidth
            capStyle: ShapePath.RoundCap
            fillColor: "transparent"
            PathAngleArc {
                centerX: root.centerX
                centerY: root.centerY
                radiusX: root.arcRadius
                radiusY: root.arcRadius
                startAngle: root.startAngle
                sweepAngle: root.degree
            }
        }
    }

}