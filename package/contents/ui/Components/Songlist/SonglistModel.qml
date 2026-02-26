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
        if (row < start) {
            // Draging upwards → reverse order
            let tmp = start
            start = row
            row = tmp
        } else {
            // Draging downwards
            //
            // Dragging Song 1 down gives a start of 0 but a row (target) value of 2.
            // But since Song 2 moves up at the same time the changed rows are the
            // postions 0,1 and not 0,1,2. Without correction this creates a phantom
            // entry at the bottom of the list when an item is dragged to be the last
            // in the list.
            //
            //                  Drag                 Result
            //              ┌───────────┐         ┌───────────┐
            // Position 0   │   Song 1  ├───┐     │   Song 2  │
            //              └───────────┘   │     └───────────┘
            //              ┌───────────┐   │     ┌───────────┐
            // Position 1   │   Song 2  │   │     │   Song 1  │
            //              └───────────┘   │     └───────────┘
            //                              │
            // Position 2               ◀──┘
            //
            row = row - 1
        }

        // Pass start and end because we only need to update positions that
        // are within the effected range
        root._updateMpdPositions(start, row)
    }
}
