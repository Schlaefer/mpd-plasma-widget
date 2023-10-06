import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import "./Components/Elements"

Kirigami.ScrollablePage {
    id: root
    visible: false
    title: qsTr("Playlists")

    Component {
        id: delegateComponentPlaylists

        Kirigami.SwipeListItem {
            id: listItemPlaylist

            // alternatingBackground: true
            onClicked: {

            }
            width: ListView.view ? ListView.view.width : implicitWidth
            actions: [
                Kirigami.Action {
                    icon.name: "list-add"
                    text: qsTr("Add to Queue")
                    onTriggered: {
                        mpdState.addPlaylistToQueue(model.title)
                    }
                },
                Kirigami.Action {
                    icon.name: "media-playback-start"
                    text: qsTr("Replace Queue")
                    onTriggered: {
                        mpdState.playPlaylist(model.title)
                    }
                },
                Kirigami.Action {
                    icon.name: "edit-delete"
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
                    icon: "edit-delete"
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

    ListView {
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
