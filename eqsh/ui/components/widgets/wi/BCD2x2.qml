import QtQuick
import QtQuick.Controls
import qs
import qs.Config
import Quickshell.Widgets
import qs.ui.Controls.providers

Control {
    id: bcd2x2
    anchors.fill: parent
    padding: 10

    contentItem: ClippingRectangle {
        id: root
        radius: Config.widgets.radius
        Rectangle {
            id: bg
            anchors.fill: parent
            scale: 2
            rotation: -20
            gradient: Gradient {
                GradientStop { position: 0.0; color: Config.general.darkMode ? Qt.darker(AccentColor.color, 10) : Qt.lighter(AccentColor.color, 2) }
                GradientStop { position: 1.0; color: Config.general.darkMode ? Qt.darker(AccentColor.color, 6) : Qt.lighter(AccentColor.color, 1.5) }
            }
        }

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
                    ctx.strokeStyle = (i <= root.currentSecond) ? AccentColor.color : (Config.general.darkMode ? "#333" : "#ddd"); // past=white, future=dark

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
            color: Config.general.darkMode ? AccentColor.textColor : AccentColor.color
            font.pixelSize: Math.min(width, height) / 4
            font.weight: Font.Bold
            text: Qt.formatTime(new Date(), "hh:mm")
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }
    }
}
