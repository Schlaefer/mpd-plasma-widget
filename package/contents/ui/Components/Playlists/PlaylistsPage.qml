pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"

Kirigami.ScrollablePage {
    id: root

    property int depth: 1

    visible: false
    title: qsTr("Playlists")

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            GlobalNav { }
        }
    }

    Component {
        id: delegateComponentPlaylists

        SwipeListItemGeneric {
            id: listItemPlaylist

            required property string title

            onClicked: {
                let properties =  {
                    "depth": root.depth + 1,
                    "playlistId": listItemPlaylist.title,
                    "title": listItemPlaylist.title,
                }
                app.pageStack.push(Qt.resolvedUrl("PlaylistSongsPage.qml"), properties)
            }
            width: ListView.view ? ListView.view.width : implicitWidth
            actions: [
                Kirigami.Action {
                    icon.name: Mpdw.icons.queuePlay
                    text: qsTr("Play")
                    onTriggered: {
                        mpdState.playPlaylist(listItemPlaylist.title)
                    }
                },
                Kirigami.Action {
                    icon.name: Mpdw.icons.queueAppend
                    text: qsTr("Append")
                    onTriggered: {
                        let playlistTitle = listItemPlaylist.title
                        let callback = () => {
                            showPassiveNotification(
                                qsTr("Added playlist %1").arg(playlistTitle),
                                Kirigami.Units.humanMoment
                            )
                        }
                        mpdState.loadPlaylist(playlistTitle, callback)
                    }
                },
                Kirigami.Action {
                    icon.name: Mpdw.icons.playlistDelete
                    text: qsTr("Remove Playlist…")
                    onTriggered: {
                        deleteConfirmationDialog.open()
                    }
                }
            ]

            contentItem: RowLayout {
                Label {
                    Layout.fillWidth: true
                    height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
                    text: listItemPlaylist.title
                    wrapMode: Text.Wrap
                }
                DialogConfirm {
                    id: deleteConfirmationDialog
                    icon: Mpdw.icons.playlistDelete
                    title: qsTr("Delete Playlist")
                    label: qsTr("The following playlist will be deleted")
                    buttonText: qsTr("Delete Playlist")
                    itemTitle: listItemPlaylist.title

                    onConfirmed: function () {
                        mpdState.removePlaylist(listItemPlaylist.title)
                        deleteConfirmationDialog.close()
                    }
                }
            }
        }
    }

    ListViewGeneric {
        id: playlistList

        delegate: delegateComponentPlaylists

        function populateModel() {
            model.clear()
            let playlists = mpdState.mpdPlaylists
            for (let i in playlists) {
                model.append({ "title": playlists[i] })
            }
        }

        Component.onCompleted: { mpdState.getPlaylists() }

        Connections {
            target: mpdState
            function onMpdPlaylistsChanged() {
                playlistList.populateModel()
            }
        }

        model: ListModel {}

        moveDisplaced: Transition {
            YAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }
}
