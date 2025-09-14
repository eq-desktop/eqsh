pragma Singleton
import Quickshell
import QtQuick
import QtQuick.Controls
import Qt.labs.folderlistmodel
import QtQuick.Dialogs

Singleton {
  function getAppName(wmclass) {
    var entry = DesktopEntries.byId(wmclass)
    if (entry) return entry.name
    return wmclass
  }

  function getAppExec(wmclass) {
    var entry = DesktopEntries.byId(wmclass)
    if (entry) return entry.execString
    return wmclass
  }
}