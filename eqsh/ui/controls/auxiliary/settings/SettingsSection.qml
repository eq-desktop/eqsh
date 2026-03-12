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

Item {
    id: root

    property bool hasTitle: true
    property alias title: title.text
    property alias content: content
    default property alias childs: content.children
    height: (hasTitle ? title.height : 0) + contentContainer.height
    width: parent.width
    Layout.preferredHeight: height
    Layout.fillWidth: true
    CFText {
        id: title
        anchors.left: parent.left
        anchors.leftMargin: 10
        text: ""
        font.pixelSize: 20
        height: 30
        visible: hasTitle
    }
    Item {
        anchors {
            top: title.bottom
            left: parent.left
            right: parent.right
        }
        id: contentContainer
        height: content.height

        RectangularShadow {
            anchors.fill: parent
            color: "#20000000"
            radius: 20
            blur: 20
            spread: 5
        }
        Rectangle {
            id: content
            anchors {
                left: parent.left
                leftMargin: 10
                rightMargin: 10
                right: parent.right
                top: parent.top
            }
            width: root.width - 20
            radius: 20
            height: content.children.map((child) => child.implicitHeight).reduce((a, b) => { return a + b; }, 0) + 28
            color: Config.general.darkMode ? "#222" : "#ffffff"
        }
    }
}