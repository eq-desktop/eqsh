pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Bluetooth
import qs.config
import Quickshell.Io

Singleton {
  id: root

  readonly property bool isDebug: Quickshell.env("AURELI_DEBUG") === "1"

  function _formatMessage(...args) {
    let level = args.pop()
    var t = getFormattedTimestamp()
    if (args.length > 1) {
      const maxLength = 14
      var module = args.shift().substring(0, maxLength).padStart(maxLength, " ")
      return `\x1b[${level === "i" ? "34m" : level === "e" ? "31m" : level === "w" ? "33m" : "35m"}[${t}]\x1b[0m \x1b[${level === "i" ? "34m" : level === "e" ? "31m" : level === "w" ? "33m" : "35m"}[${module}]\x1b[0m ` + args.join(" ")
    } else {
      return `\x1b[${level === "i" ? "34m" : level === "e" ? "31m" : level === "w" ? "33m" : "35m"}[${t}]\x1b[0m ` + args.join(" ")
    }
  }

  function _getStackTrace() {
    try {
      throw new Error("Stack trace")
    } catch (e) {
      return e.stack
    }
  }

  // Debug log
  function d(...args) {
    if (root.isDebug) {
      args.push("d")
      var msg = _formatMessage(...args)
      console.debug(msg)
    }
  }

  // Info log (always visible)
  function i(...args) {
    args.push("i")
    var msg = _formatMessage(...args)
    console.info(msg)
  }

  // Warning log (always visible)
  function w(...args) {
    args.push("w")
    var msg = _formatMessage(...args)
    console.warn(msg)
  }

  // Error log (always visible)
  function e(...args) {
    args.push("e")
    var msg = _formatMessage(...args)
    console.error(msg)
  }

  function getFormattedTimestamp(date) {
    if (!date) {
      date = new Date()
    }
    const year = date.getFullYear()

    // getMonth() is zero-based, so we add 1
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')

    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const seconds = String(date.getSeconds()).padStart(2, '0')

    return `${year}${month}${day}-${hours}${minutes}${seconds}`
  }

  function callStack() {
    var stack = _getStackTrace()
    Logger.i("Debug", "--------------------------")
    Logger.i("Debug", "Current call stack")
    // Split the stack into lines and log each one
    var stackLines = stack.split('\n')
    for (var i = 0; i < stackLines.length; i++) {
      var line = stackLines[i].trim(); // Remove leading/trailing whitespace
      if (line.length > 0) {
        // Only log non-empty lines
        Logger.i("Debug", `- ${line}`)
      }
    }
    Logger.i("Debug", "--------------------------")
  }
}