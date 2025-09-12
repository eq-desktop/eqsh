import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.VectorImage
import qs.Config
import qs.widgets.misc

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

  property bool   leftIconVisible: false
  property bool   leftIconAnimate: true
  property string leftIconColorize: ""
  property string leftIconPath: ""
  property int    leftIconRotation: 0
  property real   leftIconScale: 1
  property bool   leftIconVisibleInfinite: false
  property int    leftIconMargin: 5
  property bool   rightIconVisible: false
  property bool   rightIconAnimate: true
  property string rightIconColorize: ""
  property int    rightIconRotation: 0
  property real   rightIconScale: 1
  property string rightIconPath: ""
  property bool   rightIconVisibleInfinite: false
  property int    rightIconMargin: 5
  property int    tempWidth: 0
  property int    tempHeight: 0
  property int    tempRounding: 0
  property bool   tempResize: false
  property bool   tempResizeInfinite: false
  property bool   tempResizeForce: false

  function checkPath(path) {
    if (path.startsWith("builtin:")) {
      return Qt.resolvedUrl(Quickshell.shellDir + "/assets/svgs/notch/" + path.substring(8) + ".svg")
    } else {
      return Qt.resolvedUrl(path)
    }
  }

  // --- Scheduler ---
  property var scheduledJobs: []   // list of { expiry, callback, name }
  Timer {
    id: scheduler
    interval: 50
    repeat: true
    running: true
    onTriggered: {
      const now = Date.now()
      for (let i = scheduledJobs.length - 1; i >= 0; --i) {
        if (scheduledJobs[i].expiry <= now) {
          scheduledJobs[i].callback()
          scheduledJobs.splice(i, 1)
        }
      }
    }
  }
  function schedule(callback, delay, name) {
    if (delay <= 0) {
      Qt.callLater(callback)
    } else {
      for (let i = 0; i < scheduledJobs.length; ++i) {
        if (scheduledJobs[i].name === name) {
          scheduledJobs[i] = { expiry: Date.now() + delay, callback, name }
          return
        }
      }
      scheduledJobs.push({ expiry: Date.now() + delay, callback, name })
    }
  }

  function leftIconShow(path, timeout, margin=-1, start_delay=0, animate=true, color="", rotation=0, scale=1) {
    root.leftIconVisible = false
    root.leftIconAnimate = animate
    root.leftIconColorize = color
    root.leftIconRotation = rotation
    root.leftIconScale = scale
    root.leftIconPath = checkPath(path)
    root.leftIconMargin = margin
    leftIconVisibleInfinite = (timeout === -1)

    // schedule show
    schedule(() => {
      root.leftIconVisible = true
      if (!leftIconVisibleInfinite) {
        schedule(() => leftIconHide(), timeout)
      }
    }, start_delay, "left")
  }
  function leftIconHide() {
    root.leftIconVisible = false
  }

  function rightIconShow(path, timeout, margin=5, start_delay=0, animate=true, color="", rotation=0, scale=1) {
    root.rightIconVisible = false
    root.rightIconAnimate = animate
    root.rightIconColorize = color
    root.rightIconRotation = rotation
    root.rightIconScale = scale
    root.rightIconPath = checkPath(path)
    root.rightIconMargin = margin
    rightIconVisibleInfinite = (timeout === -1)

    // schedule show
    schedule(() => {
      root.rightIconVisible = true
      if (!rightIconVisibleInfinite) {
        schedule(() => rightIconHide(), timeout)
      }
    }, start_delay, "right")
  }
  function rightIconHide() {
    root.rightIconVisible = false
  }

  function temporaryResize(width=-1, height=-1, rounding=-1, timeout=5000, force=false, start_delay=0) {
    tempResize = false
    tempWidth = width
    tempHeight = height
    tempRounding = rounding == -1 ? Config.notch.radius : rounding
    tempResizeForce = force
    tempResizeInfinite = (timeout === -1)

    schedule(() => {
      tempResize = true
      if (!tempResizeInfinite) {
        schedule(() => temporaryResizeReset(), timeout)
      }
    }, start_delay, "resize")
  }
  function temporaryResizeReset() {
    tempWidth = 0
    tempHeight = 0
    tempRounding = 0
    tempResize = false
    tempResizeForce = false
  }

  signal expand(ShellScreen monitor)
  signal collapse(ShellScreen monitor)
  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "eqsh:lock"
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
      property bool tempResize: root.tempResize

      Behavior on margins.top {
        NumberAnimation { duration: Config.notch.hideDuration; easing.type: Easing.OutQuad }
      }

      Behavior on implicitHeight {
        NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 }
      }
      Behavior on implicitWidth {
        NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 3 }
      }

      Item {
        anchors.fill: parent
        scale: Config.general.reduceMotion ? 1 : 0
        Behavior on scale {
          NumberAnimation { duration: 1000; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }
        Component.onCompleted: {
          scale = 1;
        }

        Rectangle {
          id: notchBg
          anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
          }
          implicitWidth: parent.width - 40
          implicitHeight: parent.height
          topLeftRadius: panelWindow.islandMode ? (root.tempResize ? root.tempRounding : Config.notch.radius) : 0
          topRightRadius: panelWindow.islandMode ? (root.tempResize ? root.tempRounding : Config.notch.radius) : 0
          bottomLeftRadius: (root.tempResize ? root.tempRounding : Config.notch.radius)
          bottomRightRadius: (root.tempResize ? root.tempRounding : Config.notch.radius)
          clip: true
          color: Config.notch.backgroundColor

          HyprlandFocusGrab {
            id: grab
            windows: [ panelWindow ]
          }

          VectorImage {
            id: leftNotchIcon
            width: 15
            height: 15
            scale: root.expanded ? 0.5 : root.leftIconVisible ? leftIconScale : 0.5
            opacity: root.expanded ? 0 : root.leftIconVisible ? 1 : 0
            Behavior on scale {
              NumberAnimation { duration: leftIconAnimate == false ? 0 : Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
            }
            Behavior on opacity {
              NumberAnimation { duration: leftIconAnimate == false ? 0 : Config.notch.leftIconAnimDuration/2; easing.type: Easing.OutBack; easing.overshoot: 1 }
            }
            preferredRendererType: VectorImage.CurveRenderer
            anchors {
              left: parent.left
              leftMargin: root.leftIconMargin != -1 ? root.leftIconMargin :  Math.min((notchBg.height/2)-7.5, Config.notch.radius-7.5)
              verticalCenter: parent.verticalCenter
              Behavior on leftMargin {
                NumberAnimation { duration: leftIconAnimate == false ? 0 : Config.notch.leftIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
              }
            }
            source: leftIconPath;
            rotation: leftIconRotation
            layer.enabled: leftIconColorize != "" ? true : false
            layer.effect: MultiEffect {
              anchors.fill: leftNotchIcon
              colorization: 1
              colorizationColor: leftIconColorize
            }
          }

          VectorImage {
            id: rightNotchIcon
            width: 15
            height: 15
            scale: root.expanded ? 0.5 : root.rightIconVisible ? rightIconScale : 0.5
            opacity: root.expanded ? 0 : root.rightIconVisible ? 1 : 0
            Behavior on scale {
              NumberAnimation { duration: rightIconAnimate == false ? 0 : Config.notch.rightIconAnimDuration; easing.type: Easing.OutBack; easing.overshoot: 1 }
            }
            Behavior on opacity {
              NumberAnimation { duration: rightIconAnimate == false ? 0 : Config.notch.rightIconAnimDuration/2; easing.type: Easing.OutBack; easing.overshoot: 1 }
            }
            preferredRendererType: VectorImage.CurveRenderer
            anchors {
              right: parent.right
              rightMargin: root.rightIconMargin != -1 ? root.rightIconMargin :  Math.min((notchBg.height/2)-7.5, Config.notch.radius-7.5)
              verticalCenter: parent.verticalCenter
            }
            source: rightIconPath;
            rotation: rightIconRotation
            layer.enabled: rightIconColorize != "" ? true : false
            layer.effect: MultiEffect {
              anchors.fill: rightNotchIcon
              colorization: 1
              colorizationColor: rightIconColorize
            }
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
            Keys.onPressed: (event) => {
              if (event.key === Qt.Key_Escape) {
                root.expanded = false;
                grab.active = false;
                event.accepted = true;
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
            leftMargin: 1
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
            rightMargin: 1
          }
          color: Config.notch.backgroundColor
        }
      }
      onExpandedChanged: {
        if (root.tempResizeForce) return;
        if (root.expanded) {
          root.expand(panelWindow.screen);
        } else {
          root.collapse(panelWindow.screen);
        }
        implicitHeight = root.expanded ? Config.notch.height + 20 : Config.notch.height;
        implicitWidth = root.expanded ? minWidth + 50 : minWidth;
      }
      onTempResizeChanged: {
        if (root.tempResize) {
          implicitHeight = root.tempHeight == -1 ? Config.notch.height : root.tempHeight;
          implicitWidth = root.tempWidth == -1 ? minWidth : root.tempWidth;
        } else {
          implicitHeight = root.expanded ? Config.notch.height + 20 : Config.notch.height;
          implicitWidth = root.expanded ? minWidth + 50 : minWidth;
        }
      }
    }
  }
  IpcHandler {
    target: "notch"
    function temporaryResize(width: int, height: int, rounding: int, timeout: int, force: bool, start_delay: int) {
      root.temporaryResize(width, height, rounding, timeout, force, start_delay);
    }
    function temporaryResizeReset() {
      root.temporaryResizeReset();
    }
    function leftIconShow(path: string, timeout: int, margin: int, start_delay: int, animate: bool, color: string, rotation: int, scale: real) {
      root.leftIconShow(path, timeout, margin, start_delay, animate, color, rotation, scale);
    }
    function leftIconHide() {
      root.leftIconHide();
    }
    function rightIconShow(path: string, timeout: int, margin: int, start_delay: int, animate: bool, color: string, rotation: int, scale: real) {
      root.rightIconShow(path, timeout, margin, start_delay, animate, color, rotation, scale);
    }
    function rightIconHide() {
      root.rightIconHide();
    }
  }
}
