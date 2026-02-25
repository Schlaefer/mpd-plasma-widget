pragma ComponentBehavior: Bound

import QtQuick

/**
  * Augments ListModel with MPD specific features
  */
ListModel {
    id: root

    /**
      * Keep the "position" on our end in sync with MPD's item position
      *
      * @param {int} start position 0-based
      * @param {int} end position 0-based
      */
    function _updateMpdPositions(from = 0, to) {
        to = to || root.count - 1

        for (let i = from; i <= to; i++) {
            root.set(i, {"pos": i+""})
        }
    }

    onRowsInserted: function(parent, first, last) {
        for(let i = first; i <= last; i++) {
            let data = {
                // MPD can give us a song but has no information about it except
                // "file". This can happen if a file is listed in loaded
                // playlist but the actual file is missing on disk.
                "orphaned": false,
            }

            let insertedSong = root.get(i)
            if (insertedSong.time === "") {
                data.title = insertedSong.file
                data.orphaned = true
            }

            root.set(i, data)
        }
    }

    onRowsRemoved: function(parent, first, last) {
        // Only pass start, all positions from there on out changed on a row-remove.
        root._updateMpdPositions(first)
    }

    /**
     * Called when a row is moved
     *
     * @param {int} row - The moved rows are inserted *before* that index!
     */
    onRowsMoved: function(parent, start, end, destination, row) {
        // moved upwards → reverse order
        if (row < start) {
            let tmp = start
            start = row
            row = tmp
        }

        // Pass start and end because we only need to update positions that
        // are within the effected range
        root._updateMpdPositions(start, row)
    }
}
