import Quickshell
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick
import QtQuick.Controls

Button {
    id: button
    height: 30
    property bool primary: false
    property bool highlightEnabled: !button.primary
    property string color: "#40000000"
    property string hoverColor: "#40FFFFFF"
    property string primaryColor: AccentColor.color
    property string primaryHoverColor: Qt.lighter(primaryColor, 1.3)
    background: BoxGlass {
        anchors.fill: parent
        color: button.primary ? (mouseArea.containsMouse ? button.primaryHoverColor : button.primaryColor) : (mouseArea.containsMouse ? button.hoverColor : button.color)
        glowStrength: 0.5
        highlightEnabled: button.highlightEnabled
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            button.clicked()
        }
    }
    palette.buttonText: "white"
    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }}
    Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }}
}