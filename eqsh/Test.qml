import QtQuick
import QtQuick.Controls
import Quickshell

Column {
  ListView {
    implicitWidth: 300
    implicitHeight: 500
  
    model: DesktopEntries.applications.values.filter(a => a.name.includes(search.text))

    delegate: Text {
      required property DesktopEntry modelData

      text: modelData.name
    }
  }

  TextField {
    id: search

    implicitWidth: 300
    implicitHeight: 30

    placeholderText: "Type to search"
  }
}