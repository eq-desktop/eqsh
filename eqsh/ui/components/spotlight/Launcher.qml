import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Effects
import qs
import qs.config
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import qs.ui.controls.primitives
import qs.ui.controls.windows
import qs.ui.controls.windows.dropdown

Scope {
    id: root

    property bool actionsShown: false
    property string selectedAction: ""
    property string hoveredAction: ""
    property string glassColor: "#a0ffffff"
    property string textColor: "#1e1e1e"

    function clickAction(action: string) {
        root.hoveredAction = ""
        root.selectedAction = action
        root.actionsShown = false
    }

    Component.onCompleted: {
        Ipc.mixin("eqdesktop.spotlight", "toggle", () => {
            Runtime.spotlightOpen = !Runtime.spotlightOpen;
        });
        Ipc.mixin("eqdesktop.spotlight", "set", (visible) => {
            Runtime.spotlightOpen = visible;
        });
    }

    FollowingPanelWindow {
        id: launcher
        color: "transparent"
        WlrLayershell.namespace: "eqsh:blur"
        WlrLayershell.layer: WlrLayershell.Overlay
        WlrLayershell.keyboardFocus: launcher.isVisible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

        focusable: true

        mask: Region {
            item: Runtime.spotlightOpen ? spotlight : null
        }

        anchors {
            top: true
            bottom: true
            left: true
            right: true
        }

        property bool isVisible: Runtime.spotlightOpen

        onIsVisibleChanged: {
            if (isVisible) {
                root.actionsShown = false;
                root.hoveredAction = "";
                root.selectedAction = "";
                search.focus = true
                hideAnim.stop()
                showAnim.start()
            } else {
                search.text = ""
                root.actionsShown = false
                root.hoveredAction = ""
                showAnim.stop()
                hideAnim.start()
            }
        }

        SequentialAnimation {
            id: showAnim
            ParallelAnimation {
                PropertyAnimation {
                    target: background
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 200
                    easing.type: Easing.OutBack
                    easing.overshoot: 1
                }
                PropertyAnimation {
                    target: background
                    property: "scaleX"
                    from: 1.3
                    to: 1
                    duration: 200
                    easing.type: Easing.OutBack
                    easing.overshoot: 1
                }
            }
        }

        SequentialAnimation {
            id: hideAnim
            ParallelAnimation {
                PropertyAnimation {
                    target: background
                    property: "opacity"
                    from: 1
                    to: 0
                    duration: 200
                }
                PropertyAnimation {
                    target: background
                    property: "scaleX"
                    from: 1
                    to: 1.1
                    duration: 130
                }
            }
        }
        Item {
            id: spotlight
            anchors.fill: parent
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Runtime.spotlightOpen = false;
                }
            }
            BoxGlass {
                id: background
                z: 99
                anchors.top: parent.top
                anchors.topMargin: 200
                anchors.left: parent.left
                anchors.leftMargin: parent.width / 2 - 270
                visible: true
                opacity: 0
                width: root.actionsShown ? 340 : 540
                Behavior on width {
                    NumberAnimation {
                        duration: 300
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                }
                implicitHeight: results.height + search.height + 8
                radius: 30
                color: root.glassColor
                rimStrength: 1.7
                light: "#20ffffff"
                lightDir: Qt.point(1, 1)
                layer.enabled: true
                property real scaleX: 1
                transform: Scale {
                    xScale: background.scaleX
                    origin.x: background.width / 2
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onPositionChanged: (mouse) => {
                        if (root.selectedAction != "") return;
                        root.actionsShown = true
                        root.hoveredAction = ""
                    }
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 10

                        TextField {
                            id: search
                            Layout.fillWidth: true
                            Layout.preferredHeight: 50
                            leftPadding: 44
                            font.pixelSize: 30
                            color: root.textColor
                            CFVI {
                                id: sicon
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                size: {
                                    if (root.selectedAction == "applications") {
                                        30
                                    } else if (root.selectedAction == "files") {
                                        25
                                    } else if (root.selectedAction == "actions") {
                                        30
                                    } else if (root.selectedAction == "clipboard") {
                                        30
                                    } else {
                                        25
                                    }
                                }
                                opacity: 0.5
                                color: root.textColor
                                icon: {
                                    if (["", "search"].includes(root.selectedAction)) {
                                        "search.svg"
                                    } else if (root.selectedAction == "applications") {
                                        "spotlight/applications.svg"
                                    } else if (root.selectedAction == "files") {
                                        "spotlight/files.svg"
                                    } else if (root.selectedAction == "actions") {
                                        "spotlight/actions.svg"
                                    } else if (root.selectedAction == "clipboard") {
                                        "spotlight/clipboard.svg"
                                    }
                                }
                            }
                            background: Text {
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignLeft
                                anchors.leftMargin: 44
                                font.pixelSize: 26
                                font.weight: 500
                                color: root.textColor
                                opacity: 0.7
                                visible: search.text == ""
                                text: {
                                    if (root.hoveredAction == "" && root.selectedAction == "") {
                                        return Translation.tr("Spotlight Search")
                                    } else {
                                        switch (root.hoveredAction == "" ? root.selectedAction : root.hoveredAction) { // This has to be hardcoded, because of the Translation manager
                                            case "applications": return Translation.tr("Applications")
                                            case "files": return Translation.tr("Files")
                                            case "actions": return Translation.tr("Actions")
                                            case "clipboard": return Translation.tr("Clipboard")
                                            default: return Translation.tr("Spotlight Search")
                                        }
                                    }
                                }
                                Key {
                                    anchors {
                                        right: parent.right
                                        rightMargin: 50
                                        verticalCenter: parent.verticalCenter
                                    }
                                    key: "⌃"
                                    keyColor: root.textColor
                                    visible: root.hoveredAction != ""
                                }
                                Key {
                                    anchors {
                                        right: parent.right
                                        rightMargin: 20
                                        verticalCenter: parent.verticalCenter
                                    }
                                    keyColor: root.textColor
                                    key: {
                                        switch (root.hoveredAction) {
                                            case "applications": return "1"
                                            case "files": return "2"
                                            case "actions": return "3"
                                            case "clipboard": return "4"
                                            default: return ""
                                        }
                                    }
                                    visible: root.hoveredAction != ""
                                }
                            }
                            focus: true
                            Keys.onPressed: (event) => {
                                results.keyPressed(event)
                                if (event.key === Qt.Key_Escape) Ipc.runMixin("eqdesktop.spotlight", "toggle")
                                // action keys
                                if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_0) root.clickAction("search")
                                if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_1) root.clickAction("applications")
                                else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_2) root.clickAction("files")
                                else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_3) root.clickAction("actions")
                                else if ((event.modifiers & Qt.ControlModifier) && event.key === Qt.Key_4) root.clickAction("clipboard")
                            }
                            onTextEdited: {
                                if (text == "") {
                                    root.clickAction("");
                                    return;
                                }
                                if (root.selectedAction != "") return;
                                root.clickAction("search");
                            }

                            Rectangle {
                                anchors {
                                    right: parent.right
                                    rightMargin: 12
                                    verticalCenter: parent.verticalCenter
                                }
                                width: 18; height: 18
                                radius: 12
                                color: root.textColor
                                visible: root.selectedAction == "clipboard"
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: (mouse) => {
                                        rightClickMenuClipboard.x = mouse.x + background.x + 500
                                        rightClickMenuClipboard.y = mouse.y + background.y + 20
                                        rightClickMenuClipboard.open()
                                    }
                                }
                            }
                        }

                        ContentView {
                            id: results
                            text: search.text
                            selectedAction: root.selectedAction
                            textColor: root.textColor
                            shown: root.selectedAction != ""
                            onActionClicked: {
                                Ipc.runMixin("eqdesktop.spotlight", "toggle")
                            }
                        }
                    }
                }
            }
            DropDownMenu {
                id: rightClickMenuClipboard
                model: [
                    DropDownItem {
                        name: Translation.tr("Clear History")
                        action: function() {Cliphist.wipe()}
                    }
                ]
            }
            ActionButton {
                id: applications
                z: 1

                actionsShown: root.actionsShown
                launcherVisible: launcher.isVisible
                textColor: root.textColor
                glassColor: root.glassColor

                onHoveredAction: (action) => {root.hoveredAction = action}
                onSelectedAction: (action) => {root.clickAction(action)}

                position: 0
                action: "applications"
            }
            
            ActionButton {
                id: files
                z: 1

                actionsShown: root.actionsShown
                launcherVisible: launcher.isVisible
                textColor: root.textColor
                glassColor: root.glassColor

                onHoveredAction: (action) => {root.hoveredAction = action}
                onSelectedAction: (action) => {root.clickAction(action)}

                position: 1
                action: "files"
            }
            
            ActionButton {
                id: actions
                z: 1

                actionsShown: root.actionsShown
                launcherVisible: launcher.isVisible
                textColor: root.textColor
                glassColor: root.glassColor

                onHoveredAction: (action) => {root.hoveredAction = action}
                onSelectedAction: (action) => {root.clickAction(action)}

                position: 2
                action: "actions"
            }
            
            ActionButton {
                id: clipboard
                z: 1

                actionsShown: root.actionsShown
                launcherVisible: launcher.isVisible
                textColor: root.textColor
                glassColor: root.glassColor

                onHoveredAction: (action) => {root.hoveredAction = action}
                onSelectedAction: (action) => {root.clickAction(action)}

                position: 3
                iconSize: 38
                action: "clipboard"
            }
        }
    }
}