import Quickshell
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Material
import QtQuick.Effects
import QtQuick.VectorImage
import QtQuick.Controls.Fusion
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import Quickshell
import qs.ui.controls.auxiliary
import qs.ui.controls.auxiliary.widget
import qs.ui.controls.primitives
import qs.ui.controls.windows
import qs.ui.controls.windows.dropdown
import qs.config
import qs.ui.components.panel
import qs.ui.controls.providers
import qs.ui.components.widgets.wi

import qs.ui.common
import qs.ui.advanced.shader.glass

import qs.core.system
import qs

Item {
    id: root
    anchors.fill: parent
    property int    idVal: 0
    property string name: "Widget"
    property string size: "1x1"
    property var gridContainer
    property var grid
    property var wallpaper
    property var screen
    property bool editMode: false
    property int xPos: 0
    property int yPos: 0
    property int newXPos: 0
    property int newYPos: 0
    property var options: {}
    property var settings: []
    property var _widgetObj: null
    property int gridWidth: gridSizeX * cellsX
    property int gridHeight: gridSizeY * cellsY
    readonly property int sizeF: parseInt(size.split("x")[0]) || 1
    readonly property int sizeS: parseInt(size.split("x")[1]) || 1
    property int sizeW: gridSizeX * sizeF
    property int sizeH: gridSizeY * sizeS
    required property var modelData
    required property var deleteWidget
    property bool beingDragged: ghostRect.visible
    property bool removing: false
    property bool isOpened: false
    signal removeRequested()
    signal widgetMoved()
    signal zoomOut()
    signal zoomIn()

    property real scaleCustom: 1

    Behavior on scaleCustom {
        NumberAnimation { duration: 300; easing.type: Easing.Linear; easing.overshoot: 1 }
    }

    // Ghost rectangle
    Control {
        id: ghostRect
        visible: false
        x: gridSizeX * xPos
        y: gridSizeY * yPos
        width: sizeW
        height: sizeH
        padding: 6
        contentItem: Rectangle {
            color: "transparent"
            border.color: "#55ffffff"
            border.width: 2
            radius: 20
        }
    }
    Connections {
        target: grid
        function onClickedBg() {
            card.goBack()
            root.zoomIn()
            root.isOpened = false
        }
    }
    onEditModeChanged: {
        draggableRect.rotation = 0
    }
    transform: Scale {
        origin.x: root.width / 2
        origin.y: root.height / 2
        xScale: root.scaleCustom
        yScale: root.scaleCustom
    }
    Rectangle {
        id: draggableRect
        width: sizeW
        height: sizeH
        color: root.editMode ? "transparent" : "transparent"
        radius: Config.widgets.radius
        x: gridSizeX * xPos
        y: gridSizeY * yPos

        Behavior on x {
            NumberAnimation { duration: 300; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }

        Behavior on y {
            NumberAnimation { duration: 500; easing.type: Easing.OutBack; easing.overshoot: 1 }
        }

        property real wobbleAmp: 1.5 + Math.random()
        property int wobbleSpeed: 100 + Math.random() * 50
        property real wobbleDir: Math.random() < 0.5 ? 1 : -1

        transformOrigin: Item.Center

        SequentialAnimation on rotation {
            id: wobbleAnim
            loops: Animation.Infinite
            running: root.editMode && Config.widgets.wobbleOnEdit
            NumberAnimation { to: draggableRect.wobbleAmp * draggableRect.wobbleDir; duration: draggableRect.wobbleSpeed; easing.type: Easing.InOutQuad }
            NumberAnimation { to: -draggableRect.wobbleAmp * draggableRect.wobbleDir; duration: draggableRect.wobbleSpeed * 2; easing.type: Easing.InOutQuad }
            NumberAnimation { to: 0; duration: draggableRect.wobbleSpeed; easing.type: Easing.InOutQuad }
        }

        Behavior on rotation {
            NumberAnimation { duration: 120; easing.type: Easing.OutQuad }
        }

        property var _widget: (root.name in Plugins.widgetRegistry)
            ? Plugins.widgetRegistry[root.name]
            : ({})
        
        UIFlipCard {
            id: card
            anchors.centerIn: parent
            frontWidth: parent.width - 20
            frontHeight: parent.height - 20
            backWidth: 340
            backHeight: 400
            z: card.isFlipped ? 15 : 1
            back: BoxGlass {
                anchors.fill: parent
                color: Config.general.darkMode ? "#222" : "#eee"
                radius: 30
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                }
                Connections {
                    target: Plugins
                    function onLoadedChanged() {
                        if (!(root.name in Plugins.widgetRegistry)) {
                            Logger.w("WidgetSettings", "Widget not found yet:", root.name)
                            return
                        }
                        let name = Plugins.nameFromId(root.name.split(":")[0])
                        if (!name) return
                        pluginName.text = name.value
                    }
                }
                CFText {
                    id: widgetName
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.margins: 24
                    font.pixelSize: 18
                    text: root.name.split(":")[1].replace("-", " ").toLowerCase().split(" ").map(w => w[0].toUpperCase() + w.slice(1)).join(" ")
                }
                CFText {
                    id: pluginName
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.topMargin: 46
                    anchors.margins: 24
                    font.pixelSize: 15
                    gray: true
                    text: "Unknown Plugin"
                }
                ListView {
                    id: propertiesList
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.bottom: parent.bottom
                    anchors.topMargin: 76
                    anchors.margins: 24
                    width: 340
                    height: contentHeight
                    spacing: 10
                    model: root.settings
                    delegate: Item {
                        id: propertyItem
                        required property var modelData
                        height: 29
                        width: 292
                        function write(data, check) {
                            if (!check) return;
                            root.options[modelData.name] = data
                            bw.loadWidget(null)
                        }
                        CFText {
                            id: propertyName
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: 0
                            font.pixelSize: 12
                            font.weight: 700
                            gray: true
                            text: modelData.name
                        }
                        CFSwitch {
                            id: propertySwitch
                            visible: modelData.type == "bool"
                            anchors.left: propertyName.right
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 10
                            checked: root.options[modelData.name] || modelData.value
                            onCheckedChanged: {
                                propertyItem.write(checked, modelData.type == "bool")
                            }
                        }
                        CFTextField {
                            id: propertyField
                            visible: modelData.type != "bool"
                            text: root.options[modelData.name] || modelData.value
                            height: 29
                            anchors.left: propertyName.right
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.leftMargin: 10
                            font.pixelSize: 12
                            font.weight: 700
                            padding: 0
                            color: "#fff"
                            backgroundColor: "#2a2a2a"
                            horizontalAlignment: Text.AlignHCenter
                            onEditingFinished: {
                                propertyItem.write(text, modelData.type != "bool")
                            }
                            Keys.onReturnPressed: {
                                propertyItem.write(text, modelData.type != "bool")
                            }
                            Keys.onEscapePressed: {
                                grid.clickedBg()
                            }
                        }
                    }
                }
            }
            property int cardX: (gridSizeX * xPos) + ((parent.width - 10) / 2)
            property int cardY: (gridSizeY * yPos) + ((parent.height - 10) / 2)

            property int dx: {
                let left = cardX - 170
                let right = cardX + 170

                if (right > root.width) return right - root.width + 5
                if (left < 0) return left + 5
                return 0
            }

            property int dy: {
                let top = cardY - 200
                let bottom = cardY + 200

                if (bottom > root.height) return bottom - root.height + 5
                if (top < 0) return top + 5
                return 0
            }

            backCard.anchors.rightMargin: card.isFlipped ? dx : 0
            backCard.anchors.leftMargin: card.isFlipped ? -dx : 0

            backCard.anchors.bottomMargin: card.isFlipped ? dy : 0
            backCard.anchors.topMargin: card.isFlipped ? -dy : 0
            front: BaseWidget {
                id: bw
                widget: root
                screen: root.screen
                wallpaper: root.wallpaper
                grid: root.grid
                isOpened: true
                Component.onCompleted: {
                    if (!(options.enableBg ?? true)) {
                        bw.bg = null
                    }
                }
                Timer {
                    id: removalTimer
                    interval: 180
                    running: false
                    repeat: false
                    onTriggered: root.removeRequested()
                }

                property alias removing: root.removing
                opacity: removing ? 0 : 1
                scale: removing ? 0.7 : 1

                layer.enabled: true
                layer.effect: MultiEffect {
                    blurEnabled: true
                    blur: 1
                    blurMax: removing ? 64 : 0
                    Behavior on blurMax { NumberAnimation { duration: 180; easing.type: Easing.OutBack; easing.overshoot: 0.5 } }
                }

                Behavior on opacity { NumberAnimation { duration: 180 } }
                Behavior on scale   { NumberAnimation { duration: 180; easing.type: Easing.InBack } }

                onRemovingChanged: {
                    if (removing) removalTimer.start()
                }
                function initializeSettings() {
                    if (!draggableRect._widget.f("config")) return []
                    const names = draggableRect._widget.f("config").children.map(p => [p.raw.name, p.raw.value])
                    let props = []
                    for (let i = 0; i < names.length; i++) {
                        let [type, name] = names[i][0].split(")")
                        type = type.split("(")[1]
                        props.push({
                            type,
                            name,
                            value: names[i][1] == ";" ? "" : names[i][1]
                        })
                    }
                    if (JSON.stringify(root.settings) !== JSON.stringify(props)) {
                        root.settings = props
                    }
                }
                function loadWidget(widget) {
                    if (root._widgetObj) {
                        root._widgetObj.destroy()
                    }
                    Logger.d("Plugins", "Loading Widget", widget ? widget.id : root.name);
                    if (widget) {
                        draggableRect._widget = widget.widget
                    } else {
                        if (!Plugins.loaded) return;
                        if (!(root.name in Plugins.widgetRegistry)) {
                            Logger.w("Widget", "Widget not found yet: " + root.name)
                            return
                        }
                        draggableRect._widget = Plugins.widgetRegistry[root.name]
                    }
                    let pluginWidget = Qt.createQmlObject(draggableRect._widget.f("onRender").children[0].raw, bw)
                    root._widgetObj = pluginWidget
                    pluginWidget.gridItem = root
                    pluginWidget.baseWidget = bw
                    initializeSettings()
                }
                Connections {
                    target: Plugins
                    function onLoadedChanged() {
                        bw.loadWidget(null);
                    }
                    Component.onCompleted: {
                        if (Plugins.loaded) {
                            bw.loadWidget(null);
                        }
                    }
                }
            }
        }

        DropDownMenu {
            id: rightClickMenu
            x: 0
            y: 0
            model: [
                DropDownItem {
                    name: Translation.tr("Remove Widget.")
                    icon: Quickshell.iconPath("close-symbolic")
                    action: function() {
                        root.removing = true
                    }
                },
                DropDownItem {
                    name: Translation.tr("Edit Widget.")
                    icon: Quickshell.iconPath("edit-symbolic")
                    action: function() {
                        card.open()
                        root.isOpened = true
                        root.zoomOut()
                    }
                }
            ]
        }
        
        MouseArea {
            anchors.fill: parent
            drag.target: root.editMode ? parent : undefined
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            z: 2
            enabled: !card.isFlipped

            property int gridXPos: root.xPos
            property int gridYPos: root.yPos

            drag.minimumX: 0
            drag.maximumX: gridWidth - draggableRect.width
            drag.minimumY: 0
            drag.maximumY: gridHeight - draggableRect.height

            onClicked: (mouse) => {
                if (mouse.button != Qt.RightButton) return
                rightClickMenu.x = mouse.x + draggableRect.x
                rightClickMenu.y = mouse.y + draggableRect.y + Config.bar.height
                rightClickMenu.open()
            }

            onPositionChanged: {
                ghostRect.visible = root.editMode
                // Update ghost to show where it would snap
                gridXPos = Math.round(draggableRect.x / gridSizeX)
                gridYPos = Math.round(draggableRect.y / gridSizeY)
                ghostRect.x = gridXPos * gridSizeX
                ghostRect.y = gridYPos * gridSizeY
            }

            onReleased: {
                ghostRect.visible = false
                // Snap rectangle to grid
                if (root.xPos == gridXPos && root.yPos == gridYPos) {
                    draggableRect.x = root.xPos * gridSizeX
                    draggableRect.y = root.yPos * gridSizeY
                }
                root.newXPos = gridXPos
                root.newYPos = gridYPos
                draggableRect.x = gridXPos * gridSizeX
                draggableRect.y = gridYPos * gridSizeY
                widgetMoved();
            }
        }
    }
    Rectangle {
        id: closeButton
        width: 20
        height: 20
        radius: 15
        color: "#333"
        scale: root.editMode && !root.isOpened ? 1 : 0
        Behavior on scale { NumberAnimation { duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1 }}
        border {
            width: 1
            color: "#22ffffff"
        }
        VectorImage {
            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/x.svg")
            width: 10
            height: 10
            anchors.centerIn: parent
            preferredRendererType: VectorImage.CurveRenderer
        }
        x: draggableRect.x + 5
        y: draggableRect.y + 5
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.removing = true
            }
        }
    }
}