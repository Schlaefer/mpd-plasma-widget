import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami

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


    onRowsMoved: {
        updateMpdPositions(start, row)
    }
}
