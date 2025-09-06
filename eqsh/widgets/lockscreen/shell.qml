import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
	id: root
	LockContext {
		id: lockContext

		onUnlocked: {
			lock.locked = false;

			Qt.quit();
		}
	}

	WlSessionLock {
		id: lock
		locked: true

		WlSessionLockSurface {
			color: "transparent"
			LockSurface {
				id: locksur
				anchors.fill: parent
				context: lockContext
				Connections {
					target: lockContext
					function onUnlocking() {
						locksur.unlock();
					}
				}
			}
		}
	}
}
