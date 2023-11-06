import QtQuick
import org.kde.kirigami as Kirigami

ListModel {
    id: root


    /**
      * Keep the "position" on our end in sync with MPD expeded result
      *
      * @param {int} start position 0-based
      * @param {int} end position 0-based
      */
    // @TODO double still
    function updateMpdPositions(from = 0, to) {
        to = to || count - 1
        if (from === to) { return }

        let start = to < from ? to : from
        let end = to > from ? to : from

        for (let i = start; i <= end; i++) {
            root.model.set(i, {"position": i+1+""})
        }

        return
    }

    onRowsInserted: function(parent, first, last) {
        for(let i = first; i <= last; i++) {
            let data = {
                // Autoinitialize the checked property for item selection
                "checked": false,
                // MPD can giv us a song but has no information about it except
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

    onRowsMoved: {
        updateMpdPositions(start, row - 1)
    }
}
