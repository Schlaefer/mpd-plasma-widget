import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami
import "../Elements"

Kirigami.ScrollablePage {
    id: root

    property alias songs: listView.songs

    NavQueue {
        parentPage: root
    }

    SonglistView {
        id: listView

        property var songs

        actionsHook: root.actions.contextualActions

        delegate: SonglistItem {
            id: songlistItem
            parentView: listView
            alternatingBackground: true
        }

        Component.onCompleted: {
            listView.model.clear()
            listView.songs.forEach(function (song) {
                song.checked = false
                listView.model.append(song)
            })
        }
    }
}