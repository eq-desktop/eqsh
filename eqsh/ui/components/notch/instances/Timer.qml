import QtQuick
import Quickshell
import qs.config
import qs
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.auxiliary
import qs.ui.components.panel
import QtQuick.VectorImage
import QtQuick.Controls
import QtQuick.Effects

NotchApplication {
    id: root
    details.version: "0.1.1"
    details.appType: "media"
    meta.height: 60
    meta.width: 300

    property int remainingMs: 5 * 60 * 1000 // default 5 min
    property bool editing: false
    property string time: "05:00"

    Timer {
        id: timer
        interval: 1000
        running: false
        repeat: true
        onTriggered: {
            if (remainingMs > 0) {
                remainingMs -= 1000
                let minutes = Math.floor(remainingMs / 60000)
                let seconds = Math.floor((remainingMs % 60000) / 1000)
                root.time =
                    minutes.toString().padStart(2, '0') + ":" +
                    seconds.toString().padStart(2, '0')
            } else {
                timer.stop()
            }
        }
    }

    function resetTimeFromString(t) {
        let parts = t.split(":")
        if (parts.length === 2) {
            let m = parseInt(parts[0])
            let s = parseInt(parts[1])
            if (!isNaN(m) && !isNaN(s)) {
                remainingMs = (m * 60 + s) * 1000
                root.time = t
            }
        }
    }

    indicative: Item {
        Rectangle {
            id: indIndicator
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            width: 14
            height: 14
            radius: 7
            border.width: 4
            border.color: "#33ff9100"
            color: "#ff4925"
        }

        Text {
            id: indTimerText
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            color: "#ff4925"
            text: root.time
            font.family: Fonts.sFProMonoRegular.family
            font.pixelSize: 20
        }
    }

    active: Item {
        anchors.fill: parent

        // TIMER TEXT / INPUT SWITCHER
        Loader {
            id: timerDisplay
            anchors {
                right: parent.right
                rightMargin: 20
                verticalCenter: parent.verticalCenter
            }
            sourceComponent: root.editing ? editField : timerLabel
        }

        Component {
            id: timerLabel
            Text {
                id: timerText
                text: root.time
                color: "#ff4925"
                font.family: Fonts.sFProMonoRegular.family
                font.pixelSize: 20

                MouseArea {
                    anchors.fill: parent
                    onDoubleClicked: root.editing = true
                    hoverEnabled: true
                    cursorShape: Qt.IBeamCursor
                }
            }
        }

        Component {
            id: editField
            TextInput {
                id: inputField
                text: root.time
                color: "#ff4925"
                font.family: Fonts.sFProMonoRegular.family
                font.pixelSize: 20
                focus: true
                selectByMouse: true
                inputMask: "99:99"
                onAccepted: {
                    root.resetTimeFromString(text)
                    root.editing = false
                }
                onEditingFinished: {
                    root.resetTimeFromString(text)
                    root.editing = false
                }
            }
        }

        // START / PAUSE BUTTON
        Button {
            id: startButton
            width: 40
            height: 40
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            background: Rectangle {
                anchors.fill: parent
                color: "#30ff4925"
                radius: 99
                VectorImage {
                    source: timer.running
                            ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/pause.svg")
                            : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/play.svg")
                    width: 25
                    height: 25
                    preferredRendererType: VectorImage.CurveRenderer
                    anchors.centerIn: parent
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        colorization: 1
                        colorizationColor: "#ff4925"
                    }
                }
            }
            onClicked: {
                if (timer.running) {
                    timer.stop()
                } else {
                    timer.start()
                }
            }
        }

        // CLOSE BUTTON
        MouseArea {
            width: 40
            height: 40
            anchors {
                left: startButton.right
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            onClicked: notch.closeNotchInstance(meta.id)

            Rectangle {
                id: closeButton
                anchors.fill: parent
                color: '#20ffffff'
                radius: 99
                VectorImage {
                    id: rBClose
                    source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/notch/x.svg")
                    width: 25
                    height: 25
                    preferredRendererType: VectorImage.CurveRenderer
                    anchors.centerIn: parent
                }
            }
        }
    }
}
