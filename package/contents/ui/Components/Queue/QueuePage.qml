import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"
import "../../Components/Songlist"
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
                            icon.name: Mpdw.icons.queueFollowMode
                            tooltip: qsTr("Follow Mode - Scroll the queue to keep the currently playing song visible.") + " (" + qsTr("L") + ")" // @i18n
                            shortcut: "shift+l"
                            displayHint: Kirigami.DisplayHint.IconOnly
                            checkable: true
                            checked: true
                        },
                        Kirigami.Action {
                            text: qsTr("Queue")
                            Kirigami.Action {
                                icon.name: Mpdw.icons.queueSaveNew
                                text: qsTr("Save as New Playlist…")
                                shortcut: "s"
                                onTriggered: {
                                    queueDialogSave.open()
                                }
                            }
                            Kirigami.Action {
                                icon.name: Mpdw.icons.queueSaveReplace
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
                                icon.name: mpdToggleConsumeAct.icon.name
                                text: mpdToggleConsumeAct.text
                                shortcut: mpdToggleConsumeAct.shortcut
                                tooltip: mpdToggleConsumeAct.tooltip
                                onTriggered: mpdToggleConsumeAct.onTriggered()
                            }
                            Kirigami.Action {
                                icon.name: mpdToggleRandomAct.icon.name
                                text: mpdToggleRandomAct.text
                                shortcut: mpdToggleRandomAct.shortcut
                                tooltip: mpdToggleRandomAct.tooltip
                                onTriggered: mpdToggleRandomAct.onTriggered()
                            }
                            Kirigami.Action {
                                icon.name: mpdToggleRepeatAct.icon.name
                                text: mpdToggleRepeatAct.text
                                shortcut: mpdToggleRepeatAct.shortcut
                                tooltip: mpdToggleRepeatAct.tooltip
                                onTriggered: mpdToggleRepeatAct.onTriggered()
                            }
                            Kirigami.Action {
                                separator: true
                            }
                            Kirigami.Action {
                                text: qsTr("Clear Queue")
                                icon.name: Mpdw.icons.queueClear
                                tooltip: text + " (" + qsTr("Shift+C") + ")" // @i18n
                                shortcut: "shift+c"
                                displayHint: Kirigami.DisplayHint.IconOnly
                                onTriggered: {
                                    mpdState.clearQueue()
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

        header: SonglistHeader {
            leftActions: [
                Kirigami.Action {
                    id: rmSelctBtn
                    text: qsTr("Remove")
                    tooltip: qsTr("Remove Selected Songs")
                    icon.name: Mpdw.icons.queueRemoveSelected
                    shortcut: "Del"
                    enabled: numberSelected
                    onTriggered: {
                        let positions = songlistView.getSelected()
                        songlistView.removeSelection()
                        songlistView.updateMpdPositions()
                        mpdState.removeFromQueue(positions)
                    }
                }
            ]
            // @TODO Should be default action of SonglistView without repeating here
            rightActions: [
                Kirigami.Action {
                    text: appWindow.narrowLayout ? "" : qsTr("Deselect")
                    tooltip: qsTr("Deselect All")
                    icon.name: Mpdw.icons.selectNone
                    shortcut: "Shift+D"
                    onTriggered: {
                        songlistView.deselectAll()
                    }
                }
            ]

            Connections {
                target: songlistView
                function onSelectedChanged() {
                    // @TODO
                    songlistView.headerItem.numberSelected = songlistView.selected.length
                }
            }
        }

        function showCurrentItemInList() {
            if (!appWindow.visible) {
                return
            }

            if (!mpdState.mpdInfo) {
                return
            }

            songlistView.currentIndex = mpdState.mpdInfo.pos
            centerInView(songlistView.currentIndex)
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            text: qsTr("Queue is empty")
            visible: mpdState.mpdQueue.length === 0
        }

        delegate: SonglistItem {
            id: songlistItem

            coverLoadingPriority: 50
            isSortable: true
            parentView: songlistView
            playingIndex: mpdState.mpdInfo ? mpdState.mpdInfo.pos : -1
            carretIndex: songlistView.currentIndex

            actions: [
                Kirigami.Action {
                    icon.name: (playingIndex === model.index && mpdState.mpdPlaying)
                               ? Mpdw.icons.queuePause
                               : Mpdw.icons.queuePlay
                    text: qsTr("Play Now")
                    onTriggered: {
                        if (playingIndex === model.index) {
                            mpdState.toggle()
                        } else {
                            mpdState.playInQueue(model.pos)
                        }
                    }
                },
                Kirigami.Action {
                    icon.name: Mpdw.icons.queueRemoveSingle
                    text: qsTr("Remove from Queue")
                    visible: !appWindow.narrowLayout
                    onTriggered: {
                        let index = model.index
                        songlistView.model.remove(index)
                        songlistView.updateMpdPositions()
                        mpdState.removeFromQueue([index])
                    }
                }
            ]
        }

        Keys.onPressed: {
            if (event.key === Qt.Key_L) {
                 songlistView.showCurrentItemInList()
            }
        }

        Connections {
            function onUserInteracted() {
                if (!followCurrentSong.checked) {
                    return
                }
                followCurrentSong.checked = false
                disableFollowOnEditTimer.restart()
            }
        }

        Timer {
            id: disableFollowOnEditTimer
            interval: 120000
            onTriggered: {
                followCurrentSong.checked = true
                songlistView.showCurrentItemInList()
            }
        }
    }

    Connections {
        target: mpdState

        function onMpdQueueChanged() {
            // Queue is empty, clear everything
            if (mpdState.mpdQueue.length === 0) {
                songlistView.model.clear()
                return
            }

            var i = 0
            for (i; i < mpdState.mpdQueue.length; i++) {
                let mpdSong = mpdState.mpdQueue[i]
                let ourSong = songlistView.model.get(i)

                //console.log("------- Queue Refresh Item ---------")
                //console.log(`mpd-file: ${mpdSong.file}`)

                if (ourSong) {
                    // console.log(`our-file: ${ourSong.file}`)
                    if (mpdSong.file === ourSong.file) {
                        //console.log('Keeping our song.')
                        // As long as mpd-queue matches ours do nothing
                        continue
                    } else {
                        // Clear out selection (cache) of the item
                        songlistView.select(i, false)
                        // console.log('Removing our song.')
                        songlistView.model.remove(i)
                    }

                }
                songlistView.model.insert(i, mpdSong)
            }

            // Remove all additional items in our queue not in mpd's
            for (let k = songlistView.count - 1; k >= i; k--) {
                songlistView.model.remove(k)
            }

            if (followCurrentSong.checked)  {
                songlistView.showCurrentItemInList()
            }
        }

        function onMpdInfoChanged() {
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

    onVisibleChanged: {
        if (visible) {
            songlistView.forceActiveFocus()
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
