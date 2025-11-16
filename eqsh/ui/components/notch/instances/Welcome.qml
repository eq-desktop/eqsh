import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    id: root
    details.version: "0.1.2"
    meta.width: 300
    meta.height: 150
    isActive: true
    noMode: true
    indicative: Item {
        CFVI {
            id: scrollIndicator
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
                Behavior on leftMargin {
                    NumberAnimation { duration: Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
                }
            }
            width: 20
            height: 20
            SequentialAnimation {
                id: floatAnim
                loops: Animation.Infinite
                running: true

                NumberAnimation {
                    target: trans
                    property: "y"
                    from: -2
                    to: 2
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }

                NumberAnimation {
                    target: trans
                    property: "y"
                    from: 2
                    to: -2
                    duration: 1000
                    easing.type: Easing.InOutQuad
                }
            }
            transform: Translate {
                id: trans
                y: 0
            }
            icon: "notch/arrow-circle.svg"
        }
        Text {
            text: "Scroll Down"
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            color: "#fff"
            font.pointSize: 12
        }
    }
    active: Item {
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
                Config.account.firstTimeRunning = false
                root.closeMe()
            }
        }
    }
}
