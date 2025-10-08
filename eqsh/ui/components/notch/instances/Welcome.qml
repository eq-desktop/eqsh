import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    id: root
    details.version: "0.1.1"
    meta.width: 300
    meta.height: 150
    meta.startScale: 0.8
    notchState: "active"
    Item {
        anchors.fill: parent
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
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/smiley.svg")
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
            text: Translation.tr("Welcome")
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
            text: Translation.tr("to Equora")
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
            text: Translation.tr("(click to close)")
            color: "#80ffffff"
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                notch.closeNotchInstance(meta.id)
                Config.account.firstTimeRunning = false
            }
        }
    }
}
