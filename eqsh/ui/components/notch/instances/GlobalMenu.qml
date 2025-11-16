import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.config
import qs
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import qs.ui.components.panel
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplication {
    details.version: "0.1.0"
    details.appType: "media"
    meta.height: notch.defaultHeight+60
    meta.width: 400
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
    active: RowLayout {
        uniformCellSizes: true
        anchors {
            left: parent.left
            verticalCenter: parent.verticalCenter
        }
        width: 200
        Text {
            id: fileText
            color: "#fff"
            text: Translation.tr("File")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: editText
            color: "white"
            text: Translation.tr("Edit")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: viewText
            color: "white"
            text: Translation.tr("View")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: goText
            color: "white"
            text: Translation.tr("Go")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: windowText
            color: "white"
            text: Translation.tr("Window")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
        Text {
            id: helpText
            color: "white"
            text: Translation.tr("Help")
            font.family: Fonts.sFProDisplayRegular.family
            font.pixelSize: 15
        }
    }
}
