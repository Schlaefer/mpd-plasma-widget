import QtQuick

Item {
    id: root

    property string viewState: "normal"
    property string searchTerm: ""

    /**
      * Populates list model with hits according ot search field content
      *
      * @param {string} searchtext
      */
    function filter(searchText = "") {
        listView.model.clear()
        mpdState.library.filterLibrary(searchText)
        let hits = mpdState.library.getAartists(searchText)
        hits.forEach((hit) => { listView.model.append({"albumartist": hit}) })
    }

    function shuffle() {
        listView.model.clear()
        mpdState.library.filterLibrary()
        let hits = mpdState.library.getAartists()
        hits.sort((a, b) => { return Math.floor(Math.random() * 2) > 0 ? 1 : -1 })
        hits.forEach(hit => { listView.model.append({ "albumartist": hit }) })
    }

    onViewStateChanged: {
        switch (viewState) {
        case "shuffle":
            searchField.text = ""
            shuffle()
            listView.positionViewAtIndex(0, ListView.Beginning)
            break
        case "startSearch":
            searchFieldFocusTimer.start()
            break
        case "search":
            break
        case "normal":
        default:
            searchField.text = ""
            filter()
            listView.positionViewAtIndex(0, ListView.Beginning)
            listView.forceActiveFocus()
        }
    }

    // @BOGUS We wait here for starting up and immediately switching from Queue to
    // Artists, which is still being drawn.
    Timer {
        id: searchFieldFocusTimer
        interval: 1
        onTriggered: {
            searchField.forceActiveFocus()
            searchField.selectAll()
            viewState: "search"
        }
    }

    onSearchTermChanged: {
        if (searchTerm !== "") {
            viewState = "search"
        }
        filter(searchTerm)
    }

    Connections {
        target: mpdState
        function onLibraryChanged() { filter() }
    }

    Component.onCompleted: {
        mpdState.getLibrary()
    }
}
