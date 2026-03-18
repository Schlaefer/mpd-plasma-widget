pragma ComponentBehavior: Bound

import QtQuick
import org.kde.kirigami as Kirigami

import "../../../logic"

Item {
    id: root

    property bool active
    required property MpdState mpdState
    required property Kirigami.PageRow pageStack
    required property ListView view
    property string viewState: "normal"
    property string searchTerm: ""

    /**
      * Populates list model with hits according ot search field content
      *
      * @param {string} searchtext
      */
    function filter() {
        root.view.model.clear()
        root.mpdState.library.filterLibrary(searchTerm)
        let hits = root.mpdState.library.getAartists(searchTerm)
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
            searchTerm.text = ""
            shuffle()
            root.view.positionViewAtIndex(0, ListView.Beginning)
            break
        case "search":
            while (pageStack.depth > 1) {
                pageStack.pop()
            }
            break
        case "subpage":
            break
        case "normal":
        default:
            searchTerm.text = ""
            filter()
            root.view.positionViewAtIndex(0, ListView.Beginning)
            root.view.forceActiveFocus()
        }
    }

    onSearchTermChanged: {
        filter()
    }

    Connections {
        target: root.mpdState
        function onLibraryChanged() {
            if (root.mpdState.library) {
                root.filter()
            }
        }
    }

    onActiveChanged: {
        if (!active) return
        if (!root.mpdState.library) {
            root.mpdState.getLibrary()
            return
        }
        root.filter()
    }
}
