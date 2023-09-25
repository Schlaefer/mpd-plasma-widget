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
            data: data,
            priority: priority
        }
    }

    /**
     * Returns the next item in the queue by highest priority
     * 
     * @TODO queue ID is implicit only by a data property handled elsewhere(tm)
     * 
     * @returns Data of the item in the queue
     */
    next() {
        let keys = Object.keys(this._queue);
        if (!keys || keys.length === 0)
            return false;

        let nextItem
        keys.forEach(key => {
            if (!nextItem)
                nextItem = this._queue[key]
            else {
                if (this._queue[key].priority > nextItem.priority)
                    nextItem = this._queue[key]
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