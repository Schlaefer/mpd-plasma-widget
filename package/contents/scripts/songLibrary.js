class SongLibrary {
    constructor(library) {
        this._albums = {}
        this._lastSearchHits = []

        this._buildAlbums(library)
    }

    _buildAlbums(library) {
        library.forEach(song => {
            if (!song.albumartist || !song.album) {
                return
            }
            if (!this._albums[song.albumartist]) {
                this._albums[song.albumartist] = {}
            }
            if (!this._albums[song.albumartist][song.album]) {
                this._albums[song.albumartist][song.album] = []
            }
            this._albums[song.albumartist][song.album].push(song)
        }, this)
    }

    getSongsByAartistAndAlbum(album, albumartist) {
        return this._albums[albumartist][album]
    }

    getSongsOfAartist(aartist) {
        let songs = []
        for (const album in this._albums[aartist]) {
            this._albums[aartist][album].forEach(function (song) {
                songs.push(song)
            })
        }
        return songs
    }

    /**
     * Returns one(!) song for every album of the aartist
     *  
     * @param {string} albumartist 
     * @returns {array} of songs
     */
    getASongsByAartistPerAlbum(albumartist) {
        let songs = []
        for (const album in this._albums[albumartist]) {
            songs.push(this._albums[albumartist][album][0])
        }

        return songs
    }

    /**
     * Searches albumartist, album and title for a search term
     *  
     * @param {string} searchText text to search for
     * @returns {array} List of albumartists
     */
    searchAlbumartists(searchText = "") {
        if (searchText === "") {
            return this.getAlbumartists()
        }

        let found = []
        searchText = searchText.toLowerCase()

        onFound:
        for (const aartist in this._albums) {
            if (aartist.toLowerCase().indexOf(searchText) !== -1) {
                found.push(aartist)
                continue onFound
            }
            for (const album in this._albums[aartist]) {
                if (album.toLowerCase().indexOf(searchText) !== -1) {
                    found.push(aartist)
                    continue onFound
                }

                for (let i = 0; i < this._albums[aartist][album].length; i++) {
                    if (this._albums[aartist][album][i].title.toLowerCase().indexOf(searchText) !== -1) {
                        found.push(aartist)
                        continue onFound
                    }
                }
            }
        }

        return found
    }

    getAlbumartists() {
        return Object.keys(this._albums)
    }
}
