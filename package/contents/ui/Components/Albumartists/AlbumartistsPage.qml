import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"

Kirigami.ScrollablePage {
    id: root

    property int depth: 1
    property string shownAlbumartist
    readonly property string globalShortcut: "2"

    visible: false

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    header: QQC2.ToolBar {
        RowLayout {
            anchors.fill: parent
            GlobalNav { }
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: Kirigami.Units.gritUnit
                Kirigami.SearchField {
                    id: searchField
                    // Per default the text field is stuck at 200 width and cut off at
                    // small sizes
                    implicitWidth: root.width > 400 ? 200 : root.width / 2
                    placeholderText: qsTr("Search…")
                    onTextChanged: listView.filter(text)

                    Keys.onEscapePressed: {
                        if (searchField.text) {
                            searchField.text = ""
                        } else {
                            listView.forceActiveFocus()
                        }
                    }
                    Shortcut {
                        sequence: StandardKey.Find
                        onActivated: {
                            if (!searchField.visible) {
                                appWindow.showPage(albumartistsPage)
                            }
                            searchField.forceActiveFocus()
                        }
                    }
                }
            }
        }
    }

    ListViewGeneric {
        id: listView


        /**
          * Populates list model with hits according ot search field content
          *
          * @param {string} searchtext
          */
        function filter(searchText = "") {
            if (searchText) {
                searchText = searchText.toLowerCase()
            }

            model.clear()
            let hits = mpdState.library.searchAlbumartists(searchText)
            hits.forEach(hit => {
                             let item = {
                                 "albumartist": hit
                             }
                             model.append(item)
                         })
        }

        model: ListModel {
            id: model
        }

        delegate: SwipeListItemGeneric {
            id: listItemPlaylist

            width: ListView.view ? ListView.view.width : implicitWidth


            contentItem: MouseArea {
                implicitHeight: mainLayout.implicitHeight
                implicitWidth: mainLayout.implicitWidth

                acceptedButtons: Qt.LeftButton | Qt.RightButton
                onClicked: function (mouse) {
                    if (mouse.button === Qt.RightButton) {
                        if (!artistContextMenuLoader.item) {
                            artistContextMenuLoader.sourceComponent = contextMenuComponent
                        }
                        if (!artistContextMenuLoader.item.visible) {
                            artistContextMenuLoader.item.popup()
                        }

                        return
                    }

                    shownAlbumartist = model.albumartist
                    let properties = {
                        "depth": root.depth + 1,
                        "songs": mpdState.library.getSongsOfAartist(model.albumartist),
                        "title": model.albumartist,
                    }
                    appWindow.pageStack.push(Qt.resolvedUrl("AlbumartistSongsPage.qml"), properties)
                }

                Loader {
                    id: artistContextMenuLoader
                    property var getSongs: function () {
                        return mpdState.library.getSongsOfAartist(model.albumartist)
                    }
                }

                RowLayout {
                    id: mainLayout
                    // Layout.fillWidth: true
                    anchors.fill: parent
                    QQC2.Label {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        text: model.albumartist
                        wrapMode: Text.Wrap
                    }

                    GridLayout {
                        columns: appWindow.narrowLayout ? 4 : 6
                        rows: appWindow.narrowLayout ? 1 : -1

                        Layout.alignment: Qt.AlignRight
                        Repeater {
                            id: images
                            model: ListModel {}
                            delegate: ListCoverimage {
                                id: image
                                loadingPriority: 200

                                QQC2.ToolTip {
                                    text: model.album
                                    delay: -1
                                    visible: mouseArea.containsMouse
                                }

                                MouseArea {
                                    id: mouseArea
                                    hoverEnabled: true
                                    anchors.fill: image
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                                    onClicked: {
                                        if (mouse.button == Qt.LeftButton) {
                                            let properties = {
                                                "depth": root.depth + 1,
                                                "songs": mpdState.library.getSongsByAartistAndAlbum(
                                                             model.album,
                                                             model.albumartist),
                                                // @i18n
                                                "title": model.album + " - " + model.albumartist,
                                            }
                                            appWindow.pageStack.push(Qt.resolvedUrl("AlbumartistSongsPage.qml"),
                                                                     properties)
                                        } else if (mouse.button == Qt.RightButton) {
                                            if (!contextMenuLoader.item) {
                                                contextMenuLoader.sourceComponent = contextMenuComponent
                                            }
                                            if (!contextMenuLoader.item.visible) {
                                                contextMenuLoader.item.popup()
                                            }
                                        }
                                    }

                                    Loader {
                                        id: contextMenuLoader
                                        property var getSongs: function () {
                                            return mpdState.library.getSongsByAartistAndAlbum(model.album,
                                                                                              model.albumartist)
                                        }
                                    }
                                }
                            }
                        }

                        Component.onCompleted: {
                            let songs = mpdState.library.getASongsByAartistPerAlbum(model.albumartist)
                            songs.forEach(function (song) {
                                images.model.append(song)
                            })
                        }
                    }
                }
            }
        }

        Connections {
            target: mpdState
            function onLibraryChanged() {
                listView.filter()
            }
        }

        Component.onCompleted: {
            mpdState.getLibrary()
        }
    }

    Component {
        id: contextMenuComponent
        QQC2.Menu {
            id: contextMenu
            QQC2.MenuItem {
                icon.name: Mpdw.icons.queuePlay
                text: qsTr("Play")
                onTriggered: {
                    let songs = getSongs()
                    mpdState.replaceQueue(songs.map(song => song.file))
                }
            }
            QQC2.MenuSeparator {}
            QQC2.MenuItem {
                text: qsTr("Append")
                icon.name: Mpdw.icons.queueAppend
                onTriggered: {
                    let songs = getSongs()
                    mpdState.addSongsToQueue(songs.map(song => song.file))
                }
            }
            QQC2.MenuItem {
                text: qsTr("Insert")
                icon.name:Mpdw.icons.queueInsert
                onTriggered: {
                    let songs = getSongs()
                    mpdState.addSongsToQueue(songs.map(song => song.file), "insert")
                }
            }
        }

    }


    /*
    // @FEATURE figure out how to keep the second column visible in width layout
    Timer {
        id: fooTimer
        interval: 0
        onTriggered: {
            appWindow.pageStack.push(Qt.resolvedUrl("AlbumartistSongsPage.qml"), {
                                           "depth": root.depth + 1,
                                           "songs": root.songs
                                       })
        }
    }

    onVisibleChanged: {
        if (visible && shownAlbumartist) {
            if (appWindow.width > 720) {
                fooTimer.start()
            }
        }
    }
    */
}
