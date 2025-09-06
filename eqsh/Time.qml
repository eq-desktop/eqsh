pragma Singleton

import Quickshell
import QtQuick
import qs.config

Singleton {
  id: root
  readonly property string time: {
    Qt.formatDateTime(clock.date, Config.bar.dateFormat);
  }

  function getTime(format) {
    return Qt.formatDateTime(clock.date, format);
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}