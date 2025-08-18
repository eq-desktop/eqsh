import qs.config
import QtQuick

Box {
    id: root

    color: "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 400
            easing.type: Easing.OutQuad
        }
    }
}