import QtQuick
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"

DynamicMenu {
    id: root

    property SonglistView parentView
    property bool showSearchActions: false

    signal searchLibrary(string term)

    Component.onCompleted: {
        if (showSearchActions) actions = actions.concat(_searchActions)
    }

    actions: [
        {
            text: qsTr('Select Album'),
            icon: Mpdw.icons.selectAlbum,
            shortcut: "B",
            handler: () => parentView.model.selectNeighborsByAlbum(model, index)
        },
        {
            text: qsTr('Select Album-Artist'),
            icon: Mpdw.icons.selectArtist,
            shortcut: "V",
            handler: () => parentView.model.selectNeighborsByAartist(model, index),
        },
        { separator: true },
        {
            text: qsTr('Select Above'),
            icon: Mpdw.icons.selectAbove,
            handler: () =>  parentView.model.selectAbove(index),
            enabled: index > 0,
        },
        {
            text: qsTr('Select Below'),
            icon: Mpdw.icons.selectBelow,
            handler: () => parentView.model.selectBelow(index),
            enabled: index < parentView.model.count - 1,
        },
        { separator: true },
        {
            text: qsTr("Select All"),
            icon: Mpdw.icons.selectAll,
            shortcut: "A",
            handler: () => parentView.model.selectAll(true),
        },
        {
            text: parentView.actionDeselect.buttonText,
            shortcut: parentView.actionDeselect.shortcut,
            handler: () => parentView.actionDeselect.onTriggered(),
        },
    ]

    property var _searchActions: [
        { separator: true },
        {
            text: qsTr("Search for Album"),
            icon: Mpdw.icons.appSearch,
            enabled: model.album,
            handler: () => root.searchLibrary(parentView.model.get(index).album),
        },
        {
            enabled: root.app,
            text: qsTr("Search for Album-Artist"),
            enabled: model.albumartist,
            handler: () => root.searchLibrary(parentView.model.get(index).albumartist)
        },
    ]
}
