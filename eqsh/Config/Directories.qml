pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root

	property string notificationsPath: Quickshell.shellDir + "/Runtime/notifications.json"
	property string widgetsPath: Quickshell.shellDir + "/Runtime/widgets.json"
}