import Quickshell
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick
import QtQuick.Controls

Item {
    id: button
    property string text: "Button"
    property var clicked: () => {}
    width: buttonText.contentWidth
    height: 30
    clip: false
    property bool primary: false
    property int radius: 20
    property real rimStrength: 0.4
    property var lightDir: Qt.point(1, 1)
    property string light: "#a0ffffff"
    property bool highlightEnabled: true
    property bool liquid: false
    property string color: "#40000000"
    property string hoverColor: "#555"
    property string primaryColor: AccentColor.color
    property string primaryHoverColor: Qt.lighter(primaryColor, 1.1)
    property real disX: 0
    property real disY: 0
    scale: liquid && mouseArea.containsMouse ? (1+(10/Math.max(width, height))) : 1
    BoxGlass {
        anchors.centerIn: parent
        width: button.width
        height: button.height
        Behavior on width { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
        Behavior on height { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
        rimStrength: button.rimStrength
        radius: button.radius
        lightDir: button.lightDir
        light: button.light
        clip: false
        color: button.primary ? (mouseArea.containsMouse ? button.primaryHoverColor : button.primaryColor) : (mouseArea.containsMouse ? button.hoverColor : button.color)
        highlightEnabled: button.highlightEnabled
    }
    transform: Translate {
        x: button.disX*5
        y: button.disY*5
        Behavior on x { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
        Behavior on y { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
    }
    CFText {
        id: buttonText
        anchors.centerIn: parent
        text: button.text
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            button.clicked()
        }
        onPositionChanged: (mouse) => {
            let dis_from_centerX = (parent.width/2) - mouse.x
            let dis_from_centerY = (parent.height/2) - mouse.y
            let scaleX = 1/parent.width
            let scaleY = 1/parent.height
            scaleX *= 2
            button.disX = -(dis_from_centerX * scaleX)
            button.disY = -(dis_from_centerY * scaleY)
        }
        onExited: {
            button.disX = 0
            button.disY = 0
        }
    }
    Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 3 }}
    Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }}
}