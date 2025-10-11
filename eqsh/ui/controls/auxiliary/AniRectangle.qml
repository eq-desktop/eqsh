import qs.config
import QtQuick

Box {
    id: root
    Behavior on color {
        ColorAnimation {
            duration: 400
            easing.type: Easing.OutQuad
        }
    }
}