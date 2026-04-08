import Quickshell
import QtQuick
import QtQuick.Layouts
import qs
import qs.config
import qs.ui.controls.advanced
import qs.ui.controls.auxiliary
import qs.ui.controls.primitives

Rectangle {
    id: root
    required property var modelData
    required property int index
    property string title: modelData.title
    property string description: modelData.description
    property string icon: Quickshell.iconPath(modelData.icon)
    property var clicked: modelData.clicked
    property bool bgForIcon: true
    property string textColor: Config.general.darkMode ? "#dfdfdf" : "#222"
    property string descColor: "#a0555555"

    transform: Translate {
        x: 10
    }
    width: parent ? parent.width-20 : 0
    height: 50
    radius: 15
    color: "transparent"

    property bool hovered: false
    property bool hasDescription: modelData.description != ""

    Rectangle {
        id: background
        anchors {
            verticalCenter: parent.verticalCenter
            left: parent.left
            leftMargin: 12
        }
        width: 40
        height: 40
        radius: 10
        color: "#20ffffff"
        visible: root.bgForIcon
    }
    Image {
        id: icon
        anchors.centerIn: background
        source: root.icon
        width: 40
        height: 40
        smooth: true
        mipmap: true
        layer.enabled: true
        scale: 1
    }

    CFText {
        anchors {
            verticalCenter: root.hasDescription ? undefined : parent.verticalCenter
            top: root.hasDescription ? parent.top : undefined
            left: icon.right
            leftMargin: 12
            topMargin: 10
            right: parent.right
            rightMargin: 50
        }
        text: root.title
        color: root.textColor
        font.pixelSize: 15
        font.weight: 400
        elide: Text.ElideRight
        noAnimate: true
    }

    CFText {
        anchors.bottom: parent.bottom
        anchors.left: icon.right
        anchors.leftMargin: 12
        anchors.bottomMargin: 8
        anchors.right: parent.right
        anchors.rightMargin: 50
        text: root.description
        color: root.descColor
        font.pixelSize: 14
        font.weight: 400
        elide: Text.ElideRight
        noAnimate: true
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onEntered: parent.hovered = true
        onExited: parent.hovered = false
        onClicked: (mouse) => {root.clicked(mouse)}
    }
}