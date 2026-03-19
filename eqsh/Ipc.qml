pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Services.Pipewire
import Quickshell.Io
import qs.ui.controls.auxiliary

import "root:/config/mixins.js" as Mixins

Singleton {
    id: root
    function init() {}
    property var mixins: Mixins.mixins
    property var audioSink: Pipewire.defaultAudioSink
    function getMixin(name: string): var {return mixins[name] || {}}
    function runMixin(name: string, method: string, ...args) {
        const mixin = getMixin(name)
        if (mixin[method]) void mixin[method](...args)
    }
    function mixin(name: string, method: string, handler: var) {
        if (!mixins[name]) mixins[name] = {}
        mixins[name][method] = handler
    }

    // ==============================================================
    IpcHandler {
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
    IpcHandler {
        target: "spotlight"
        function set(visible: bool) {
            runMixin("eqdesktop.spotlight", "set", visible)
        }
        function toggle() {
            runMixin("eqdesktop.spotlight", "toggle")
        }
    }
    IpcHandler {
        target: "menubar"
        function set(visible: bool) {
            runMixin("eqdesktop.menubar", "set", visible)
        }
        function toggle() {
            runMixin("eqdesktop.menubar", "toggle")
        }
    }
    // ===============================================================
    CustomShortcut {
        name: "spotlight"
        description: "Toggle Spotlight"
        onPressed: {
            runMixin("eqdesktop.spotlight", "toggle");
        }
    }
}