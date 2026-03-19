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

    function cleanup() {
        mpdState.mockReset()
    }

    function initTestItem() {
        testItem = createTemporaryObject(Qt.createComponent(
            "../../../package/contents/ui/Components/Playlists/PlaylistsPage.qml"),
            parent,
            {
                app: mockApp,
                mpdState: mpdState,
                narrowLayout: false,
                visible: true,
            })
    }

    function test_initWithNoPlaylists() {
        initTestItem()
        const list = findChild(testItem, 'playlistsList')
        compare(list.count, 0)
    }

    function test_initWithPlaylists() {
        mpdState.r.playlistsCreate(2)
        initTestItem()
        const list = findChild(testItem, 'playlistsList')
        compare(list.count, 2)
    }

    function test_updatePlaylists() {
        initTestItem()
        const list = findChild(testItem, 'playlistsList')
        compare(list.count, 0)
        mpdState.r.playlistsCreate(3)
        compare(list.count, 3)
        mpdState.mockReset()
        compare(list.count, 0)
    }
}
