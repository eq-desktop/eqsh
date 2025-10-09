import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Controls.Fusion
import QtQuick.Effects

Button {
    id: root
    property var appInfo
    property int size: 64
    background: Rectangle {
        color: "transparent"
        width: size
        height: size
    }
    width: size
    height: size
    IconImage {
        id: iconImage
        source: Quickshell.iconPath(appInfo.icon)
        width: root.size - 20
        height: root.size - 20
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        smooth: true
        asynchronous: true
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: "#80000000"   // semi-transparent black
            shadowBlur: 0.5            // how soft the shadow is
            shadowHorizontalOffset: 8
            shadowVerticalOffset: 8
            blurEnabled: true
            blurMax: 32                // max blur radius
        }
    }
    Text {
        id: label
        text: appInfo.name
        font.pixelSize: 12
        color: "white"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
    }
}