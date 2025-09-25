import QtQuick
import Quickshell
import qs.Config
import qs.Core.System
import qs.ui.Controls.providers
import QtQuick.VectorImage
import QtQuick.Effects

Rectangle {
    anchors.fill: parent
    color: "transparent"
    scale: 0.8
    opacity: 0
    Component.onCompleted: {
        scale = 1
        opacity = 1
    }
    Behavior on scale {
        NumberAnimation { duration: Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    Behavior on opacity {
        NumberAnimation { duration: Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
    }
    VectorImage {
        id: welcomeIcon
        width: 60
        height: 60
        preferredRendererType: VectorImage.CurveRenderer
        anchors {
            left: parent.left
            leftMargin: 30
            verticalCenter: parent.verticalCenter
        }
        source: Qt.resolvedUrl(Quickshell.shellDir + "/Media/icons/smiley.svg")
        rotation: 0
        layer.enabled: true
        layer.effect: MultiEffect {
            anchors.fill: welcomeIcon
            colorization: 1
            colorizationColor: AccentColor.color
        }
    }

    Text {
        id: welcomeText
        anchors {
            left: welcomeIcon.right
            leftMargin: 10
            top: welcomeIcon.top
            topMargin: -8
        }
        text: "Welcome"
        color: "white"
        font.pixelSize: 32
    }

    Text {
        id: welcomeText2
        anchors {
            left: welcomeText.left
            top: welcomeText.bottom
        }
        font.family: Fonts.sFProRounded.family
        text: "to Equora"
        color: "white"
        font.pixelSize: 16
    }

    Text {
        id: closeText
        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 10
        }
        font.family: Fonts.sFProRounded.family
        text: "(click to close)"
        color: "#80ffffff"
        font.pixelSize: 12
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            customNotchHide()
            temporaryResizeReset()
            Config.account.firstTimeRunning = false
        }
    }
}
