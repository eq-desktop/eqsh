import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs
import qs.ui.controls.providers
import qs.ui.controls.primitives

BaseWidget {
    id: bw
    content: Item {
        id: root

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 15
            spacing: -4

            CFText {
                id: month
                text: Qt.locale(Config.general.language).toString(new Date(), "MMMM")
                font.pixelSize: textSizeM
                font.weight: 600
                font.capitalization: Font.AllUppercase
                color: Config.appearance.multiAccentColor ? '#ff3838' : AccentColor.color
                height: 10
            }

            DayOfWeekRow {
                id: row
                locale: grid.locale

                Layout.column: 1
                Layout.fillWidth: true
                delegate: CFText {
                    text: narrowName
                    font.weight: 500
                    font.pixelSize: bw.textSize
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    required property string narrowName
                }
            }

            MonthGrid {
                id: grid
                locale: Qt.locale(Config.general.language)

                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.bottomMargin: -bw.textSize + 10
                delegate: Item {
                    required property var model
                    CFRect {
                        anchors {
                            fill: parent
                            margins: -4
                        }
                        radius: 99
                        color: model.today ? (Config.appearance.multiAccentColor ? '#ff3838' : AccentColor.color) : "transparent"
                    }
                    CFText {
                        id: textCell
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        font.pixelSize: bw.textSize
                        height: parent.height
                        width: parent.width
                        colorLightMode: model.today ? AccentColor.textColor : "#1e1e1e"
                        visible: model.month === grid.month
                        text: grid.locale.toString(model.date, "d")
                    }
                }
            }
        }
    }
}
