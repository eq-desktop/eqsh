//@ pragma UseQApplication
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.components.panel
import qs.components.lockscreen
import qs.components.dock
import qs.components.misc
import qs.components.notifi
import qs.widgets.misc
import qs.config
import qs.utils

Scope {
  id: root
  property string customAppName: ""
  ReloadPopup {}
  Background {}
  HyprPersist {}
  //Dock {}
  Bar {
    id: bar
    customAppName: root.customAppName
    Loader {
      readonly property Component lock: Lock {
        onLock: {
          bar.visible = false
        }
        onUnlock: {
          bar.visible = true
        }
      }
      sourceComponent: Config.lockScreen.enable ? lock : null
    }
    EdgeTrigger {
      id: triggerBar
      position: "tlr"
      height: 1
      onHovered: (monitor) => {
        if (triggerBar.active) {
          triggerBar.active = false
          triggerBar.height = 1
          bar.shown = false
          triggerBar.topMargin = 0
          if (Config.bar.autohide) {
            bar.forceHide = true
          }
          return;
        }
        triggerBar.active = true
        triggerBar.height = monitor.height - Config.bar.height
        bar.shown = true
        triggerBar.topMargin = Config.bar.height
        if (Config.bar.autohide) {
          bar.forceHide = false
        }
      }
    }
    Notch {
      id: notch
      onCollapse: (monitor) => triggerNotch.toggle(monitor);
      EdgeTrigger {
        id: triggerNotch
        position: "tlr"
        height: 1
        function toggle(monitor) {
          if (triggerNotch.active && !notch.expanded) {
            triggerNotch.active = false
            triggerNotch.height = 1
            notch.shown = false
            triggerNotch.topMargin = 0
            if (Config.notch.autohide) {
              notch.forceHide = true
            }
            return;
          }
          triggerNotch.active = true
          triggerNotch.height = monitor.height - (Config.notch.height+(Config.notch.islandMode ? 8 : 3))
          notch.shown = true
          triggerNotch.topMargin = (Config.notch.height+(Config.notch.islandMode ? 8 : 3))
          if (Config.notch.autohide) {
            notch.forceHide = false
          }
        }
        onClicked: (monitor) => toggle(monitor);
        onHovered: (monitor) => toggle(monitor);
      }
    }
  }
  NotificationList {}
  ActivateLinux {}
  Version {}
  Dialog {
    id: dialog
    onCustomAppNameChanged: {
      root.customAppName = dialog.customAppName;
    }
  }
  ScreenCorners {}
  // PanelWindow {
  //   implicitHeight: 500
  //   implicitWidth: 500
  //   Test {}
  // }
}