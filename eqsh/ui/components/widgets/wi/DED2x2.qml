import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs
import qs.config
import qs.ui.controls.providers

BaseWidget {
    id: rt
    content: Item {
        id: root
        property int currentSecond: Time.getSeconds()

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
            color: Config.general.darkMode ? "#fff" : "#222"
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 30
            text: Time.getTime("dd")
            anchors.top: daylong.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.topMargin: 16+10
        }

        Text {
            id: events
            color: Config.general.darkMode ? "#aaa" : "#555"
            font.pixelSize: 10
            text: Translation.tr("No events today")
            font.weight: 300
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.bottomMargin: 30
        }
    }
}
