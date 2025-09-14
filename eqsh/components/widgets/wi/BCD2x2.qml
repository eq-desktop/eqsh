import QtQuick
import QtQuick.Controls
import qs
import qs.Config
import qs.widgets.providers

Control {
    id: bcd2x2
    anchors.fill: parent
    padding: 10

    contentItem: Rectangle {
        id: root
        radius: Config.widgets.radius
        color: "#000"

        property int currentSecond: new Date().getSeconds()

        Timer {
            interval: 1000
            running: true
            repeat: true
            onTriggered: {
                root.currentSecond = new Date().getSeconds()
                dashCanvas.requestPaint()
                text.text = Qt.formatTime(new Date(), "hh:mm")
            }
        }

        Canvas {
            id: dashCanvas
            anchors.fill: parent
            onPaint: {
                let ctx = getContext("2d");
                ctx.reset();
                ctx.lineWidth = 2;

                let dashCount = 60;
                let r = Math.min(width, height) / 2 - 6;
                let cx = width / 2;
                let cy = height / 2;

                for (let i = 0; i < dashCount; i++) {
                    ctx.strokeStyle = (i <= root.currentSecond) ? AccentColor.color : "#333"; // past=white, future=dark

                    let angle = (i / dashCount) * 2 * Math.PI;
                    let x1 = cx + Math.cos(angle) * r;
                    let y1 = cy + Math.sin(angle) * r;
                    let x2 = cx + Math.cos(angle) * (r - 6);
                    let y2 = cy + Math.sin(angle) * (r - 6);

                    ctx.beginPath();
                    ctx.moveTo(x1, y1);
                    ctx.lineTo(x2, y2);
                    ctx.stroke();
                }
            }
        }

        Text {
            id: text
            anchors.fill: parent
            color: AccentColor.textColor
            font.pixelSize: Math.min(width, height) / 4
            font.weight: Font.Bold
            text: Qt.formatTime(new Date(), "hh:mm")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
