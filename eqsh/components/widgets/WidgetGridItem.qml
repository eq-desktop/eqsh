import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell
import qs.widgets.misc
import qs.widgets.windows
import qs.config
import qs.components.panel
import qs.widgets.providers
import qs

Item {
    id: root
    anchors.fill: parent
    property int    idVal: 0
    property string name: "Widget"
    property string size: "1x1"
    property var gridContainer
    property int xPos: 0
    property int yPos: 0
    property int newXPos: 0
    property int newYPos: 0
    property int gridWidth: gridSizeX * cellsX
    property int gridHeight: gridSizeY * cellsY
    readonly property int sizeF: parseInt(size.split("x")[0]) || 1
    readonly property int sizeS: parseInt(size.split("x")[1]) || 1
    property int sizeW: gridSizeX * sizeF
    property int sizeH: gridSizeY * sizeS
    required property var modelData
    signal widgetMoved()
    // Ghost rectangle
    Rectangle {
        id: ghostRect
        width: sizeW
        height: sizeH
        color: "#22000000"
        border.color: "#55ffffff"
        border.width: 3
        radius: 8
        visible: false
        x: gridSizeX * xPos
        y: gridSizeY * yPos
    }
    Rectangle {
        id: draggableRect
        width: sizeW
        height: sizeH
        color: "#4488ff"
        radius: 8
        x: gridSizeX * xPos
        y: gridSizeY * yPos

        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }

        Behavior on y {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }

        Text {
            anchors.centerIn: parent
            text: root.name == "basic-clock-digital-2x2" ? "Clock" : sizeF + "x" + sizeS
            font.pixelSize: 12
        }

        MouseArea {
            anchors.fill: parent
            drag.target: parent

            property int gridXPos: 0
            property int gridYPos: 0

            drag.minimumX: 0
            drag.maximumX: gridWidth - draggableRect.width
            drag.minimumY: 0
            drag.maximumY: gridHeight - draggableRect.height

            onPressed: ghostRect.visible = true

            onPositionChanged: {
                // Update ghost to show where it would snap
                gridXPos = Math.round(draggableRect.x / gridSizeX)
                gridYPos = Math.round(draggableRect.y / gridSizeY)
                ghostRect.x = gridXPos * gridSizeX
                ghostRect.y = gridYPos * gridSizeY
            }

            onReleased: {
                // Snap rectangle to grid
                root.newXPos = gridXPos
                root.newYPos = gridYPos
                draggableRect.x = gridXPos * gridSizeX
                draggableRect.y = gridYPos * gridSizeY
                ghostRect.visible = false
                widgetMoved();
            }
        }
    }
}