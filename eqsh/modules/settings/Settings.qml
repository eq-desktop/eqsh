//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic
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
import qs.modules.settings.pages
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.ui.controls.primitives
import Quickshell.Io
import Quickshell.Widgets

Scope {
    Component.onCompleted: {
        Ipc.mixin("eqdesktop.settings", "toggle", () => {
            Runtime.settingsOpen = !Runtime.settingsOpen;
        })
    }
    FloatingWindow {
        id: settingsApp
        visible: Runtime.settingsOpen
        title: Translation.tr("Systemsettings")
        minimumSize: "675x540"
        maximumSize: Qt.size(675, screen.height-Config.bar.height)
        
        onClosed: {
            Runtime.settingsOpen = false
        }

        onVisibleChanged: {
            if (!visible) {
                history = []
            }
        }

        property var history: []

        color: "transparent"

        component UILabel: Text {
            color: Config.general.darkMode ? "#fff" : "#000"
            font.pixelSize: 16
        }

        component UITextField: TextField {
            color: Config.general.darkMode ? "#fff" : "#000"
            font.pixelSize: 16
            Layout.minimumWidth: 250
            background: Rectangle {
                anchors.fill: parent
                color: Config.general.darkMode ? "#2a2a2a" : "#fefefe"
                border {
                    width: 1
                    color: "#aaa"
                }
                radius: 10
            }
        }

        component UICheckBox: CFCheckBox {
        }

        Loader {
            anchors.fill: parent
            active: true
            asynchronous: true
            sourceComponent: RowLayout {
                anchors.fill: parent

                Sidebar { id: sidebar }

                Item {
                    id: contentArea
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    Rectangle {
                        anchors.fill: parent
                        color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
                    }

                    Rectangle {
                        id: pageTitle
                        height: 50
                        width: parent.width
                        color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
                        radius: 0
                        RectangularShadow {
                            anchors.fill: pageControl
                            color: "#20000000"
                            radius: 20
                            blur: 20
                            spread: 5
                        }
                        Rectangle {
                            id: pageControl
                            height: 38
                            width: 80
                            radius: 20
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"
                            Rectangle {
                                width: 1
                                height: 20
                                anchors.centerIn: parent
                                color: "#10000000"
                            }
                            VectorImage {
                                source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-left-bold.svg")
                                anchors.left: parent.left
                                anchors.leftMargin: 5
                                width: 30
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: 1
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization: 1
                                    colorizationColor: Config.general.darkMode ? "#fff" : "#333"
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        contentView.openHistory()
                                    }
                                }
                            }
                            VectorImage {
                                source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/chevron-right-bold.svg")
                                anchors.right: parent.right
                                anchors.rightMargin: 5
                                width: 30
                                height: 30
                                anchors.verticalCenter: parent.verticalCenter
                                opacity: 0.2
                                layer.enabled: true
                                layer.effect: MultiEffect {
                                    colorization: 1
                                    colorizationColor: Config.general.darkMode ? "#fff" : "#333"
                                }
                            }
                        }
                        Text {
                            anchors.left: pageControl.right
                            anchors.leftMargin: 15
                            anchors.verticalCenter: parent.verticalCenter
                            verticalAlignment: Text.AlignVCenter
                            text: contentView.currentIndex == 0 ? "Account" : sidebar.sb.model[contentView.currentIndex]
                            color: Config.general.darkMode ? "#fff" : "#555"
                            font.weight: 700
                            font.pixelSize: 14
                        }
                        Rectangle {
                            height: 0.5
                            width: parent.width+10
                            anchors.left: parent.left
                            anchors.leftMargin: -10
                            anchors.bottom: parent.bottom
                            color: "#55aaaaaa"
                        }
                    }

                    // Content area
                    StackLayout {
                        id: contentView
                        anchors.top: pageTitle.bottom
                        anchors.left: parent.left
                        anchors.leftMargin: -10
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                        anchors.margins: 0
                        width: parent.width
                        height: parent.height - 75
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        currentIndex: 0
                        property bool fromHistory: false

                        signal pageChanged(var index)

                        function setIndex(index) {
                            if (contentView.currentIndex != index) {
                                settingsApp.history.push({ index: contentView.currentIndex })
                                contentView.currentIndex = index
                            }
                        }

                        function openHistory() {
                            if (settingsApp.history.length == 0) return
                            contentView.fromHistory = true
                            let lastHist = settingsApp.history.pop()
                            contentView.currentIndex = lastHist.index
                            pageChanged(lastHist)
                        }

                        function openSettings(page) {
                            Runtime.settingsOpen = true
                            contentView.setIndex(page)
                        }

                        Loader {
                            active: contentView.currentIndex == 0
                            sourceComponent: Account { property var history: settingsApp.history; property var contentViewO: contentView }
                        }
                        Space { property var history: settingsApp.history; property var contentViewO: contentView }
                        Loader {
                            active: contentView.currentIndex == 2
                            sourceComponent: Wifi { property var history: settingsApp.history; property var contentViewO: contentView }
                        }
                        Loader {
                            active: contentView.currentIndex == 3
                            sourceComponent: Bluetooth { property var history: settingsApp.history; property var contentViewO: contentView }
                        }
                        Loader {
                            active: contentView.currentIndex == 4
                            sourceComponent: Network { property var history: settingsApp.history; property var contentViewO: contentView }
                        }
                        Loader {
                            active: contentView.currentIndex == 5
                            sourceComponent: Energy { property var history: settingsApp.history; property var contentViewO: contentView }
                        }
                        Space { property var history: settingsApp.history; property var contentViewO: contentView }
                        Loader {
                            active: contentView.currentIndex == 7
                            sourceComponent: General { property var history: settingsApp.history; property var contentViewO: contentView }
                        }
                        Loader {
                            active: contentView.currentIndex == 8
                            sourceComponent: Appearance { property var history: settingsApp.history; property var contentViewO: contentView }
                        }

                        Loader {
                            active: contentView.currentIndex == 9
                            sourceComponent: MenuBar { property var history: settingsApp.history; property var contentViewO: contentView }
                        }

                        Loader {
                            active: contentView.currentIndex == 10
                            sourceComponent: Wallpaper { property var history: settingsApp.history; property var contentViewO: contentView }
                        }

                        Loader {
                            active: contentView.currentIndex == 11
                            sourceComponent: Notifications { property var history: settingsApp.history; property var contentViewO: contentView }
                        }

                        // Dialogs
                        ScrollView {
                            ColumnLayout {
                                anchors.fill: parent
                                UICheckBox {
                                    textVal: Translation.tr("Enable Dialogs")
                                    checked: Config.dialogs.enable
                                    onToggled: Config.dialogs.enable = checked
                                }
                                UILabel { text: Translation.tr("Width") }
                                SpinBox {
                                    value: Config.dialogs.width
                                    onValueModified: Config.dialogs.width = value
                                    from: 100; to: 600
                                }
                                UILabel { text: Translation.tr("Height") }
                                SpinBox {
                                    value: Config.dialogs.height
                                    onValueModified: Config.dialogs.height = value
                                    from: 100; to: 600
                                }
                            }
                        }

                        // Notch
                        ScrollView {
                            ColumnLayout {
                                id: notchView
                                anchors.fill: parent
                                UICheckBox {
                                    textVal: Translation.tr("Enable Notch")
                                    checked: Config.notch.enable
                                    onToggled: Config.notch.enable = checked
                                }
                                //UILabel { text: Translation.tr("Island mode") }
                                //property var notchOptions: ["Dynamic Island", "Notch"]
                                //ComboBox {
                                //    model: notchView.notchOptions.map(Translation.tr)
                                //    Component.onCompleted: {
                                //        currentIndex = Config.notch.islandMode ? 0 : 1
                                //    }
                                //    onCurrentIndexChanged: {
                                //        Config.notch.islandMode = (currentIndex == 0)
                                //    }
                                //}
                                UILabel { text: Translation.tr("Background color") }
                                Button {
                                    text: Translation.tr("Set Color")
                                    onClicked: colorDialog.open()
                                }
                                ColorDialog {
                                    id: colorDialog
                                    selectedColor: Config.notch.backgroundColor
                                    onAccepted: Config.notch.backgroundColor = selectedColor
                                }
                                UILabel { text: Translation.tr("Visual-Only mode") }
                                ComboBox {
                                    model: [Translation.tr("No"), Translation.tr("Yes")]
                                    currentIndex: Config.notch.onlyVisual ? 1 : 0
                                    onCurrentIndexChanged: Config.notch.onlyVisual = currentIndex == 1
                                }
                                UILabel { text: Translation.tr("Auto hide") }
                                ComboBox {
                                    model: [Translation.tr("No"), Translation.tr("Yes")]
                                    currentIndex: Config.notch.autohide ? 1 : 0
                                    onCurrentIndexChanged: Config.notch.autohide = currentIndex == 1
                                }
                            }
                        }

                        // Launchpad
                        ScrollView {
                            ColumnLayout {
                                anchors.fill: parent
                                UICheckBox {
                                    textVal: Translation.tr("Enable Launchpad")
                                    checked: Config.launchpad.enable
                                    onToggled: Config.launchpad.enable = checked
                                }
                            }
                        }

                        // Lockscreen
                        ScrollView {
                            ColumnLayout {
                                anchors.fill: parent
                                UICheckBox {
                                    textVal: Translation.tr("Enable Lockscreen")
                                    checked: Config.lockScreen.enable
                                    onToggled: Config.lockScreen.enable = checked
                                }
                                UILabel { text: Translation.tr("Date Format") }
                                UITextField {
                                    Layout.fillWidth: true
                                    text: Config.lockScreen.dateFormat
                                    onEditingFinished: Config.lockScreen.dateFormat = text
                                }
                                UILabel { text: Translation.tr("Time Format") }
                                UITextField {
                                    Layout.fillWidth: true
                                    text: Config.lockScreen.timeFormat
                                    onEditingFinished: Config.lockScreen.timeFormat = text
                                }
                                UILabel { text: Translation.tr("Blur Lockscreen") }
                                ComboBox {
                                    model: [Translation.tr("No"), Translation.tr("Yes")]
                                    currentIndex: Config.lockScreen.blur ? 1 : 0
                                    onCurrentIndexChanged: Config.lockScreen.blur = currentIndex == 1
                                }
                                UILabel { text: Translation.tr("Avatar Size") }
                                SpinBox {
                                    value: Config.lockScreen.avatarSize
                                    onValueModified: Config.lockScreen.avatarSize = value
                                    from: 0; to: 100
                                }
                                UILabel { text: Translation.tr("User Note") }
                                UITextField {
                                    Layout.fillWidth: true
                                    text: Config.lockScreen.userNote
                                    onEditingFinished: Config.lockScreen.userNote = text
                                }
                                UICheckBox {
                                    textVal: Translation.tr("Custom Background")
                                    checked: Config.lockScreen.useCustomWallpaper
                                    onToggled: Config.lockScreen.useCustomWallpaper = checked
                                }
                                UITextField {
                                    visible: Config.lockScreen.useCustomWallpaper
                                    Layout.fillWidth: true
                                    text: Config.lockScreen.customWallpaperPath
                                    onEditingFinished: Config.lockScreen.customWallpaperPath = text
                                }
                            }
                        }

                        // Widgets
                        ScrollView {
                            ColumnLayout {
                                anchors.fill: parent
                                UICheckBox {
                                    textVal: Translation.tr("Enable Widgets")
                                    checked: Config.widgets.enable
                                    onToggled: Config.widgets.enable = checked
                                }
                                UILabel { text: Translation.tr("Location") }
                                UITextField {
                                    Layout.fillWidth: true
                                    text: Config.widgets.location
                                    onEditingFinished: Config.widgets.location = text
                                }
                                CFButton {
                                    text: Translation.tr("Edit Widgets")
                                    onClicked: {
                                        Runtime.widgetEditMode = true
                                        Runtime.settingsOpen = false
                                    }
                                }
                            }
                        }

                        // Osd
                        ScrollView {
                            ColumnLayout {
                                anchors.fill: parent
                                UICheckBox {
                                    textVal: Translation.tr("Enable OSD")
                                    checked: Config.osd.enable
                                    onToggled: Config.osd.enable = checked
                                }
                                UILabel { text: Translation.tr("Animation") }
                                ComboBox {
                                    model: [Translation.tr("Scale"), Translation.tr("Fade"), Translation.tr("Bubble")]
                                    currentIndex: Config.osd.animation - 1
                                    onCurrentIndexChanged: Config.osd.animation = currentIndex + 1
                                }
                                UILabel { text: Config.osd.animation }
                            }
                        }
                    }
                }
            }
        }
    }
}