import Quickshell
import QtQuick
import QtQuick.Effects

MultiEffect {
    id: blur
    blurEnabled: true
    blur: 1
    blurMax: 64
    blurMultiplier: 1.2
    autoPaddingEnabled: false
}