import QtQuick
import qs.ui.controls.primitives

Rectangle {
    id: root
    property string key: "⌘"
    property string keyColor: "#fff"
    width: 24
    height: 24
    radius: 8
    color: "#20ffffff"
    CFText {
        anchors.centerIn: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: root.key
        font.weight: Font.Bold
        font.pixelSize: 18
        color: root.keyColor
    }
}