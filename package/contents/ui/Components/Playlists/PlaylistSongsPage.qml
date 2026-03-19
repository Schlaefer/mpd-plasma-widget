import QtQuick
import org.kde.kirigami as Kirigami
import "../../Components/Songlist"
import "../../../logic"

Kirigami.ScrollablePage {
    id: root

    required property MpdState mpdState
    required property bool narrowLayout
    required property Kirigami.PageRow pageStack
    property alias playlistId: listView.playlistId

    signal searchLibrary(term: string)

    header: SonglistNav {
        id: nav
        pageStack: root.pageStack
        title: root.title
    }

    SonglistView {
        id: listView

        mpdState: root.mpdState
        narrowLayout: root.narrowLayout

        property string playlistId

        delegate: SonglistItem {
            id: songlistItem
            mpdState: root.mpdState
            narrowLayout: root.narrowLayout
            parentView: listView
            carretIndex: listView.currentIndex
            contextmenuShowSearchActions: true

            onSearchLibrary: term => root.searchLibrary(term)
        }

        Component.onCompleted: {
            root.mpdState.getPlaylist(playlistId)
        }

        Connections {
            target: root.mpdState
            function onGotPlaylist(playlistData) {
                listView.model.clear()
                for (let i in playlistData) {
                    listView.model.append(playlistData[i])
                }
            }
        }
    }
}
