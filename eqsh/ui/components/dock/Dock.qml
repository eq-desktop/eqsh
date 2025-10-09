import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.VectorImage
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Wayland
import Quickshell.Hyprland
import qs.config
import qs
import qs.core.foundation
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import QtQuick.Controls.Fusion

Scope {
  id: root

  property bool shown: false
  property var desktopentries: DesktopEntries

  component DockItem: Button {
    id: app
    width: 50
    height: 50
    implicitWidth: width
    implicitHeight: height
    property string appName: ""
    property bool   launchpad: false
    property bool   settings: false
    property bool   spacer: false
    property var    entry: (launchpad || settings || spacer) ? null : appName != "" ? desktopentries.heuristicLookup(appName) : null

    background: Rectangle {
      anchors.fill: parent
      color: "transparent"
      radius: 12
      Image {
        anchors.fill: parent
        source: launchpad ? Qt.resolvedUrl(Quickshell.shellDir + "/media/pngs/launchpad.png") : settings ? Quickshell.iconPath("org.gnome.Settings") : ""
        fillMode: Image.PreserveAspectFit
        visible: launchpad || settings
        width: app.width
        height: app.height
        asynchronous: true
        smooth: true
        mipmap: true
        layer.enabled: true
      }
      Rectangle {
        anchors.centerIn: parent
        width: 2
        height: app.height * 0.75
        radius: 2
        color: Config.general.darkMode ? "#50ffffff" : "#50000000"
        visible: spacer
      }
      Image {
        anchors.centerIn: parent
        width: app.width
        height: app.height
        asynchronous: true
        smooth: true
        mipmap: true
        visible: entry !== null && !(launchpad || settings || spacer)
        source: entry ? Quickshell.iconPath(entry.icon) : ""
        layer.enabled: true
      }
      Rectangle {
        radius: 99
        width: 4
        height: 4
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -6
        visible: appName == "org.gnome.Nautilus" && !(launchpad || settings || spacer)
        color: Config.general.darkMode ? "#80ffffff" : "#80000000"
      }
    }

    onClicked: {
      if (entry) {
        entry.execute()
      }
      if (launchpad) {
        Runtime.launchpadOpen = !Runtime.launchpadOpen
      } else if (settings) {
        Runtime.settingsOpen = !Runtime.settingsOpen
      }
    }
  }

  Connections {
    target: DesktopEntries
    function onApplicationsChanged() {
      desktopentries = DesktopEntries
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "eqsh:blur"
      required property var modelData
      screen: modelData

      anchors {
        bottom: true
      }

      mask: Region {
        item: root.shown ? dock : null
      }

      implicitHeight: 120
      implicitWidth: dock.implicitWidth + 10
      exclusiveZone: -1
      color: "transparent"
      visible: true
      MouseArea {
        id: dockMouseArea
        anchors.fill: parent
        hoverEnabled: true
        onEntered: {
          dock.mouseInside = true
          dock.mouseX = mouseX
        }
        onPositionChanged: dock.mouseX = mouseX
        onExited: {
          dock.mouseInside = false
          dock.mouseX = mouseX
        }
        propagateComposedEvents: true
        onClicked: (mouse)=> {
          mouse.accepted = false
        }
        Item {
          id: dock
          implicitWidth: dockRow.implicitWidth + 20
          anchors {
            fill: parent
            bottomMargin: root.shown ? 0 : -100
            Behavior on bottomMargin {
              NumberAnimation {
                duration: Config.dock.showAnimation ? 500 : 0
                easing.type: Easing.InOutQuad
              }
            }
          }

          BoxExperimental {
            id: dockBackground
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            highlight: AccentColor.color
            implicitWidth: dockRow.implicitWidth + 20
            implicitHeight: 65
            radius: 20
            anchors.bottomMargin: 6
          }

          // Public state für Maus
          property real mouseX: 0
          property bool mouseInside: false

          RowLayout {
            id: dockRow
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 15
            spacing: 8

            Repeater {
              id: dockRepeater
              model: Config.dock.apps
              delegate: DockItem {
                appName: modelData
                width: modelData == "eq:spacer" ? 10 : 50
                launchpad: modelData == "eq:launchpad"
                settings: modelData == "eq:settings"
                spacer: modelData == "eq:spacer"
              }
            }
          }
        }
      }
    }
  }
}
