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
    property var gridItem
    property var baseWidget
    property var options: gridItem?.options ?? ({})
    property int textSize: baseWidget?.textSize ?? 0
    property int textSizeM: baseWidget?.textSizeM ?? 0
    property int textSizeL: baseWidget?.textSizeL ?? 0
    property int textSizeXL: baseWidget?.textSizeXL ?? 0
    property int textSizeXXL: baseWidget?.textSizeXXL ?? 0
    property int textSizeSL: baseWidget?.textSizeSL ?? 0
    property int textSizeSSL: baseWidget?.textSizeSSL ?? 0
    function getOption(name, defaultVal) {
        if (!(name in root.options)) return defaultVal;
        if (root.options[name] != "") return root.options[name];
        return defaultVal;
    }
    Connections {
        target: Plugins
        function onLoadedChanged() {
            root.destroy();
        }
    }
}