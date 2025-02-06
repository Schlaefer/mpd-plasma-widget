import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"
import "../../Components/Songlist"
import "../../Components/Queue"
import "../../../scripts/formatHelpers.js" as FmH

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
                            id: queueMenu
                            text: qsTr("Queue")
                            Kirigami.MnemonicData.enabled: false
                            Kirigami.Action {
                                icon.name: Mpdw.icons.queueSaveNew
                                text: qsTr("Save as New Playlist…")
                                shortcut: "Ctrl+S"
                                onTriggered: {
                                    queueDialogSave.open()
                                }
                            }
                            Kirigami.Action {
                                icon.name: Mpdw.icons.queueSaveReplace
                                text: qsTr("Replace Playlist…")
                                 shortcut: "Ctrl+Shift+S"
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
                                id: showCurrentSongAction
                                icon.name: Mpdw.icons.queueShowCurrent
                                text: qsTr("Show Current Song")
                                shortcut: "L"
                                onTriggered: {
                                    if (!queuePage.visible) { appWindow.showPage(queuePage) }
                                    followMode.autoMode = true
                                    followMode.showCurrent()
                                }
                            }
                            Kirigami.Action {
                                separator: true
                            }
                            Kirigami.Action {
                                text: qsTr("Clear Queue")
                                icon.name: Mpdw.icons.queueClear
                                shortcut: "Shift+C"
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
            rightActions: [songlistView.actionDeselect]

            Connections {
                target: songlistView
                function onSelectedChanged() {
                    // @TODO
                    songlistView.headerItem.numberSelected = songlistView.selected.length
                }
            }
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
                    icon.name: (songlistItem.playingIndex === model.index && mpdState.mpdPlaying)
                               ? Mpdw.icons.queuePause
                               : Mpdw.icons.queuePlay
                    text: qsTr("Play Now")
                    onTriggered: {
                        if (songlistItem.playingIndex === model.index) {
                            mpdState.togglePlayPause()
                        } else {
                            mpdState.playInQueue(model.pos)
                        }
                    }
                },
                Kirigami.Action {
                    icon.name: Mpdw.icons.queueRemoveSingle
                    text: qsTr("Remove from Queue")
                    visible: !main.appWindow.narrowLayout
                    onTriggered: {
                        let index = model.index
                        songlistView.model.remove(index)
                        songlistView.updateMpdPositions()
                        mpdState.removeFromQueue([index])
                    }
                }
            ]
        }
    }

    QueueFollowModeController {
        id: followMode
        currentPosition: mpdState.mpdInfo ? mpdState.mpdInfo.pos : -1
        listView: songlistView
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

            followMode.showCurrent()
        }

        function onMpdInfoChanged() {
            followMode.showCurrent()
        }
    }

    Component.onCompleted: {
        // @BOGUS Initiates triggering populating Queue and Playlists on app
        // window opening. Make it ask properly for the already available data from
        // mpdState in both places. Required for Loader those pages anyway.
        mpdState.update()
    }

    Connections {
        target: main.appWindow
        function onHeightChanged() {
            followMode.showCurrent()
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
