import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami
import "../Songlist"

Kirigami.ScrollablePage {
    id: root

    property alias songs: listView.songs

    SonglistView {
        id: listView

        property var songs

        delegate: SonglistItem {
            id: songlistItem
            parentView: listView
            alternatingBackground: true
            carretIndex: listView.currentIndex
        }

        Component.onCompleted: {
            listView.model.clear()
            listView.songs.forEach(function (song) {
                listView.model.append(song)
            })
        }
    }
}
