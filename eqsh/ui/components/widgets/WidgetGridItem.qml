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
import qs.ui.controls.auxiliary.widget
import qs.ui.controls.primitives
import qs.ui.controls.windows
import qs.ui.controls.windows.dropdown
import qs.config
import qs.ui.components.panel
import qs.ui.controls.providers
import qs.ui.components.widgets.wi
import qs.core.system
import qs

Item {
    id: root
    anchors.fill: parent
    property int    idVal: 0
    property string name: "Widget"
    property string size: "1x1"
    property var gridContainer
    property var grid
    property var wallpaper
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
    property bool beingDragged: ghostRect.visible
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
            running: root.editMode && Config.widgets.wobbleOnEdit
            NumberAnimation { to: draggableRect.wobbleAmp * draggableRect.wobbleDir; duration: draggableRect.wobbleSpeed; easing.type: Easing.InOutQuad }
            NumberAnimation { to: -draggableRect.wobbleAmp * draggableRect.wobbleDir; duration: draggableRect.wobbleSpeed * 2; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 0; duration: draggableRect.wobbleSpeed; easing.type: Easing.InOutQuad }
        }

        Behavior on rotation {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        property var _widget: root.name in Plugins.widgetRegistry ? Plugins.widgetRegistry[root.name] | ({}) : ({})
        
        
        BaseWidget {
            id: bw
            widget: root
            screen: root.screen
            wallpaper: root.wallpaper
            grid: root.grid
            Component.onCompleted: {
                if (!(options.enableBg ?? true)) {
                    bw.bg = null
                }
            }
            Connections {
                target: Plugins
                function onLoadedChanged() {
                    if (!(root.name in Plugins.widgetRegistry)) return
                    draggableRect._widget = Plugins.widgetRegistry[root.name]
                    let pluginWidget = Qt.createQmlObject(draggableRect._widget.f("onRender").children[0].raw, bw)
                    pluginWidget.options = root.options
                    pluginWidget.textSize = bw.textSize
                    pluginWidget.textSizeM = bw.textSizeM
                    pluginWidget.textSizeL = bw.textSizeL
                    pluginWidget.textSizeXL = bw.textSizeXL
                    pluginWidget.textSizeXXL = bw.textSizeXXL
                    pluginWidget.textSizeSL = bw.textSizeSL
                    pluginWidget.textSizeSSL = bw.textSizeSSL
                }
                Component.onCompleted: {
                    if (!Plugins.loaded) return;
                    if (!(root.name in Plugins.widgetRegistry)) return
                    draggableRect._widget = Plugins.widgetRegistry[root.name]
                    let pluginWidget = Qt.createQmlObject(draggableRect._widget.f("onRender").children[0].raw, bw)
                    pluginWidget.options = root.options
                    pluginWidget.textSize = bw.textSize
                    pluginWidget.textSizeM = bw.textSizeM
                    pluginWidget.textSizeL = bw.textSizeL
                    pluginWidget.textSizeXL = bw.textSizeXL
                    pluginWidget.textSizeXXL = bw.textSizeXXL
                    pluginWidget.textSizeSL = bw.textSizeSL
                    pluginWidget.textSizeSSL = bw.textSizeSSL
                }
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