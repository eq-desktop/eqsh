import Quickshell
import QtQuick
import QtQuick.Layouts
import qs
import qs.config
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import qs.ui.controls.providers

import "root:/agents/time.js" as TimeUtils

ListView {
    id: root
    spacing: 4

    signal actionClicked()
    signal keyPressed(var event)

    required property string textColor

    onKeyPressed: (event) => {
        // check if key is arrow down
        if (event.key === Qt.Key_Down) {
            if (root.selected === -1) {
                root.selected = 0
                return
            }
            root.incrementCurrentIndex()
            root.selected = root.currentIndex
        }
        // check if key is arrow up
        if (event.key === Qt.Key_Up) {
            root.decrementCurrentIndex()
            root.selected = root.currentIndex
        }

        if (event.key === Qt.Key_Return) {
            if (root.selected === -1 && root.recommended !== -1) {
                model.values[root.recommended]?.clicked()
                return
            }
            if (root.selected !== -1 && root.selected < model.values.length) {
                model.values[root.selected]?.clicked()
            }
        }
    }

    property int recommended: -1
    property int selected: -1

    required property string text
    required property list<var> answers
    model: ScriptModel {
        values: Cliphist.preparedEntries.map(entry => ({
            type: Cliphist.entryType(entry.name.target),
            text: entry.name.target,
            time: Date.now(),
            clicked: (mouse) => {
                if (!mouse) {
                    root.actionClicked()
                    Cliphist.paste(entry.target)
                    return;
                }
                if (mouse.button === Qt.LeftButton) {
                    root.actionClicked()
                    Cliphist.paste(entry.name.target)
                } else {
                    Cliphist.deleteEntry(entry.entry)
                }
            }
        }))
    }
    onTextChanged: {
        model.values = Cliphist.fuzzyQuery(root.text).map(entry => ({
            type: Cliphist.entryType(entry.name.target),
            text: entry.name.target,
            time: Date.now(),
            clicked: (mouse) => {
                if (!mouse) {
                    root.actionClicked()
                    Cliphist.copy(entry.entry)
                    return;
                }
                if (mouse.button === Qt.LeftButton) {
                    root.actionClicked()
                    Cliphist.copy(entry.entry)
                } else {
                    Cliphist.deleteEntry(entry.entry)
                }
            }
        }))
        root.currentIndex = 0
        root.recommended = 0
    }

    property int customHeight: model.values.length == 0 ? 50 : root.contentHeight

    CFText {
        visible: model.values.length == 0
        anchors.centerIn: parent
        color: root.textColor
        font.pixelSize: 18
        text: Translation.tr("No results found")
    }

    delegate: ContentItem {
        id: contentItem
        property bool isRecommended: root.recommended === contentItem.index
        property bool isSelected: root.selected === contentItem.index
        color: isSelected ? AccentColor.color : (isRecommended ? "#50555555" : "transparent")
        textColor: isSelected ? AccentColor.textColor : "#222"
        descColor: isSelected ? Qt.alpha(AccentColor.textColor, 0.5) : "#a0555555"
        title: modelData?.text ?? ""
        description: modelData ? `${modelData.type.charAt(0).toUpperCase() + modelData.type.slice(1)}` : ""
        icon: Quickshell.iconPath("text")
        clicked: modelData?.clicked ?? (() => {})

        bgForIcon: false

        Rectangle {
            id: rightItem
            anchors {
                right: parent.right
                rightMargin: 12
                verticalCenter: parent.verticalCenter
            }
            width: 30; height: 30
            radius: 15
            color: "#30555555"
            CFVI {
                anchors.centerIn: parent
                size: 20
                color: contentItem.textColor
                icon: "spotlight/clipboard-fill.svg"
                noAnimate: true
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    if (modelData.type == "file") {
                        Quickshell.clipboardText = (contentItem.modelData.text.startsWith("file://") ? contentItem.modelData.text : "file://" + contentItem.modelData.text)
                        return;
                    }
                    Quickshell.clipboardText = contentItem.modelData.text
                }
            }
        }
    }
}