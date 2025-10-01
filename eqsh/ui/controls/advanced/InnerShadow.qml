import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects

Item {
    id: root
    anchors.fill: parent
    property real   radius: parent.radius
    property string color: "black"
    property int    strength: 1
    property real   blur: 0.5
    property real   blurMax: 32
    property real   shadowOpacity: 1
    property int    offsetX: 0
    property int    offsetY: 0
    ClippingRectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"
        Rectangle {
            anchors.fill: parent
            anchors.leftMargin: root.offsetX - root.strength
            anchors.rightMargin: -root.offsetX - root.strength
            anchors.topMargin: root.offsetY - root.strength
            anchors.bottomMargin: -root.offsetY - root.strength
            color: "transparent"
            opacity: root.shadowOpacity
            radius: root.radius
            border.color: root.color
            border.width: root.strength*2
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: root.blur
                blurMax: root.blurMax
            }
        }
    }
}