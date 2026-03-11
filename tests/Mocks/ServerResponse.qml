import QtQuick

QtObject {
    signal dataChanged()

    function reset() {
        _playlistsReset()
        _libraryReset()

        return this
    }

    // #############################################
    // # Playlists - listplaylists
    // #############################################

    property var _mockPlaylists: []

    function playlistsCreate(numberOfItems) {
        for (let i = 0; i < numberOfItems; i++) {
            _mockPlaylists.push({playlist: `Pl ${i + 1}`})
        }

        dataChanged()
        return this
    }

    function playlistsGetResponse() {
        if (_mockPlaylists.length === 0) {
            return ""
        }

        return JSON.stringify(_mockPlaylists)
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
