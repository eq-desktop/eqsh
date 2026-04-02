import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs
import qs.config
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import qs.ui.controls.primitives
import qs.ui.controls.windows

UILiquid {
    id: root

    required property bool actionsShown
    required property bool launcherVisible
    required property string textColor
    required property string glassColor

    signal hoveredAction(string action)
    signal selectedAction(string action)

    property int position: 0
    property int iconSize: 32
    property string action: "applications"
    property real positionX: 270 + (root.actionsShown && root.launcherVisible ? (parent.width / 2 - 170) + (68*root.position) : (parent.width / 2 - 270))
    z: 1
    anchors {
        left: parent.left
        leftMargin: root.positionX
        Behavior on leftMargin { NumberAnimation { duration: 250 } }
        top: parent.top
        topMargin: 200
    }
    onEntered: root.hoveredAction(root.actionsShown && root.launcherVisible ? root.action : "")
    onClicked: root.selectedAction(root.action)
    width: 58; height: 58
    BoxGlass {
        anchors.centerIn: parent
        radius: 30; width: 58; height: 58
        color: root.glassColor
        rimStrength: 0.2
        light: "#20ffffff"; lightDir: Qt.point(1, 1)
        layer.enabled: true
        visible: true
        scale: root.actionsShown && root.launcherVisible ? 1 : 0
        opacity: root.actionsShown && root.launcherVisible ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 } }
        Behavior on opacity { NumberAnimation { duration: 200 } }
        layer.effect: MultiEffect {
            blurEnabled: blur != 0
            blurMax: 64
            blur: root.actionsShown && root.launcherVisible ? 0 : 1
            Behavior on blur { NumberAnimation { duration: 350 } }
        }
        CFVI {
            anchors.centerIn: parent
            id: appIcon
            icon: `spotlight/${root.action}.svg`
            size: root.iconSize
            color: root.textColor
        }
    }
}