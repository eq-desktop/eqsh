import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs
import qs.config
import qs.ui.controls.providers
import qs.ui.controls.primitives

BaseWidget {
    id: bw
    content: Item {
        id: root

        RowLayout {
            id: layout
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            CFText {
                id: day
                color: Config.appearance.multiAccentColor ? '#ff3838' : AccentColor.color
                font.pixelSize: bw.textSizeXL
                font.weight: 600
                text: Time.getTime("ddd").replace(/\.$/, "")
            }
            CFText {
                id: mon
                color: Config.general.darkMode ? "#666" : "#444"
                font.pixelSize: bw.textSizeXL
                font.weight: 600
                text: Time.getTime("MMM").replace(/\.$/, "")
            }
        }
        CFText {
            id: daynum
            anchors.top: layout.bottom
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: Config.general.darkMode ? "#fff" : "#222"
            font.family: Fonts.sFProDisplayBlack.family
            font.pixelSize: height - 30
            font.weight: 700
            text: Time.getTime("dd")
        }
    }
}
