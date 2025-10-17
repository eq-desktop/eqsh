import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick.VectorImage
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell
import qs.ui.controls.auxiliary
import qs.ui.controls.windows
import qs.ui.controls.windows.dropdown
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
    property var screen
    property bool editMode: false
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
    required property var deleteWidget
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
    onEditModeChanged: {
        draggableRect.rotation = 0
    }
    Rectangle {
        id: draggableRect
        width: sizeW
        height: sizeH
        color: root.editMode ? "transparent" : "transparent"
        radius: Config.widgets.radius
        x: gridSizeX * xPos
        y: gridSizeY * yPos

        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }

        Behavior on y {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }

        property real wobbleAmp: 1.5 + Math.random()
        property int wobbleSpeed: 100 + Math.random() * 50
        property real wobbleDir: Math.random() < 0.5 ? 1 : -1

        transformOrigin: Item.Center

        SequentialAnimation on rotation {
            id: wobbleAnim
            loops: Animation.Infinite
            running: root.editMode
            NumberAnimation { to: draggableRect.wobbleAmp * draggableRect.wobbleDir; duration: draggableRect.wobbleSpeed; easing.type: Easing.InOutQuad }
            NumberAnimation { to: -draggableRect.wobbleAmp * draggableRect.wobbleDir; duration: draggableRect.wobbleSpeed * 2; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 0; duration: draggableRect.wobbleSpeed; easing.type: Easing.InOutQuad }
        }

        Behavior on rotation {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        Loader {
            id: loader
            anchors.fill: parent
            property Component bCD2x2: BCD2x2 { widget: root; screen: root.screen }
            property Component bBD4x2: BBD4x2 { widget: root; screen: root.screen }
            property Component cLD2x2: CLD2x2 { widget: root; screen: root.screen }
            property Component bWD2x2: BWD2x2 { widget: root; screen: root.screen }
            property Component dED2x2: DED2x2 { widget: root; screen: root.screen }
            property Component dCD2x2: DCD2x2 { widget: root; screen: root.screen }
            property Component bID2x2: BID2x2 { widget: root; screen: root.screen }
            sourceComponent: {
                root.name == "basic-clock-digital-2x2" ? bCD2x2 :
                root.name == "battery-bar-display-4x2" ? bBD4x2 :
                root.name == "calender-display-2x2" ? cLD2x2 :
                root.name == "basic-weather-display-2x2" ? bWD2x2 : 
                root.name == "day-calendar-display-2x2" ? dCD2x2 : 
                root.name == "day-event-display-2x2" ? dED2x2 : 
                root.name == "basic-image-display-2x2" ? bID2x2 : undefined
            }
        }

        DropDownMenu {
            id: rightClickMenu
            x: 0
            y: 0
            model: [
                DropDownItem {
                    name: Translation.tr("Remove Widget.")
                    icon: Quickshell.iconPath("close-symbolic")
                    action: function() {
                        root.deleteWidget(root)
                    }
                }
            ]
        }
        
        MouseArea {
            anchors.fill: parent
            drag.target: root.editMode ? parent : undefined
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property int gridXPos: root.xPos
            property int gridYPos: root.yPos

            drag.minimumX: 0
            drag.maximumX: gridWidth - draggableRect.width
            drag.minimumY: 0
            drag.maximumY: gridHeight - draggableRect.height

            onClicked: (mouse) => {
                if (mouse.button != Qt.RightButton) return
                rightClickMenu.x = mouse.x + draggableRect.x
                rightClickMenu.y = mouse.y + draggableRect.y + Config.bar.height
                rightClickMenu.open()
            }

            onPositionChanged: {
                ghostRect.visible = root.editMode
                // Update ghost to show where it would snap
                gridXPos = Math.round(draggableRect.x / gridSizeX)
                gridYPos = Math.round(draggableRect.y / gridSizeY)
                ghostRect.x = gridXPos * gridSizeX
                ghostRect.y = gridYPos * gridSizeY
            }

            onReleased: {
                ghostRect.visible = false
                // Snap rectangle to grid
                if (root.xPos == gridXPos && root.yPos == gridYPos) {
                    draggableRect.x = root.xPos * gridSizeX
                    draggableRect.y = root.YPos * gridSizeY
                }
                root.newXPos = gridXPos
                root.newYPos = gridYPos
                draggableRect.x = gridXPos * gridSizeX
                draggableRect.y = gridYPos * gridSizeY
                widgetMoved();
            }
        }
    }
    Rectangle {
        id: closeButton
        width: 20
        height: 20
        radius: 15
        color: "#333"
        scale: root.editMode ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }}
        border {
            width: 1
            color: "#22ffffff"
        }
        VectorImage {
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/x.svg")
            width: 10
            height: 10
            anchors.centerIn: parent
            preferredRendererType: VectorImage.CurveRenderer
        }
        x: draggableRect.x + 5
        y: draggableRect.y + 5
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.deleteWidget(root);
            }
        }
    }
}