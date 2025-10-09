//@ pragma UseQApplication
//@ pragma Env QT_SCALE_FACTOR=1
//@ pragma IconTheme MacTahoe-dark
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
import qs.ui.components.popup
import qs.ui.components.spotlight
import qs.ui.components.widgets
import qs.ui.components.settings
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.config
import qs.core.foundation

Scope {
  id: root
  Settings {}
  HyprPersist {}
  ReloadPopup {}
  Loader { active: Config.wallpaper.enable; sourceComponent: Background {}}
  Loader {
    active: Config.lockScreen.enable
    asynchronous: true
    sourceComponent: Lock {
      onUnlocking: if (!Config.notch.delayedLockAnim) Runtime.locked = false
      onUnlock: Runtime.locked = false
      onLock: Runtime.locked = true
    }
  }
  StatusBar {
    id: bar
    customAppName: Runtime.customAppName
    visible: !Runtime.locked
    EdgeTrigger {
      id: triggerBar
      position: "tlr"
      height: 2
      onHovered: (monitor) => {
        if (triggerBar.active) {
          triggerBar.active = false
          triggerBar.height = 2
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
  Loader { active: Config.launchpad.enable; asynchronous: true; sourceComponent: LaunchPad {} }
  Dock {
    id: dock
    EdgeTrigger {
      id: triggerDock
      position: "blr"
      height: 1
      onHovered: (monitor) => {
        if (triggerDock.active) {
          triggerDock.active = false
          triggerDock.height = 2
          dock.shown = false
          triggerDock.bottomMargin = 0
          return;
        }
        triggerDock.active = true
        triggerDock.height = monitor.height - 120
        dock.shown = true
        triggerDock.bottomMargin = 120
      }
    }
  }
  Loader { active: Config.osd.enable; asynchronous: true; sourceComponent: VolumeOSD {} }
  Loader { active: Config.osd.enable; asynchronous: true; sourceComponent: BrightnessOSD {} }
  Launcher {}
  Popup {}
  Notch {
    id: notch
    EdgeTrigger {
      id: triggerNotch
      position: "tlr"
      height: 2
      function toggle(monitor) {
        if (triggerNotch.active && !notch.expanded) {
          triggerNotch.active = false
          triggerNotch.height = 2
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
  Loader { active: Config.dialogs.enable; asynchronous: true; sourceComponent: Dialog {}}
  ActivateLinux {}
  Version {}
  ScreenCorners {}
}