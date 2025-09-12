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
import qs.Config
import qs.components.panel
import qs.widgets.providers
import qs

Scope {
    id: root

    FullWindow {
        id: editwidgets
        IpcHandler {
            target: "fullwindow"
            function toggle() {
                editwidgets.toggle();
            }
        }

        zoomLayerOne: false
        contentLayerOne: Item {
            anchors.fill: parent
            XrayR {
                xPos: 100        // rectangle position x
                yPos: 100        // rectangle position y
                widthVal: 400    // rectangle width
                heightVal: 400   // rectangle height
            }
            Rectangle {
                id: barMockup
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                width: parent.width
                height: Config.bar.height
                color: "#222"
            }
        }

        zoomLayerTwo: true
        contentLayerTwo: WidgetGrid {
            id: grid
            anchors.fill: parent
            onWidgetMoved: (item) => {
                grid.save(item);
            }
            WidgetGridItem {
                idVal: modelData.idVal
                name:  modelData.name
                size:  modelData.size
                xPos:  modelData.xPos
                yPos:  modelData.yPos
                onWidgetMoved: {
                    grid.widgetMoved(this);
                }
            }
        }
    }
}