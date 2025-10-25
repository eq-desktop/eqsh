import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Io
import qs
import qs.config
import qs.ui.controls.windows
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives
import qs.ui.controls.providers
import qs.ui.controls.advanced

import "root:/agents/ai.js" as AIAgent

Scope {
    id: root
    property var agent: AIAgent

    FileView {
        id: sigridPrompt
        path: Config.sigrid.systemPromptLocation
        blockLoading: true
    }

    function toggle() {
        Runtime.aiOpen = !Runtime.aiOpen;
    }
    IpcHandler {
        target: "sigrid"
        function toggle() {
            root.toggle();
        }
    }
    CustomShortcut {
        name: "sigrid"
        description: "Toggle Sigrid"
        onPressed: {
            root.toggle();
        }
    }
    FollowingPanelWindow {
        id: panelWindow
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "eqsh:lock-blur"
        anchors {
            top: true
            right: true
            bottom: true
        }
        focusable: true
        exclusiveZone: -1
        color: "transparent"
        implicitWidth: 400
        margins {
            top: Config.bar.height
        }
        mask: Region {
            item: Runtime.aiOpen ? contentItem : null
        }
        visible: true
        property string state: "ask" // ask, answer, error
        property bool showing: Runtime.aiOpen
        property bool visibleC: false
        property list<var> answers: []
        onShowingChanged: {
            if (showing) {
                showAIAnim.start()
                hideAIAnim.stop()
                grab.active = true
            } else {
                hideAIAnim.start()
                showAIAnim.stop()
                grab.active = false
            }
        }

        PropertyAnimation {
            id: showAIAnim
            target: contentItem
            properties: "anchors.topMargin"
            from: -10
            to: 10
            duration: 500
            easing.type: Easing.OutBack
            easing.overshoot: 0.5
            onStarted: {
                panelWindow.visibleC = true
                contentItem.opacity = 1
                contentItem.scale = 1
            }
        }

        PropertyAnimation {
            id: hideAIAnim
            target: contentItem
            properties: "anchors.topMargin"
            from: 10
            to: -10
            duration: 500
            easing.type: Easing.OutBack
            easing.overshoot: 2
            onStarted: {
                contentItem.opacity = 0
                contentItem.scale = 0.9
            }
            onFinished: {
                panelWindow.visibleC = false
            }
        }

        HyprlandFocusGrab {
            id: grab
            windows: [ panelWindow ]
            onCleared: {
                Runtime.aiOpen = false
            }
        }

        Item {
            id: contentItem
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 10
                topMargin: -10
                bottom: parent.bottom
            }
            scale: 0.9
            Behavior on scale { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
            onScaleChanged: {
                panelWindow.mask.changed();
            }
            opacity: 0
            visible: panelWindow.visibleC
            width: 300
            BoxGlass {
                id: input
                anchors {
                    top: parent.top
                    horizontalCenter: parent.horizontalCenter
                    margins: 10
                }
                z: 3
                width: 300
                height: 40
                light: '#380404'
                glowStrength: 0.2
                negLight: '#50380404'
                property real siconScale: 1
                property real xOffset: 0
                property bool error: false
                property bool loading: false
                transform: Translate { x: input.xOffset }
                TextField {
                    id: inputText
                    anchors.fill: parent
                    focus: Runtime.aiOpen
                    color: "#fff"
                    leftPadding: 38
                    CFI {
                        id: sicon
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 4
                        size: 34
                        scale: input.siconScale
                        sourceSize: Qt.size(128, 128)
                        opacity: 1
                        colorized: false
                        icon: "ai.png"
                    }
                    background: CFText {
                        anchors.fill: parent
                        anchors.leftMargin: 38
                        verticalAlignment: Text.AlignVCenter
                        horizontalAlignment: Text.AlignLeft
                        color: input.error ? "#ff5f5f" : '#fff'
                        font.weight: 500
                        opacity: inputText.text == "" ? 1 : 0
                        text: input.loading ? Translation.tr("Sigrid is thinking…") : input.error ? Translation.tr("Error: Please try again later…") : Translation.tr("Ask Sigrid…")
                    }
                    renderType: Text.NativeRendering
                    font.family: Fonts.sFProDisplayRegular.family
                    font.pixelSize: 16
                    onAccepted: {
                        console.info("Request AI Answer To: " + inputText.text)
                        acceptAnim.start()
                        loadingAnim.start()
                        loadingAnim2.start()
                        input.error = false
                        input.loading = true
                        panelWindow.answers.push(["user", inputText.text])
                        agent.call(inputText.text, Config.sigrid.key, Config.sigrid.model, {systemPrompt: sigridPrompt.text(), previousMessages: panelWindow.answers.map(function(a) { return {role: a[0], content: a[1]} })}, function(success, response) {
                            input.loading = false
                            loadingAnim.stop()
                            loadingAnim2.stop()
                            input.siconScale = 1
                            Runtime.aiOpen = true
                            if (success) {
                                panelWindow.state = "answer"
                                input.glowStrength = 0
                                panelWindow.answers.push(["sigrid", response.candidates[0].content.parts[0].text])
                            } else {
                                panelWindow.state = "error"
                                wiggleAnim.start()
                                input.error = true
                            }
                        })
                        inputText.text = ""
                    }
                }
                SequentialAnimation {
                    id: wiggleAnim
                    running: false
                    loops: 1
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x - 10; duration: 100; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x + 10; duration: 100; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x - 7; duration: 100; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x + 7; duration: 100; easing.type: Easing.InOutQuad }
                    PropertyAnimation { target: input; property: "xOffset"; to: input.x; duration: 100; easing.type: Easing.InOutQuad }
                }
                SequentialAnimation {
                    id: acceptAnim
                    running: false
                    PropertyAnimation {
                        target: input
                        property: "scale"
                        to: 1.02
                        duration: 75
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                    PropertyAnimation {
                        target: input
                        property: "scale"
                        to: 1
                        duration: 75
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                }
                SequentialAnimation {
                    id: loadingAnim2
                    running: false
                    loops: -1
                    PropertyAnimation {
                        target: input
                        property: "siconScale"
                        to: 1.1
                        duration: 500
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                    PropertyAnimation {
                        target: input
                        property: "siconScale"
                        to: 1
                        duration: 1000
                        easing.type: Easing.OutBack
                        easing.overshoot: 2
                    }
                }
                SequentialAnimation {
                    id: loadingAnim
                    running: false
                    loops: -1

                    // Soft initial glow rise
                    PropertyAnimation {
                        target: input
                        property: "glowStrength"
                        to: 0.6
                        duration: 300
                        easing.type: Easing.OutQuad
                    }

                    // Gentle color cycle
                    ColorAnimation { target: input; property: "light"; to: "#b37aff"; duration: 2000; easing.type: Easing.InOutSine } // Purple
                    ColorAnimation { target: input; property: "light"; to: "#6699ff"; duration: 2000; easing.type: Easing.InOutSine } // Blue
                    ColorAnimation { target: input; property: "light"; to: "#ff5f5f"; duration: 2000; easing.type: Easing.InOutSine } // Red
                    ColorAnimation { target: input; property: "light"; to: "#ffd97a"; duration: 2000; easing.type: Easing.InOutSine } // Yellow
                    ColorAnimation { target: input; property: "light"; to: "#b37aff"; duration: 2000; easing.type: Easing.InOutSine } // Back to Purple
                }
            }
            ListView {
                id: answers
                anchors {
                    top: input.bottom
                    topMargin: 10
                    horizontalCenter: parent.horizontalCenter
                    bottom: parent.bottom
                }
                width: 300
                spacing: 10
                model: ScriptModel {
                    values: panelWindow.answers
                }
                add: Transition {
                    NumberAnimation { properties: "scale"; from: 0; to: 1; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2 }
                    NumberAnimation { properties: "opacity"; from: 0; to: 1; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2 }
                }
                remove: Transition {
                    NumberAnimation { properties: "scale"; from: 1; to: 0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2 }
                    NumberAnimation { properties: "opacity"; from: 1; to: 0; duration: 300; easing.type: Easing.OutBack; easing.overshoot: 2 }
                }
                header: Item {
                    height: 40
                    width: 300
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            panelWindow.answers.splice(0, panelWindow.answers.length)
                        }
                        BoxGlass {
                            id: header
                            color: '#2a1f0707'
                            light: '#50380404'
                            negLight: '#50380404'
                            z: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottomMargin: 10
                            width: clearBtnText.implicitWidth + 20
                            height: 30
                            scale: 1
                            opacity: 1
                            Text {
                                id: clearBtnText
                                anchors.fill: parent
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                color: "#fff"
                                text: Translation.tr("Clear")
                                font.family: Fonts.sFProDisplayBlack.family
                            }
                        }
                    }
                }
                headerPositioning: ListView.PullBackHeader
                delegate: BoxGlass {
                    id: output
                    required property var modelData
                    required property var index
                    color: '#2a1f0707'
                    light: '#50380404'
                    negLight: '#50380404'
                    z: 1
                    width: 300
                    property string text: modelData[0] == "user" ? "<font color=\"#aaa\">You: </font>" + modelData[1] : modelData[1]
                    opacity: 1
                    height: content.height + 20
                    scale: 1

                    ScrollView {
                        id: content
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: 10
                        }
                        contentWidth: 280
                        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                        height: Math.min(500, textO.implicitHeight)
                        TextEdit {
                            id: textO
                            renderType: Text.NativeRendering
                            font.family: Fonts.sFProDisplayBlack.family
                            text: output.text
                            color: "#fff"
                            selectionColor: "#555"
                            wrapMode: Text.Wrap
                            readOnly: true
                            width: 280
                            textFormat: TextEdit.MarkdownText
                        }
                    }
                    MouseArea {
                        id: mousearea
                        anchors.fill: parent
                        hoverEnabled: true
                    }

                    Rectangle {
                        anchors {
                            top: parent.top
                            right: parent.right
                            margins: 10.5
                        }
                        width: 15
                        height: 15
                        radius: 7.5
                        color: "#2a1f0707"
                        border {
                            width: 1
                            color: "#80ffffff"
                        }
                        scale: mousearea.containsMouse ? 1 : 0
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
                        CFVI {
                            anchors.centerIn: parent
                            size: 10
                            opacity: 1
                            icon: "x.svg"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                panelWindow.answers.splice(output.index, 1)
                            }
                        }
                    }
                }
            }
        }
    }
}