/**
 * Implements a simple priority queue
 */
class FetchQueue {
    constructor() {
        this._queue = {}
        // this._debug = true
    }

    /**
     * Adds item to the queue 
     * 
     * @param {string} id ID for the queue item
     * @param {*} data Data for the item
     * @param {int} priority Priority in the queue (the lower the number the higher the priority)
     */
    add(id, data, priority) {
        // @BOGUS only happens on actual plasma desktop, never in the simulator
        if (typeof(data) === 'undefined') {
            return
        }
        if (this._queue[id]) {
            if(this._queue[id].priority > priority) {
                // Existing item has become higher priority
                this._debugMsg(`Increased priority ${id} from ${this._queue[id].priority} to ${priority}`)
                this._queue[id].priority = priority
            }
            // Item already exists
            this._debugMsg(`Item ${id} already exists.`)
            return
        }

        this._queue[id] = {
            // Looks silly. But alas sometimes if you just do a "data: data" it will
            // store the whole queue-item as empty and therefore undefined. Don't know
            // why. Looks like there could be an issue if the key is a file-ID instead
            // of the album?? - Spend to much time on it already. This works.
            data: {
                "album": data.album,
                "albumartist": data.albumartist,
                "artist": data.artist,
                "file": data.file,
            },
            priority: priority
        }
        this._debugMsg(`Added ${id} with priority ${priority}`)
    }

    /**
     * Returns the next item in the queue by highest priority
     * 
     * @returns Data of the item in the queue
     */
    next() {
        let keys = Object.keys(this._queue);
        if (!keys || keys.length === 0)
            return false;

        let nextItem
        // let nextItem = this._queue[keys[0]]
        keys.forEach(key => {
            if (!nextItem) {
                nextItem = this._queue[key]
            }
            else {
                if (this._queue[key].priority < nextItem.priority) {
                    nextItem = this._queue[key]
                }
            }
        }, this)

        this._debugMsg(`next() returned ${nextItem.data.file} with priority ${nextItem.priority}`)
        return nextItem.data
    }

    /**
     * Deletes item from queue 
     * 
     * @param {string} id Id in queue
     */
    delete(id) {
        delete this._queue[id]
    }

    _debugMsg(msg) {
        if (!this._debug) {
            return
        }
        console.log("FetchQueue - " + msg)
    }
}
