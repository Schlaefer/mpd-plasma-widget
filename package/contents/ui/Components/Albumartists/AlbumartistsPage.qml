import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../Mpdw.js" as Mpdw
import "../../Components/Elements"

Kirigami.ScrollablePage {
    id: root

    property int depth: 1
    property string shownAlbumartist

    property alias searchField: searchField
    property alias viewState: controller.viewState

    visible: false

    AlbumartistsController { id: controller }

    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    header: QQC2.ToolBar {
        RowLayout {
            anchors.fill: parent
            GlobalNav { }
            QQC2.ToolButton {
                id: shuffleBtn
                icon.name: Mpdw.icons.queueRandom
                checkable: true
                checked: controller.viewState === "shuffle"
                onClicked: checked ? controller.viewState = "shuffle" : controller.viewState = "normal"
                QQC2.ToolTip {
                    text: qsTr("Suggest")
                }
            }
            RowLayout {
                Layout.alignment: Qt.AlignRight
                Layout.rightMargin: Kirigami.Units.smallSpacing
                Kirigami.SearchField {
                    id: searchField
                    // Per default the text field is stuck at 200 width and cut off at
                    // small sizes
                    implicitWidth: root.width > 400 ? 200 : (root.width/2) - (10000/root.width)
                    placeholderText: qsTr("Search…")
                    onTextChanged: controller.searchTerm = text

                    // Don't double navigate in search field (left, right) and
                    // list view (up, down) at the same time.
                    Keys.onUpPressed: (event) => { event.accepted = true }
                    Keys.onDownPressed: (event) => { event.accepted = true }
                    Keys.onTabPressed: (event) => { listView.forceActiveFocus() }

                    // Disable default Ctrl+F behavior
                    focusSequence: undefined
                    Keys.onEscapePressed: (event) => {
                        if (searchField.text.length > 0) {
                            searchField.text = ""
                        } else {
                            controller.viewState = "normal"
                        }
                        event.accepted = true
                    }
                }
            }
        }
    }

    ListViewGeneric {
        id: listView

        model: ListModel { }

        delegate: SwipeListItemGeneric {
            id: listItemPlaylist

            required property string albumartist

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

                    shownAlbumartist = listItemPlaylist.albumartist
                    let properties = {
                        "depth": root.depth + 1,
                        "songs": mpdState.library.getSongsOfAartist(listItemPlaylist.albumartist),
                        "title": listItemPlaylist.albumartist,
                    }
                    app.pageStack.push(Qt.resolvedUrl("AlbumartistSongsPage.qml"), properties)
                }

                Loader {
                    id: artistContextMenuLoader
                    property var getSongs: function () {
                        return mpdState.library.getSongsOfAartist(listItemPlaylist.albumartist)
                    }
                }

                RowLayout {
                    id: mainLayout
                    // Layout.fillWidth: true
                    anchors.fill: parent

                    QQC2.Label {
                        Layout.fillWidth: true
                        text: listItemPlaylist.albumartist
                        wrapMode: Text.Wrap
                        Layout.alignment: Qt.AlignVCenter
                    }

                    GridLayout {
                        columns: win.narrowLayout ? 4 : 6
                        rows: win.narrowLayout ? 1 : -1

                        Layout.alignment: Qt.AlignRight

                        Repeater {
                            id: images
                            model: ListModel {}
                            delegate: ListCoverimage {
                                id: image
                                loadingPriority: 200

                                // Move picture inside the automatic Kirigami
                                // mouse hover highlight
                                Layout.rightMargin: Kirigami.Units.smallSpacing

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
                                            app.pageStack.push(Qt.resolvedUrl("AlbumartistSongsPage.qml"),
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
                            let songs = mpdState.library.getASongsByAartistPerAlbum(listItemPlaylist.albumartist)
                            songs.forEach(function (song) {
                                images.model.append(song)
                            })
                        }
                    }
                }
            }
        }
    }

    Component {
        id: contextMenuComponent
        // PlasmaComponent.Menu creates wierd transparency and border?
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
                    let callback = function() {
                        showPassiveNotification(qsTr("%n appended", "", songs.length),  Kirigami.Units.humanMoment)
                    }

                    mpdState.addSongsToQueue(songs.map(song => song.file), "append", callback)
                }
            }
            QQC2.MenuItem {
                text: qsTr("Insert")
                icon.name:Mpdw.icons.queueInsert
                onTriggered: {
                    let songs = getSongs()
                    let callback = function() {
                        showPassiveNotification(qsTr("%n inserted", "", songs.length),  Kirigami.Units.humanMoment)
                    }
                    mpdState.addSongsToQueue(songs.map(song => song.file), "insert", callback)
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
