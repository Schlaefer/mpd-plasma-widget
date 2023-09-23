import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

GroupBox {
    property var mpd

    RowLayout {
        anchors.right: parent.right

        CheckBox {
            id: random

            icon.name: "media-playlist-shuffle"
            text: qsTr("Random")
            onClicked: mpd.toggleRandom()

            Connections {
                function onMpdOptionsChanged() {
                    random.checked = mpd.mpdOptions.random === "on";
                }

                target: mpd
            }

        }

        CheckBox {
            id: consume

            icon.name: "tool-eraser-symbolic"
            text: qsTr("Consume")
            onClicked: mpd.toggleConsume()

            Connections {
                function onMpdOptionsChanged() {
                    consume.checked = mpd.mpdOptions.consume === "on";
                }

                target: mpd
            }

        }

    }

}
