import QtQuick
import QtQuick.Shapes

Item {
    id: root

    enum CornerEnum { TopLeft, TopRight, BottomLeft, BottomRight }
    property var corner: RoundedCorner.CornerEnum.TopLeft

    property int implicitSize: 25
    property color color: "#000000"

    implicitWidth: implicitSize
    implicitHeight: implicitSize

    property bool isTopLeft: corner === RoundedCorner.CornerEnum.TopLeft
    property bool isBottomLeft: corner === RoundedCorner.CornerEnum.BottomLeft
    property bool isTopRight: corner === RoundedCorner.CornerEnum.TopRight
    property bool isBottomRight: corner === RoundedCorner.CornerEnum.BottomRight
    property bool isTop: isTopLeft || isTopRight
    property bool isBottom: isBottomLeft || isBottomRight
    property bool isLeft: isTopLeft || isBottomLeft
    property bool isRight: isTopRight || isBottomRight

    Shape {
        anchors {
            top: root.isTop ? parent.top : undefined
            bottom: root.isBottom ? parent.bottom : undefined
            left: root.isLeft ? parent.left : undefined
            right: root.isRight ? parent.right : undefined
        }
        layer.enabled: true
        layer.smooth: true
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            id: shapePath
            strokeWidth: 0
            fillColor: root.color
            pathHints: ShapePath.PathSolid & ShapePath.PathNonIntersecting

            startX: switch (root.corner) {
                case RoundedCorner.CornerEnum.TopLeft: return 0;
                case RoundedCorner.CornerEnum.TopRight: return root.implicitSize;
                case RoundedCorner.CornerEnum.BottomLeft: return 0;
                case RoundedCorner.CornerEnum.BottomRight: return root.implicitSize;
            }
            startY: switch (root.corner) {
                case RoundedCorner.CornerEnum.TopLeft: return 0;
                case RoundedCorner.CornerEnum.TopRight: return 0;
                case RoundedCorner.CornerEnum.BottomLeft: return root.implicitSize;
                case RoundedCorner.CornerEnum.BottomRight: return root.implicitSize;
            }
            PathAngleArc {
                moveToStart: false
                centerX: root.implicitSize - shapePath.startX
                centerY: root.implicitSize - shapePath.startY
                radiusX: root.implicitSize
                radiusY: root.implicitSize
                startAngle: switch (root.corner) {
                    case RoundedCorner.CornerEnum.TopLeft: return 180;
                    case RoundedCorner.CornerEnum.TopRight: return -90;
                    case RoundedCorner.CornerEnum.BottomLeft: return 90;
                    case RoundedCorner.CornerEnum.BottomRight: return 0;
                }
                sweepAngle: 90
            }
            PathLine {
                x: shapePath.startX
                y: shapePath.startY
            }
        }
    }

}