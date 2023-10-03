import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15

QQC2.GroupBox {
    RowLayout {
        anchors.right: parent.right

        QQC2.CheckBox {
            id: random

            icon.name: "media-playlist-shuffle"
            text: qsTr("Random")
            onClicked: mpdState.toggleRandom()

            QQC2.ToolTip {
                text: qsTr("Z")
                visible: hovered
            }

            Shortcut {
                sequence: "z"
                onActivated: random.checked = !random.checked
            }

            Connections {
                function onMpdOptionsChanged() {
                    random.checked = mpdState.mpdOptions.random === "on"
                }
                target: mpdState
            }
        }

        QQC2.CheckBox {
            id: consume

            icon.name: "tool-eraser-symbolic"
            text: qsTr("Consume")
            onClicked: mpdState.toggleConsume()

            QQC2.ToolTip {
                text: qsTr("R")
                visible: hovered
            }

            Shortcut {
                sequence: "r"
                onActivated: consume.checked = !consume.checked
            }

            Connections {
                function onMpdOptionsChanged() {
                    consume.checked = mpdState.mpdOptions.consume === "on"
                }
                target: mpdState
            }
        }
    }
}
