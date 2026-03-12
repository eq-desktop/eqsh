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
import qs.ui.controls.primitives
import qs.ui.controls.windows
import qs.ui.controls.windows.dropdown
import qs.config
import qs.ui.components.panel
import qs.ui.components.background
import qs.ui.controls.providers
import qs

Item {
    id: root
    property int cellsX: Config.widgets.cellsX || 16
    property int cellsY: Config.widgets.cellsY || 10
    property color backgroundColor: "#00000000"
    property bool editMode: false
    property var wallpaper
    property var screen

    // Compute usable size (excluding bar)
    property int usableWidth: parent.width
    property int usableHeight: parent.height - Config.bar.height

    // Compute grid size so it fits exactly
    property int gridSizeX: Math.floor(usableWidth / cellsX)
    property int gridSizeY: Math.floor(usableHeight / cellsY)

    // Compute margins to center the grid
    property int marginX: Math.floor((usableWidth - gridSizeX * cellsX) / 2)
    property int marginY: Math.floor((usableHeight - gridSizeY * cellsY) / 2) + Config.bar.height
    signal widgetMoved(item: var);

    default property Component delegate: WidgetGridItem {
        idVal: modelData?.idVal || 0
        name:  modelData?.name || ""
        size:  modelData?.size || "1x1"
        xPos:  modelData?.xPos || 0
        yPos:  modelData?.yPos || 0
        options: modelData?.options || {}
        editMode: root.editMode
        screen: root.screen
        wallpaper: root.wallpaper
        deleteWidget: root.deleteWidget
        grid: root
        onWidgetMoved: {
            root.widgetMoved(this);
        }
        onRemoveRequested: deleteWidget(this)
    }

    function save(item) {
        const existing = Runtime.widgets.filter(w => w.idVal !== item.idVal)

        Runtime.widgets = existing.concat([{
            idVal: item.idVal,
            name: item.name,
            size: item.size,
            xPos: item.newXPos,
            yPos: item.newYPos,
            options: item.options
        }])
    }

    function deleteWidget(item) {
        Runtime.widgets = Runtime.widgets.filter(w => w.idVal !== item.idVal)
    }

    Rectangle {
        id: background
        color: "transparent"
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        DropDownMenu {
            id: rightClickMenu
            model: [
                DropDownItem {
                    kb: "⌃⌘W"
                    name: Translation.tr("Edit Widgets")
                    icon: Quickshell.iconPath("widget-packing-symbolic")
                    action: function() {Runtime.widgetEditMode = !Runtime.widgetEditMode}
                },
                DropDownItem {
                    type: "item"
                    kb: "⌃⌘R"
                    name: Translation.tr("Settings")
                    action: function() {Runtime.settingsOpen = !Runtime.settingsOpen}
                    icon: Quickshell.iconPath("settings")
                },
                DropDownSpacer {},
                DropDownItem {
                    name: Translation.tr("Set Wallpaper")
                    action: function() {Runtime.settingsOpen = !Runtime.settingsOpen}
                    icon: Quickshell.iconPath("preferences-desktop-wallpaper-symbolic")
                }
            ]
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton | Qt.LeftButton
            onClicked: (mouse) => {
                if (mouse.button == Qt.LeftButton) {
                    if (Runtime.widgetEditMode) Runtime.widgetEditMode = false
                    return;
                }
                rightClickMenu.x = mouse.x
                rightClickMenu.y = mouse.y
                rightClickMenu.open();
            }
        }

        WidgetAdd {

        }

        UIButton {
            width: 100
            anchors {
                top: parent.top
                left: parent.left
                leftMargin: 15
                topMargin: 5
            }
            color: "#aaa"
            hoverColor: "#888"
            text: Translation.tr("Close")
            clicked: () => {
                if (!Runtime.widgetEditMode) return;
                Runtime.widgetEditMode = false
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
                blurMax: root.editMode ? 0 : 64
                Behavior on  blurMax { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
            }
            opacity: root.editMode ? 1 : 0
        }

        UIButton {
            id: addButton
            width: 100
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 15
                topMargin: 5
            }
            text: Translation.tr("+")
            primary: true
            liquid: true
            clicked: () => {
                if (!Runtime.widgetEditMode) return;
                Runtime.widgetAddOpen = true
            }
            layer.enabled: true
            layer.effect: MultiEffect {
                blurEnabled: true
                blur: 1
                blurMax: root.editMode ? 0 : 64
                Behavior on  blurMax { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
            }
            opacity: root.editMode ? 1 : 0
        }

        Control {
            id: gridContainer
            x: marginX
            y: marginY
            width: gridSizeX * cellsX
            height: gridSizeY * cellsY

            Repeater {
                anchors.fill: parent
                model: ScriptModel {
                    values: Runtime.widgets
                }
                delegate: root.delegate
            }
        }
    }
}