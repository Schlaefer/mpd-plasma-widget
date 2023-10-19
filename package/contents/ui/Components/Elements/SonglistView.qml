import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import "../../Components/Elements"

ListViewGeneric {
    id: root

    signal userInteracted()

    property var actionsHook

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
    // @TODO do we really need it if we keep click without deselect?
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

            model.setProperty(index, "checked", state)
            selectLastSelected = state ? index : -1

            if (state) {
                selected.push(index)
            } else {
                selected.splice(existsAtPosition, 1)
            }
        }

        selected.sort(function(a, b) { return a - b; })
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

    function getSelected() {
        return selected;
    }

    function getSelectedPositionsMpdBased() {
        return getSelected().map(function(position) { return position + 1 })
    }

    function removeSelection() {
        let positions = getSelected()

        // removing from bottom otherwise the index of lower elements changes
        for (let i = positions.length - 1; i >= 0; i--) {
            model.remove(positions[i], 1)
        }
    }

    function updateMpdPositions() {
        for (var i = 0; i < model.count; i++) {
            let newPosition = i+1
            model.set(i, {"position": newPosition + ""})
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

    function centerInView(index) {
        songlistView.positionViewAtIndex(index, ListView.Center)
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_B) {
            let state = !(event.modifiers & Qt.ShiftModifier)
            root.selectNeighborsByAlbum(model.get(root.currentIndex), root.currentIndex, state)
        } else if (event.key === Qt.Key_D) {
            if (event.modifiers & Qt.ShiftModifier) {
                root.deselectAll()
            }
        } else if (event.key === Qt.Key_L) {
            centerInView()
        }
        event.accepted = true
    }


    Keys.onUpPressed: {
        if (root.currentIndex > 0) {
            if (event.modifiers & Qt.ShiftModifier) {
                root.select(root.currentIndex)
            }
            root.positionViewAtIndex(root.currentIndex, ListView.Contain)
            root.currentIndex--
        }

        if (event.modifiers && (Qt.ShiftModifier)) {
            root.select(root.currentIndex)
        }
        userInteracted()
        event.accepted = true
    }

    Keys.onDownPressed: {
        if (root.currentIndex < root.count - 1) {
            if (event.modifiers & Qt.ShiftModifier) {
                root.select(root.currentIndex)
            }
            root.positionViewAtIndex(root.currentIndex, ListView.Contain)
            root.currentIndex++
        }

        if (event.modifiers && Qt.ShiftModifier) {
            root.select(root.currentIndex)
        }
        userInteracted()
        event.accepted = true
    }

    Keys.onSpacePressed: {
        if (selectEndOfListDebounceTimer.running) {
            selectEndOfListDebounceTimer.restart()
            return
        } else {
            root.selectToggle(root.currentIndex)
        }

        if (root.currentIndex < root.count - 1) {
            root.positionViewAtIndex(root.currentIndex, ListView.Contain)
            root.currentIndex++
        } else {
            selectEndOfListDebounceTimer.start()
        }
        userInteracted()
        event.accepted = true
    }

    Keys.onReturnPressed: {
        let position = model.get(root.currentIndex).position
        mpdState.playInQueue(position)
        userInteracted()
        event.accepted = true
    }

    Timer {
        id: selectEndOfListDebounceTimer
        interval: 400
    }

    // onCountChanged: {
    // }

    model: ListModel {
        /**
          * Keep the "position" on our end in sync with MPD expeded result
          *
          * @param {int} start position 0-based
          * @param {int} end position 0-based
          */
        function updatePositionAfterMove(from, to) {
            if (from === to) { return }
            let start = to < from ? to : from
            let end = to > from ? to : from
            for (let i = start; i <= end; i++) {
                root.model.set(i, {"position": i+1+""})
            }
        }
    }

    moveDisplaced: Transition {
        YAnimator {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Component.onCompleted: {
        if (actionsHook) {
            let menu = contextualMenuItems.createObject(actionsHook.parent)
            // @SOMEDAY why is that not working adding items to the Queue menu in queue?
//            actionsHook.push(menu.children[0])
            actionsHook.push(menu)
        }
    }

    Component {
        id: contextualMenuItems

        Kirigami.Action {
            text: qsTr("Songs")
            Kirigami.Action {
                text:  qsTr("Replace Queue")
                icon.name: "media-play-playback"
                onTriggered: {
                    mpdState.replaceQueue(getSelectedFilesOrAll())
                }
            }
            Kirigami.Action {
                separator: true
            }
            Kirigami.Action {
                text: qsTr("Append to Queue")
                icon.name: "media-playlist-append"
                onTriggered: {
                    mpdState.addSongsToQueue(getSelectedFilesOrAll())
                }

            }
            Kirigami.Action {
                text: qsTr("Insert After Current")
                icon.name: "timeline-insert"
                onTriggered: {
                    mpdState.addSongsToQueue(getSelectedFilesOrAll(), "insert")
                }
            }
            Kirigami.Action {
                separator: true
            }
            Kirigami.Action {
                text: qsTr("Select All")
                icon.name: "edit-select-all-symbolic"
                onTriggered: {
                    listView.selectAll()
                }
            }
            Kirigami.Action {
                text: qsTr("Deselect All")
                onTriggered: {
                    listView.deselectAll()
                }
            }
        }
    }
}
