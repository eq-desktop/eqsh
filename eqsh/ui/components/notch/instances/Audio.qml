import QtQuick
import Quickshell
import Quickshell.Widgets
import qs.config
import qs
import qs.core.system
import qs.ui.controls.providers
import qs.ui.controls.primitives
import qs.ui.controls.auxiliary.notch
import qs.ui.components.panel
import QtQuick.VectorImage
import QtQuick.Controls
import QtQuick.Effects

NotchApplication {
    id: root
    details.version: "Elephant-1"
    details.appType: "media"
    immortal: true
    meta.indicativeWidth: 210
    meta.informativeHeight: meta.indicativeHeight + 20
    meta.height: 200
    meta.width: 400

    properties.useScaleX: false
    z: 98
    ColorQuantizer {
        id: quantizer
        depth: 3
        rescaleSize: 64
        source: MusicPlayerProvider.thumbnail
    }

    indicative: Item {
        visible: MusicPlayerProvider.isPlaying && root.isFocused
        onVisibleChanged: {
            if (visible) {
                root.indicativeShowAnim.start()
            }
        }
        ClippingRectangle {
            anchors {
                left: parent.left
                leftMargin: 10
                topMargin: 4
                top: parent.top
            }
            radius: 7
            width: 20
            height: 20
            CFI {
                id: thumbnail
                anchors.fill: parent
                colorized: false
                source: MusicPlayerProvider.thumbnail
            }
            transform: Scale {
                origin.x: thumbnail.width
                xScale: root.properties.scaleX
            }
        }
        CFText {
            anchors {
                left: parent.left
                leftMargin: 10
                topMargin: 28
                top: parent.top
            }
            opacity: root.notchState === "informative" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            text: MusicPlayerProvider.title
            elide: Text.ElideRight
            font.weight: 400
            height: 12
            font.pixelSize: 12
            width: parent.width - thumbnail.width
        }
        Rectangle {
            anchors {
                right: parent.right
                rightMargin: 45
                topMargin: 28+16
                top: parent.top
            }
            opacity: root.notchState === "informative" ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: 300; easing.type: Easing.InOutQuad } }
            height: 50
            width: 16
            transform: Rotation {
                angle: -90
            }
            gradient: Gradient {
                stops: [
                    GradientStop { position: 0.0; color: "#00000000" },
                    GradientStop { position: 0.7; color: "#ff000000" },
                    GradientStop { position: 1.0; color: "#ff000000" }
                ]
            }
        }
    }

    active: Item {
        MultiEffect {
            source: thumbnail
            anchors.fill: thumbnail
            blurEnabled: true
            blur: 1
            blurMultiplier: 1
            blurMax: 64
            scale: 2
            autoPaddingEnabled: true
        }
        ClippingRectangle {
            id: thumbnail
            anchors.bottom: time.top
            anchors.left: parent.left
            anchors.margins: 10
            anchors.bottomMargin: 20
            width: 60
            height: 60
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
                top: thumbnail.top
                left: thumbnail.right
                right: parent.right
                topMargin: 10
                leftMargin: 10
                rightMargin: 10
            }
            text: MusicPlayerProvider.title
            elide: Text.ElideRight
            font.weight: 600
        }
        Text {
            id: artist
            anchors {
                top: title.bottom
                left: thumbnail.right
                right: parent.right
                leftMargin: 10
                rightMargin: 10
            }
            text: MusicPlayerProvider.artist
            color: "#aaffffff"
            elide: Text.ElideRight
            font.weight: 400
        }
        // Progress Bar
        CFText {
            id: time
            anchors {
                left: parent.left
                leftMargin: 10
                bottom: controls.top
                bottomMargin: 10
            }
            // position is in seconds
            text: Qt.formatTime(new Date(MusicPlayerProvider.position * 1000), "mm:ss")
            color: "#aaffffff"
            elide: Text.ElideRight
        }
        ProgressBar {
            id: control
            anchors {
                left: time.right
                leftMargin: 10
                right: remainingTime.left
                rightMargin: 10
                verticalCenter: time.verticalCenter
            }
            height: 5
            value: MusicPlayerProvider.position / MusicPlayerProvider.duration
            background: Rectangle {
                implicitHeight: 5
                color: '#323232'
                radius: 5
            }
            contentItem: Item {
                implicitHeight: 5

                // Progress indicator for determinate state.
                Rectangle {
                    width: control.visualPosition * parent.width
                    height: parent.height
                    radius: 5
                    color: '#ffffff'
                    visible: !control.indeterminate
                }
            }
        }
        CFText {
            id: remainingTime
            anchors {
                right: parent.right
                rightMargin: 10
                bottom: controls.top
                bottomMargin: 10
            }
            // position is in seconds
            text: Qt.formatTime(new Date((MusicPlayerProvider.duration-MusicPlayerProvider.position) * 1000), "-mm:ss")
            color: "#aaffffff"
            elide: Text.ElideLeft
        }
        Row {
            id: controls
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 0
            Button {
                width: 50
                height: 50
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
                width: 50
                height: 50
                background: Item {}
                icon {
                    width: 50
                    height: 50
                    source: MusicPlayerProvider.isPlaying ? Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/pause.svg") : Qt.resolvedUrl(Quickshell.shellDir + "/media/icons/music/play.svg")
                }
                onClicked: {
                    MusicPlayerProvider.togglePlay()
                }
            }
            Button {
                width: 50
                height: 50
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
}
