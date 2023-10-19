import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami
import "../Elements"

Kirigami.ScrollablePage {
    id: root

    property alias playlistId: listView.playlistId

    SonglistView {
        id: listView

        property string playlistId

        delegate: SonglistItem {
            id: songlistItem
            parentView: listView
            carretIndex: listView.currentIndex
        }

        Component.onCompleted: {
            mpdState.getPlaylist(playlistId)
        }

        Connections {
            function onGotPlaylist(playlistData) {
                listView.model.clear()
                for (let i in playlistData) {
                    playlistData[i].checked = false
                    listView.model.append(playlistData[i])
                }
            }

            target: mpdState
        }
    }
}
