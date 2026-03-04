pragma ComponentBehavior: Bound

import QtQuick

import "../../../logic"

Item {
    id: root

    required property MpdState mpdState
    required property ListView view
    property string viewState: "normal"
    property string searchTerm: ""

    /**
      * Populates list model with hits according ot search field content
      *
      * @param {string} searchtext
      */
    function filter(searchText = "") {
        root.view.model.clear()
        root.mpdState.library.filterLibrary(searchText)
        let hits = root.mpdState.library.getAartists(searchText)
        hits.forEach((hit) => { root.view.model.append({"albumartist": hit}) })
    }

    function shuffle() {
        root.view.model.clear()
        root.mpdState.library.filterLibrary()
        let hits = root.mpdState.library.getAartists()
        hits.sort((a, b) => { return Math.floor(Math.random() * 2) > 0 ? 1 : -1 })
        hits.forEach(hit => { root.view.model.append({ "albumartist": hit }) })
    }

    onViewStateChanged: {
        switch (viewState) {
        case "shuffle":
            searchField.text = ""
            shuffle()
            root.view.positionViewAtIndex(0, ListView.Beginning)
            break
        case "startSearch":
            searchField.forceActiveFocus()
            break
        case "search":
            break
        case "normal":
        default:
            searchField.text = ""
            filter()
            root.view.positionViewAtIndex(0, ListView.Beginning)
            root.view.forceActiveFocus()
        }
    }

    onSearchTermChanged: {
        if (searchTerm !== "") {
            viewState = "search"
        }
        filter(searchTerm)
    }

    Connections {
        target: root.mpdState
        function onLibraryChanged() {
            if (root.mpdState.library) {
                root.filter()
            }
        }
    }

    Component.onCompleted: {
        root.mpdState.registerClient()
        if (root.mpdState.library) {
            filter()
        }
        root.mpdState.getLibrary()
        return
    }

    Component.onDestruction: {
        // onDestruction is triggered when main.qml destroys the window
        root.mpdState.unregisterClient()
    }
}
