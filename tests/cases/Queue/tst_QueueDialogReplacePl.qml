import QtQuick
import QtTest
import "../../Mocks"
import "../../../package/contents/ui/Components/Queue"

TestCase {
    name: "QueueDialogReplacePl"

    property QueueDialogReplacePl testItem

    MpdStateMock {
        id: mpdState
        cfgMpdHost: ""
        cfgMpdPort: ""
        scriptRoot: ""
    }

    function resetTestItem() {
        testItem = createTemporaryObject(Qt.createComponent(
            "../../../package/contents/ui/Components/Queue/QueueDialogReplacePl.qml"),
            null,
            { mpdState: mpdState })
    }

    function test_comboBoxInitWithNoPlaylists() {
        mpdState.mockPlaylistsClear()
        resetTestItem()
        const listCombo = findChild(testItem, 'listCombo')
        compare(listCombo.count, 0)
    }

    function test_comboBoxUpdatePlaylists() {
        mpdState.mockPlaylistsClear()
        resetTestItem()
        const listCombo = findChild(testItem, 'listCombo')
        compare(listCombo.count, 0)
        mpdState.mockPlaylistsSet(3)
        compare(listCombo.count, 3)
        mpdState.mockPlaylistsClear()
        compare(listCombo.count, 0)
    }

    function test_comboBoxInitWithPlaylists() {
        mpdState.mockPlaylistsSet(2)
        resetTestItem()
        compare(findChild(testItem, 'listCombo').count, 2)
    }
}