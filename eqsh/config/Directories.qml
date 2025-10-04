pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root

	property string runtimeDir: Quickshell.shellDir + "/runtime"
	property string notificationsPath: runtimeDir + "/notifications.json"
	property string widgetsPath: runtimeDir + "/widgets.json"
}