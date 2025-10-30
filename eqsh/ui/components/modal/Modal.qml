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
  property bool   useIcon: true
  property var actions: []
  property var    args: []
  property var    variables: ({})
  property list<var> actionables: []

  onCustomAppNameChanged: Runtime.customAppName = customAppName

  // internal structure to store parsed actions
  property var parsedActions: ([])

  onActionsChanged: {
    // check if actions is already an object
    if (typeof actions === "object") {
      root.parsedActions = actions
      return
    }
    if (actions.trim() === "")
      return
    try {
      parsedActions = JSON.parse(actions)
    } catch (e) {
      console.warn("Modal: Failed to parse actions:", e)
      parsedActions = ([])
    }
  }

  function close() {
    fadeOutAnim.start()
    root.customAppName = ""
  }

  PanelWindow {
    WlrLayershell.layer: WlrLayer.Overlay
    id: panelWindow
    exclusiveZone: -1
    visible: true
    color: "transparent"
    WlrLayershell.namespace: "eqsh:blur"
    focusable: true

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
      implicitWidth: Math.min(355, Math.max(200, titleText.paintedWidth + 40))
      implicitHeight: Math.min(550, Math.max(220, titleText.height + iconImage.height + descriptionText.height + actionColumn.implicitHeight + (root.useIcon ? 120 : 100)))


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
        color: Config.general.darkMode ? "#a0333333" : "#efefef"
        radius: 30
      }

      HyprlandFocusGrab {
        id: grab
        active: root.visible
        windows: [ panelWindow ]
        onCleared: {
        }
      }

      CFI {
        id: iconImage
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.useIcon ? 20 : 0
        anchors.leftMargin: 20
        width: 64
        height: root.useIcon ? 64 : 0
        colorized: false
        visible: !root.iconPath.endsWith(".svg") && root.useIcon && root.iconPath !== ""
        source: root.iconPath !== "" ? root.iconPath : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/dialog-warning.svg")
      }

      CFVI {
        id: iconVectorImage
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.topMargin: root.useIcon ? 20 : 0
        anchors.leftMargin: 20
        size: root.useIcon ? 64 : 0
        colorized: false
        visible: (root.iconPath.endsWith(".svg") || root.iconPath == "") && root.useIcon
        source: root.iconPath !== "" && root.iconPath.endsWith(".svg") ? root.iconPath : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/dialog-warning.svg")
      }

      CFText {
        id: titleText
        anchors.top: root.iconPath.endsWith(".svg") && root.useIcon ? iconVectorImage.bottom : iconImage.bottom
        anchors.left: parent.left
        anchors.topMargin: 20
        anchors.leftMargin: 20
        onPaintedWidthChanged: {
          titleText.width = Math.min(315, titleText.paintedWidth)
        }
        text: root.title
        font.pixelSize: 14
        font.weight: 500
        color: Config.general.darkMode ? "#fff" : "#111"
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.Wrap
      }

      CFText {
        id: descriptionText
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: titleText.bottom
        anchors.topMargin: 20
        width: parent.width - 40
        text: root.description
        font.pixelSize: 14
        color: Config.general.darkMode ? "#ddd" : "#333"
        horizontalAlignment: Text.AlignLeft
        elide: Text.ElideRight
        wrapMode: Text.Wrap
      }


      ColumnLayout {
        id: actionColumn
        anchors {
          bottom: parent.bottom
          margins: 20
          left: parent.left
          right: parent.right
        }
        spacing: 0
        height: (root.parsedActions.length * 40)

        Repeater {
          model: root.parsedActions
          delegate: RowLayout {
            spacing: 10
            Repeater {
              model: modelData
              height: 30
              delegate: Rectangle {
                id: actionWrapper
                color: "transparent"
                required property var modelData
                Layout.fillWidth: modelData.fillWidth || true
                Layout.preferredWidth: modelData.fillWidth ? undefined : (modelData.width || 100)
                Layout.preferredHeight: 30
                Loader {
                  id: actionLoader
                  anchors.fill: parent
                  function replaceVars(string="") {
                    var result = string
                    for (var key in root.variables) {
                      var re = new RegExp(`\\$${key}`, "g")
                      result = result.replace(re, root.variables[key])
                    }
                    return result
                  }
                  function redirectCall(modelData) {
                    var redirected = null
                    for (var i = 0; i < root.actionables.length; i++) {
                      if (root.actionables[i].ident === modelData.callbackRedirect) {
                        redirected = root.actionables[i]
                        break
                      }
                    }
                    if (redirected == null) {
                      console.warn("Modal: callbackRedirect target not found:", modelData.callbackRedirect)
                      return
                    }
                    if (redirected.modelData.callback) {
                      redirected.modelData.callback(root, root.variables, redirected)
                    } else {
                      // replace variable in command with input text e.g. $password
                      redirected.processCommand = replaceVars(redirected.modelData.command || "echo No command provided")
                      redirected.processRunning = true
                      fadeOutAnim.start()
                      root.customAppName = ""
                    }
                    return
                  }
                  property Component button: CFButton {
                    id: rButton
                    anchors.fill: parent
                    Process {
                      id: process
                      running: rButton.processRunning
                      command: [ "sh", "-c", rButton.processCommand ]
                    }
                    property var modelData: actionWrapper.modelData
                    property string processCommand: modelData.command || "echo No command provided"
                    property bool   processRunning: false
                    property string ident: modelData.id || ""
                    highlightEnabled: false
                    color: Config.general.darkMode ? "#80333333" : "#80aaaaaa"
                    hoverColor: Config.general.darkMode ? "#99555555" : "#99999999"
                    palette.buttonText: modelData.primary ? "#fff" : Config.general.darkMode ? "#fff" : "#111"
                    Layout.fillWidth: modelData.fillWidth || true
                    Layout.preferredWidth: modelData.fillWidth ? undefined : (modelData.width || 100)
                    Layout.preferredHeight: 30
                    primary: modelData.primary || false
                    primaryColor: modelData.primaryColor ? modelData.primaryColor : "#007cff"
                    primaryHoverColor: modelData.primaryColor ? Qt.darker(modelData.primaryColor) : "#005fab"
                    text: modelData.label || "Button"
                    icon {
                      source: modelData.iconPath || ""
                      width: Math.round(rButton.width * 0.6)
                      height: Math.round(rButton.height * 0.6)
                    }
                    onClicked: {
                      if (modelData.callbackRedirect) {
                        redirectCall(modelData)
                        return
                      }
                      if (modelData.callback) {
                        modelData.callback(root, root.variables, rButton)
                      } else {
                        // replace variable in command with input text e.g. $password
                        processCommand = replaceVars(modelData.command || "echo No command provided")
                        processRunning = true
                        fadeOutAnim.start()
                        root.customAppName = ""
                      }
                    }
                    Component.onCompleted: {
                      root.actionables.push(rButton)
                    }
                  }
                  property Component input: CFTextField {
                    id: inputT
                    Process {
                      id: process
                      running: inputT.processRunning
                      command: [ "sh", "-c", inputT.processCommand ]
                    }
                    property var modelData: actionWrapper.modelData
                    property string processCommand: modelData.command || "echo No command provided"
                    property bool   processRunning: false
                    property real xOffset: 0
                    property var process: process
                    property string ident: modelData.id || ""
                    transform: Translate {
                      id: inputTranslate
                      x: inputT.xOffset
                      y: 0
                    }
                    anchors.fill: parent
                    SequentialAnimation {
                      id: wiggleAnim
                      running: false
                      loops: 1
                      PropertyAnimation { target: inputT; property: "xOffset"; to: inputT.x - 10; duration: 100; easing.type: Easing.InOutQuad }
                      PropertyAnimation { target: inputT; property: "xOffset"; to: inputT.x + 10; duration: 100; easing.type: Easing.InOutQuad }
                      PropertyAnimation { target: inputT; property: "xOffset"; to: inputT.x - 7; duration: 100; easing.type: Easing.InOutQuad }
                      PropertyAnimation { target: inputT; property: "xOffset"; to: inputT.x + 7; duration: 100; easing.type: Easing.InOutQuad }
                      PropertyAnimation { target: inputT; property: "xOffset"; to: inputT.x; duration: 100; easing.type: Easing.InOutQuad }
                    }
                    function wiggle() {
                      wiggleAnim.running = false
                      wiggleAnim.running = true
                    }
                    Layout.fillWidth: modelData.fillWidth || true
                    Layout.preferredWidth: modelData.fillWidth ? undefined : (modelData.width || 100)
                    echoMode: modelData.inputType === "password" ? TextInput.Password : TextInput.Normal
                    font.pixelSize: 14
                    text: root.variables[modelData.variable] || ""
                    placeholderText: modelData.placeholder || ""
                    onTextChanged: {root.variables[modelData.variable] = text; placeholderText = (modelData.placeholder || "")}
                    onAccepted: {
                      if (modelData.callbackRedirect) {
                        redirectCall(modelData)
                        return
                      }
                      if (modelData.callback) {
                        modelData.callback(root, root.variables, inputT)
                      } else {
                        // replace variable in command with input text e.g. $password
                        processCommand = replaceVars(modelData.command || "echo No command provided")
                        processRunning = true
                        fadeOutAnim.start()
                        root.customAppName = ""
                      }
                    }
                    Component.onCompleted: {
                      root.actionables.push(inputT)
                      Qt.callLater(() => inputT.forceActiveFocus())
                    }
                  }
                  active: true
                  sourceComponent: modelData.type === "input" ? input : button
                }
              }
            }
          }
        }
      }
    }
  }

  function reset() {
    root.customAppName = ""
    root.title = ""
    root.description = ""
    root.actions = []
    root.iconPath = ""
    root.useIcon = true
    root.parsedActions = []
    root.variables = ({})
    root.actionables = []
    root.visible = false
  }

  function newInstance(appName, title, description, actions, iconPath, useIcon) {
    reset()
    root.customAppName = appName
    root.title = title
    root.description = description
    root.actions = actions
    root.iconPath = iconPath
    root.useIcon = useIcon
    root.visible = true
  }

  FileView {
    id: fileView
    blockLoading: true
  }

  IpcHandler {
    id: ipcHandler
    target: "modal"

    function instance(appName: string, title: string, description: string, actionsJsonPath: string, iconPath: string, useIcon: bool): void {
      fileView.path = actionsJsonPath
      var actions = fileView.text()
      fileView.path = ""
      newInstance(appName, title, description, actions, iconPath, useIcon)
    }
    Component.onCompleted: {
      Runtime.subscribe("modal", (params) => {
        newInstance(params.appName || "", params.title || "", params.description || "", params.actions || [], params.iconPath || "", params.useIcon !== false)
      })
    }
  }
}
