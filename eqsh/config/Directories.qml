pragma Singleton

import Quickshell
import QtQuick

Singleton {
	id: root

	property string notificationsPath: Quickshell.shellDir + "/cache/notifications.json"
}