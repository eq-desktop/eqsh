import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs
import qs.config
import qs.ui.controls.providers
import qs.ui.controls.primitives

BaseWidget {
    id: bw
    content: Item {
        id: root
        property int currentSecond: Time.getSeconds()

        CFText {
            id: daylong
            anchors.fill: parent
            color: Config.appearance.multiAccentColor ? '#ff3838' : AccentColor.color
            font.pixelSize: bw.textSizeL
            text: Time.getTime("dddd")
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.topMargin: 15
        }

        CFText {
            id: day
            anchors.fill: parent
            color: Config.general.darkMode ? "#fff" : "#222"
            font.pixelSize: bw.textSizeXXL
            text: Time.getTime("dd")
            anchors.top: daylong.bottom
            anchors.topMargin: bw.textSizeL+15
            anchors.left: parent.left
            anchors.leftMargin: 15
        }

        CFText {
            id: events
            color: Config.general.darkMode ? "#aaa" : "#555"
            font.pixelSize: bw.textSize
            text: Translation.tr("No events today")
            font.weight: 300
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 15
            anchors.bottomMargin: 30
        }
    }
}
