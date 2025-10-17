import QtQuick
import QtQuick.Controls
import qs.config
import QtQuick.Layouts
import QtQuick.Dialogs
import QtQuick.Effects
import QtQuick.Shapes
import QtQuick.VectorImage
import Quickshell
import qs
import qs.ui.components.settings.pages
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.ui.controls.primitives
import Quickshell.Io
import Quickshell.Widgets

ScrollView {
    ColumnLayout {
        anchors.fill: parent
        CFText { text: Translation.tr("Language") }
        ComboBox {
            model: Translation.availableLanguages
            Component.onCompleted: { // Prevents Binding loop
                // set initial index once
                currentIndex = model.findIndex(l => l === Config.general.language)
            }
            onCurrentTextChanged: {
                Config.general.language = currentText;
            }
        }
    }
}