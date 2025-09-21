//@ pragma UseQApplication
//@ pragma Env QT_SCALE_FACTOR=1
import Quickshell
import Quickshell.Wayland
import Quickshell.Io
import QtQuick
import qs.ui.components.panel
import qs.ui.components.lockscreen
import qs.ui.components.dock
import qs.ui.components.misc
import qs.ui.components.notifi
import qs.ui.components.launchpad
import qs.ui.components.osd
import qs.ui.components.dialog
import qs.ui.components.notch
import qs.ui.components.widgets
import qs.ui.components.settings
import qs.ui.Controls.Auxiliary
import qs.ui.Controls.Advanced
import qs.ui.Controls.providers
import qs.Config
import qs.Core.Foundation

Scope {
  id: root
  Settings {}
  HyprPersist {}
  ReloadPopup {}
  Loader { active: Config.wallpaper.enable; sourceComponent: Background {}}
  Loader {
    active: Config.lockScreen.enable
    sourceComponent: Lock {
      onUnlocking: if (!Config.notch.delayedLockAnim) Runtime.locked = false
      onUnlock: Runtime.locked = false
      onLock: Runtime.locked = true
    }
  }
  //Dock {}
  StatusBar {
    id: bar
    customAppName: Runtime.customAppName
    visible: !Runtime.locked
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
  }
  NotificationList {}
  Loader { active: Config.launchpad.enable; sourceComponent: LaunchPad {} }
  Loader { active: Config.osd.enable; sourceComponent: VolumeOSD {} }
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
  Loader { active: Config.dialogs.enable; sourceComponent: Dialog {}}
  Loader { active: Config.widgets.enable; sourceComponent: EditWidgets {}}
  ActivateLinux {}
  Version {}
  ScreenCorners {}
}