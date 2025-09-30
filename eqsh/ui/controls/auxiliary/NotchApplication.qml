import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs.ui.controls.providers
import QtQuick.VectorImage
import QtQuick.Effects

Item {
    id: root
    property Details details: Details {}
    property Meta meta: Meta {}

    Rectangle {
        id: notchBg
        anchors.fill: parent
        color: Config.notch.backgroundColor
        topLeftRadius: Config.notch.islandMode ? Config.notch.radius : 0
        topRightRadius: Config.notch.islandMode ? Config.notch.radius : 0
        bottomLeftRadius: Config.notch.radius
        bottomRightRadius: Config.notch.radius
    }

    component Meta: QtObject {
        property int  width: notch.defaultWidth
        property int  height: notch.defaultHeight
        property real startScale: 1
        property real startOpacity: 0
        property int  animDuration: 500
        property int  closeAfterMs: -1 // -1 to disable auto-close
        property var  id: null
    }
    component Details: QtObject {
        property string version: "0.1.0"
        property string shadowColor: "#000000"
        property string appType: "indicator" // indicator, alert, media
    }
    anchors.fill: parent
    opacity: meta.startOpacity
    scale: meta.startScale
    Component.onCompleted: {
        notch.setSize(meta.width, meta.height)
        opacity = 1
        scale = 1
    }
    Behavior on opacity {
        NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    Behavior on scale {
        NumberAnimation { duration: meta.animDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    property var runningNotchInstances: notch.runningNotchInstances
    onRunningNotchInstancesChanged: {
        if (meta.id !== null) {
            if (!runningNotchInstances.includes(meta.id)) {
                root.destroy()
            }
        }
    }
    Timer {
        interval: meta.closeAfterMs
        running: meta.closeAfterMs !== -1
        repeat: false
        onTriggered: {
            notch.closeNotchInstance(meta.id)
        }
    }
}
