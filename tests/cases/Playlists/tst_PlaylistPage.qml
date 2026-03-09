import QtQuick
import QtTest
import org.kde.kirigami as Kirigami
import "../../Mocks"
import "../../../package/contents/ui/Components/Playlists"

TestCase {
    name: "PlaylistsPage"

    property PlaylistsPage testItem

    MpdStateMock {
        id: mpdState
        cfgMpdHost: ""
        cfgMpdPort: ""
        scriptRoot: ""
    }

    Kirigami.ApplicationItem { id: mockApp }
    Kirigami.Page { id: mockPage }

    function resetTestItem() {
        testItem = createTemporaryObject(Qt.createComponent(
            "../../../package/contents/ui/Components/Playlists/PlaylistsPage.qml"),
            null,
            {
                app: mockApp,
                mpdState: mpdState,
                narrowLayout: false,
                pageStack: Kirigami.PageRow
            })
    }

    function test_noPlaylists() {
        mpdState.mockPlaylistsClear()
        resetTestItem()
        const list = findChild(testItem, 'playlistsList')
        compare(list.count, 0)
    }

    function test_updatePlaylists() {
        mpdState.mockPlaylistsClear()
        resetTestItem()
        const list = findChild(testItem, 'playlistsList')
        compare(list.count, 0)
        mpdState.mockPlaylistsSet(3)
        compare(list.count, 3)
        mpdState.mockPlaylistsClear()
        compare(list.count, 0)
    }

    function test_comboBoxInitWithPlaylists() {
        mpdState.mockPlaylistsSet(2)
        resetTestItem()
        const list = findChild(testItem, 'playlistsList')
        compare(list.count, 2)
    }
}