pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Io
import qs.services
import qs
import qs.ui.controls.auxiliary

import "root:/config/mixins.js" as Mixins

Singleton {
    id: root
    function init() {}
    property var mixins: Mixins.mixins
    property var audioSink: Pipewire.defaultAudioSink
    function getMixin(name: string): var {return mixins[name] || {}}
    function runMixin(name: string, method: string, ...args) {
        Logger.d("Ipc::runMixin", name, method, args)
        const mixin = getMixin(name)
        if (mixin[method]) {
            for (const handler of mixin[method]) {
                handler(...args)
            }
        }
    }
    function returnMixin(name: string, method: string, ...args): var {
        Logger.d("Ipc::returnMixin", name, method, args)
        const mixin = getMixin(name)
        let result = []
        if (mixin[method]) {
            for (const handler of mixin[method]) {
                result.push(handler(...args))
            }
        }
        return result
    }
    function returnLastMixin(name: string, method: string, ...args): var {
        Logger.d("Ipc::returnLastMixin", name, method, args)
        const result = returnMixin(name, method, ...args)
        if (result.length > 0) {
            return result[result.length - 1]
        }
        return undefined
    }
    function mixin(name: string, method: string, handler: var) {
        Logger.d("Ipc::mixin", name, method, handler)
        Logger.d("Ipc", "Assigning new handler", name, method, handler)
        if (!mixins[name]) throw new Error(`Mixin ${name} does not exist`)
        mixins[name][method].push(handler)
    }

    // ==============================================================
    IpcHandler { ////////////// Audio
        target: "audio"
        function louder() {
            if (!audioSink) return
            runMixin("eqdesktop.util.audio", "louder")
            audioSink.audio.volume += 0.1
        }
        function quieter() {
            if (!audioSink) return
            runMixin("eqdesktop.util.audio", "quieter")
            audioSink.audio.volume -= 0.1
        }
        function setVolume(volume: real) {
            if (!audioSink) return
            runMixin("eqdesktop.util.audio", "setVolume", volume)
            audioSink.audio.volume = volume
        }
    }
    IpcHandler { ////////////// Spotlight
        target: "spotlight"
        function set(visible: bool) {
            runMixin("eqdesktop.spotlight", "set", visible)
        }
        function toggle() {
            runMixin("eqdesktop.spotlight", "toggle")
        }
    }
    IpcHandler { ////////////// Menubar
        target: "menubar"
        function set(visible: bool) {
            runMixin("eqdesktop.menubar", "set", visible)
        }
        function toggle() {
            runMixin("eqdesktop.menubar", "toggle")
        }
    }
    IpcHandler { ////////////// AI
        target: "ai"
        function set(visible: bool) {
            runMixin("eqdesktop.ai", "set", visible)
        }
        function toggle() {
            runMixin("eqdesktop.ai", "toggle")
        }
    }
    IpcHandler { ////////////// Widgets
        target: "widgets"
        function toggleEditMode() {
            runMixin("eqdesktop.widgets", "toggleEditMode")
        }
    }
    IpcHandler { ////////////// Wallpaper
        target: "wallpaper"
        function change(path: string) {
            runMixin("eqdesktop.wallpaper", "change", path)
        }
    }
    IpcHandler { ////////////// Launchpad
        target: "launchpad"
        function toggle() {
            runMixin("eqdesktop.launchpad", "toggle")
        }
    }
    IpcHandler { ////////////// Lock
        target: "lock"

        function lock(): void {
			runMixin("eqdesktop.lock", "lock")
        }

        function unlock(): void {
			runMixin("eqdesktop.lock", "unlock")
        }

        function isLocked(): bool {
            return returnLastMixin("eqdesktop.lock", "isLocked")
        }
    }
    IpcHandler { ////////////// Notch
        target: "notch"
        function instance(code: string) {
            runMixin("eqdesktop.notch", "instance", code)
        }
        function activateInstance() {
            runMixin("eqdesktop.notch", "activateInstance")
        }
        function informInstance() {
            runMixin("eqdesktop.notch", "informInstance")
        }
        function closeInstance() {
            runMixin("eqdesktop.notch", "closeInstance")
        }
        function closeAllInstances() {
            runMixin("eqdesktop.notch", "closeAllInstances")
        }
    }
    IpcHandler { ////////////// Control Center
        target: "controlCenter"
        function open() {
            runMixin("eqdesktop.controlCenter", "open")
        }
        function close() {
            runMixin("eqdesktop.controlCenter", "close")
        }
        function openBluetooth() {
            runMixin("eqdesktop.controlCenter.bluetooth", "open")
        }
        function openWifi() {
            runMixin("eqdesktop.controlCenter.wifi", "open")
        }
    }
    IpcHandler { ////////////// Settings
        target: "settings"
        function toggle() {
            runMixin("eqdesktop.settings", "toggle")
        }
    }
	IpcHandler { ////////////// Notification Center
		target: "notificationCenter"
		function toggle() {
			runMixin("eqdesktop.notificationCenter", "toggle")
		}
	}
	IpcHandler { ////////////// Screenshot
		target: "screenshot"
		function open() {
			runMixin("eqdesktop.screenshot", "open")
		}
		function region() {
			runMixin("eqdesktop.screenshot", "region")
		}
		function screen() {
			runMixin("eqdesktop.screenshot", "screen")
		}
	}
    property bool isHypr: CompositorService.isHyprland
    // ===============================================================
    CustomShortcut {
        name: "screenshot"
        description: "Open Screenshot"
        onPressed: {
            runMixin("eqdesktop.screenshot", "open");
        }
    }
    CustomShortcut {
        name: "screenshotEntireScreen"
        description: "Take Screenshot of Entire Screen"
        onPressed: {
            runMixin("eqdesktop.screenshot", "screen");
        }
    }
    CustomShortcut {
        name: "screenshotRegion"
        description: "Take Screenshot of Selected Region"
        onPressed: {
            runMixin("eqdesktop.screenshot", "region");
        }
    }
    CustomShortcut {
        name: "spotlight"
        description: "Toggle Spotlight"
        onPressed: {
            runMixin("eqdesktop.spotlight", "toggle");
        }
    }
    CustomShortcut {
        name: "ai"
        description: "Toggle AI"
        onPressed: {
            runMixin("eqdesktop.ai", "toggle")
        }
    }
    CustomShortcut {
        name: "widgets"
        description: "Enter Widget Edit Mode"
        onPressed: {
            runMixin("eqdesktop.widgets", "toggleEditMode")
        }
    }
    CustomShortcut {
        name: "launchpad"
        description: "Toggle Launchpad"
        onPressed: {
            runMixin("eqdesktop.launchpad", "toggle")
        }
    }
    CustomShortcut {
        name: "toggleNotchActiveInstance"
        description: "Toggle notch active instance"
        onPressed: {
            runMixin("eqdesktop.notch", "activateInstance")
        }
    }
    CustomShortcut {
        name: "toggleNotchInfo"
        description: "Toggle notch info panel"
        onPressed: {
            runMixin("eqdesktop.notch", "informInstance")
        }
    }
    CustomShortcut {
        name: "controlCenterBluetooth"
        description: "Open Control Center Bluetooth Menu"
        onPressed: {
            runMixin("eqdesktop.controlCenter.bluetooth", "open")
        }
    }
    CustomShortcut {
        name: "controlCenter"
        description: "Open Control Center"
        onPressed: {
            runMixin("eqdesktop.controlCenter", "open")
        }
    }
    CustomShortcut {
        name: "settings"
        description: "Toggle Settings"
        onPressed: {
            runMixin("eqdesktop.settings", "toggle")
        }
    }
    CustomShortcut {
        name: "lock"
        description: "Lock the screen"
        onPressed: {
            runMixin("eqdesktop.lock", "lock")
        }
    }
    CustomShortcut {
    	name: "notificationCenter"
    	description: "Toggle Notification Center"
    	onPressed: {
    		runMixin("eqdesktop.notificationCenter", "toggle")
    	}
    }
    CustomShortcut {
    	name: "notificationCenterOpen"
    	description: "Open Notification Center"
    	onPressed: {
    		runMixin("eqdesktop.notificationCenter", "set", true)
    	}
    }
    CustomShortcut {
    	name: "notificationCenterClose"
    	description: "Close Notification Center"
    	onPressed: {
    		runMixin("eqdesktop.notificationCenter", "set", false)
    	}
    }
}
