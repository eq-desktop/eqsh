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
    Rectangle {
        anchors.fill: parent
        color: "transparent"
    }
    ColumnLayout {
        anchors.centerIn: parent
        spacing: 20
        width: parent.width

        Item {
            width: 120
            height: 120
            Layout.alignment: Qt.AlignHCenter
            Blur {
                source: imageContainer
                anchors.fill: imageContainer
                anchors.margins: 0
                blur: 1
                autoPaddingEnabled: true
            }

            // Profile Picture
            ClippingRectangle {
                id: imageContainer
                width: 120
                height: 120
                radius: 99
                color: "transparent"
                clip: true
                Layout.alignment: Qt.AlignHCenter
                FileDialog {
                    id: fileDialog
                    selectedFile: Config.account.avatarPath
                    nameFilters: ["Images (*.jpg *.jpeg *.png)", "All files (*)"]
                    onSelectedFilesChanged: {
                        Config.account.avatarPath = selectedFiles[0]
                        profileImage.source = Config.account.avatarPath
                    }
                }
                MouseArea {
                    id: editImageMouse
                    anchors.fill: parent
                    onClicked: {
                        fileDialog.open()
                    }
                    hoverEnabled: true
                    Item {
                        id: profilePic
                        anchors.fill: parent
                        CFVI {
                            id: imageS
                            anchors.fill: parent
                            source: Config.account.avatarPath == "" ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/user.svg") : ""
                            fillMode: Image.PreserveAspectCrop
                        }
                        Image {
                            id: profileImage
                            anchors.fill: parent
                            source: Config.account.avatarPath == "" ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/user.svg") : Config.account.avatarPath
                            fillMode: Image.PreserveAspectCrop
                            onStatusChanged: {
                                if (profileImage.status == Image.Error) {
                                    imageS.source = Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/user.svg")
                                    profileImage.source = ""
                                }
                            }
                        }
                    }
                    RectangularShadow {
                        anchors.fill: editImage
                        color: "#ffffff"
                        radius: 20
                        blur: 15
                        spread: 10
                        opacity: editImageMouse.containsMouse ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad} }
                    }
                    Text {
                        id: editImage
                        anchors {
                            bottom: parent.bottom
                            bottomMargin: 15
                            horizontalCenter: parent.horizontalCenter
                        }
                        opacity: editImageMouse.containsMouse ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: 200; easing.type: Easing.InOutQuad} }
                        text: Translation.tr("Edit")
                    }
                }
            }
        }
        CFTextField {
            background: Rectangle { color: "transparent" }
            text: Config.account.name
            onEditingFinished: Config.account.name = text
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
        }

        // Activation Key
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 4

            CFText { text: Translation.tr("Activation Key") }
            CFTextField {
                Layout.preferredWidth: 300
                text: Config.account.activationKey
                onEditingFinished: Config.account.activationKey = text
                placeholderText: Translation.tr("Activation Key")
            }
        }
    }
}