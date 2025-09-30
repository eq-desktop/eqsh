import QtQuick
import QtQuick.Controls
import qs
import qs.config
import Quickshell.Widgets
import qs.ui.controls.providers

BaseWidget {
    content: Item {
        id: root
        anchors.fill: parent

        Rectangle {
            id: background
            color: "transparent"
            anchors.fill: parent

            Text {
                id: text
                anchors.fill: parent
                color: Config.general.darkMode ? "#fff" : "#222"
                font.family: Fonts.sFProRounded.family
                font.pixelSize: 40
                font.weight: Font.Bold
                text: Time.getTime("hh:mm")
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            PathView {
                id: pathView
                model: 60
                anchors.fill: parent

                delegate: Rectangle {
                    id: rect
                    required property int modelData
                    width: pathView.width / 60
                    height: pathView.width / 20
                    color: "white"
                    radius: 15
                    antialiasing: true
                    rotation: modelData * 360 / pathView.model

                    // distance behind current second (wrap around)
                    property int diff: (Time.getSeconds() - modelData + pathView.model) % pathView.model

                    // set tail length
                    property int tailLength: 50
                    opacity: diff <= tailLength ? Math.exp(-0.06 * diff) : 0

                    Behavior on opacity {
                        NumberAnimation { duration: 200; easing.type: Easing.InOutQuad }
                    }
                }

                path: Path {
                    id: myPath
                    property real radius: pathView.width / 4
                    startX: pathView.width / 2

                    PathLine {
                        relativeX: pathView.width / 4
                    }

                    PathArc {
                        relativeX: myPath.radius
                        relativeY: myPath.radius
                        radiusX: myPath.radius
                        radiusY: myPath.radius
                    }

                    PathLine {
                        relativeX: 0
                        relativeY: pathView.width / 2
                    }

                    PathArc {
                        relativeX: -myPath.radius
                        relativeY: myPath.radius
                        radiusX: myPath.radius
                        radiusY: myPath.radius
                    }

                    PathLine {
                        relativeX: -pathView.width / 2
                        relativeY: 0
                    }

                    PathArc {
                        relativeX: -myPath.radius
                        relativeY: -myPath.radius
                        radiusX: myPath.radius
                        radiusY: myPath.radius
                    }

                    PathLine {
                        relativeX: 0
                        relativeY: -pathView.width / 2
                    }

                    PathArc {
                        relativeX: myPath.radius
                        relativeY: -myPath.radius
                        radiusX: myPath.radius
                        radiusY: myPath.radius
                    }

                    PathLine {
                        relativeX: pathView.width / 4
                        relativeY: 0
                    }
                }
            }
        }
    }
}
