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

    Keys.onPressed: (event) => {
        if (event.key == Qt.Key_A) {
            // if (event.modifiers & Qt.ControlModifier) {
                root.model.selectAll()

                event.accepted = true
                userInteracted()
            // }
        } else if (event.key == Qt.Key_B) {
            let state = !(event.modifiers & Qt.ShiftModifier)
            root.model.selectNeighborsByAlbum(model.get(root.currentIndex), root.currentIndex, state)

            userInteracted()
            event.accepted = true
        } else if (event.key == Qt.Key_V) {
            let state = !(event.modifiers & Qt.ShiftModifier)
            root.model.selectNeighborsByAartist(model.get(root.currentIndex), root.currentIndex, state)

            userInteracted()
            event.accepted = true
        }
    }

    Keys.onUpPressed: (event) => {
        if (root.currentIndex > 0) {
            if (event.modifiers & Qt.ShiftModifier) {
                root.model.select(root.currentIndex)
            }
            root.positionViewAtIndex(root.currentIndex, ListView.Contain)
            root.currentIndex--
        }

        if (event.modifiers && (Qt.ShiftModifier)) {
            root.model.select(root.currentIndex)
        }

        userInteracted()
        event.accepted = true
    }

    Keys.onDownPressed: (event) => {
        if (root.currentIndex < root.count - 1) {
            if (event.modifiers & Qt.ShiftModifier) {
                root.model.select(root.currentIndex)
            }
            root.positionViewAtIndex(root.currentIndex, ListView.Contain)
            root.currentIndex++
        }

        if (event.modifiers && Qt.ShiftModifier) {
            root.model.select(root.currentIndex)
        }

        userInteracted()
        event.accepted = true
    }

    Keys.onSpacePressed: (event) => {
        if (selectEndOfListDebounceTimer.running) {
            selectEndOfListDebounceTimer.restart()
            return
        } else {
            root.model.selectToggle(root.currentIndex)
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
        mpdState.playInQueue(position)
        userInteracted()
        event.accepted = true
    }

    Timer {
        id: selectEndOfListDebounceTimer
        interval: 400
    }

    model: SonglistSelectModel {}

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
                tooltip: qsTr("Replace Queue and Start Playing")
                icon.name: Mpdw.icons.queuePlay
                onTriggered: {
                    mpdState.replaceQueue(root.model.getSelectedFilesOrAll())
                }
            },
            Kirigami.Action {
                text: qsTr("Append")
                shortcut: "W"
                icon.name: Mpdw.icons.queueAppend
                tooltip: qsTr("Append to End of Queue")
                onTriggered: {
                    let songs = root.model.getSelectedFilesOrAll()
                    let callback = () => {
                        app.showPassiveNotification(qsTr("%n appended", "", songs.length),  Kirigami.Units.humanMoment)
                    }

                    mpdState.addSongsToQueue(songs, "append", callback)
                }

            },
            Kirigami.Action {
                text: qsTr("Insert")
                shortcut: "E"
                tooltip: qsTr("Insert After Current Song")
                icon.name: Mpdw.icons.queueInsert
                onTriggered: {
                    let songs = root.model.getSelectedFilesOrAll()
                    let callback = () => {
                        app.showPassiveNotification(qsTr("%n inserted", "", songs.length),  Kirigami.Units.humanMoment)
                    }
                    mpdState.addSongsToQueue(songs, "insert", callback)
                }
            }
        ]
        rightActions: [actionDeselect]
    }

    Kirigami.Action {
        id: actionDeselect

        readonly property string buttonText: qsTr("Deselect")

        text: win.narrowLayout ? "" : buttonText
        tooltip: qsTr("Deselect All")
        icon.name: Mpdw.icons.selectNone
        // Both queue and album pages can have the button at the same time. Only act
        // on the view visisble to the user.
        shortcut: root.activeFocus ? "Shift+A" : undefined
        onTriggered: root.model.deselectAll()
    }

    onCurrentIndexChanged: {
        forceActiveFocus(root.itemAtIndex(root.currentIndex))
    }
}
