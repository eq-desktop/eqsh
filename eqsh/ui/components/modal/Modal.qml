import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell
import QtQuick
import QtQuick.Effects
import QtQuick.VectorImage
import QtQuick.Layouts
import qs.config
import qs
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.primitives
import qs.ui.controls.providers

Scope {
  id: root

  property string customAppName: ""
  property bool visible: false
  property string title: ""
  property string description: ""
  property string iconPath: ""
  property string actions: ""

  onCustomAppNameChanged: Runtime.customAppName = customAppName

  // internal structure to store parsed actions
  property var parsedActions: []

  onActionsChanged: {
    parsedActions = []
    if (actions.trim() === "")
      return
    const pairs = actions.split(",")
    for (let i = 0; i < pairs.length; i++) {
      const kv = pairs[i].split("=")
      if (kv.length === 2) {
        let label = kv[0].trim().replace(/^"|"$/g, "")
        const command = kv[1].trim().replace(/^"|"$/g, "")
        // if label ends with "".primary", cut it off and mark it as primary
        if (label.endsWith(".primary")) {
          label = label.substring(0, label.length - ".primary".length)
          parsedActions.push({ label: label, command: command, primary: true })
        } else {
          parsedActions.push({ label: label, command: command, primary: false })
        }
      }
    }
    root.parsedActions = parsedActions
  }

  PanelWindow {
    WlrLayershell.layer: WlrLayer.Overlay
    id: panelWindow
    exclusiveZone: -1
    visible: true
    color: "transparent"
    WlrLayershell.namespace: "eqsh:blur"

    anchors {
      top: true
      left: true
      right: true
      bottom: true
    }

    mask: Region { item: root.visible ? modal : null }

    Item {
      id: modal
      anchors.centerIn: parent
      opacity: root.visible ? 1 : 0
      implicitWidth: Math.max(200, titleText.paintedWidth + 40)
      implicitHeight: titleText.height + descriptionText.height + actionRow.implicitHeight + 80


      PropertyAnimation {
        id: fadeOutAnim
        target: modal
        property: "opacity"
        to: 0
        duration: 150
        onFinished: {
          root.visible = false
        }
      }

      Behavior on opacity {
        NumberAnimation { duration: 150; easing.type: Easing.InOutQuad }
      }

      BoxGlass {
        anchors.fill: parent
        color: Config.general.darkMode ? "#80333333" : "#80ffffff"
        radius: 30
      }
      Text {
        id: titleText
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: 20
        anchors.leftMargin: 20
        text: root.title
        font.pixelSize: 16
        font.weight: 500
        color: Config.general.darkMode ? "#fff" : "#111"
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
      }

      Text {
        id: descriptionText
        anchors.centerIn: parent
        width: parent.width - 40
        text: root.description
        font.pixelSize: 14
        color: Config.general.darkMode ? "#ddd" : "#333"
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
        wrapMode: Text.WordWrap
      }

      RowLayout {
        id: actionRow
        anchors {
          bottom: parent.bottom
          margins: 20
          left: parent.left
          right: parent.right
        }
        spacing: 10
        height: 40

        Repeater {
          model: root.parsedActions
          delegate: CFButton {
            Process {
              id: process
              running: false
              command: [ "sh", "-c", modelData.command ]
            }
            highlightEnabled: false
            color: Config.general.darkMode ? "#80333333" : "#80dddddd"
            palette.buttonText: modelData.primary ? AccentColor.textColor : Config.general.darkMode ? "#fff" : "#111"
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            primary: modelData.primary
            text: modelData.label
            onClicked: {
              process.running = true
              fadeOutAnim.start()
              root.customAppName = ""
            }
          }
        }
      }
    }
  }

  IpcHandler {
    target: "modal"

    function instance(appName: string, title: string, description: string, actions: string): void {
      root.customAppName = appName
      root.title = title
      root.description = description
      root.actions = actions
      root.visible = true
    }
  }
}
