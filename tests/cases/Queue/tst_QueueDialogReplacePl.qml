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

    function cleanup() {
        mpdState.mockReset()
    }

    function initTestItem() {
        testItem = createTemporaryObject(Qt.createComponent(
            "../../../package/contents/ui/Components/Queue/QueueDialogReplacePl.qml"),
            null,
            { mpdState: mpdState })
    }

    function test_comboBoxInitWithNoPlaylists() {
        initTestItem()
        const listCombo = findChild(testItem, 'listCombo')
        compare(listCombo.count, 0)
    }

    function test_comboBoxUpdatePlaylists() {
        mpdState.r.playlistsCreate(3)
        initTestItem()
        const listCombo = findChild(testItem, 'listCombo')
        compare(listCombo.count, 3)
        mpdState.mockReset()
        compare(listCombo.count, 0)
    }

    function test_comboBoxInitWithPlaylists() {
        mpdState.r.playlistsCreate(2)
        initTestItem()
        compare(findChild(testItem, 'listCombo').count, 2)
    }
}
