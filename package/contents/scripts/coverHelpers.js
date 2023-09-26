.pragma library

/**
 * Implements a simple priority queue
 */
class FetchQueue {
    constructor() {
        this._queue = {}
    }

    /**
     * Adds item to the queue 
     * 
     * @param {string} id ID for the queue item
     * @param {*} data Data for the item
     * @param {int} priority Priority in the queue (the lower the number the higher the priority)
     */
    add(id, data, priority) {
        this._queue[id] = {
            // Looks silly. But alas sometimes if you just do a "data: data" it will
            // store the whole queue-item as empty and therefore undefined. Don't know
            // why. Looks like there could be an issue if the key is a file-ID instead
            // of the album?? -  Spend to much time on it already. This works.
            data: {
                "file": data.file,
                "album": data.album
            },
            priority: priority
        }
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
        keys.forEach(key => {
            if (!nextItem) {
                nextItem = this._queue[key]
            }
            else {
                if (this._queue[key].priority > nextItem.priority) {
                    nextItem = this._queue[key]
                }
            }
        }, this)

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

    /**
     * Checks if queue has item with ID 
     * 
     * @param {string} id 
     * @returns 
     */
    has(id) {
        return id in this._queue
    }
}
