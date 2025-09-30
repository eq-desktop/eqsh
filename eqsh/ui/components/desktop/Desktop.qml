import Quickshell
import QtQuick

Item {
    id: root
    anchors.fill: parent

    property real startX: 0
    property real startY: 0

    PropertyAnimation {
        id: showAnim
        target: selectionBox
        property: "opacity"
        from: 0
        to: 1
        duration: 0
    }

    PropertyAnimation {
        id: hideAnim
        target: selectionBox
        property: "opacity"
        from: 1
        to: 0
        duration: 125
    }

    Rectangle {
        id: selectionBox
        visible: true
        color: "#50ffffff"
        opacity: 0
        border.color: "#80333333"
        border.width: 1
        radius: 5
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        onPressed: (mouse) => {
            root.startX = mouse.x
            root.startY = mouse.y

            selectionBox.x = root.startX
            selectionBox.y = root.startY
            selectionBox.width = 0
            selectionBox.height = 0
            showAnim.running = true
        }

        onPositionChanged: (mouse) => {
            selectionBox.x = Math.min(mouse.x, root.startX)
            selectionBox.y = Math.min(mouse.y, root.startY)
            selectionBox.width = Math.abs(mouse.x - root.startX)
            selectionBox.height = Math.abs(mouse.y - root.startY)
        }

        onReleased: (mouse) => {
            hideAnim.running = true
        }
    }
}
