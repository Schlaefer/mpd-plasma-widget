class SongLibrary {
    constructor(library) {
        this._albums = {}

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
        return this._songSorter(songs)
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

        return this._songSorter(songs)
    }

    _songSorter(songs) {
        return songs.sort((a, b) => {
            if (a.date !== "" && b.date !== "") {
                let aDate = parseInt(a.date)
                let bDate = parseInt(b.date)
                if (aDate > bDate) return 1
                if (aDate < bDate) return -1
            }

            let aAlbum = a.album.toLowerCase()
            let bAlbum = b.album.toLowerCase()
            if (aAlbum > bAlbum) return 1
            if (aAlbum < bAlbum) return -1

            if (a.tracknumber !== "" && b.tracknumber !== "") {
                let aTrack = a.tracknumber !== "" ? parseInt(a.tracknumber) : 0
                let bTrack = b.tracknumber !== "" ? parseInt(b.tracknumber) : 0

                if (aTrack > bTrack) return 1
                if (aTrack < bTrack) return -1
            }

            return 0
        })
    }

    /**
     * Searches albumartist, album and title for a search term
     *  
     * @param {string} searchText text to search for
     * @returns {array} List of albumartists
     */
    searchAlbumartists(searchText = "") {
        let found = []

        if (searchText === "") {
            found = Object.keys(this._albums)
        } else {
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
        }

        found.sort((a, b) => {
            return a.toLowerCase() > b.toLowerCase() ? 1 : -1
        })

        return found
    }
}
