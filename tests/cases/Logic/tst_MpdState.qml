import QtQuick
import QtTest
import "../../Mocks"

TestCase {
    property MpdStateMock testItem: MpdStateMock {
        id: mpdState
        cfgMpdHost: ""
        cfgMpdPort: ""
        scriptRoot: ""
    }

    function cleanup() {
        testItem.mockReset()
    }

    function test_getLibraryEmptyAlbumArtistAndArtist() {
        mpdState.r.libraryAddSong({title: "title"})
        compare(mpdState.library.getASongsByAartistPerAlbum("Unknown Artist").length, 1)
        compare(mpdState.library.getSongsOfAartist("Unknown Artist")[0].album, "Unknown Album")
        compare(mpdState.library.getSongsOfAartist("Unknown Artist")[0].albumartist, "Unknown Artist")
    }
}
