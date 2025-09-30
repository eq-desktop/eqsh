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
import qs.ui.controls.auxiliary
import qs.ui.controls.windows
import qs.config
import qs.ui.components.panel
import qs.ui.controls.providers
import qs
import qs.ui.components.widgets.wi

Item {
    id: root
    anchors.fill: parent
    property int    idVal: 0
    property string name: "Widget"
    property string size: "1x1"
    property var gridContainer
    property bool editable: false
    property int xPos: 0
    property int yPos: 0
    property int newXPos: 0
    property int newYPos: 0
    property var options: {}
    property int gridWidth: gridSizeX * cellsX
    property int gridHeight: gridSizeY * cellsY
    readonly property int sizeF: parseInt(size.split("x")[0]) || 1
    readonly property int sizeS: parseInt(size.split("x")[1]) || 1
    property int sizeW: gridSizeX * sizeF
    property int sizeH: gridSizeY * sizeS
    required property var modelData
    signal widgetMoved()
    // Ghost rectangle
    Control {
        id: ghostRect
        visible: false
        x: gridSizeX * xPos
        y: gridSizeY * yPos
        width: sizeW
        height: sizeH
        padding: 6
        contentItem: Rectangle {
            color: "transparent"
            border.color: "#55ffffff"
            border.width: 2
            radius: 20
        }
    }
    Rectangle {
        id: draggableRect
        width: sizeW
        height: sizeH
        color: root.editable ? "transparent" : "transparent"
        radius: Config.widgets.radius
        x: gridSizeX * xPos
        y: gridSizeY * yPos

        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }

        Behavior on y {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }

        Loader {
            id: loader
            anchors.fill: parent
            property Component bCD2x2: BCD2x2 {}
            property Component bBD4x2: BBD4x2 {}
            property Component cLD2x2: CLD2x2 {}
            property Component bWD2x2: BWD2x2 {}
            property Component dED2x2: DED2x2 {}
            property Component dCD2x2: DCD2x2 {}
            sourceComponent: {
                root.name == "basic-clock-digital-2x2" ? bCD2x2 :
                root.name == "battery-bar-display-4x2" ? bBD4x2 :
                root.name == "calender-display-2x2" ? cLD2x2 :
                root.name == "basic-weather-display-2x2" ? bWD2x2 : 
                root.name == "day-calendar-display-2x2" ? dCD2x2 : 
                root.name == "day-event-display-2x2" ? dED2x2 : undefined
            }
        }

        
        MouseArea {
            anchors.fill: parent
            drag.target: root.editable ? parent : undefined

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