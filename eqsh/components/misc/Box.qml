import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: box

    property color color: "#01ffffff"
    property int borderSize: 1
    property string highlight: '#aaffffff'
    property string weakHighlight: 'transparent'

    // Individual corner radii
    property int radius: 20
    property int topLeftRadius: radius
    property int topRightRadius: radius
    property int bottomRightRadius: radius
    property int bottomLeftRadius: radius

    property int animationSpeed: 16
    property int animationSpeed2: 16

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    Behavior on highlight { PropertyAnimation { duration: animationSpeed2; easing.type: Easing.InSine } }
    Behavior on weakHighlight { PropertyAnimation { duration: animationSpeed2; easing.type: Easing.InSine } }

    onColorChanged: canvas.requestPaint();
    onTopLeftRadiusChanged: canvas.requestPaint();
    onTopRightRadiusChanged: canvas.requestPaint();
    onBottomRightRadiusChanged: canvas.requestPaint();
    onBottomLeftRadiusChanged: canvas.requestPaint();
    onHighlightChanged: canvas.requestPaint();
    onWeakHighlightChanged: canvas.requestPaint();
    onWidthChanged: canvas.requestPaint();
    onHeightChanged: canvas.requestPaint();
    

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d");
            const w = width - 2;
            const h = height - 2;

            const tl = Math.max(0, Math.min(topLeftRadius, Math.min(w, h) / 2));
            const tr = Math.max(0, Math.min(topRightRadius, Math.min(w, h) / 2));
            const br = Math.max(0, Math.min(bottomRightRadius, Math.min(w, h) / 2));
            const bl = Math.max(0, Math.min(bottomLeftRadius, Math.min(w, h) / 2));

            ctx.reset();
            ctx.clearRect(0, 0, width, height); // clear whole canvas
            ctx.save();

            // offset everything so stroke is centered
            ctx.translate(1, 1);

            // Rounded rect path
            ctx.beginPath();
            ctx.moveTo(tl, 0);
            ctx.lineTo(w - tr, 0);
            ctx.arcTo(w, 0, w, tr, tr);
            ctx.lineTo(w, h - br);
            ctx.arcTo(w, h, w - br, h, br);
            ctx.lineTo(bl, h);
            ctx.arcTo(0, h, 0, h - bl, bl);
            ctx.lineTo(0, tl);
            ctx.arcTo(0, 0, tl, 0, tl);
            ctx.closePath();

            // Fill
            ctx.fillStyle = color;
            ctx.fill();

            // === Highlights ===
            ctx.beginPath();
            ctx.moveTo(tl, 0);
            ctx.lineTo(w - tr, 0);
            ctx.arcTo(w, 0, w, tr, tr);
            ctx.lineTo(w, h - br);
            ctx.arcTo(w, h, w - br, h, br);
            ctx.lineTo(bl, h);
            ctx.arcTo(0, h, 0, h - bl, bl);
            ctx.lineTo(0, tl);
            ctx.arcTo(0, 0, tl, 0, tl);
            ctx.closePath();

            ctx.strokeStyle = highlight;
            ctx.lineWidth = 1;
            ctx.stroke();
            ctx.lineWidth = 0.5;

            // Erase
            ctx.globalCompositeOperation = "destination-out";

            // Top-right corner cut
            ctx.beginPath();
            ctx.moveTo(w - tr, 0);
            ctx.arcTo(w, 0, w, tr, tr);
            ctx.lineTo(w, 0);
            ctx.closePath();
            ctx.strokeStyle = "black";
            ctx.stroke();

            // Bottom-left corner cut
            ctx.beginPath();
            ctx.moveTo(0, h - bl);
            ctx.arcTo(0, h, bl, h, bl);
            ctx.lineTo(0, h);
            ctx.closePath();
            ctx.strokeStyle = "black";
            ctx.stroke();

            // Reset mode
            ctx.globalCompositeOperation = "source-over";

            // === "Dim" gradients ===
            // Top-right dim
            let trGrad = ctx.createRadialGradient(w, 0, 0, w, 0, tr * 2);
            trGrad.addColorStop(0, weakHighlight ? weakHighlight : "transparent");
            trGrad.addColorStop(0.1, weakHighlight ? weakHighlight : "transparent");
            trGrad.addColorStop(1, highlight ? highlight : "transparent");

            ctx.beginPath();
            ctx.moveTo(w - tr, 0);
            ctx.arcTo(w, 0, w, tr, tr);
            ctx.strokeStyle = trGrad;
            ctx.lineWidth = 2;
            ctx.stroke();

            // Bottom-left dim
            let blGrad = ctx.createRadialGradient(0, h, 0, 0, h, bl * 2);
            blGrad.addColorStop(0, weakHighlight ? weakHighlight : "transparent");
            blGrad.addColorStop(0.1, weakHighlight ? weakHighlight : "transparent");
            blGrad.addColorStop(1, highlight ? highlight : "transparent");

            ctx.beginPath();
            ctx.moveTo(0, h - bl);
            ctx.arcTo(0, h, bl, h, bl);
            ctx.strokeStyle = blGrad;
            ctx.lineWidth = 2;
            ctx.stroke();


            ctx.restore();

        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
    }
}
