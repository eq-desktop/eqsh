import QtQuick

Item {
    id: root

    property alias frontCard: frontFace
    property alias backCard: backFace

    property alias front: frontFace.children
    property alias back: backFace.children

    property int frontWidth: 180
    property int frontHeight: 180
    property int backWidth: 220
    property int backHeight: 220

    width: frontWidth; height: frontHeight

    transform: Matrix4x4 {
        matrix: Qt.matrix4x4(
            1, 0,    0,   0,
            0, 1,    0,   0,
            0, 0,    1,   0,
            0, 0, 0.002,  1   // perspective
        )
    }

    property real flipAngle: 0
    property real cardScale: 1.0
    property bool isFlipped: false
    property bool isPressed: false

    function goBack() {
        if (!root.isFlipped) return;
        unflip.start();
    }

    function open() {
        if (root.isFlipped) return;
        flip.start();
    }

    function pressDown() {
        if (root.isFlipped) return;
        pressing.start();
        root.isPressed = true;
    }

    function letGo() {
        pressing.stop();
        release.start();
        root.isPressed = false;
    }

    Rectangle {
        id: frontFace
        anchors.fill: parent
        color: "transparent"
        radius: 25
        layer.enabled: true
        visible: root.flipAngle <= 90
        transform: Rotation {
            origin.x: root.width / 2
            origin.y: root.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: root.flipAngle
        }
        scale: root.cardScale
    }

    Rectangle {
        id: backFace
        anchors.fill: parent
        anchors {
            Behavior on leftMargin {
                NumberAnimation { duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
            Behavior on rightMargin {
                NumberAnimation { duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
            Behavior on topMargin {
                NumberAnimation { duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
            Behavior on bottomMargin {
                NumberAnimation { duration: 600; easing.type: Easing.OutBack; easing.overshoot: 1.2 }
            }
        }
        color: "transparent"
        radius: 40
        layer.enabled: true
        visible: root.flipAngle > 90
        transform: Rotation {
            origin.x: root.width / 2
            origin.y: root.height / 2
            axis { x: 0; y: 1; z: 0 }
            angle: root.flipAngle + 180
        }
        scale: root.cardScale
    }

    SequentialAnimation {
        id: pressing
        NumberAnimation {
            target: root; property: "cardScale"
            to: 1.2; duration: 700
            easing.type: Easing.Linear
            easing.overshoot: 1.6
        }
    }

    SequentialAnimation {
        id: release
        NumberAnimation {
            target: root; property: "cardScale"
            to: 1.0; duration: 280
            easing.type: Easing.OutBack
            easing.overshoot: 1.2
        }
    }

    SequentialAnimation {
        id: flip
        ScriptAction { script: root.isFlipped = true }

        ParallelAnimation {
            NumberAnimation {
                target: root; property: "flipAngle"
                from: 0; to: 180; duration: 560
                easing.type: Easing.OutBack
                easing.overshoot: 1.0
            }
            SequentialAnimation {
                NumberAnimation {
                    target: root; property: "cardScale"
                    to: 1.4; duration: 80
                    easing.type: Easing.InQuad
                }
                ParallelAnimation {
                    NumberAnimation {
                        target: root; property: "cardScale"
                        to: 1.0; duration: 280
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                    NumberAnimation {
                        target: root; property: "width"
                        from: root.frontWidth; to: root.backWidth; duration: 280
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                    NumberAnimation {
                        target: root; property: "height"
                        from: root.frontHeight; to: root.backHeight; duration: 280
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: unflip
        ScriptAction { script: root.isFlipped = false }
        ParallelAnimation {
            NumberAnimation {
                target: root; property: "flipAngle"
                from: 180; to: 0; duration: 560
                easing.type: Easing.OutBack
                easing.overshoot: 1.0
            }
            SequentialAnimation {
                ParallelAnimation {
                    NumberAnimation {
                        target: root; property: "cardScale"
                        to: 1.0; duration: 80
                        easing.type: Easing.OutBack
                        easing.overshoot: 1.2
                    }
                    NumberAnimation {
                        target: root; property: "width"
                        from: root.backWidth; to: root.frontWidth; duration: 280
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                    NumberAnimation {
                        target: root; property: "height"
                        from: root.backHeight; to: root.frontHeight; duration: 280
                        easing.type: Easing.OutBack
                        easing.overshoot: 0.5
                    }
                }
            }
        }
    }
}