import Quickshell
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick
import QtQuick.Controls

Item {
    id: root
    clip: false
    property alias mouseCapture: mouseArea
    property bool hovered: mouseArea.containsMouse
    property bool stretching: true
    property bool stretchingX: stretching
    property bool stretchingY: stretching
    property bool resizing: false
    property real disX: 0
    property real disY: 0
    property int translateModifierX: 0
    property int translateModifierY: 0
    property real scaleModifier: 1
    property real requestedW: 0
    property real requestedH: 0
    property point requestedMoveVector: Qt.point(-20, -20)
    signal clicked(var mouse)
    scale: mouseArea.containsMouse ? (scaleModifier+(10/Math.max(width, height))) : 1
    transform: [
        Scale {
            origin.x: root.width/2
            origin.y: root.height/2
            xScale: root.stretchingX ? 1+Math.abs(root.disX/10) : 1
            yScale: root.stretchingY ? 1+Math.abs(root.disY/10) : 1
            Behavior on xScale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
            Behavior on yScale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1.5 } }
        },
        Translate {
            x: (root.disX*5)+root.translateModifierX
            y: (root.disY*5)+root.translateModifierY
            Behavior on x { NumberAnimation { duration: 150; } }
            Behavior on y { NumberAnimation { duration: 150; } }
        }
    ]
    Behavior on scale { NumberAnimation { duration: resizing ? 500 : 300; easing.type: Easing.OutBack; easing.overshoot: 3 }}
    Behavior on opacity { NumberAnimation { duration: 500; easing.type: Easing.InOutQuad }}
    //Behavior on width { NumberAnimation { duration: 200; easing.type: Easing.InOutBack }}
    //Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.InOutBack }}
    function sizeTo(w, h, moveVec) {
        root.requestedW = w
        root.requestedH = h
        root.requestedMoveVector = moveVec
        sizeChangeAnim.restart()
    }
    SequentialAnimation {
        id: sizeChangeAnim
        PropertyAction {
            target: root
            property: "resizing"
            value: true
        }
        ParallelAnimation {
            PropertyAnimation {
                target: root
                property: "width"
                to: root.requestedW
                duration: 300
                easing.type: Easing.InOutBack
            }
            PropertyAnimation {
                target: root
                property: "height"
                to: root.requestedH
                duration: 300
                easing.type: Easing.InOutBack
            }
            PropertyAction {
                target: root
                property: "scaleModifier"
                value: 0.8
            }
            SequentialAnimation {
                ParallelAnimation {
                    PropertyAction {
                        target: root
                        property: "translateModifierX"
                        value: root.requestedMoveVector.x
                    }
                    PropertyAction {
                        target: root
                        property: "translateModifierY"
                        value: root.requestedMoveVector.y
                    }
                }
                PauseAnimation { duration: 150 }
                ParallelAnimation {
                    PropertyAction {
                        target: root
                        property: "translateModifierX"
                        value: 0
                    }
                    PropertyAction {
                        target: root
                        property: "translateModifierY"
                        value: 0
                    }
                }
                PropertyAction {
                    target: root
                    property: "scaleModifier"
                    value: 1
                }
            }
        }
        PropertyAction {
            target: root
            property: "resizing"
            value: false
        }
    }
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: (mouse) => {
            root.clicked(mouse)
        }
        onPressed: (mouse) => {
            if (root.resizing) return
            root.scaleModifier = 0.9
        }
        onReleased: (mouse) => {
            if (root.resizing) return
            root.scaleModifier = 1
        }
        onPositionChanged: (mouse) => {
            let dis_from_centerX = (parent.width/2) - mouse.x
            let dis_from_centerY = (parent.height/2) - mouse.y
            let scaleX = 1/parent.width
            let scaleY = 1/parent.height
            scaleX *= 2
            root.disX = -(dis_from_centerX * scaleX)
            root.disY = -(dis_from_centerY * scaleY)
        }
        onExited: {
            root.disX = 0
            root.disY = 0
        }
    }
}