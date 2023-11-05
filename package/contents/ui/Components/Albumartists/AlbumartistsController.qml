import QtQuick 2.15

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
            searchField.forceActiveFocus()
            searchField.selectAll()
            viewState: "search"
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
