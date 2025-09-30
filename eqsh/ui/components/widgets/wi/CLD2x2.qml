import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.config
import qs
import qs.ui.controls.providers

BaseWidget {
    content: Item {
        id: root

        property date today: new Date()
        property int year: today.getFullYear()
        property int month: today.getMonth() // 0–11

        function daysInMonth(year, month) {
            let firstDay = new Date(year, month, 1).getDay();
            firstDay = (firstDay === 0 ? 7 : firstDay); // make Sunday = 7
            let days = new Date(year, month + 1, 0).getDate();
            let arr = [];

            // fill blanks before first day
            for (let i = 1; i < firstDay; i++)
                arr.push({day: -1, isToday: false});

            // fill actual days
            for (let d = 1; d <= days; d++) {
                let isToday = (d === root.today.getDate() &&
                               month === root.today.getMonth() &&
                               year === root.today.getFullYear());
                arr.push({day: d, isToday: isToday});
            }

            return arr;
        }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            // Month header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    font.bold: true
                    font.pixelSize: 10
                    color: Config.general.darkMode ? AccentColor.color : Qt.darker(AccentColor.color, 1.1)
                    text: Time.getTime("MMMM")
                }
            }

            // Day names
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: [Translation.tr("Mo"), Translation.tr("Tu"), Translation.tr("We"), Translation.tr("Th"), Translation.tr("Fr"), Translation.tr("Sa"), Translation.tr("Su")]
                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14
                        color: Config.general.darkMode ? "#bbb" : "#555"
                        text: modelData
                    }
                }
            }

            // Calendar grid
            GridView {
                id: gridView
                Layout.fillWidth: true
                Layout.fillHeight: true
                cellWidth: 20
                cellHeight: 18
                model: root.daysInMonth(root.year, root.month)

                delegate: Rectangle {
                    width: gridView.cellWidth
                    height: gridView.cellHeight
                    color: (modelData.isToday ? AccentColor.color : "transparent")
                    radius: 30

                    Label {
                        anchors.centerIn: parent
                        text: modelData.day > 0 ? modelData.day : ""
                        color: modelData.isToday ? (Config.general.darkMode ? "#fff" : "#222") : (Config.general.darkMode ? "#ddd" : "#333")
                        font.pixelSize: 10
                        font.bold: modelData.isToday
                    }
                }
            }
        }
    }
}
