import QtQuick
import Quickshell
import qs.config
import qs.core.system
import qs.ui.controls.primitives
import qs.ui.controls.providers
import qs.ui.controls.auxiliary.notch
import QtQuick.VectorImage
import QtQuick.Effects

NotchApplicationEl2 {
    id: root
    meta.startWidth: notch.defaultWidth
    meta.startHeight: notch.defaultHeight
    meta.width: notch.defaultWidth
    meta.height: notch.defaultHeight
    properties.animDuration: 1000
    noMode: true
    states: ({
        "pop": {
            width: meta.informativeWidth,
            height: meta.informativeHeight,
            offset: {
                x: 0,
                y: 0
            },
            curve: [1.05, 1, 1],
            duration: 500
        }
    })
    indicative: Item {
        CFVI {
            id: lockIcon
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            icon: "lock.svg"
            size: 16
            transformOrigin: Item.Center

            SequentialAnimation {
                id: wiggleAnim
                running: false

                NumberAnimation { target: lockIcon; property: "rotation"; to: -15; duration: 60 }
                NumberAnimation { target: lockIcon; property: "rotation"; to: 15; duration: 120 }
                NumberAnimation { target: lockIcon; property: "rotation"; to: -10; duration: 100 }
                NumberAnimation { target: lockIcon; property: "rotation"; to: 10; duration: 100 }
                NumberAnimation { target: lockIcon; property: "rotation"; to: 0; duration: 80 }
            }
        }

        Connections { target: root
            function onClicked(pressed) {
                if (wiggleAnim.running) return;
                wiggleAnim.restart()
                root.setState("pop")
            }
        }
    }
}
