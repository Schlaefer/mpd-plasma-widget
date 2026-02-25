pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami
import "./../../Mpdw.js" as Mpdw
import "./../../../logic"

Loader {
    id: root

    required property var main
    required property MpdState mpdState
    required property VolumeState volumeState

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton

        onWheel: function (wheel) {
            root.volumeState.wheel(wheel.angleDelta.y)
        }

        onClicked: mouse => {
            switch (mouse.button) {
                case Qt.MiddleButton:
                root.mpdState.togglePlayPause()
                break
                default:
                root.mpdState.connect()
                root.main.expanded = !root.main.expanded
            }
        }

        Kirigami.Icon {
            id: icon
            anchors.fill: parent
            source: root.mpdState.mpdPlaying ? Mpdw.icons.queuePause : Mpdw.icons.queuePlay
        }
    }
}
