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

Item {
    id: root
    property int cellsX: Config.widgets.cellsX || 16
    property int cellsY: Config.widgets.cellsY || 10
    property color backgroundColor: "#00000000"
    property bool editable: false
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
        editable: root.editable
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
        let temp = root.widgets;
        temp[item.idVal] = {
            idVal: item.idVal,
            name: item.name,
            size: item.size,
            xPos: item.newXPos,
            yPos: item.newYPos,
            options: item.options
        };
        const fileContents = JSON.stringify({
            widgets: temp
        }, null, 4);
        widgetFileView.setText(fileContents);
    }

    Rectangle {
        color: "transparent"
        x: 0
        y: 0
        width: parent.width
        height: parent.height

        Rectangle {
            id: gridContainer
            x: marginX
            y: marginY
            width: gridSizeX * cellsX
            height: gridSizeY * cellsY
            color: backgroundColor

            Repeater {
                anchors.fill: parent
                model: root.widgets
                delegate: root.delegate
            }
        }
    }
}