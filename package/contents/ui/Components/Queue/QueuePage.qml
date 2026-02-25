import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"
import "../../Components/Songlist"
import "../../Components/Queue"
import "../../../logic"

Kirigami.ScrollablePage {
    id: root

    required property MpdState mpdState
    required property bool narrowLayout
    property alias followMode: followMode

    Layout.fillWidth: true
    title: qsTr("Queue")
    visible: false

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            GlobalNav {
                narrowLayout: root.narrowLayout
            }
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
                                    queueDialogLoader.setSource("QueueDialogSave.qml", {
                                        mpdState: root.mpdState
                                    })
                                    queueDialogLoader.active = true
                                    queueDialogLoader.item.open()
                                }
                            }
                            Kirigami.Action {
                                icon.name: Mpdw.icons.queueSaveReplace
                                text: qsTr("Replace Playlist…")
                                shortcut: "Ctrl+Shift+S"
                                onTriggered: {
                                    queueDialogLoader.setSource("QueueDialogReplacePl.qml", {
                                        mpdState: root.mpdState
                                    })
                                    queueDialogLoader.active = true
                                    queueDialogLoader.item.open()
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
                                icon.name: showCurrentSongAction.icon.name
                                text: showCurrentSongAction.text
                                shortcut: showCurrentSongAction.shortcut
                                onTriggered: showCurrentSongAction.trigger()
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
                                    root.mpdState.clearQueue()
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

        mpdState: root.mpdState
        narrowLayout: root.narrowLayout

        header: SonglistHeader {
            leftActions: [
                Kirigami.Action {
                    id: rmSelctBtn
                    text: qsTr("Remove")
                    tooltip: qsTr("Remove Selected Songs")
                    icon.name: Mpdw.icons.queueRemoveSelected
                    shortcut: "Del"
                    enabled: songlistView.model.selected.length
                    onTriggered: {
                        let positions = songlistView.model.getSelected()
                        songlistView.model.selectedRemove()
                        root.mpdState.removeFromQueue(positions)
                    }
                }
            ]
            rightActions: [songlistView.actionDeselect]
        }

        Kirigami.PlaceholderMessage {
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.largeSpacing * 4)
            text: qsTr("Queue is empty")
            visible: root.mpdState.mpdQueue.length === 0
        }

        delegate: SonglistItem {
            id: songlistItem

            coverLoadingPriority: 50
            isSortable: true
            mpdState: root.mpdState
            narrowLayout: root.narrowLayout
            parentView: songlistView
            playingIndex: root.mpdState.mpdInfo ? root.mpdState.mpdInfo.pos : -1
            carretIndex: songlistView.currentIndex

            actions: [
                Kirigami.Action {
                    icon.name: (songlistItem.playingIndex === model.index && root.mpdState.mpdPlaying)
                               ? Mpdw.icons.queuePause
                               : Mpdw.icons.queuePlay
                    tooltip: qsTr("Play Now")
                    onTriggered: {
                        if (songlistItem.playingIndex === model.index) {
                            root.mpdState.togglePlayPause()
                        } else {
                            root.mpdState.playInQueue(model.pos)
                        }
                    }
                },
                Kirigami.Action {
                    icon.name: Mpdw.icons.queueRemoveSingle
                    tooltip: qsTr("Remove from Queue")
                    visible: !root.narrowLayout
                    onTriggered: {
                        let index = model.index
                        songlistView.model.remove(index)
                        root.mpdState.removeFromQueue([index])
                    }
                }
            ]
        }
    }

    QueueFollowModeController {
        id: followMode
        currentPosition: root.mpdState.mpdInfo ? root.mpdState.mpdInfo.pos : -1
        listView: songlistView
    }


    function populateQueue() {
        // Queue is empty, clear everything
        if (root.mpdState.mpdQueue.length === 0) {
            songlistView.model.clear()
            return
        }

        var i = 0
        for (i; i < root.mpdState.mpdQueue.length; i++) {
            let mpdSong = root.mpdState.mpdQueue[i]
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
                    songlistView.model.select(i, false)
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

    Connections {
        target: root.mpdState

        function onMpdQueueChanged() {
            root.populateQueue()
        }

        function onMpdInfoChanged() {
            followMode.showCurrent()
        }
    }

    Component.onCompleted: {
        root.populateQueue()
    }

    Connections {
        target: win
        function onHeightChanged() {
            followMode.showCurrent()
        }
    }

    onVisibleChanged: {
        if (visible) {
            songlistView.forceActiveFocus()
        }
    }

    Loader {
        id: queueDialogLoader
        active: false
        anchors.fill: parent
    }
}
