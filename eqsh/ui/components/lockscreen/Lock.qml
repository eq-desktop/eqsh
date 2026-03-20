import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs
import qs.ui.controls.auxiliary

Scope {
	id: root
	signal lock()
	signal unlock()
	signal unlocking()
    LazyLoader {
		id: loader
		ShellRoot {
			LockContext {
				id: lockContext

				Connections {
					target: root
					function onUnlock() {
						lock.locked = false;
					}
				}

				onUnlocked: {
					root.unlock();
					lock.locked = false;
				}
			}

			WlSessionLock {
				id: lock
				locked: true
				onLockedChanged: {
					if (!locked)
						loader.active = false;
				}
				WlSessionLockSurface {
					id: lockSurface
					color: "transparent"
					LockSurface {
						id: locksur
						anchors.fill: parent
						context: lockContext
						screen: lockSurface.screen
						Connections {
							target: lockContext
							function onUnlocking() {
								root.unlocking();
								locksur.unlock();
							}
						}
					}
				}
			}
		}
    }

	Component.onCompleted: {
		Ipc.mixin("eqdesktop.lock", "lock", () => {
			root.lock();
			loader.activeAsync = true;
		});
		Ipc.mixin("eqdesktop.lock", "unlock", () => {
			root.unlock();
		});
		Ipc.mixin("eqdesktop.lock", "isLoaded", () => {
			return loader.active;
		});
	}

	function lockScreen() {
		root.lock();
		loader.activeAsync = true;
	}
}