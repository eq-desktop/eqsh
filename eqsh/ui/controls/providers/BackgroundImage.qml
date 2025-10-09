import Quickshell
import QtQuick
import QtMultimedia
import QtQuick.Effects
import qs.config

Loader {
    anchors.fill: parent
    id: root

    property bool  blurEnabled: false
    property real  blur: 0
    property int   blurMax: 64
    property int   duration: 500


    property string source: Config ? Config?.wallpaper?.path ?? "/usr/share/aureli/Star-Lens.jpg" : "/usr/share/aureli/Star-Lens.jpg"
    property bool  fadeIn: false

    opacity: fadeIn ? 0 : 1
    Behavior on opacity {
        NumberAnimation { duration: root.duration; easing.type: Easing.InOutQuad}
    }

    Behavior on scale {
        NumberAnimation { duration: root.duration; easing.type: Easing.InOutQuad}
    }


    Component.onCompleted: {
        if (fadeIn) {
            opacity = 1;
        }
    }

    property Component color: Rectangle {
        color: Config.wallpaper.color
    }
    property Component image: Image {
        source: root.source
        fillMode: Image.PreserveAspectCrop
        anchors.fill: parent
        asynchronous: true

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
    sourceComponent: Config.wallpaper.path == "" ? color : image
}