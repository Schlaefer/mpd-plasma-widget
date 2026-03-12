import QtQuick
import QtTest
import "../../Mocks"

TestCase {
    name: "MpdState"

    property MpdStateMock testItem: MpdStateMock {
        id: mpdState
        cfgMpdHost: ""
        cfgMpdPort: ""
        scriptRoot: ""
    }

    function cleanup() {
        testItem.mockReset()
    }

    SignalSpy {
        id: gotPlaylistSpy
        target: mpdState
        signalName: "gotPlaylist"
    }

    function test_getPlaylistEmptyPlaylist() {
        mpdState.r.playlistsCreate(1)
        compare(gotPlaylistSpy.count, 0)
        const pl = mpdState.getPlaylist('Pl 1')
        compare(gotPlaylistSpy.count, 1)
        compare(gotPlaylistSpy.signalArguments[0][0], [])
    }
}
