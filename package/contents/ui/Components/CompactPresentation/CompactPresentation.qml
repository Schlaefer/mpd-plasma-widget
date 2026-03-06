pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.workspace.components as WorkspaceComponents
import "./../../Mpdw.js" as Mpdw
import "./../../../logic"

Loader {
    id: root

    required property var main
    required property MpdState mpdState
    required property VolumeState volumeState
    readonly property int animationDuration: 200

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => {
            switch (mouse.button) {
                case Qt.MiddleButton:
                    root.mpdState.togglePlayPause()
                break
                default:
                    root.main.expanded = !root.main.expanded
            }
        }
        onWheel: function (wheel) {
            root.volumeState.wheel(wheel.angleDelta.y)
            volume.visible = true
            volume.opacity = 1
            volumeTimer.restart()
        }

        Timer {
            id: volumeTimer
            interval: Kirigami.Units.humanMoment
            onTriggered: {
                volume.opacity = 0
            }
        }

        Kirigami.Icon {
            id: playStatus
            anchors.fill: parent
            source: root.mpdState.isPlaying ? Mpdw.icons.queuePause : Mpdw.icons.queuePlay

            WorkspaceComponents.BadgeOverlay {
                id: volume
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                icon: parent // provide for internal height calculation
                opacity: 0
                visible: false
                text: root.volumeState.volume

                Behavior on opacity {
                    OpacityAnimator {
                        duration: root.animationDuration
                        easing.type: Easing.InQuad
                        onFinished: volume.visible = false
                    }
                }
            }
        }
    }
}
