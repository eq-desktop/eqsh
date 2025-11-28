import QtQuick
import QtQuick.VectorImage
import QtQuick.Effects
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Widgets
import QtQuick.Layouts
import Quickshell.Wayland
import qs.ui.controls.auxiliary
import qs.ui.controls.providers
import qs.ui.controls.advanced
import qs.ui.controls.windows
import qs.ui.controls.primitives
import qs.core.system
import qs.config
import qs
import QtQuick.Controls.Fusion

Item {
    anchors.fill: parent

    required property color glassColor
    required property color glassRimColor
    required property real  glassRimStrength
    required property real  glassRimStrengthStrong
    required property point glassLightDirStrong
    required property color textColor

    id: musicPlayerContainer
    ClippingRectangle {
        id: thumbnail
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 10
        width: 40
        height: 40
        radius: 15
        color: "#20ffffff"
        Image {
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
            source: MusicPlayerProvider.thumbnail
            smooth: true
            mipmap: true
        }
    }
    CFText {
        id: title
        anchors {
            top: thumbnail.bottom
            left: parent.left
            right: parent.right
            topMargin: 10
            leftMargin: 10
            rightMargin: 10
        }
        color: "#ffffff"
        text: MusicPlayerProvider.title
        elide: Text.ElideRight
        font.weight: 600
    }
    Text {
        id: artist
        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
            leftMargin: 10
            rightMargin: 10
        }
        text: MusicPlayerProvider.artist
        color: "#aaffffff"
        elide: Text.ElideRight
        font.weight: 400
    }
    Row {
        id: controls
        anchors.top: artist.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 0
        Button {
            width: 40
            height: 40
            background: Item {}
            icon {
                width: 35
                height: 35
                source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/backward.svg")
            }
            onClicked: {
                MusicPlayerProvider.previous()
            }
        }
        Button {
            width: 40
            height: 40
            background: Item {}
            icon {
                width: 40
                height: 40
                source: MusicPlayerProvider.isPlaying ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/pause.svg") : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/play.svg")
            }
            onClicked: {
                MusicPlayerProvider.togglePlay()
            }
        }
        Button {
            width: 40
            height: 40
            background: Item {}
            icon {
                width: 35
                height: 35
                source: Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/forward.svg")
            }
            onClicked: {
                MusicPlayerProvider.next()
            }
        }
    }
}