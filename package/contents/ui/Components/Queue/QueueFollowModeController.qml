import QtQuick
import "../../Components/Songlist"

/**
 * Manages the "Follow Mode" that keeps the currently playing songs highlighted
 */
Item {
    id: root

    property SonglistView listView
    property int currentPosition: -1
    property bool autoMode: true
    property bool viewReady: false

    // A scrolling is happening because of our showCurrent
    property bool _ourScrolling: false

    function showCurrent() {
        if (!viewReady || currentPosition === -1 || !autoMode) {
            return
        }

        _ourScrolling = true
        root.listView.currentIndex = currentPosition
        root.listView.positionViewAtIndex(currentPosition, ListView.Center)
        // I'm not sure if setting this here and now is an async problem.
        // Seems to work though.
        _ourScrolling = false
    }

    Timer {
        id: disableFollowOnEditTimer
        interval: 120000
        onTriggered: {
            root.autoMode = true
            root.showCurrent()
        }
    }

    // Scrolling is considered user interaction
    function onContentYChanged() {
        if (!viewReady) return
        // Don't react on our own showCurrent scrolling
        if (_ourScrolling) {
            return
        }

        // List initialization emits scroll events, we ignore those
        if (listView.count === 0) {
            return
        }

        if (autoMode || disableFollowOnEditTimer.running) {
            autoMode = false
            disableFollowOnEditTimer.restart()
        }
    }

    // Everything the list view indicated as user interaction
    function onUserInteracted() {
        if (!viewReady) return
        if (autoMode || disableFollowOnEditTimer.running) {
            autoMode = false
            disableFollowOnEditTimer.restart()
        }
    }

    Component.onCompleted: {
        listView.visible = false
        win.frameSwapped.connect(onFirstDrawnFrame)
    }

    function onFirstDrawnFrame() {
        win.frameSwapped.disconnect(onFirstDrawnFrame)
        root.viewReady = true
        root.showCurrent()
        listView.visible = true
    }

    // Debug
    // onAutoModeChanged: {
    //     console.log("Queue Follow Mode autoMode changed to:", autoMode)
    // }
}
