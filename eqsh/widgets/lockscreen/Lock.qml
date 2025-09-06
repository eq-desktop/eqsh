import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import qs.components.misc

Scope {
	id: root
	signal lock()
	signal unlock()
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