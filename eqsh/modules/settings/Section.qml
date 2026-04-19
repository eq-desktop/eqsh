import QtQuick
import QtQuick.Layouts
import qs.config
Item {
    Layout.fillWidth: true
    height: 120
    default property alias content: content.children
    Rectangle {
        id: content
        anchors.fill: parent
        color: Config.general.darkMode ? "#222" : "#f8f8f8"
        radius: 15
    }
}