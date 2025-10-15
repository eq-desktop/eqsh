import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import qs
import qs.config
import qs.ui.controls.providers

BaseWidget {
    id: root
    content: Image {
        id: bg
        anchors.fill: parent
        source: root.widget.options.source
    }
}
