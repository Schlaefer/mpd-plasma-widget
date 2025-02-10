import QtQuick

/**
  * Implements selection via "checked" model property
  */
SonglistModel {
    id: root

    /**
      * Last selected item
      *
      * Used for selecting ranges.
      */
    property int selectLastSelected: -1

    /**
      * List of the currently selected items
      *
      * Mostly for performance so we don't have to constantly query all models
      */
    property var selected: []

    /**
      * Set selection state of an list-item
      *
      * This shall be the only place actually changing the model data
      *
      * @param {int|array} indices Index or list of indices
      * @param {bool} state select (true, default) or deselect (false)
      */
    function select(indices, state = true) {
        if (Number.isInteger(indices)) {
            indices = [indices]
        }
        if (!Array.isArray(indices)) {
            throw new Error("Invalid argument: indices must be an int or array")
        }

        for (let i = indices.length - 1; i >= 0; i--) {
            let index = indices[i]
            var existsAtPosition = selected.indexOf(index)
            if ((existsAtPosition > -1 && state) || (existsAtPosition === -1 && !state)) {
                continue
            }

            root.setProperty(index, "checked", state)
            selectLastSelected = state ? index : -1

            if (state) {
                selected.push(index)
            } else {
                selected.splice(existsAtPosition, 1)
            }
        }

        selected.sort(function(a, b) { return a - b; })
        selectedChanged()
    }

    function selectToggle(index) {
        let newState = !model.get(index).checked
        select(index, newState)
    }

    function selectAll() {
        select(Array.from({length: model.count}, (v,i) => i), true)
    }

    function deselectAll() {
        if (selected.length === 0) {
            return
        }
        select(selected, false)
    }

    function selectTo(to) {
        if (selectLastSelected === -1 || selectLastSelected === to) {
            return
        }
        if (to > selectLastSelected) {
            for (var i = selectLastSelected; i <= to; i++) {
                select(i)
            }
        } else {
            for (var k = selectLastSelected; k >= to; k--) {
                select(k)
            }
        }
    }

    function selectNeighborsByAlbum(song, index, state = true) {
        let positions = _getNeighbors(song, index, (a, b) => { return a.album === b.album })
        select(positions, state)
    }

    function selectNeighborsByAartist(song, index, state = true) {
        let positions = _getNeighbors(song, index, (a, b) => { return a.albumartist === b.albumartist })
        select(positions, state)
    }

    function _getNeighbors(song, index, comparator) {
        let found = [index]
        // find previous
        var i
        for (i = index - 1; i >= 0; i--) {
            var mdl = model.get(i)
            if (comparator(song, mdl)) {
                found.push(i)
            } else {
                break
            }
        }
        // find next
        for (i = index + 1; i < model.count; i++) {
            let mdl = model.get(i)
            if (comparator(song, mdl)) {
                found.push(i)
            } else {
                break
            }
        }

        found.sort(function (a, b) {
            return a - b;
        })

        return found
    }

    function selectAbove(index) {
        for (let i = 0; i < index; i++) {
            select(i)
        }
    }

    function selectBelow(index) {
        for (let i = index + 1 ; i < model.count; i++) {
            select(i)
        }
    }

    function getSelectedSongs() {
        return selected.map(function(index) { return model.get(index) })
    }

    function getSelected() {
        return selected;
    }

    /**
      * Remove selected items from selection
      */
    function selectedRemove() {
        let positions = getSelected()

        // removing from bottom otherwise the index of lower elements changes
        for (let i = positions.length - 1; i >= 0; i--) {
            model.remove(positions[i], 1)
        }
    }

    /**
      * Get all the selected files in the list or all if none is selected
      *
      * @return {array} selected files
      */
    function getSelectedFilesOrAll() {
        let files = []
        var i

        for (i = 0; i < model.count; i++) {
            let song = model.get(i)
            if (song.checked === true ) {
                files.push(song.file)
            }
        }

        if (files.length === 0) {
            for (i = 0; i < model.count; i++) {
                files.push(model.get(i).file)
            }
        }

        return files
    }

    function _updateSelectPositions(from) {
        let newSelected = []
        for (var i = 0; i < model.count; i++) {
            if (model.get(i).checked) {
                newSelected.push(i)
            }
        }
        // There are listeners on selected, but for some reason the
        // onSelectedChanged() signal is not properly triggered automatically (as it
        // should) if we manipulate selected in the for loop above. So we set selected
        // only *once* here, which always triggers properly.
        //
        // Test case:
        // 1. Select an item on the queue
        // 2. Hit "Remove" trashcan-button on other item
        // 3. Check if the SonglistView "Remove" button in header is still active
        selected = newSelected
    }

    onRowsInserted: function (parent, first, last) {
        for (var i = first; i <= last; i++) {
            let data = {
                // Autoinitialize the checked property for item selection
                "checked": false,
            }
            root.set(i, data)
        }
    }

    onRowsRemoved: function(parent, first, last) {
        _updateSelectPositions()
    }
}
