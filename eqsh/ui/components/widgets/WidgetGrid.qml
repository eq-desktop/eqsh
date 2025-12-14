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
    property list<var> widgets: []

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
        idVal: modelData.idVal || 0
        name:  modelData.name || ""
        size:  modelData.size || "1x1"
        xPos:  modelData.xPos || 0
        yPos:  modelData.yPos || 0
        options: modelData.options || {}
        editMode: root.editMode
        screen: root.screen
        wallpaper: root.wallpaper
        deleteWidget: root.deleteWidget
        grid: root
        onWidgetMoved: {
            root.widgetMoved(this);
        }
    }

    FileView {
        id: widgetFileView
        watchChanges: true
        path: Qt.resolvedUrl(Directories.widgetsPath)
        onLoaded: {
            const fileContents = widgetFileView.text();
            root.widgets = JSON.parse(fileContents).widgets;
        }
        onFileChanged: {
            this.reload();
        }
    }

    function save(item) {
        // Find the index of the widget with the same idVal
        const index = root.widgets.findIndex(w => w.idVal === item.idVal);

        // If found, update the existing entry
        if (index !== -1) {
            root.widgets[index] = {
                idVal: item.idVal,
                name: item.name,
                size: item.size,
                xPos: item.newXPos,
                yPos: item.newYPos,
                options: item.options
            };
        } else {
            // Otherwise, add it as a new widget
            root.widgets.push({
                idVal: item.idVal,
                name: item.name,
                size: item.size,
                xPos: item.newXPos,
                yPos: item.newYPos,
                options: item.options
            });
        }

        // Save updated widgets to disk
        const fileContents = JSON.stringify({ widgets: root.widgets }, null, 4);
        widgetFileView.setText(fileContents);
    }

    function deleteWidget(item) {
        const index = root.widgets.findIndex(w => w.idVal === item.idVal);
        if (index !== -1) {
            root.widgets.splice(index, 1);
            const fileContents = JSON.stringify({ widgets: root.widgets }, null, 4);
            widgetFileView.setText(fileContents);
        }
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

        CFButton {
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
            onClicked: {
                Runtime.widgetEditMode = false
            }
            transform: Translate {
                id: translateClose
                x: root.editMode ? 0 : -50
                y: root.editMode ? 0 : -10
                Behavior on x { NumberAnimation { duration: 1000; easing.type: Easing.OutBack; easing.overshoot: 1 }}
                Behavior on y { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }}
            }
            scale: root.editMode ? 1 : 0.5
            opacity: root.editMode ? 1 : 0
        }

        CFButton {
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
            font.pixelSize: 16
            transform: Translate {
                id: translateAdd
                x: root.editMode ? 0 : 50
                y: root.editMode ? 0 : -10
                Behavior on x { NumberAnimation { duration: 1000; easing.type: Easing.OutBack; easing.overshoot: 1 }}
                Behavior on y { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }}
            }
            scale: root.editMode ? 1 : 0.5
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
                    values: root.widgets
                }
                delegate: root.delegate
            }
        }
    }
}