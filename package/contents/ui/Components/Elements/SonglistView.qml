import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import "../../Components/Elements"

ListViewGeneric {
    id: root

    property var actionsHook

    function selectAll(state = true) {
        select(Array.from({length: model.count}, (v,i) => i), state)
    }

    function selectNeighborsByAlbum(song, index) {
        let positions = _getNeighbors(song, index, (a, b) => { return a.album === b.album })
        select(positions)
    }

    function selectNeighborsByAartist(song, index) {
        let positions = _getNeighbors(song, index, (a, b) => { return a.artist === b.artist })
        select(positions)
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
            model.setProperty(i, 'checked', true)
        }
    }

    function selectBelow(index) {
        for (let i = index + 1 ; i < model.count; i++) {
            model.setProperty(i, 'checked', true)
        }
    }

    function select(positions, state = true) {
        if (!Array.isArray(positions)) {
            throw new Error("Invalid argument: positions must be an array")
        }
        positions.forEach(function(position) {
            model.setProperty(position, 'checked', state)
        })
    }

    function getSelection() {
        let positions = []

        for (var i = 0; i < model.count; i++) {
            let song = model.get(i)
            if (song.checked === true ) {
                positions.push(i)
            }
        }

        return positions
    }

    function getSelectedPositionsMpdBased() {
        let positions = []

        for (var i = 0; i < model.count; i++) {
            let song = model.get(i)
            if (song.checked === true ) {
                positions.push(song.position)
            }
        }

        return positions
    }

    function removeSelection() {
        let positions = getSelection()

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

    // onCountChanged: {
    // }
    Connections {
        function onVisibleChanged() {
//            root.showCurrentItemInList()
        }

        target: appWindow
    }

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
                    listView.selectAll(false)
                }
            }
        }
    }
}
