// CornerThingy mk2 by SealEgg
import QtQuick
import QtQuick.Shapes

Item {
    id: root
    anchors.fill: parent
    property var cornerType: "cubic" // cubic, rounded or inverted
    property int cornerHeight: 30
    property int cornerWidth: cornerHeight // default is square, but you can set a separate width
     
    property color color: "#000000"
    property var corners: [0] // 0 is top right, 1 is top left, 2 is bottom left, 3 is bottom right

    Repeater{
        model: root.cornerType === "cubic" ? root.corners : 0
        delegate: Shape {
            id: cubicShape
            asynchronous: true
            preferredRendererType: Shape.CurveRenderer
            width: root.cornerWidth
            height: root.cornerHeight

            property int currentCorner: modelData

            anchors.right: currentCorner === 0 || currentCorner === 3 ? root.right : undefined
            anchors.left: currentCorner === 1 || currentCorner === 2 ? root.left : undefined
            anchors.top: currentCorner <= 1 ? root.top : undefined
            anchors.bottom: currentCorner > 1 ? root.bottom : undefined

            ShapePath {
                fillColor: root.color
                strokeWidth: 0
                    
                startX: cubicShape.currentCorner % 2 === 0 ? 0 : root.cornerWidth; startY: 0

                PathCubic {
                    x: cubicShape.currentCorner % 2 === 0 ? root.cornerWidth : 0; y: root.cornerHeight
                    relativeControl1X: cubicShape.currentCorner % 2 === 0 ? root.cornerWidth/2 : -root.cornerWidth/2; relativeControl1Y: 0
                    relativeControl2X: cubicShape.currentCorner % 2 === 0 ? root.cornerWidth/2 : -root.cornerWidth/2; relativeControl2Y: root.cornerHeight
                }

                PathLine {
                    x: cubicShape.currentCorner % 2 === 0 ? root.cornerWidth : 0; y: 0
                }
            }

            transform: Rotation {
            origin.x: root.cornerWidth / 2
            origin.y: root.cornerHeight / 2
            angle: currentCorner > 1 ? 180 : 0
            }
        }
    }
    Repeater{
        model: root.cornerType === "rounded" ? root.corners : 0
        delegate: Shape {
            id: roundedShape
            asynchronous: true
            preferredRendererType: Shape.CurveRenderer
            width: root.cornerWidth
            height: root.cornerHeight

            property int currentCorner: modelData

            anchors.right: currentCorner === 0 || currentCorner === 3 ? root.right : undefined
            anchors.left: currentCorner === 1 || currentCorner === 2 ? root.left : undefined
            anchors.top: currentCorner <= 1 ? root.top : undefined
            anchors.bottom: currentCorner > 1 ? root.bottom : undefined

            ShapePath {
                startX: 0
                startY: 0
                strokeWidth: -1
                fillColor: root.color

                PathLine {x: root.cornerWidth; y: 0 }
                PathLine { x: root.cornerWidth; y: root.cornerHeight }
                PathArc { 
                    x: 0; y: 0
                    radiusX: root.cornerWidth; radiusY: root.cornerHeight
                }
            } 
            transform: Rotation {
                origin.x: root.cornerWidth / 2
                origin.y: root.cornerHeight / 2
                angle: currentCorner*-90
                } 
        }       
    }

    Repeater{
        model: root.cornerType === "inverted" ? root.corners : 0
        delegate: Shape {
            id: invertedShape
            asynchronous: true
            preferredRendererType: Shape.CurveRenderer
            width: root.cornerWidth
            height: root.cornerHeight

            property int currentCorner: modelData

            anchors.right: currentCorner === 0 || currentCorner === 3 ? root.right : undefined
            anchors.left: currentCorner === 1 || currentCorner === 2 ? root.left : undefined
            anchors.top: currentCorner <= 1 ? root.top : undefined
            anchors.bottom: currentCorner > 1 ? root.bottom : undefined

            ShapePath {
                startX: 0
                startY: 0
                strokeWidth: -1
                fillColor: root.color

                PathArc { 
                    x: root.cornerWidth; y: root.cornerHeight
                    radiusX: root.cornerWidth; radiusY: root.cornerHeight
                }
                PathLine { x: root.cornerWidth; y: 0}
            } 
            transform: Rotation {
                origin.x: root.cornerWidth / 2
                origin.y: root.cornerHeight / 2
                angle: currentCorner*-90
                } 
        }       
    }
}
    