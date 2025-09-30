import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.config
import qs.ui.controls.providers
import qs.ui.controls.primitives
import qs.ui.controls.advanced
import Quickshell.Wayland

PopupWindow {
  id: root
  property QsMenuHandle menu
  property var anchorItem: null
  property real anchorX
  property real anchorY
  property bool isSubMenu: false
  property bool isHovered: rootMouseArea.containsMouse
  property ShellScreen screen

  readonly property int menuWidth: 180

  implicitWidth: menuWidth

  // Use the content height of the Flickable for implicit height
  implicitHeight: Math.min(screen ? screen.height * 0.9 : Screen.height * 0.9,
                           flickable.contentHeight + (20))
  visible: false
  color: "transparent"
  anchor.item: anchorItem
  anchor.rect.x: anchorX
  anchor.rect.y: Config.bar.height - (isSubMenu ? 0 : 4)

  function showAt(item, x, y) {
    if (!item) {
      Logger.warn("TrayMenu", "anchorItem is undefined, won't show menu.")
      return
    }

    if (!opener.children || opener.children.values.length === 0) {
      //Logger.warn("TrayMenu", "Menu not ready, delaying show")
      Qt.callLater(() => showAt(item, x, y))
      return
    }

    anchorItem = item
    anchorX = x
    anchorY = y

    visible = true
    forceActiveFocus()

    // Force update after showing.
    Qt.callLater(() => {
                   root.anchor.updateAnchor()
                 })
  }

  function hideMenu() {
    visible = false

    // Clean up all submenus recursively
    for (var i = 0; i < columnLayout.children.length; i++) {
      const child = columnLayout.children[i]
      if (child?.subMenu) {
        child.subMenu.hideMenu()
        child.subMenu.destroy()
        child.subMenu = null
      }
    }
  }

  // Full-sized, transparent MouseArea to track the mouse.
  MouseArea {
    id: rootMouseArea
    anchors.fill: parent
    hoverEnabled: true
  }

  Item {
    anchors.fill: parent
    Keys.onEscapePressed: root.hideMenu()
  }

  QsMenuOpener {
    id: opener
    menu: root.menu
  }

  BoxExperimental {
    anchors.fill: parent
    radius: 20
  }

  Flickable {
    id: flickable
    anchors.fill: parent
    anchors.margins: 10
    contentHeight: columnLayout.implicitHeight
    interactive: true
    clip: true

    // Use a ColumnLayout to handle menu item arrangement
    ColumnLayout {
      id: columnLayout
      width: flickable.width
      spacing: 0

      Repeater {
        model: opener.children ? [...opener.children.values] : []

        delegate: Rectangle {
          id: entry
          required property var modelData

          Layout.preferredWidth: parent.width
          Layout.preferredHeight: {
            if (modelData?.isSeparator) {
              return 8
            } else {
              // Calculate based on text content
              const textHeight = text.contentHeight || (16 * 1.2)
              return Math.max(28, textHeight + (20))
            }
          }

          color: "transparent"
          property var subMenu: null

          EDivider {
            anchors.centerIn: parent
            width: parent.width - (20)
            visible: modelData?.isSeparator ?? false
          }

          Rectangle {
            anchors.fill: parent
            color: mouseArea.containsMouse ? AccentColor.color : "transparent"
            radius: 15
            visible: !(modelData?.isSeparator ?? false)

            RowLayout {
              anchors.fill: parent
              anchors.leftMargin: 5
              anchors.rightMargin: 5
              spacing: 5

                Text {
                    id: text
                    Layout.fillWidth: true
                    color: (modelData?.enabled
                            ?? true) ? (mouseArea.containsMouse ? "#000" : "#fff") : "#fff"
                    text: modelData?.text !== "" ? modelData?.text.replace(/[\n\r]+/g, ' ') : "..."
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }

              Image {
                Layout.preferredWidth: 25
                Layout.preferredHeight: 25
                source: modelData?.icon ?? ""
                visible: (modelData?.icon ?? "") !== ""
                fillMode: Image.PreserveAspectFit
              }

              Text {
                text: modelData?.hasChildren ? "menu" : ""
                font.pointSize: 16
                verticalAlignment: Text.AlignVCenter
                visible: modelData?.hasChildren ?? false
                color: "#fff"
              }
            }

            MouseArea {
              id: mouseArea
              anchors.fill: parent
              hoverEnabled: true
              enabled: (modelData?.enabled ?? true) && !(modelData?.isSeparator ?? false) && root.visible

              onClicked: {
                if (modelData && !modelData.isSeparator && !modelData.hasChildren) {
                  modelData.triggered()
                  root.hideMenu()
                }
              }

              onEntered: {
                if (!root.visible)
                  return

                // Close all sibling submenus
                for (var i = 0; i < columnLayout.children.length; i++) {
                  const sibling = columnLayout.children[i]
                  if (sibling !== entry && sibling?.subMenu) {
                    sibling.subMenu.hideMenu()
                    sibling.subMenu.destroy()
                    sibling.subMenu = null
                  }
                }

                // Create submenu if needed
                if (modelData?.hasChildren) {
                  if (entry.subMenu) {
                    entry.subMenu.hideMenu()
                    entry.subMenu.destroy()
                  }

                  const submenuWidth = menuWidth
                  const overlap = 4 // A small overlap to bridge the mouse path

                  // Check if there's enough space on the right
                  const globalPos = entry.mapToGlobal(0, 0)
                  const openLeft = (globalPos.x + entry.width + submenuWidth > (screen ? screen.width : Screen.width))

                  // Position with overlap
                  const anchorX = openLeft ? -submenuWidth + overlap : entry.width - overlap

                  // Create submenu
                  entry.subMenu = Qt.createComponent("TrayMenu.qml").createObject(root, {
                                                                                    "menu": modelData,
                                                                                    "anchorItem": entry,
                                                                                    "anchorX": anchorX,
                                                                                    "anchorY": 0,
                                                                                    "isSubMenu": true,
                                                                                    "screen": screen
                                                                                  })

                  if (entry.subMenu) {
                    entry.subMenu.showAt(entry, anchorX, 0)
                  }
                }
              }

              onExited: {
                Qt.callLater(() => {
                               if (entry.subMenu && !entry.subMenu.isHovered) {
                                 entry.subMenu.hideMenu()
                                 entry.subMenu.destroy()
                                 entry.subMenu = null
                               }
                             })
              }
            }
          }

          Component.onDestruction: {
            if (subMenu) {
              subMenu.destroy()
              subMenu = null
            }
          }
        }
      }
    }
  }
}