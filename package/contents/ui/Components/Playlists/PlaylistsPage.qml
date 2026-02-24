pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"
import "../../../logic"

Kirigami.ScrollablePage {
    id: root

    required property bool narrowLayout
    required property MpdState mpdState
    required property Kirigami.PageRow pageStack
    property int depth: 1

    visible: false
    title: qsTr("Playlists")

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            GlobalNav {
                narrowLayout: root.narrowLayout
             }
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
                    "mpdState": root.mpdState,
                    "narrowLayout": Qt.binding(() => root.narrowLayout),
                    "pageStack": root.pageStack,
                    "playlistId": listItemPlaylist.title,
                    "title": listItemPlaylist.title,
                }
                root.pageStack.push(Qt.resolvedUrl("PlaylistSongsPage.qml"), properties)
            }
            width: ListView.view ? ListView.view.width : implicitWidth
            actions: [
                Kirigami.Action {
                    icon.name: Mpdw.icons.queuePlay
                    tooltip: qsTr("Replace Queue and Start Playing")
                    onTriggered: {
                        root.mpdState.playPlaylist(listItemPlaylist.title)
                    }
                },
                Kirigami.Action {
                    icon.name: Mpdw.icons.queueAppend
                    tooltip: qsTr("Append to End of Queue")
                    onTriggered: {
                        let playlistTitle = listItemPlaylist.title
                        let callback = () => {
                            app.showPassiveNotification(
                                qsTr("Added playlist %1").arg(playlistTitle),
                                Kirigami.Units.humanMoment
                            )
                        }
                        root.mpdState.loadPlaylist(playlistTitle, callback)
                    }
                },
                Kirigami.Action {
                    icon.name: Mpdw.icons.playlistDelete
                    tooltip: qsTr("Remove Playlist…")
                    onTriggered: {
                        deleteConfirmationDialog.itemTitle = listItemPlaylist.title
                        deleteConfirmationDialog.open()
                    }
                }
            ]

            contentItem: RowLayout {
                Label {
                    Layout.fillWidth: true
                    //@BOGUS
                    height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
                    text: listItemPlaylist.title
                    wrapMode: Text.Wrap
                }
            }
        }
    }

    DialogConfirm {
        id: deleteConfirmationDialog
        icon: Mpdw.icons.playlistDelete
        title: qsTr("Delete Playlist")
        label: qsTr("The following playlist will be deleted")
        buttonText: qsTr("Delete Playlist")

        onConfirmed: function () {
            root.mpdState.removePlaylist(itemTitle)
            deleteConfirmationDialog.close()
        }
    }

    ListViewGeneric {
        id: playlistList

        delegate: delegateComponentPlaylists

        function populateModel() {
            model.clear()
            let playlists = root.mpdState.mpdPlaylists
            for (let i in playlists) {
                model.append({ "title": playlists[i] })
            }
        }

        Component.onCompleted: { root.mpdState.getPlaylists() }

        Connections {
            target: root.mpdState
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
