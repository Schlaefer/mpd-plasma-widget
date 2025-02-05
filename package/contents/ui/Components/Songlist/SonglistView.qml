import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"

ListViewGeneric {
    id: root

    // @TODO We only care about it on the QueuePage for the follow mode,
    // so this should be handled on the QueuePage only if possible.
    signal userInteracted()

    property alias actionDeselect: actionDeselect

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

            model.setProperty(index, "checked", state)
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

    function removeSelection() {
        let positions = getSelected()

        // removing from bottom otherwise the index of lower elements changes
        for (let i = positions.length - 1; i >= 0; i--) {
            model.remove(positions[i], 1)
        }
    }

    // @TODO rename; listen to model?
    function updateMpdPositions(from) {
        selected = []
        for (var i = 0; i < model.count; i++) {
            if (model.get(i).checked) {
                selected.push(i)
            }
            // @TODO still
            model.set(i, {"position": i+1+""})
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

    Keys.onPressed: (event) => {
        if (event.key == Qt.Key_A) {
            // if (event.modifiers & Qt.ControlModifier) {
                root.selectAll()

                event.accepted = true
                userInteracted()
            // }
        } else if (event.key == Qt.Key_B) {
            let state = !(event.modifiers & Qt.ShiftModifier)
            root.selectNeighborsByAlbum(model.get(root.currentIndex), root.currentIndex, state)

            userInteracted()
            event.accepted = true
        }
    }


    Keys.onUpPressed: (event) => {
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

    Keys.onDownPressed: (event) => {
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

    Keys.onSpacePressed: (event) => {
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

    Keys.onReturnPressed: (event) => {
        let position = model.get(root.currentIndex).pos
        mpdState.playInQueue(position - 1)
        userInteracted()
        event.accepted = true
    }

    Timer {
        id: selectEndOfListDebounceTimer
        interval: 400
    }

    model: SonglistModel {}

    moveDisplaced: Transition {
        YAnimator {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    headerPositioning: ListView.OverlayHeader
    header: SonglistHeader {
        leftActions: [
            Kirigami.Action {
                text: qsTr("Play")
                shortcut: "Q"
                enabled: root.activeFocus
                tooltip: qsTr("Replace Queue and Start Playing")
                icon.name: Mpdw.icons.queuePlay
                onTriggered: {
                    mpdState.replaceQueue(getSelectedFilesOrAll())
                }
            },
            Kirigami.Action {
                text: qsTr("Append")
                shortcut: "W"
                enabled: root.activeFocus
                icon.name: Mpdw.icons.queueAppend
                tooltip: qsTr("Append to End of Queue")
                onTriggered: {
                    mpdState.addSongsToQueue(getSelectedFilesOrAll())
                }

            },
            Kirigami.Action {
                text: qsTr("Insert")
                shortcut: "E"
                enabled: root.activeFocus
                tooltip: qsTr("Insert After Current Song")
                icon.name: Mpdw.icons.queueInsert
                onTriggered: {
                    mpdState.addSongsToQueue(getSelectedFilesOrAll(), "insert")
                }
            }
        ]
        rightActions: [actionDeselect]
    }

    Kirigami.Action {
        id: actionDeselect

        readonly property string buttonText: qsTr("Deselect")

        text: main.appWindow.narrowLayout ? "" : buttonText
        tooltip: qsTr("Deselect All")
        icon.name: Mpdw.icons.selectNone
        shortcut: "Shift+D"
        enabled: root.activeFocus
        onTriggered: root.deselectAll()
    }

    onCurrentIndexChanged: {
        forceActiveFocus(root.itemAtIndex(root.currentIndex))
    }
}
