class SongLibrary {
    constructor(library) {
        // Full library
        this._albums = this._buildLibrary(library)
        // Filtered library
        this._filteredAlbums = this._albums
    }

    getSongsByAartistAndAlbum(album, albumartist) {
        return this._filteredAlbums[albumartist][album]
    }

    getSongsOfAartist(aartist) {
        let songs = []
        for (const album in this._filteredAlbums[aartist]) {
            this._filteredAlbums[aartist][album].forEach(function (song) {
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
        for (const album in this._filteredAlbums[albumartist]) {
            songs.push(this._filteredAlbums[albumartist][album][0])
        }

        return this._songSorter(songs)
    }

    /**
     * Gets list of albumartists
     *  
     * @returns {array} List of albumartists
     */
    getAartists() {
        return Object.keys(this._filteredAlbums).sort((a, b) => {
            return a.toLowerCase() > b.toLowerCase() ? 1 : -1
        })
    }

    filterLibrary(searchText = "") {
        if (searchText === "") {
            this._filteredAlbums = this._albums
            return
        }

        let foundSongs = []

        searchText = searchText.toLowerCase()

        onAartistMatches:
        for (let aartist in this._albums) {
            if (aartist.toLowerCase().indexOf(searchText) !== -1) {
                for (let album in this._albums[aartist]) {
                    foundSongs = foundSongs.concat(this._albums[aartist][album])
                }
                continue onAartistMatches
            }

            onAlbumMatches:
            for (let album in this._albums[aartist]) {
                if (album.toLowerCase().indexOf(searchText) !== -1) {
                    foundSongs = foundSongs.concat(this._albums[aartist][album])
                    continue onAlbumMatches
                }

                for (let i = 0; i < this._albums[aartist][album].length; i++) {
                    if (this._albums[aartist][album][i].title && this._albums[aartist][album][i].title.toLowerCase().indexOf(searchText) !== -1) {
                        foundSongs.push(this._albums[aartist][album][i])
                    } else if (this._albums[aartist][album][i].genre && this._albums[aartist][album][i].genre.toLowerCase().indexOf(searchText) !== -1)  {
                        foundSongs.push(this._albums[aartist][album][i])
                    }
                }
            }
        }

        this._filteredAlbums = this._buildLibrary(foundSongs)
    }

    /**
     * Build library structure out of list of songs
     * 
     * @param {list} library list of songs
     * @returns library object {aartist1: {album1: [{song1}, ...], album2: [...]}, aartist2: ...}
     */
    _buildLibrary(library) {
        let tree = {}
        library.forEach(function(song) {
            if (song.directory || song.playlist) {
                return
            }

            if (!song.albumartist || !song.album) {
                return
            }
            if (!tree[song.albumartist]) {
                tree[song.albumartist] = {}
            }
            if (!tree[song.albumartist][song.album]) {
                tree[song.albumartist][song.album] = []
            }
            tree[song.albumartist][song.album].push(song)
        }, this)

        return tree
    }

    _songSorter(songs) {
        return songs.sort((a, b) => {
            if (a.date !== "" && b.date !== "") {
                let aDate = parseInt(a.date)
                let bDate = parseInt(b.date)
                if (aDate > bDate) return 1
                if (aDate < bDate) return -1
            }

            if (a.album && b.album) {
                let aAlbum = a.album.toLowerCase()
                let bAlbum = b.album.toLowerCase()
                if (aAlbum > bAlbum) return 1
                if (aAlbum < bAlbum) return -1
            }

            if (a.disc !== "" && b.disc !== "") {
                if (a.disc > b.disc) return 1
                if (a.disc < b.disc) return -1
            }

            if (a.track !== "" && b.track !== "") {
                let aTrack = a.track !== "" ? parseInt(a.track) : 0
                let bTrack = b.track !== "" ? parseInt(b.track) : 0

                if (aTrack > bTrack) return 1
                if (aTrack < bTrack) return -1
            }

            return 0
        })
    }
}
