import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell
import QtQuick
import qs.config
import qs.components.misc

Scope {
  id: root
  property bool shown: false
  property bool appInFullscreen: false
  property bool forceHide: Config.notch.autohide
  property bool inFullscreen: shown ? forceHide : appInFullscreen || forceHide
  property bool expanded: false
  property string activeWindow: ""
  property string notchInput: ""
  property string notchMode: "shell"

  signal expand(ShellScreen monitor)
  signal collapse(ShellScreen monitor)
  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      id: panelWindow
      property bool islandMode: Config.notch.islandMode
      required property var modelData
      screen: modelData

      anchors.top: true
      implicitWidth: Config.notch.minWidth
      implicitHeight: Config.notch.height
      exclusiveZone: -1
      visible: Config.notch.enable
      color: "transparent"

      margins {
        top: inFullscreen ? -40 : (islandMode ? (Config.notch.margin) : 0)
      }

      Connections {
        target: Hyprland
        function onRawEvent(event) {
          switch (event.name) {
            case "fullscreen": {
              root.appInFullscreen = event.data == 1;
            }
          }
        }
      }

      property bool expanded: root.expanded
      property int minWidth: Config.notch.minWidth
      property int maxWidth: Config.notch.maxWidth

      Behavior on margins.top {
        NumberAnimation { duration: Config.notch.hideDuration; easing.type: Easing.OutQuad }
      }

      Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 3 }
      }
      Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 3 }
      }

      Item {
        anchors.fill: parent

        Box {
          id: notchBg
          anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
          }
          borderSize: 1
          implicitWidth: parent.width - 40
          implicitHeight: parent.height
          topLeftRadius: panelWindow.islandMode ? Config.notch.radius : 0
          topRightRadius: panelWindow.islandMode ? Config.notch.radius : 0
          bottomLeftRadius: Config.notch.radius
          bottomRightRadius: Config.notch.radius
          clip: true
          color: Config.notch.backgroundColor

          animationSpeed: 200
          animationSpeed2: 150

          highlight: "transparent" //root.expanded ? '#aaa' : "transparent"
          weakHighlight: "transparent" //root.expanded ? '#000' : "transparent"

          HyprlandFocusGrab {
            id: grab
            windows: [ panelWindow ]
          }

          TextField {
            id: searchInput
            anchors.horizontalCenter: parent.horizontalCenter
            height: expanded ? 35 : Config.notch.height
            width: Math.min(panelWindow.maxWidth-60, Math.max(panelWindow.minWidth, contentWidth + 40))
            visible: !Config.notch.onlyVisual
            focus: true
            color: Config.notch.color
            background: Text {
              text: Config.notch.signature
              color: searchInput.text == "" && !root.expanded ? "#fff" : "transparent"
              verticalAlignment: Text.AlignVCenter
              horizontalAlignment: Text.AlignHCenter
            }
            font.pixelSize: 14
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            activeFocusOnPress: true
            placeholderTextColor: "#aaaaaaaa"
            onActiveFocusChanged: {
              if (!activeFocus) {
                root.expanded = false;
                grab.active = false;
              }
            }
            onTextChanged: {
              root.notchInput = searchInput.text;
              var newWidth = Math.min(panelWindow.maxWidth, Math.max(panelWindow.minWidth, searchInput.contentWidth + 80));
              panelWindow.implicitWidth = root.expanded ? newWidth : panelWindow.minWidth;
              if (searchInput.text[0] == "=") {
                root.notchMode = "calc"
                panelWindow.implicitHeight = Config.notch.height + 60;
              } else {
                root.notchMode = "shell"
                panelWindow.implicitHeight = Config.notch.height + 20
              }
            }
            onAccepted: {
              let command = root.notchInput;
              searchInput.text = "";
              if (command[0] == "=") {
                console.log("Math");
              } else if (command[0] == "$") {
                Quickshell.execDetached(["sh", "-c", command.slice(1)]);
              }
              root.expanded = false;
              grab.active = false;
            }
          }

          Rectangle {
            anchors {
              top: searchInput.bottom
              horizontalCenter: parent.horizontalCenter
            }
            visible: expanded && root.notchMode == "calc"
            implicitHeight: 30
            implicitWidth: panelWindow.width-75
            color: "transparent"
            radius: 7
            border {
              width: 2
              color: "#55aaaaaa"
            }
            Text {
              anchors.fill: parent
              visible: expanded && root.notchMode == "calc"
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              color: "#fff"
              function getText() {
                if (root.notchMode == "calc") {
                  try {
                    return typeof eval(root.notchInput.slice(1)) === "number" ? eval(root.notchInput.slice(1)) : "";
                  } catch (_) {
                    return "⬤";
                  }
                } else {
                  return "";
                }
              }

              text: getText()
            }
          }

          MouseArea {
            anchors.fill: notchBg
            visible: !root.expanded && !Config.notch.onlyVisual
            onClicked: {
              root.expanded = true;
              grab.active = true;
            }
          }
        }

        Corner {
          visible: Config.notch.fluidEdge && !Config.notch.islandMode
          orientation: 1
          width: 20
          height: 20 * Config.notch.fluidEdgeStrength
          anchors {
            top: parent.top
            left: parent.left
          }
          color: Config.notch.backgroundColor
        }
        Corner {
          visible: Config.notch.fluidEdge && !Config.notch.islandMode
          orientation: 1
          invertH: true
          width: 20
          height: 20 * Config.notch.fluidEdgeStrength
          anchors {
            top: parent.top
            right: parent.right
          }
          color: Config.notch.backgroundColor
        }
      }
      onExpandedChanged: {
        if (root.expanded) {
          root.expand(panelWindow.screen);
        } else {
          root.collapse(panelWindow.screen);
        }
        implicitHeight = root.expanded ? Config.notch.height + 20 : Config.notch.height;
        implicitWidth = root.expanded ? minWidth + 50 : minWidth;
      }
    }
  }
}
