import QtQuick
import org.kde.kirigami as Kirigami
import "../Songlist"
import "../../../logic"

Kirigami.ScrollablePage {
    id: root

    required property MpdState mpdState
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

        mpdState: root.mpdState
        narrowLayout: root.narrowLayout

        delegate: SonglistItem {
            id: songlistItem
            mpdState: root.mpdState
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
