import QtQuick
import QtQuick.Controls
import qs
import qs.Config
import qs.ui.Controls.providers

Control {
    id: bcd2x2
    anchors.fill: parent
    padding: 10

    contentItem: Rectangle {
        id: root
        radius: Config.widgets.radius
        color: "#0a0a0a"

        property int currentSecond: new Date().getSeconds()

        Text {
            id: daylong
            anchors.fill: parent
            color: AccentColor.color
            font.pixelSize: 16
            text: Time.getTime("dddd")
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 10
        }

        Text {
            id: day
            anchors.fill: parent
            color: AccentColor.textColor
            font.pixelSize: 30
            text: Qt.formatDateTime(new Date(), "dd")
            anchors.top: daylong.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 16+10
        }

        Text {
            id: events
            color: "#aaa"
            font.pixelSize: 12
            text: "No events today"
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottomMargin: 30
        }
    }
}
