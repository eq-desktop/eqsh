import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Item {
    id: box

    property color color: "#22ffffff"
    property int borderSize: 1
    property color borderColor: '#22ffffff'
    property string highlight: 'rgba(255, 255, 255, 0.5)'
    property string weakHighlight: 'rgba(255, 255, 255, 0.3)'

    // Individual corner radii
    property int radius: 20
    property int topLeftRadius: radius
    property int topRightRadius: radius
    property int bottomRightRadius: radius
    property int bottomLeftRadius: radius

    property int animationSpeed: 50
    property int animationSpeed2: 25

    Behavior on color { PropertyAnimation { duration: animationSpeed; easing.type: Easing.InSine } }
    Behavior on highlight { PropertyAnimation { duration: animationSpeed2; easing.type: Easing.InSine } }
    Behavior on weakHighlight { PropertyAnimation { duration: animationSpeed2; easing.type: Easing.InSine } }

    onColorChanged: canvas.requestPaint();
    onBorderColorChanged: canvas.requestPaint();
    onTopLeftRadiusChanged: canvas.requestPaint();
    onTopRightRadiusChanged: canvas.requestPaint();
    onBottomRightRadiusChanged: canvas.requestPaint();
    onBottomLeftRadiusChanged: canvas.requestPaint();
    onHighlightChanged: canvas.requestPaint();

    Canvas {
        id: canvas
        anchors.fill: parent

        onPaint: {
            const ctx = getContext("2d");
            const w = width;
            const h = height;

            const tl = Math.max(0, Math.min(topLeftRadius, Math.min(w, h) / 2));
            const tr = Math.max(0, Math.min(topRightRadius, Math.min(w, h) / 2));
            const br = Math.max(0, Math.min(bottomRightRadius, Math.min(w, h) / 2));
            const bl = Math.max(0, Math.min(bottomLeftRadius, Math.min(w, h) / 2));

            ctx.reset();
            ctx.clearRect(0, 0, w, h);
            ctx.save();

            // Rounded rect path (per-corner radii)
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

            // Stroke border
            ctx.strokeStyle = borderColor;
            ctx.lineWidth = 1;
            ctx.stroke();

            // Highlight lines
            const y = 0.5;
            const bottomY = h - 0.5;

            const topGradient = ctx.createLinearGradient(tl, y, w - tr, y);
            topGradient.addColorStop(0, highlight !== "transparent" ? weakHighlight : 'transparent');
            topGradient.addColorStop(1, 'rgba(255, 255, 255, 0)');
            const bottomGradient = ctx.createLinearGradient(bl, bottomY, w - br, bottomY);
            bottomGradient.addColorStop(0, 'rgba(255, 255, 255, 0)');
            bottomGradient.addColorStop(1, highlight !== "transparent" ? weakHighlight : 'transparent');

            // Top highlight
            ctx.beginPath();
            ctx.moveTo(tl, y);
            ctx.lineTo(w - tr, y);
            ctx.strokeStyle = topGradient;
            ctx.lineWidth = 1;
            ctx.stroke();

            // Top-left corner highlight
            ctx.beginPath();
            ctx.moveTo(tl, 0);
            ctx.arcTo(0, 0, 0, tl, tl);
            ctx.strokeStyle = highlight !== "transparent" ? highlight : 'transparent';
            ctx.lineWidth = 1;
            ctx.stroke();

            // Bottom highlight
            ctx.beginPath();
            ctx.moveTo(bl, bottomY);
            ctx.lineTo(w - br, bottomY);
            ctx.strokeStyle = bottomGradient;
            ctx.lineWidth = 1;
            ctx.stroke();

            // Bottom-right corner highlight
            ctx.beginPath();
            ctx.moveTo(w - br, h);
            ctx.arcTo(w, h, w, h - br, br);
            ctx.strokeStyle = highlight !== "transparent" ? highlight : 'transparent';
            ctx.lineWidth = 1;
            ctx.stroke();

            ctx.restore();
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        Component.onCompleted: requestPaint()
    }
}
