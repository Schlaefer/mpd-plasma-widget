import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ScrollablePage {
    id: playlistPage

    property var mpd

    visible: false
    title: qsTr("Playlists")

    Component {
        id: delegateComponentPlaylists

        Kirigami.SwipeListItem {
            id: listItemPlaylist

            alternatingBackground: true
            onClicked: {
            }
            width: ListView.view ? ListView.view.width : implicitWidth
            actions: [
                Kirigami.Action {
                    icon.name: "media-playback-start"
                    text: qsTr("Replace Queue")
                    onTriggered: {
                        mpd.playPlaylist(model.title);
                    }
                },
                Kirigami.Action {
                    icon.name: "list-add"
                    text: qsTr("Add to Queue")
                    onTriggered: {
                        mpd.addPlaylistToQueue(model.title);
                    }
                }
            ]

            contentItem: RowLayout {
                Label {
                    Layout.fillWidth: true
                    height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
                    font.bold: mpd.mpdFile == model.file ? true : false
                    text: model.title
                    wrapMode: Text.Wrap
                }

            }

        }

    }

    ListView {
        id: playlistList

        delegate: delegateComponentPlaylists

        Connections {
            function onMpdPlaylistsChanged() {
                playlistList.model.clear();
                let playlists = mpd.mpdPlaylists;
                for (let i in playlists) {
                    playlistList.model.append({
                        "title": playlists[i]
                    });
                }
            }

            target: mpd
        }

        model: ListModel {
        }

        moveDisplaced: Transition {
            YAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }

        }

    }

}
