import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.ui.Controls.providers

Control {
    id: calendarWidget
    anchors.fill: parent
    padding: 10

    contentItem: Rectangle {
        id: root
        radius: 12
        color: "#0a0a0a"

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

            // Month + year header
            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignLeft
                    font.bold: true
                    font.pixelSize: 10
                    color: AccentColor.color
                    text: Qt.formatDate(new Date(root.year, root.month, 1), "MMMM")
                }
            }

            // Day names
            RowLayout {
                Layout.fillWidth: true
                Repeater {
                    model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                    Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        font.pixelSize: 14
                        color: "#bbb"
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
                        color: modelData.isToday ? "#fff" : "#ddd"
                        font.pixelSize: 10
                        font.bold: modelData.isToday
                    }
                }
            }
        }
    }
}
