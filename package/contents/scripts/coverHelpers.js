.pragma library

class FetchQueue {
    constructor() {
        this._queue = {}
    }

    add(id, data, priority) {
        this._queue[id] = {
            data: data,
            priority: priority
        }
    }

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

    delete(id) {
        delete this._queue[id]
    }

    has(id) {
        return id in this._queue
    }
}