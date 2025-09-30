pragma Singleton

import Quickshell
import QtQuick
import qs.config

Singleton {
  id: root
  readonly property string date: clock.date
  readonly property string time: {
    getTime(Config.bar.dateFormat);
  }

  function getTime(format) {
    return Qt.locale(Config.general.language).toString(clock.date, format)
  }

  function getSeconds() {
    return clock.date.getSeconds();
  }

  SystemClock {
    id: clock
    precision: SystemClock.Seconds
  }
}