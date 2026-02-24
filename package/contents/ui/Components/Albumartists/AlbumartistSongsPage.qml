import QtQuick
import org.kde.kirigami as Kirigami
import "../Songlist"

Kirigami.ScrollablePage {
    id: root

    required property bool narrowLayout
    required property Kirigami.PageRow pageStack
    property alias songs: listView.songs

    header: SonglistNav {
        id: nav
        title: root.title
        pageStack: root.pageStack
    }

    SonglistView {
        id: listView

        property var songs

        narrowLayout: root.narrowLayout

        delegate: SonglistItem {
            id: songlistItem
            narrowLayout: root.narrowLayout
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
