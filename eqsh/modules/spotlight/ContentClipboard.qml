import Quickshell
import QtQuick
import QtQuick.Layouts
import qs
import qs.config
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import qs.ui.controls.providers
import qs.services

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
            if (root.selected !== -1 && root.selected < model.values.length) {
                model.values[root.selected]?.clicked()
                return
            }
            if (root.selected === -1 && root.recommended !== -1) {
                model.values[root.recommended]?.clicked()
                return
            }
        }
    }

    property int recommended: -1
    property int selected: -1

    required property string text
    required property list<var> answers
    model: ScriptModel {
        values: ClipboardService.history.map(entry => ({
            type: entry.type,
            text: entry.data,
            time: entry.date,
            b64: entry.b64,
            path: entry.path,
            clicked: (mouse) => {
                if (!mouse) {
                    root.actionClicked()
                    Quickshell.clipboardText = entry.data
                    return;
                }
                if (mouse.button === Qt.LeftButton) {
                    root.actionClicked()
                    Quickshell.clipboardText = entry.data
                } else {
                    return;
                    //Cliphist.deleteEntry(entry.entry)
                }
            }
        })).sort((a, b) => b.time - a.time)
    }
    onTextChanged: {
        model.values = ClipboardService.fuzzyQuery(root.text).map(entry => ({
            type: "text",
            text: entry ? entry.name : "",
            time: entry.date,
            b64: entry.b64,
            path: entry.path,
            clicked: (mouse) => {
                if (!mouse) {
                    root.actionClicked()
                    Quickshell.clipboardText = entry.data
                    return;
                }
                if (mouse.button === Qt.LeftButton) {
                    root.actionClicked()
                    Quickshell.clipboardText = entry.data
                } else {
                    return;
                    //Cliphist.deleteEntry(entry.entry)
                }
            }
        })).sort((a, b) => b.time - a.time)
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
        textColor: isSelected ? AccentColor.textColor : Config.general.darkMode ? "#dfdfdf" : "#222"
        descColor: isSelected ? Qt.alpha(AccentColor.textColor, 0.5) : "#a0555555"
        title: modelData.type == "Image" ? "Image" : modelData.text.replace(/\n/g, "")
        description: modelData.type == "Image" ? TimeUtils.getFriendlyTime(modelData.time, Translation) : `${modelData.type.charAt(0).toUpperCase() + modelData.type.slice(1)} · ${TimeUtils.getFriendlyTime(modelData.time, Translation)}`
        icon: modelData.type == "Image" ? "file://" + modelData.path : Quickshell.iconPath("text")
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