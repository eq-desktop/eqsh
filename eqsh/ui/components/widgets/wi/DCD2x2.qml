import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs
import qs.config
import qs.ui.controls.providers

BaseWidget {
    content: Item {
        id: root

        RowLayout {
            id: layout
            anchors.top: parent.top
            anchors.topMargin: 15
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 10
            Text {
                id: day
                color: AccentColor.color
                font.pixelSize: 20
                font.weight: 600
                text: Time.getTime("ddd").replace(/\.$/, "")
            }
            Text {
                id: mon
                color: Config.general.darkMode ? "#fff" : "#222"
                font.pixelSize: 20
                font.weight: 600
                text: Time.getTime("MMM").replace(/\.$/, "")
            }
        }
        Text {
            id: daynum
            anchors.top: layout.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: Config.general.darkMode ? "#fff" : "#222"
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 60
            font.weight: 400
            text: Time.getTime("dd")
        }
    }
}
