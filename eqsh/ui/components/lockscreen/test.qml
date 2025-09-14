import QtQuick
import Quickshell

ShellRoot {
	LockContext {
		id: lockContext
		onUnlocked: Qt.quit();

		onUnlocking: {
			locksur.unlock();
		}
	}

	FloatingWindow {
		color: "transparent"
		LockSurface {
			id: locksur
			anchors.fill: parent
			context: lockContext
		}
	}

	Connections {
		target: Quickshell

		function onLastWindowClosed() {
			Qt.quit();
		}
	}
}
