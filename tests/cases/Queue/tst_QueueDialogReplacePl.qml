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

    function test_ComboBoxInitWithNoPlaylists() {
        mpdState.mpdPlaylists = []
        resetTestItem()
        const listCombo = findChild(testItem, 'listCombo')
        compare(listCombo.count, 0)
    }

    function test_ComboBoxUpdatePlaylists() {
        mpdState.mpdPlaylists = []
        resetTestItem()
        const listCombo = findChild(testItem, 'listCombo')
        compare(listCombo.count, 0)
        mpdState.mpdPlaylists = ['a', 'b', 'c']
        compare(listCombo.count, 3)
        mpdState.mpdPlaylists = []
        compare(listCombo.count, 0)
    }

    function test_ComboBoxInitWithPlaylists() {
        mpdState.mpdPlaylists = ['a', 'b']
        resetTestItem()
        compare(findChild(testItem, 'listCombo').count, 2)
    }
}