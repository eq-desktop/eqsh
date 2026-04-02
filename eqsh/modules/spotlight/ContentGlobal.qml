import Quickshell
import QtQuick
import QtQuick.Layouts
import qs
import qs.config
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives

ListView {
    id: root
    spacing: 4

    required property string text
    required property list<var> answers
    signal keyPressed(var event)

    required property string textColor

    model: ScriptModel {
        values: root.text == "" ? [] : root.answers
    }

    delegate: ContentItem {}
}