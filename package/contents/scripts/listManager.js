class ListManager {
    constructor() {
        this._checked = []
        // this._debug = true
    }

    reset() {
        this._checked = []
    }

    check(index) {
        this._checked.push(index)
        this._debugMsg("check(" + index + ")")
    }

    checkAll(models) {
        this._checked = Array.from(Array(models.count).keys())
    }

    uncheck(index) {
        let currentIndex = this._checked.indexOf(index)
        if (currentIndex > -1) {
            this._checked.splice(currentIndex, 1)
        }
        this._debugMsg("Uncheck: " + index)
    }

    checkNeighboursArtist(models, model, index) {
        this._checked.push(...this._getNeighboursArtist(models, model, index))
    }

    uncheckNeighboursArtist(models, model, index) {
        let found = this._getNeighboursArtist(models, model, index)
        this._checked = this._checked.filter((el) => !found.includes(el))
    }

    checkNeighboursAlbum(models, model, index) {
        this._checked.push(...this._getNeighboursAlbum(models, model, index))
    }

    uncheckNeighboursAlbum(models, model, index) {
        let found = this._getNeighboursAlbum(models, model, index)
        this._checked = this._checked.filter((el) => !found.includes(el))
    }

    _getNeighboursArtist(models, model, index) {
        return this._getNeighbours(models, model, index, (a, b) => { return a.albumartist === b.albumartist })
    }

    _getNeighboursAlbum(models, model, index) {
        return this._getNeighbours(models, model, index, (a, b) => { return a.album === b.album })
    }

    _getNeighbours(models, model, index, comparator) {
        let found = [index]
        // find previous
        for (let i = index - 1; i >= 0; i--) {
            let mdl = models.get(i)
            if (comparator(model, mdl)) {
                found.push(i)
            } else {
                break
            }
        }
        // find next
        for (let i = index + 1; i < models.count; i++) {
            let mdl = models.get(i)
            if (comparator(model, mdl)) {
                found.push(i)
            } else {
                break
            }
        }

        found.sort(function (a, b) {
            return a - b;
        })

        this._debugMsg("_getNeighbours found: " + JSON.stringify(found))
        return found
    }

    checkSongsAbove(models, index) {
        let found = []
        for (let i = 0; i < index; i++) {
            found.push(i)
        }
        this._debugMsg("checkSongsAbove: " + JSON.stringify(found))
        this._checked.push(...found)
    }

    checkSongsBelow(models, index) {
        let found = []
        for (let i = index + 1 ; i < models.count; i++) {
            found.push(i)
        }
        this._debugMsg("checkSongsBelow: " + JSON.stringify(found))
        this._checked.push(...found)
    }

    getChecked() {
        this._debugMsg("getChecked: " + JSON.stringify(this._checked))
        return [...new Set(this._checked)]
    }

    /**
     * Returns checked items in mpd's index-1-based
     *  
     * @returns {array}
     */
    getCheckedMpd() {
        let items = this.getChecked().map(item => { return item + 1 })
        this._debugMsg(items)
        return items
    }

    _debugMsg(msg) {
        if (!this._debug) {
            return
        }
        console.log("ListManager - " + msg)
    }
}
