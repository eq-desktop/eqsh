import Quickshell
import QtQuick
import QtQuick.Effects
import qs.Config

Image {
    id: root
    source: Config.wallpaper.path
    fillMode: Image.PreserveAspectCrop
    anchors.fill: parent

    property bool  blurEnabled: false
    property real  blur: 0
    property int   blurMax: 64
    property int   duration: 500

    property bool  fadeIn: true

    opacity: fadeIn ? 0 : 1
    Behavior on opacity {
        NumberAnimation { duration: root.duration; easing.type: Easing.InOutQuad}
    }

    Behavior on scale {
        NumberAnimation { duration: root.duration; easing.type: Easing.InOutQuad}
    }


    Component.onCompleted: {
    opacity = 1;
    }

    layer.enabled: true
    layer.effect: MultiEffect {
        anchors.fill: parent
        blurEnabled: root.blurEnabled
        blur: root.blur
        blurMax: root.blurMax
        autoPaddingEnabled: false
        Behavior on blur {
            NumberAnimation { duration: root.duration; easing.type: Easing.InOutQuad}
        }
    }
}