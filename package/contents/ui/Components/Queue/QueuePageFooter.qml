import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15

QQC2.ToolBar {
    RowLayout {
        anchors.fill: parent
        RowLayout {
            Layout.alignment: Qt.AlignLeft
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            // @SOMEDAY duplicating a lot here, figure it out
            QueueFooterCheckbox {
                id: randomCheckbox

                itDesc: qsTr("Random")
                itSc: qsTr("z")
                iconName: "media-playlist-shuffle"

                onCheckedChanged: {
                    // This catches ourself immediatly reversing the command we got from mpd
                    let localState = mpdState.mpdOptions.random === "on"
                    if (randomCheckbox.checked === localState) {
                        return
                    }
                    mpdState.toggleRandom()
                }

                Connections {
                    function onMpdOptionsChanged() {
                        // This catches us getting our own cmd replied, so don't act on it.
                        let localState = mpdState.mpdOptions.random === "on"
                        if (randomCheckbox.checked === localState) {
                            return
                        }
                        randomCheckbox.checked = mpdState.mpdOptions.random === "on"
                    }
                    target: mpdState
                }
            }

            QueueFooterCheckbox {
                id: consumeCheckbox

                itDesc: qsTr("Consume")
                itSc: qsTr("r")
                iconName: "draw-eraser"

                onCheckedChanged: {
                    // This catches ourself immediatly reversing the command we got from mpd
                    let localState = mpdState.mpdOptions.consume === "on"
                    if (consumeCheckbox.checked === localState) {
                        return
                    }
                    mpdState.toggleConsume()
                }

                Connections {
                    function onMpdOptionsChanged() {
                        // This catches us getting our own cmd replied, so don't act on it.
                        let localState = mpdState.mpdOptions.consume === "on"
                        if (consumeCheckbox.checked === localState) {
                            return
                        }
                        consumeCheckbox.checked = mpdState.mpdOptions.consume === "on"
                    }
                    target: mpdState
                }
            }
        }
    }
}
