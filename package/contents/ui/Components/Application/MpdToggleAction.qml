pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami
import "../../../logic"

Kirigami.Action {
    id: root

    required property string mpdOption
    required property MpdState mpdState

    function update() {
        // This catches us getting our own cmd replied, so don't act on it.
        let localState = root.mpdState[root.mpdOption]
        if (root.checked === localState) {
            return
        }
        root.checked = root.mpdState[root.mpdOption]
    }

    onCheckedChanged: {
        let localState = root.mpdState[root.mpdOption]
        if (root.checked === localState) {
            return
        }
        root.triggered()
    }

    Component.onCompleted: {
        const option = root.mpdOption
        const connection = option.charAt(0).toUpperCase() + option.slice(1)
        mpdState["on" + connection + "Changed"].connect(update)
        update()
    }
}
