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
    id: root
    Layout.fillWidth: true
    width: parent.width
    ColumnLayout {
        width: parent.width
        anchors.fill: parent
        anchors.margins: 0
        uniformCellSizes: true
        Item {
            id: barSection
            Layout.fillWidth: true
            Layout.preferredHeight: 100
            z: 1000
            CFSwitch {
                id: barSwitch
                anchors {
                    top: parent.top
                    topMargin: 10
                    left: parent.left
                    leftMargin: 20
                }
                checked: Config.bar.enable
                onClicked: {
                    Config.bar.enable = checked
                }
                text: Translation.tr("Enable Bar")
            }
            ClippingRectangle {
                id: barSectionBackground
                anchors {
                    top: parent.top
                    topMargin: 50
                    margins: 10
                    left: parent.left
                    right: parent.right
                }
                width: parent.width - 20
                height: 30
                color: "#333"
                radius: 15
                CFI {
                    anchors.fill: parent
                    source: Config.wallpaper.path
                    fillMode: Image.PreserveAspectCrop
                    sourceClipRect: Qt.rect(0, 0, parent.width, parent.height)
                    sourceSize: Qt.size(parent.width, parent.height)
                    asynchronous: false
                    colorized: false
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#70000000"
                    radius: 15
                }
            }
            Item {
                id: bar
                anchors.fill: barSectionBackground
                height: 30
                RowLayout {
                    spacing: -6
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                    }
                    Item {
                        Layout.minimumWidth: 50
                        VectorImage {
                            source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/icon.svg")
                            preferredRendererType: VectorImage.CurveRenderer
                            width: 20
                            height: 20
                            anchors.centerIn: parent
                        }
                        opacity: 0.5
                    }
                    Item {
                        id: editableName
                        Layout.minimumWidth: 50
                        Layout.alignment: Qt.AlignVCenter
                        implicitHeight: nameText.implicitHeight

                        property bool editing: false

                        CFText {
                            id: nameText
                            visible: !editableName.editing
                            text: Config.bar.defaultAppName
                            font.weight: 700
                            color: "#fff"
                            horizontalAlignment: Text.AlignHCenter
                            anchors.centerIn: parent

                            MouseArea {
                                anchors.fill: parent
                                acceptedButtons: Qt.LeftButton
                                onClicked: {
                                    editableName.editing = true
                                    nameEdit.forceActiveFocus()
                                }
                                hoverEnabled: true
                                cursorShape: Qt.IBeamCursor
                            }
                        }

                        CFTextField {
                            id: nameEdit
                            visible: editableName.editing
                            text: Config.bar.defaultAppName
                            anchors.fill: parent
                            height: 24
                            anchors.margins: 0
                            font.pixelSize: 12
                            font.weight: 700
                            padding: 0
                            color: "#fff"
                            backgroundColor: "#2a2a2a"
                            horizontalAlignment: Text.AlignHCenter
                            focus: editableName.editing
                            onEditingFinished: {
                                Config.bar.defaultAppName = text
                                editableName.editing = false
                            }
                            Keys.onReturnPressed: {
                                Config.bar.defaultAppName = text
                                editableName.editing = false
                            }
                            onFocusChanged: if (!focus && editableName.editing) editableName.editing = false
                        }
                        Rectangle {
                            id: suggestionBox
                            visible: nameEdit.focus
                            width: 75
                            height: 150
                            anchors.top: nameEdit.bottom
                            anchors.horizontalCenter: nameEdit.horizontalCenter
                            anchors.topMargin: 10
                            color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
                            radius: 4
                            border.color: "#444"
                            border.width: 1
                            z: 1000

                            ScrollView {
                                id: scrollView
                                anchors.fill: parent
                                ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                                Column {
                                    spacing: 0
                                    anchors.fill: parent
                                    anchors.margins: 0

                                    Repeater {
                                        model: ["Finder", "Aureli", "Equora", "Arch", "NixOS", "Fedora", "Manjaro", "CentOS", "Debian", "Lubuntu", "Linux Mint", "Ubuntu", "Kali", "Windows", "Linux"]
                                        delegate: Item {
                                            width: parent.width
                                            height: 22
                                            Rectangle {
                                                id: item
                                                anchors.fill: parent
                                                anchors.topMargin: 2
                                                anchors.bottomMargin: 2
                                                anchors.leftMargin: 4
                                                anchors.rightMargin: 4
                                                radius: 4
                                                color: hovered ? AccentColor.color : "transparent"

                                                property bool hovered: false
                                                CFText {
                                                    text: modelData
                                                    anchors.verticalCenter: parent.verticalCenter
                                                    anchors.left: parent.left
                                                    anchors.leftMargin: 6
                                                    font.pixelSize: 12
                                                    noAnimate: true
                                                    color: item.hovered ? AccentColor.textColor : (Config.general.darkMode ? "#fff" : "#000")
                                                }

                                                MouseArea {
                                                    anchors.fill: parent
                                                    hoverEnabled: true
                                                    onEntered: parent.hovered = true
                                                    onExited: parent.hovered = false
                                                    onClicked: {
                                                        nameEdit.text = modelData
                                                        Config.bar.defaultAppName = modelData
                                                        editableName.editing = false
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    CFText {
                        text: Translation.tr("File")
                        color: "#fff"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.minimumWidth: 50
                        padding: 10
                        opacity: 0.5
                    }
                    CFText {
                        text: Translation.tr("Edit")
                        color: "#fff"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.minimumWidth: 50
                        padding: 10
                        opacity: 0.5
                    }
                    CFText {
                        text: Translation.tr("View")
                        color: "#fff"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.minimumWidth: 50
                        padding: 10
                        opacity: 0.5
                    }
                    CFText {
                        text: Translation.tr("Go")
                        color: "#fff"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.minimumWidth: 50
                        padding: 10
                        opacity: 0.5
                    }
                    CFText {
                        text: Translation.tr("Window")
                        color: "#fff"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.minimumWidth: 50
                        padding: 10
                        opacity: 0.5
                    }
                    CFText {
                        text: Translation.tr("Help")
                        color: "#fff"
                        horizontalAlignment: Text.AlignHCenter
                        Layout.minimumWidth: 50
                        padding: 10
                        opacity: 0.5
                    }
                }
            }
        }
        Item {
            id: dateFormat
            Layout.preferredHeight: 100

            property string savedFormat: Config.bar.dateFormat || "dddd, MMMM d yyyy"
            property bool edited: dateFormatInput.text !== savedFormat

            ColumnLayout {
                spacing: 6
                anchors.fill: parent
                transform: Translate { x: 10 } // Dont ask... :( ColumnLayout is weird

                CFText {
                    text: Translation.tr("Date Format")
                    font.weight: 700
                }

                CFTextField {
                    id: dateFormatInput
                    Layout.fillWidth: true
                    text: dateFormat.savedFormat
                    placeholderText: "e.g. dddd, MMMM d yyyy"

                    onTextChanged: {
                        dateFormat.edited = text !== dateFormat.savedFormat
                    }
                }

                CFText {
                    id: datePreview
                    text: Qt.formatDateTime(new Date(), dateFormatInput.text)
                    color: "#aaa"
                    font.pixelSize: 12
                }

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: datePreview.text = Qt.formatDateTime(new Date(), dateFormatInput.text)
                }

                // Buttons show only when edited
                RowLayout {
                    visible: dateFormat.edited
                    spacing: 10
                    Layout.alignment: Qt.AlignLeft

                    CFButton {
                        text: Translation.tr("Revert")
                        color: Config.general.darkMode ? "#444" : "#aaa"
                        hoverColor: Config.general.darkMode ? "#555" : "#bbb"
                        highlightEnabled: false
                        onClicked: {
                            dateFormatInput.text = dateFormat.savedFormat
                            dateFormat.edited = false
                        }
                    }

                    CFButton {
                        text: Translation.tr("Accept")
                        primary: true
                        onClicked: {
                            Config.bar.dateFormat = dateFormatInput.text
                            dateFormat.savedFormat = dateFormatInput.text
                            dateFormat.edited = false
                        }
                    }
                }
            }
        }

        //UILabel { text: Translation.tr("Auto hide") }
        //ComboBox {
        //    model: [Translation.tr("No"), Translation.tr("Yes")]
        //    currentIndex: Config.bar.autohide ? 1 : 0
        //    onCurrentIndexChanged: Config.bar.autohide = currentIndex == 1
        //}
    }
}