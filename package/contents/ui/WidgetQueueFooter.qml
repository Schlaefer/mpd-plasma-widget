import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

GroupBox {
    RowLayout {
        anchors.right: parent.right

        CheckBox {
            id: random

            icon.name: "media-playlist-shuffle"
            text: qsTr("Random")
            onClicked: mpdState.toggleRandom()

            Connections {
                function onMpdOptionsChanged() {
                    random.checked = mpdState.mpdOptions.random === "on";
                }
                target: mpdState
            }

        }

        CheckBox {
            id: consume

            icon.name: "tool-eraser-symbolic"
            text: qsTr("Consume")
            onClicked: mpdState.toggleConsume()

            Connections {
                function onMpdOptionsChanged() {
                    consume.checked = mpdState.mpdOptions.consume === "on";
                }
                target: mpdState
            }

        }

    }

}
