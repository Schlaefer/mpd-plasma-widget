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

        const search = searchText.toLowerCase()
        const albumsByArtist = this._albums;

        for (const aartist in this._albums) {
            const aartistLower = aartist.toLowerCase()
            const aartistAlbums = albumsByArtist[aartist]; 

            if (aartistLower.includes(search)) {
                for (const album in aartistAlbums) {
                    foundSongs.push(...aartistAlbums[album])
                }
                continue
            }

            for (const album in aartistAlbums) {
               const albumLower = album.toLowerCase(); 
               const songs = aartistAlbums[album];

                if (albumLower.includes(search)) {
                    foundSongs.push(...songs)
                    continue
                }
                for (let i = 0; i < songs.length; i++) {
                    const song = songs[i]

                    const title = song.title
                    if (title && title.toLowerCase().includes(search)) {
                        foundSongs.push(song);
                        continue
                    }

                    const genre = song.genre
                    if (genre && genre.toLowerCase().includes(search)) {
                        foundSongs.push(song);
                        continue
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
