import QtQuick
import qs.ui.controls.primitives
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import QtQuick.Layouts
import qs.ui.controls.providers
import qs.config
import qs.core.system
import qs

Item {
    id: root
    anchors.fill: parent
    anchors.margins: 10
    property var options: null
    property int textSize: 0
    property int textSizeM: 0
    property int textSizeL: 0
    property int textSizeXL: 0
    property int textSizeXXL: 0
    property int textSizeSL: 0
    property int textSizeSSL: 0
    Connections {
        target: Plugins
        function onLoadedChanged() {
            root.destroy();
        }
    }
}