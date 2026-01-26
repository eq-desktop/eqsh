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
import qs.core.foundation
import qs.ui.components.settings.pages
import qs.ui.controls.auxiliary
import qs.ui.controls.advanced
import qs.ui.controls.providers
import qs.ui.controls.primitives
import Quickshell.Io
import Quickshell.Widgets
import Qt.labs.folderlistmodel

ScrollView {
    id: root
    property string wallpaperFolder: SPPathResolver.strip(Config.wallpaper.folder)
    property string selectedWallpaper: Config.wallpaper.path || ""
    anchors.leftMargin: 10

    ColumnLayout {
        id: layout
        width: parent.width
        anchors.leftMargin: 10
        anchors.fill: parent
        spacing: 10

        // Wallpaper Preview
        Rectangle {
            Layout.fillWidth: true
            height: 150
            Layout.leftMargin: -10
            color: Config.general.darkMode ? "#1e1e1e" : "#ffffff"

            ClippingRectangle {
                id: preview
                anchors {
                    left: parent.left
                    leftMargin: 10
                    top: parent.top
                    topMargin: 10
                    bottom: parent.bottom
                    bottomMargin: 10
                }
                width: 200
                radius: 20
                Image {
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectCrop
                    sourceSize: Qt.size(preview.width, preview.height)
                    source: Config.wallpaper.path
                }
            }

            CFSwitch {
                anchors {
                    left: preview.right
                    leftMargin: 20
                    top: parent.top
                    topMargin: 20
                }
                checked: Config.wallpaper.enable
                onToggled: Config.wallpaper.enable = checked
                text: Translation.tr("Enable Wallpaper")
            }
            FileDialog {
                id: fileDialog
                selectedFile: Config.wallpaper.path
                nameFilters: ["Images (*.jpg *.jpeg *.png)", "All files (*)"]
                onAccepted: {
                    SPPathResolver.copy(selectedFile, Config.wallpaper.folder)
                    Config.wallpaper.path = selectedFile
                }
            }

            CFButton {
                anchors {
                    left: preview.right
                    leftMargin: 20
                    bottom: parent.bottom
                    bottomMargin: 20
                }
                width: 150
                text: Translation.tr("Add another wallpaper...")
                primary: true
                onClicked: {
                    fileDialog.open()
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 1
                color: Config.general.darkMode ? "#333333" : "#dddddd"
            }
        }

        // Wallpaper Grid
        FolderListModel {
            id: wallpaperModel
            folder: Qt.resolvedUrl(root.wallpaperFolder)
            nameFilters: ["*.jpg", "*.png", "*.jpeg", "*.webp"]
            showDirs: false
        }

        GridView {
            id: grid
            Layout.fillWidth: true
            Layout.preferredHeight: Math.ceil(wallpaperModel.count / 3) * (cellHeight)
            cellWidth: 146
            cellHeight: 100
            model: wallpaperModel
            interactive: false // Disable inner scrolling since ScrollView handles it

            delegate: Rectangle {
                width: 140
                height: 90
                radius: 19
                required property string fileURL
                border.width: root.selectedWallpaper === fileURL ? 3 : 0
                Behavior on border.width { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 }}
                border.color: root.selectedWallpaper === fileURL ? AccentColor.color : "transparent"
                color: "transparent"

                ClippingRectangle {
                    anchors.fill: parent
                    anchors.margins: 3
                    radius: 15
                    color: "#33111111"
                    CFI {
                        anchors.fill: parent
                        source: fileURL
                        asynchronous: true
                        colorized: false
                        sourceSize: Qt.size(width, height)
                    }
                }

                MouseArea {
                    id: marea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        root.selectedWallpaper = fileURL
                        Config.wallpaper.path = fileURL
                    }
                }

                Rectangle {
                    id: delButton
                    width: 20
                    height: 20
                    radius: 10
                    color: Config.general.darkMode ? "#333" : "#999"
                    opacity: marea.containsMouse || delbarea.containsMouse ? 1 : 0
                    CFVI {
                        anchors.centerIn: parent
                        size: 15
                        icon: "x.svg"
                        colorized: true
                        color: Config.general.darkMode ? "#999" : "#333"
                    }
                }
                MouseArea {
                    id: delbarea
                    hoverEnabled: true
                    anchors.fill: delButton
                    onClicked: {
                        let name = SPPathResolver.getName(fileURL)
                        SPPathResolver.rename(fileURL, ".trashed." + name)
                    }
                }
            }
        }

        // Colors Grid
        GridView {
            id: colorGrid
            Layout.fillWidth: true
            Layout.preferredHeight: (Math.ceil(model.length / 7) * cellHeight) + 50
            cellWidth: 60
            cellHeight: 60
            interactive: false
            model: Config.wallpaper.colors

            header: CFText {
                text: Translation.tr("Colors")
                Layout.fillWidth: true
                height: 40
                gray: true
                font.pixelSize: 16
                font.weight: 500
            }

            delegate: Rectangle {
                id: color
                width: 50
                height: 50
                radius: 25
                required property int index
                required property string modelData
                border.width: Config.wallpaper.path === "" && modelData === Config.wallpaper.color ? 3 : 0
                border.color: Config.wallpaper.path === "" && modelData === Config.wallpaper.color ? AccentColor.color : "transparent"
                color: modelData === "add" ? Config.general.darkMode ? "#333" : "#999" : modelData

                CFVI {
                    anchors.centerIn: parent
                    size: 40
                    icon: "notch/plus.svg"
                    colorized: true
                    color: Config.general.darkMode ? "#999" : "#333"
                    visible: modelData === "add"
                }

                ColorDialog {
                    id: colorDialog
                    onAccepted: {
                        let newColors = Config.wallpaper.colors.slice()
                        newColors.splice(1, 0, colorDialog.selectedColor)
                        Config.wallpaper.colors = newColors
                    }
                }

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (modelData === "add") {
                            colorDialog.open()
                            return
                        }
                        root.selectedWallpaper = ""
                        Config.wallpaper.path = ""
                        Config.wallpaper.color = color.color
                    }
                }

                Rectangle {
                    anchors {
                        top: parent.top
                        right: parent.right
                    }
                    visible: modelData !== "add"
                    scale: mouseArea.containsMouse ? 1 : 0
                    Behavior on scale { NumberAnimation { duration: 200; easing.type: Easing.OutBack; easing.overshoot: 1 }}
                    width: 15
                    height: 15
                    radius: 7.5
                    color: Config.general.darkMode ? "#333" : "#999"
                    CFVI {
                        anchors.centerIn: parent
                        size: 10
                        icon: "x.svg"
                        colorized: true
                        color: Config.general.darkMode ? "#999" : "#333"
                        visible: modelData !== "add"
                    }
                    MouseArea {
                        enabled: modelData !== "add"
                        anchors.fill: parent
                        onClicked: {
                            let newColors = Config.wallpaper.colors.slice()
                            newColors.splice(index, 1)
                            Config.wallpaper.colors = newColors
                        }
                    }
                }
            }
        }
    }
}
