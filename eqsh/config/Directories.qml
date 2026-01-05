pragma Singleton

import Quickshell
import QtQuick
import qs.core.foundation

Singleton {
	id: root

	property string runtimeDir: SPPathResolver.home + "/.config/aureli"
	property string notificationsPath: runtimeDir + "/notifications.json"
	property string widgetsPath: runtimeDir + "/widgets.json"
	property string pluginsPath: runtimeDir + "/plugins"
}