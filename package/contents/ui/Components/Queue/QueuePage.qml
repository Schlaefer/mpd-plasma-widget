import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import "../../Components/Elements"
import "../../Components/Queue"

Kirigami.ScrollablePage {
    id: queuePage

    readonly property string globalShortcut: "1"

    Layout.fillWidth: true
    title: qsTr("Queue")
    visible: false

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            GlobalNav { }
            RowLayout {
                Kirigami.ActionToolBar {
                    id: actionToolBar
                    alignment: Qt.AlignRight

                    actions: [
                        Kirigami.Action {
                            id: followCurrentSong
                            text: qsTr("Follow Playing Song")
                            icon.name: "mark-location"
                            tooltip: qsTr("Follow Mode - Scroll the queue to keep the currently playing song visible.") + " (" + qsTr("L") + ")" // @i18n
                            shortcut: "l"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            checkable: true
                            checked: true
                        },
                        Kirigami.Action {
                            text: qsTr("Clear Queue")
                            icon.name: "edit-delete"
                            tooltip: text + " (" + qsTr("Shift+C") + ")" // @i18n
                            shortcut: "shift+c"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            onTriggered: {
                                mpdState.clearQueue()
                            }
                        },
                        Kirigami.Action {
                            text: qsTr("Queue")
                            Kirigami.Action {
                                icon.name: "document-save-as"
                                text: qsTr("Save as New Playlist…")
                                shortcut: "s"
                                onTriggered: {
                                    queueDialogSave.open()
                                }
                            }
                            Kirigami.Action {
                                icon.name: "document-replace"
                                text: qsTr("Replace Playlist…")
                                 shortcut: "shift+s"
                                onTriggered: {
                                    queueDialogReplacePl.open()
                                }
                            }
                            Kirigami.Action {
                                separator: true
                            }
                            Kirigami.Action {
                                text: qsTr("Remove Selection")
                                icon.name: "edit-delete-remove"
                                // icon.name: "checkbox"
                                shortcut: "del"
                                onTriggered: {
                                    let positions = songlistView.getSelectedPositionsMpdBased()
                                    mpdState.removeFromQueue(positions)
                                }
                            }
                        }
                    ]
                }
            }
        }
    }


    SonglistView {
        id: songlistView

        QueueEmptyPlaceholder {
            anchors.centerIn: parent
        }

        function loadQueue(queue) {
            songlistView.model.clear()
            for (let i in queue) {
                let item = queue[i]
                item.checked = false
                songlistView.model.append(item)
            }
            if (followCurrentSong.checked)  {
                songlistView.showCurrentItemInList()
            }
        }

        function showCurrentItemInList() {
            if (!appWindow.visible) {
                return
            }
            let i
            for (i = 0; i < model.count; i++) {
                if (model.get(i).file === mpdState.mpdFile) {
                    break
                }
            }

            songlistView.currentIndex = i
            songlistView.positionViewAtIndex(i, ListView.Center)
        }

        delegate: SonglistItem {
            id: songlistItem

            coverLoadingPriority: 50
            isSortable: true
            parentView: songlistView
            playingIndex: mpdState.mpdInfo.position ? mpdState.mpdInfo.position - 1 : -1
            showSongMenu: false

            actions: [
                Kirigami.Action {
                    icon.name: (playingIndex === model.index
                                && mpdState.mpdPlaying) ? "media-playback-pause" : "media-playback-start"
                    text: qsTr("Play Now")
                    onTriggered: {
                        if (playingIndex === model.index) {
                            mpdState.toggle()
                        } else {
                            mpdState.playInQueue(model.position)
                        }
                    }
                },
                Kirigami.Action {
                    icon.name: "edit-delete"
                    text: qsTr("Remove from Queue")
                    visible: !appWindow.narrowLayout
                    onTriggered: {
                        let positionToRemove = model.position

                        songlistView.model.remove(index)
                        // Keep our state in sync with mpd's
                        for (let i = 0; i < songlistView.model.count; i++) {
                            songlistView.model.set(i, {position: i+1 + ""})
                        }

                        mpdState.removeFromQueue([positionToRemove])
                    }
                }
            ]

            onDoubleClicked: {
                mpdState.playInQueue(model.position)
            }


        }
    }

    Connections {
        target: mpdState

        function onMpdQueueChanged() {
            if (songlistView.model.count === 0 || songlistView.model.count !== mpdState.mpdQueue.length) {
                songlistView.loadQueue(mpdState.mpdQueue)

                return
            }

            // Check if the mpd queue is identical with ours and only update
            // ours if it doesn't match. That prevents redrawing and losing
            // our scroll position when e.g. reordering or deleting songs.
            // @SOMEDAY Could be improved by only changing songs that don't match ours
            for (let i = 0; i < songlistView.model.count; i++) {
                let sameFile = mpdState.mpdQueue[i].file === songlistView.model.get(i).file
                let samePosition = (mpdState.mpdQueue[i].position === songlistView.model.get(i).position)
                if (!sameFile || !samePosition) {
                    songlistView.loadQueue(mpdState.mpdQueue)

                    return

                }
            }
        }

        function onMpdFileChanged() {
            if (followCurrentSong.checked)  {
                songlistView.showCurrentItemInList()
            }
        }
    }

    Component.onCompleted: {
        // @BOGUS Initiates triggering populating Queue and Playlists on app
        // window opening. Make it ask properly for the already available data from
        // mpdState in both places. Required for Loader those pages anyway.
        mpdState.update()
    }

    Connections {
        target: appWindow
        function onHeightChanged() {
            if (followCurrentSong.checked)  {
                songlistView.showCurrentItemInList()
            }
        }
    }

    // @SOMEDAY loader
    QueueDialogSave {
        id: queueDialogSave
    }

    // @SOMEDAY loader
    QueueDialogReplacePl {
        id: queueDialogReplacePl
    }
}
