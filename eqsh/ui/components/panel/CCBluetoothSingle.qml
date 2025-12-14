import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import QtQuick.Controls
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Pipewire
import QtQuick.Layouts
import Quickshell.Wayland
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import qs.ui.controls.advanced
import qs.ui.controls.primitives
import qs.ui.controls.windows
import qs.core.system
import qs.config
import qs
import QtQuick.Controls.Fusion

Scope {
    function open() {
        panelWindow.opened = true;
    }
    id: root

    property color glassColor: Theme.glassColor
    property color glassRimColor: Theme.glassRimColor
    property real  glassRimStrength: Theme.glassRimStrength
    property real  glassRimStrengthStrong: Theme.glassRimStrengthStrong
    property point glassLightDirStrong: Theme.glassLightDirStrong
    property color textColor: Theme.textColor

    required property var screen
    property alias opened: panelWindow.opened
    CustomShortcut {
        name: "controlCenterBluetooth"
        description: "Open Control Center Bluetooth Menu"
        onPressed: {
            root.open()
        }
    }
    function openBluetooth() {
        root.open()
        root.bluetoothOpened = true;
    }
    Component.onCompleted: {
      Runtime.subscribe("controlCenterBluetooth", () => {
        openBluetooth()
      })
    }
    Pop {
        id: panelWindow
        margins.right: 10
        keyboardFocus: WlrKeyboardFocus.Exclusive

        onEscapePressed: () => {
            panelWindow.opened = false;
        }
        
        content: Item {
            id: contentRoot
            focus: true
            
            BoxGlass {
                width: 310
                height: 250
                radius: 20
                anchors {
                    top: parent.top
                    right: parent.right
                    topMargin: Config.bar.height+5
                }
                color: root.glassColor
                light: root.glassRimColor
                rimStrength: 1.3
                lightDir: Qt.point(1, -0.2)
                CCBluetooth {
                    width: 310
                    height: 250
                    glassColor: root.glassColor
                    glassRimColor: root.glassRimColor
                    glassRimStrength: root.glassRimStrength
                    glassRimStrengthStrong: root.glassRimStrengthStrong
                    glassLightDirStrong: root.glassLightDirStrong
                    textColor: root.textColor
                }
            }
        }
    }
}