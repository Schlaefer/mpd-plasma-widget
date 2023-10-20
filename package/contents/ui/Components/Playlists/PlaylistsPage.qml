import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"

Kirigami.ScrollablePage {
    id: root

    property int depth: 1
    readonly property string globalShortcut: "3"

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

            onClicked: {
                appWindow.pageStack.push(Qt.resolvedUrl("PlaylistSongsPage.qml"), {
                                               "depth": root.depth + 1,
                                               "playlistId": model.title
                                           })
            }
            width: ListView.view ? ListView.view.width : implicitWidth
            actions: [
                Kirigami.Action {
                    icon.name: Mpdw.icons.queueAppend
                    text: qsTr("Add Playlist to Queue")
                    onTriggered: {
                        mpdState.addPlaylistToQueue(model.title)
                    }
                },
                Kirigami.Action {
                    icon.name: Mpdw.icons.queuePlay
                    text: qsTr("Replace Queue with Playlist")
                    onTriggered: {
                        mpdState.playPlaylist(model.title)
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
                    text: model.title
                    wrapMode: Text.Wrap
                }
                DialogConfirm {
                    id: deleteConfirmationDialog
                    icon: Mpdw.icons.playlistDelete
                    title: qsTr("Delete Playlist")
                    label: qsTr("The following playlist will be deleted")
                    buttonText: qsTr("Delete Playlist")
                    itemTitle: model.title

                    onConfirmed: function () {
                        mpdState.removePlaylist(model.title)
                        deleteConfirmationDialog.close()
                    }
                }
            }
        }
    }

    ListViewGeneric {
        id: playlistList

        delegate: delegateComponentPlaylists

        Connections {
            function onMpdPlaylistsChanged() {
                playlistList.model.clear()
                let playlists = mpdState.mpdPlaylists
                for (let i in playlists) {
                    playlistList.model.append({
                                                  "title": playlists[i]
                                              })
                }
            }

            target: mpdState
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
