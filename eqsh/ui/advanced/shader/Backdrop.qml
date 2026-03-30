import Quickshell
import Quickshell.Widgets
import QtQuick
import QtQuick.Effects

ShaderEffectSource {
    property int sourceX: 0
    property int sourceY: 0
    property int sourceW: 0
    property int sourceH: 0
    sourceRect: Qt.rect(sourceX, sourceY, sourceW, sourceH)
    hideSource: false
    live: true
}