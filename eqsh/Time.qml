pragma Singleton

import Quickshell
import QtQuick
import qs.config

Singleton {
  id: root
  readonly property string time: {
    Qt.formatDateTime(clock.date, Config.bar.dateFormat);
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}