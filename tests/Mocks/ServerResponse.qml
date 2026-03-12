import QtQuick

QtObject {
    signal dataChanged()

    function reset() {
        _playlistsReset()
        _libraryReset()

        return this
    }

    // #############################################
    // # Playlists
    // #############################################

    property var _mockPlaylists: []

    function playlistsCreate(numberOfItems) {
        for (let i = 0; i < numberOfItems; i++) {
            _mockPlaylists.push({playlist: `Pl ${i + 1}`, songs: []})
        }

        dataChanged()
        return this
    }

    // listplaylists
    function playlistsGetResponse(): string {
        if (_mockPlaylists.length === 0) return ""
        return JSON.stringify(_mockPlaylists.map(p => ({ playlist: p.playlist })))
    }

    // listplaylistinfo
    function playlistGetResponse(title: string): string {
        const songs = _mockPlaylists.find(pl => pl.playlist === title).songs
        if (songs.length === 0) return ""
        return JSON.stringify(songs)
    }

    function _playlistsReset() {
        _mockPlaylists = []
    }

    // #############################################
    // # Song Library - listallinfo
    // #############################################

    property var _mockLibary: []

    function libraryAddSong(song) {
        _mockLibary = _mockLibary.concat(song)

        dataChanged()
        return this
    }

    function libraryGetResponse() {
        return JSON.stringify(_mockLibary)
    }

    function _libraryReset() {
        _mockLibary = []
    }
}
