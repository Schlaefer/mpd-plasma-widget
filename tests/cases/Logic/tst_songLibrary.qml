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

    function test_getLibrarySortingYear() {
        mpdState.r.libraryAddSong({title: "1", track: "1", date: "1995", albumartist: "A", album: "B"})
        mpdState.r.libraryAddSong({title: "2", track: "2", date: "1996", albumartist: "A", album: "B"})
        mpdState.r.libraryAddSong({title: "3", track: "3", date: "1995", albumartist: "A", album: "B"})

        mpdState.r.libraryAddSong({title: "1", track: "1", date: "1994", albumartist: "A", album: "C"})
        mpdState.r.libraryAddSong({title: "2", track: "2", date: "1994", albumartist: "A", album: "C"})
        mpdState.r.libraryAddSong({title: "3", track: "3", date: "1994", albumartist: "A", album: "C"})

        const songs = mpdState.library.getSongsOfAartist("A")

        compare(songs[0].album, "C")
        compare(songs[1].album, "C")
        compare(songs[2].album, "C")
        compare(songs[0].title, "1")
        compare(songs[1].title, "2")
        compare(songs[2].title, "3")

        compare(songs[3].album, "B")
        compare(songs[4].album, "B")
        compare(songs[5].album, "B")
        compare(songs[3].title, "1")
        compare(songs[4].title, "2")
        compare(songs[5].title, "3")
    }

    function test_getLibraryEmptyAlbumArtistAndArtist() {
        mpdState.r.libraryAddSong({title: "title"})
        compare(mpdState.library.getASongsByAartistPerAlbum("Unknown Artist").length, 1)
        compare(mpdState.library.getSongsOfAartist("Unknown Artist")[0].album, "Unknown Album")
        compare(mpdState.library.getSongsOfAartist("Unknown Artist")[0].albumartist, "Unknown Artist")
    }
}
