import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15

QQC2.ToolBar {
    RowLayout {
        anchors.fill: parent
        RowLayout {
            Layout.alignment: Qt.AlignLeft

            QQC2.ToolButton {
                text: qsTr("Queue…")
                icon.name: "media-playback-playing"
                onClicked: menuB.open()

                QQC2.Menu {
                    id: menuB
                    QQC2.MenuItem {
                        icon.name: "document-save-as"
                        text: qsTr("Save Queue")
                        // @todo
                        // shortcut: "shift+s"
                        onTriggered: {
                            queueDialogSave.open()
                        }

                        QueueDialogSave {
                            id: queueDialogSave
                        }
                    }
                    QQC2.MenuSeparator {}
                    QQC2.MenuItem {
                        text: qsTr("Clear Queue")
                        icon.name: "bqm-remove"
                        onTriggered: {
                            mpdState.clearPlaylist()
                        }
                    }
                }
            }

            QQC2.ToolButton {
                text: qsTr("Selected Items…")
                icon.name: "checkbox"
                onClicked: menuA.open()

                QQC2.Menu {
                    id: menuA
                    QQC2.MenuItem {
                        text: qsTr("Remove From Queue")
                        icon.name: "bqm-remove"
                        // @TODO
                        // shortcut: "del"
                        onTriggered: {
                            let items = queueList.listManager.getCheckedMpd()
                            mpdState.removeFromQueue(items)
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight

            QQC2.CheckBox {
                id: random

                icon.name: "media-playlist-shuffle"
                text: qsTr("Random")
                onClicked: mpdState.toggleRandom()

                QQC2.ToolTip {
                    text: qsTr("Z")
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
}
