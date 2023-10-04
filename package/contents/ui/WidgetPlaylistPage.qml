import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents

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
                    icon.name: "media-playback-start"
                    text: qsTr("Replace Queue")
                    onTriggered: {
                        mpdState.playPlaylist(model.title)
                    }
                },
                Kirigami.Action {
                    icon.name: "list-add"
                    text: qsTr("Add to Queue")
                    onTriggered: {
                        mpdState.addPlaylistToQueue(model.title)
                    }
                },
                Kirigami.Action {
                    icon.name: "edit-delete"
                    text: qsTr("Remove Playlist…")
                    onTriggered: {
                        deletePrompt.open()
                    }
                }
            ]

            contentItem: RowLayout {
                Label {
                    Layout.fillWidth: true
                    height: Math.max(implicitHeight,
                                     Kirigami.Units.iconSizes.smallMedium)
                    text: model.title
                    wrapMode: Text.Wrap
                }

                Kirigami.PromptDialog {
                    id: deletePrompt
                    title: qsTr("Delete Playlist")

                    standardButtons: Kirigami.Dialog.NoButton
                    showCloseButton: false

                    customFooterActions: [
                        Kirigami.Action {
                            text: qsTr("Delete Playlist")
                            iconName: "dialog-ok"
                            onTriggered: {
                                mpdState.removePlaylist(model.title)
                                deletePrompt.close()
                            }
                        },
                        Kirigami.Action {
                            text: qsTr("Cancel")
                            iconName: "cancel"
                            onTriggered: {
                                deletePrompt.close()
                            }
                        }
                    ]

                    // @TODO refactor and merge with QueueDialogSave confirmation
                    ColumnLayout {
                        spacing: Kirigami.Units.largeSpacing

                        PlasmaComponents.Label {
                            text: qsTr(
                                      "The following playlist will be deleted:")
                        }
                        PlasmaComponents.Label {
                            text: model.title
                            font.weight: Font.Bold
                        }
                        // @TODO this spams a lot of loop errors from kirigami framework
                        Kirigami.InlineMessage {
                            Layout.fillWidth: true
                            visible: true
                            type: Kirigami.MessageType.Warning
                            text: qsTr("This is a permanent operation.")
                        }
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
