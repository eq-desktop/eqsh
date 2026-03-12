import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs
import qs.config
import qs.core.system
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import qs.ui.controls.primitives
import qs.ui.controls.windows
import "root:/agents/kavo/kvoNode.js" as KvoNode

Scope {
  id: root

  function toggle() {
    Runtime.widgetAddOpen = !Runtime.widgetAddOpen
  }

  FollowingPanelWindow {
    id: widgetAdd
    anchors {
      top: true
      left: true
      right: true
      bottom: true
    }
    color: "transparent"
    WlrLayershell.namespace: "eqsh:blur"

    mask: Region {
      item: widgetAdd.opened ? loader : null
    }

    property bool opened: false
    property bool closing: false

    Timer {
      id: hideTimer
      interval: 200
      running: false
      onTriggered: {
        widgetAdd.opened = false
        Runtime.widgetAddOpen = false
      }
    }

    Connections {
      target: Runtime
      function onWidgetAddOpenChanged() {
        if (Runtime.widgetAddOpen) {
          widgetAdd.opened = true
          widgetAdd.closing = false
          hideTimer.stop()
        }
        else {
          widgetAdd.closing = true
          hideTimer.start()
        }
      }
    }

    property var monitor: Hyprland.monitorFor(screen)
    property real sF: Math.min(0.7777, (1+(1-monitor.scale || 1)))
    property int textSize: 16*sF
    property int textSizeM: 20*sF
    property int textSizeL: 26*sF
    property int textSizeXL: 32*sF
    property int textSizeXXL: 40*sF
    property int textSizeSL: 64*sF
    property int textSizeSSL: 86*sF

    property var categories: [
      "special:search",
      "special:all",
      "Battery",
      "Clock",
      "Calender",
      "Weather",
      "Media"
    ]

    HyprlandFocusGrab {
      id: grab
      windows: [ widgetAdd ]
      active: widgetAdd.opened
      onCleared: {
        Runtime.widgetAddOpen = false
      }
    }

    Loader {
      id: loader
      anchors.centerIn: parent
      width: parent.width * 0.5
      height: parent.height * 0.95
      active: widgetAdd.opened
      sourceComponent: ClippingRectangle {
        id: contentItem
        width: parent.width
        height: parent.height
        color: "transparent"
        radius: 25
        opacity: 0
        scale: 0.95
        Connections {
          target: widgetAdd
          function onClosingChanged() {
            opacity = widgetAdd.closing ? 0 : 1
            scale = widgetAdd.closing ? 0.95 : 1
          }
        }
        Component.onCompleted: {
          opacity = 1
          scale = 1
        }

        Behavior on opacity { NumberAnimation { duration: 180 } }
        Behavior on scale { NumberAnimation { duration: 180; easing.type: Easing.OutBack } }

        layer.enabled: true
        layer.effect: MultiEffect {
          blurEnabled: true
          blur: 1
          blurMax: 32
          Component.onCompleted: { blurMax = 0 }
          Connections {
            target: widgetAdd
            function onClosingChanged() {
              blurMax = widgetAdd.closing ? 32 : 0
            }
          }
          Behavior on blurMax { NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
        }
        BoxGlass {
          id: background
          anchors.fill: parent
          visible: contentItem.opacity !== 0
          radius: 25
          color: Theme.glassColor
          light: Theme.glassRimColor
          rimStrength: false ? 0.2 : 1.7
          Seperator {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 250
            color: "#30ffffff"
          }
          ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 20
            anchors.topMargin: 20
            anchors.bottomMargin: 0
            spacing: 8
            property int selected: 1
            model: ScriptModel {
              values: widgetAdd.categories
            }
            delegate: Item {
              id: item
              required property var index
              required property var modelData
              width: 210
              height: 40
              CFRectExperimental {
                id: bg
                anchors.fill: parent
                radius: 10
                color: modelData == "special:search" ? "transparent" : list.selected == item.index || mousearea.containsMouse ? (mousearea.containsMouse && list.selected == item.index ? "#30ffffff" : "#20ffffff") : "#00ffffff"
              }
              CFText {
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 16
                text: {
                  if (modelData == "special:search") {
                    return ""
                  }
                  if (modelData == "special:all") {
                    return "All Widgets"
                  }
                  return Translation.tr(modelData)
                }
              }
              MouseArea {
                id: mousearea
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                  if (modelData == "special:search") {
                    return;
                  } else {
                    list.selected = item.index
                  }
                }
              }
              Loader {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                active: modelData == "special:search"
                sourceComponent: CFTextField {
                  CFVI {
                    id: sicon
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: 12
                    size: 16
                    opacity: 0.5
                    transform: Translate { y: -1 }
                    icon: "search.svg"
                  }
                  width: 210
                  height: 40
                  padding: 10
                  leftPadding: 34
                  id: icon
                  font.pixelSize: 16
                  placeholderText: "Search Widgets"
                  placeholderTextColor: "#fff"
                  focus: true
                  Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                      root.toggle();
                    }
                  }
                }
              }
            }
          }
          Item {
            id: viewRight
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 250
            anchors.right: parent.right
          }
          ClippingRectangle {
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.leftMargin: 250
            radius: 30
            anchors.right: parent.right
            color: "transparent"
            ScrollView {
              id: control
              anchors.top: parent.top
              anchors.bottom: parent.bottom
              anchors.horizontalCenter: parent.horizontalCenter
              width: ((135+8)*3)-8
              ScrollBar.vertical: ScrollBar {
                parent: control
                x: (control.width - width)+20
                y: control.topPadding
                height: control.availableHeight
                active: control.ScrollBar.horizontal.active
              }
              Flow {
                id: layout
                spacing: 8
                anchors.top: parent.top
                anchors.topMargin: 20
                anchors.bottomMargin: 50
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                Connections {
                  target: Plugins
                  function onLoadedChanged() {
                    if (!Plugins.loaded) return;
                    repeater.model = Plugins.asArray(Plugins.widgetRegistry);
                  }
                }
                Repeater {
                  id: repeater
                  model: Plugins.asArray(Plugins.widgetRegistry)
                  delegate: Item {
                    id: item

                    required property var index
                    required property var modelData
                    property var kavo: new KvoNode.KvoNode(modelData.value._obj)
                    property var prefSize: item.kavo.nav("meta.preferredSize")?.value || "2x2"
                    property int prefSizeX: prefSize ? Number(prefSize.split("x")[0]) : 2
                    property int prefSizeY: prefSize ? Number(prefSize.split("x")[1]) : 2

                    property real gridX: 67.5
                    property real gridY: 67.5

                    width: ((gridX)*prefSizeX)
                    height: ((gridY)*prefSizeY)+20 // 20 for text

                    Layout.preferredWidth: width
                    Layout.preferredHeight: height
                    BoxGlass {
                      id: bw
                      anchors.fill: parent
                      anchors.bottomMargin: 20
                      radius: 25
                      color: "#222"
                      light: "#50ffffff"
                      property real sF: widgetAdd.sF
                      property int textSize: widgetAdd.textSize
                      property int textSizeM: widgetAdd.textSizeM
                      property int textSizeL: widgetAdd.textSizeL
                      property int textSizeXL: widgetAdd.textSizeXL
                      property int textSizeXXL: widgetAdd.textSizeXXL
                      property int textSizeSL: widgetAdd.textSizeSL
                      property int textSizeSSL: widgetAdd.textSizeSSL
                      Component.onCompleted: {
                        if (!Plugins.loaded) return;
                        let pluginWidget = Qt.createQmlObject(item.kavo.f("onRender").children[0].raw, bw)
                        pluginWidget.anchors.margins = 0
                        pluginWidget.options = root.options
                        pluginWidget.textSize = widgetAdd.textSize
                        pluginWidget.textSizeM = widgetAdd.textSizeM
                        pluginWidget.textSizeL = widgetAdd.textSizeL
                        pluginWidget.textSizeXL = widgetAdd.textSizeXL
                        pluginWidget.textSizeXXL = widgetAdd.textSizeXXL
                        pluginWidget.textSizeSL = widgetAdd.textSizeSL
                        pluginWidget.textSizeSSL = widgetAdd.textSizeSSL
                      }
                    }
                    CFText {
                      anchors.top: bw.bottom
                      anchors.horizontalCenter: bw.horizontalCenter
                      text: item.kavo.nav("meta.name").value
                      font.pixelSize: 14
                    }
                    MouseArea {
                      anchors.fill: parent
                      onClicked: {
                        Runtime.widgets.push({
                          idVal: Runtime.widgets.length,
                          name: modelData.id,
                          options: {},
                          size: prefSize,
                          xPos: 0,
                          yPos: 0
                        })
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}