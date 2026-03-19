pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"
import "../../../logic"

Kirigami.PageRow {
    id: root

    required property bool narrowLayout
    required property MpdState mpdState
    required property Kirigami.ApplicationItem app
    property PlaylistSongsPage _currentSubPage
    property bool _firstLoad: true

    signal searchLibrary(string term)

    // becoming true the first time triggers page data loading
    visible: false

    function search() {
        while (root.depth > 1) {
            root.pop()
        }
        navSearchField.forceActiveFocus()
    }

    initialPage: Kirigami.ScrollablePage {
        property int depth: 1

        visible: false
        title: qsTr("Playlists")

        Connections {
            target: root._currentSubPage
            function onSearchLibrary(term) {
                root.searchLibrary(term)
            }
        }

        globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
        header: ToolBar {
            RowLayout {
                anchors.fill: parent
                GlobalNav {
                    app: root.app
                    narrowLayout: root.narrowLayout
                }
                NavSearchField {
                    id: navSearchField
                    placeholder: qsTr("Search Playlists…")
                    tooltip: "Ctrl+Shift+F"
                    pageWidth: root.width
                    onEscapePressed: playlistList.forceActiveFocus()
                    onTabPressed: playlistList.forceActiveFocus()
                    onTextChanged: playlistList.populateModel(text)
                }
            }
        }

        Component {
            id: delegateComponentPlaylists

            SwipeListItemGeneric {
                id: listItemPlaylist
                required property string title
                width: playlistList.width - playlistList.leftMargin - playlistList.rightMargin // pushes action buttons away from under scrollbar

                onClicked: {
                    let properties =  {
                        "mpdState": root.mpdState,
                        "narrowLayout": Qt.binding(() => root.narrowLayout),
                        "pageStack": root,
                        "playlistId": listItemPlaylist.title,
                        "title": listItemPlaylist.title,
                    }
                    root._currentSubPage = root.push(Qt.resolvedUrl("PlaylistSongsPage.qml"), properties)
                }
                actions: [
                    Kirigami.Action {
                        icon.name: Mpdw.icons.queuePlay
                        tooltip: qsTr("Replace Queue and Start Playing")
                        onTriggered: {
                            root.mpdState.playPlaylist(listItemPlaylist.title)
                        }
                    },
                    Kirigami.Action {
                        icon.name: Mpdw.icons.queueAppend
                        tooltip: qsTr("Append to End of Queue")
                        onTriggered: {
                            let playlistTitle = listItemPlaylist.title
                            let callback = () => {
                                AppContext.notify(qsTr("Added playlist %1").arg(playlistTitle))
                            }
                            root.mpdState.loadPlaylist(playlistTitle, callback)
                        }
                    },
                    Kirigami.Action {
                        icon.name: Mpdw.icons.playlistDelete
                        tooltip: qsTr("Remove Playlist…")
                        onTriggered: {
                            deleteConfirmationDialog.itemTitle = listItemPlaylist.title
                            deleteConfirmationDialog.open()
                        }
                    }
                ]

                contentItem: RowLayout {
                    id: mainLayout

                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.rightMargin: listItemPlaylist.overlayWidth // margin for action buttons
                        verticalAlignment: Text.AlignVCenter
                        text: listItemPlaylist.title
                        wrapMode: Text.Wrap
                    }
                }
            }
        }

        DialogConfirm {
            id: deleteConfirmationDialog
            icon: Mpdw.icons.playlistDelete
            title: qsTr("Delete Playlist")
            label: qsTr("The following playlist will be deleted")
            buttonText: qsTr("Delete Playlist")

            onConfirmed: function () {
                root.mpdState.removePlaylist(itemTitle, (status) => {
                    if (status != 0) {
                        AppContext.notify(qsTr("Error deleting playlist").arg(itemTitle))
                    }
                })
                deleteConfirmationDialog.close()
            }
        }

        ListViewGeneric {
            id: playlistList
            objectName: "playlistsList"

            delegate: delegateComponentPlaylists

            function populateModel(searchTerm = ""){
                let playlists = root.mpdState.mpdPlaylists
                if (searchTerm) {
                    playlists = playlists.filter((title) => title.toLowerCase().match(searchTerm.toLowerCase()))
                }
                let i = 0
                for (i = 0; i < playlists.length; i++) {
                    const mpdTitle = playlists[i]
                    const ourTitle = model.get(i)?.title
                    if (ourTitle) {
                        if (mpdTitle === ourTitle) { continue }
                        model.remove(i)
                    }
                    model.insert(i, {"title": mpdTitle})
                }
                for (let k = model.count - 1; k >= i; k--) {
                    model.remove(k)
                }
            }

            Connections {
                target: root.mpdState
                function onMpdPlaylistsChanged() {
                    playlistList.populateModel()
                }
            }

            model: ListModel {}

            moveDisplaced: Transition {
                YAnimator {
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }

    onVisibleChanged: {
        if (!visible) return

        if (!_firstLoad) return
        _firstLoad = false

        if (root.mpdState.mpdPlaylists.length === 0) {
            root.mpdState.getPlaylists()
            return
        }
        playlistList.populateModel()
    }
}
