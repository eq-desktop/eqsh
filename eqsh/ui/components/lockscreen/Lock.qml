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

    CustomShortcut {
        name: "lock"
        description: "Lock the current session"
        onPressed: {
			root.lock();
			loader.activeAsync = true;
		}
    }

    CustomShortcut {
        name: "unlock"
        description: "Unlock the current session"
        onPressed: {
			root.unlock();
			loader.item.locked = false;
		}
    }

    IpcHandler {
        target: "eqlock"

        function lock(): void {
			root.lock();
            loader.activeAsync = true;
        }

        function unlock(): void {
			root.unlock();
            loader.item.locked = false;
        }

        function isLocked(): bool {
            return loader.active;
        }
    }
}