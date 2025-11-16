import QtQuick

Item {
    id: root
    width: 300
    height: 30
    property real radius: 50
    property real fluid: root.radius + 30
    property real bottomLeftRadius: radius
    property real bottomRightRadius: radius
    property real topLeftRadius: radius
    property real topRightRadius: radius
    property color color: "black"

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)

            ctx.fillStyle = root.color
            ctx.beginPath()

            // Top line + top-right cubic
            ctx.moveTo(root.radius, 0)
            ctx.lineTo(root.width + root.fluid - root.topRightRadius, 0)
            ctx.bezierCurveTo(root.width, 0, root.width, 0, root.width, root.topRightRadius)

            // Right line + bottom-right cubic
            ctx.lineTo(root.width, root.height - root.bottomRightRadius)
            ctx.bezierCurveTo(root.width, root.height, root.width, root.height, root.width - root.bottomRightRadius, root.height)

            // Bottom line + bottom-left cubic
            ctx.lineTo(root.bottomLeftRadius, root.height)
            ctx.bezierCurveTo(0, root.height, 0, root.height, 0, root.height - root.bottomLeftRadius)

            // Left line + top-left cubic
            ctx.lineTo(0, root.topLeftRadius)
            ctx.bezierCurveTo(0, 0, 0, 0, root.topLeftRadius - root.fluid, 0)

            ctx.closePath()
            ctx.fill()
        }

        Component.onCompleted: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }
}
