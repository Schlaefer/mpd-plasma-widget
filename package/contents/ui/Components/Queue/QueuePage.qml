import "../../../scripts/formatHelpers.js" as FormatHelpers
import "../../../scripts/listManager.js" as ListManager
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import "../Elements"

Kirigami.ScrollablePage {
    id: queuePage
    visible: false
    title: qsTr("Queue")
    Layout.fillWidth: true

    actions {
        contextualActions: [
            Kirigami.Action {
                text: qsTr("Queue…")
                icon.name: "media-playback-playing"

                Kirigami.Action {
                    icon.name: "document-save-as"
                    text: qsTr("Save Queue")
                    tooltip: qsTr("Shift+S")
                    shortcut: "shift+s"
                    onTriggered: {
                        queueDialogSave.open()
                    }
                }
                Kirigami.Action {
                    icon.name: "document-replace"
                    text: qsTr("Replace Playlist")
                    // tooltip: qsTr("Shift+S")
                    // shortcut: "shift+s"
                    onTriggered: {
                        queueDialogReplacePl.open()
                    }
                }
                Kirigami.Action {
                    separator: true
                }
                Kirigami.Action {
                    text: qsTr("Clear Queue")
                    icon.name: "bqm-remove"
                    tooltip: qsTr("C")
                    shortcut: "c"
                    onTriggered: {
                        mpdState.clearPlaylist()
                    }
                }
            },
            Kirigami.Action {
                text: qsTr("Selected Items…")
                icon.name: "checkbox"

                Kirigami.Action {
                    text: qsTr("Remove From Queue")
                    icon.name: "bqm-remove"
                    shortcut: "del"
                    onTriggered: {
                        let items = queueList.listManager.getCheckedMpd()
                        mpdState.removeFromQueue(items)
                    }
                }
            }
        ]
    }

    QueueDialogSave {
        id: queueDialogSave
    }
    QueueDialogReplacePl {
        id: queueDialogReplacePl
    }

    ListView {
        id: queueList

        property int lastManipulatedItem: -1
        property var listManager: new ListManager.ListManager()

        // Scroll without animation when active item changes
        highlightMoveDuration: 0

        function checkItems() {
            let items = queueList.listManager.getChecked()
            for (var i = 0; i < model.count; i++) {
                model.setProperty(i, 'checked', items.indexOf(i) > -1)
            }
        }

        function showCurrentItemInList() {
            if (!appWindow.visible) {
                return
            }
            if (lastManipulatedItem !== -1) {
                // @SOMEDAY The list redraw usually destroys or scrolling postion. Better than nothing
                queueList.positionViewAtIndex(lastManipulatedItem, ListView.Center)
                // @SOMEDAY better highlight of item
                queueList.currentIndex = lastManipulatedItem
                lastManipulatedItem = -1
                return
            }
            let i
            for (i = 0; i < model.count; i++) {
                if (model.get(i).file == mpdState.mpdFile) {
                    break
                }
            }
            queueList.positionViewAtIndex(i, ListView.Center)
            queueList.currentIndex = i
        }

        // onCountChanged: {
        // }
        Connections {
            function onVisibleChanged() {
                queueList.showCurrentItemInList()
            }

            target: appWindow
        }

        Connections {
            function onMpdQueueChanged() {
                queueList.model.clear()
                for (let i in mpdState.mpdQueue) {
                    let item = mpdState.mpdQueue[i]
                    item.checked = false
                    queueList.model.append(item)
                }
                queueList.showCurrentItemInList()
                // @SOMEDAY That implementation is beyond my paygrade
                // Note that ListView keeps the items checked otherwise, which could
                // be usefull for an future implentation.
                queueList.listManager.reset()
                queueList.checkItems()
            }
            target: mpdState
        }

        model: ListModel {}

        delegate: Item {
            width: queueList.width
            implicitHeight: listItem.implicitHeight

            Kirigami.SwipeListItem {
                id: listItem
                // width: ListView.view ? ListView.view.width : implicitWidth
                width: queueList.width
                // alternatingBackground: true
                alternateBackgroundColor: isQueueItem(
                                              model) ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
                backgroundColor: isQueueItem(model) ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor

                function isQueueItem(model) {
                    return (mpdState.mpdInfo.file == model.file) && (mpdState.mpdInfo.position == model.position)
                }

                actions: [
                    Kirigami.Action {
                        icon.name: "media-playback-start"
                        text: qsTr("Play Now")
                        onTriggered: {
                            mpdState.playInQueue(model.position)
                        }
                    },
                    Kirigami.Action {
                        icon.name: "edit-delete"
                        text: qsTr("Remove from Queue")
                        onTriggered: {
                            mpdState.removeFromQueue([model.position])
                            // @TODO
                            // queueList.lastManipulatedItem = index
                        }
                    }
                ]

                RowLayout {
                    width: queueList.width
                    Kirigami.ListItemDragHandle {
                        property int startIndex: -1
                        property int endIndex

                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium

                        listItem: listItem
                        listView: queueList
                        onMoveRequested: (oldIndex, newIndex) => {
                                             if (startIndex === -1) {
                                                 startIndex = oldIndex
                                             }
                                             endIndex = newIndex
                                             queueList.model.move(oldIndex, newIndex, 1)
                                         }
                        onDropped: {
                            queueList.lastManipulatedItem = endIndex
                            mpdState.moveInQueue(startIndex + 1, endIndex + 1)
                            startIndex = index
                        }
                    }

                    CheckBox {
                        id: checkBox
                        text: model.name
                        checked: model.checked
                        onCheckedChanged: {
                            if (checked) {
                                queueList.listManager.check(index)
                                model.checked = true
                            } else {
                                queueList.listManager.uncheck(index)
                                model.checked = false
                            }
                        }
                    }

                    Image {
                        id: image

                        Layout.preferredHeight: Kirigami.Units.iconSizes.medium
                        Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                        mipmap: true
                        fillMode: Image.PreserveAspectFit

                        function setCover(coverPath) {
                            if (coverPath === null) {
                                return false
                            }
                            image.source = coverPath
                        }

                        function onGotCover(id) {
                            // @BOGUS Why did we do that? What's happening here?
                            if (typeof (coverManager) === "undefined") {
                                return
                            }
                            if (coverManager.getId(model) !== id) {
                                return
                            }
                            getCover()
                        }

                        function getCover() {
                            let cover = coverManager.getCover(model)
                            if (typeof (cover) === 'undefined') {
                                return false
                            }
                            coverManager.gotCover.disconnect(onGotCover)
                            setCover(cover)
                        }

                        Component.onCompleted: {
                            let cover = coverManager.getCover(model)
                            if (cover) {
                                setCover(cover)

                                return
                            }
                            coverManager.gotCover.connect(onGotCover)
                        }
                    }

                    MouseArea {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        acceptedButtons: Qt.LeftButton | Qt.RightButton

                        onClicked: function (mouse) {
                            if (mouse.button == Qt.LeftButton) {
                                model.checked = !model.checked
                            }
                            if (mouse.button == Qt.RightButton) {
                                contextMenu.visible ? contextMenu.close() : contextMenu.popup()
                            }
                        }

                        Menu {
                            id: contextMenu
                            MenuItem {
                                text: qsTr("Select All")
                                // @SOMEDAY shortcut
                                onTriggered: {
                                    queueList.listManager.checkAll(queueList.model)
                                    queueList.checkItems()
                                }
                            }
                            MenuItem {
                                text: qsTr("Deselect All")
                                // @SOMEDAY shortcut
                                onTriggered: {
                                    queueList.listManager.reset()
                                    queueList.checkItems()
                                }
                            }
                            MenuSeparator {}
                            MenuItem {
                                text: qsTr('Select Neighbors by Album')
                                visible: !checkBox.checked
                                // @SOMEDAY shortcut
                                onTriggered: {
                                    let albumItems = queueList.listManager.checkNeighboursAlbum(queueList.model,
                                                                                                model, index)
                                    queueList.checkItems()
                                }
                            }
                            MenuItem {
                                text: qsTr('Deselect Neighbors by Album')
                                visible: checkBox.checked
                                // @SOMEDAY shortcut
                                onTriggered: {
                                    let albumItems = queueList.listManager.uncheckNeighboursAlbum(queueList.model,
                                                                                                  model, index)
                                    queueList.checkItems()
                                }
                            }
                            MenuItem {
                                text: qsTr('Select Neighbors by Album-Artist')
                                visible: !checkBox.checked
                                // @SOMEDAY shortcut
                                onTriggered: {
                                    let albumItems = queueList.listManager.checkNeighboursArtist(queueList.model,
                                                                                                 model, index)
                                    queueList.checkItems()
                                }
                            }
                            MenuItem {
                                text: qsTr('Deselect Neighbors by Album-Artist')
                                visible: checkBox.checked
                                // @SOMEDAY shortcut
                                onTriggered: {
                                    let albumItems = queueList.listManager.uncheckNeighboursArtist(queueList.model,
                                                                                                   model, index)
                                    queueList.checkItems()
                                }
                            }
                            MenuSeparator {}
                            MenuItem {
                                text: qsTr('Select Songs Above')
                                // @SOMEDAY shortcut
                                onTriggered: {
                                    queueList.listManager.checkSongsAbove(queueList.model, index)
                                    queueList.checkItems()
                                }
                                enabled: index > 0
                            }
                            MenuItem {
                                text: qsTr('Select Songs Below')
                                // @SOMEDAY shortcut
                                onTriggered: {
                                    queueList.listManager.checkSongsBelow(queueList.model, index)
                                    queueList.checkItems()
                                }
                                enabled: index < queueList.count - 1
                            }
                        }

                        ColumnLayout {
                            spacing: 0
                            // @TODO text doesn't wrap
                            Row {
                                Layout.leftMargin: Kirigami.Units.largeSpacing

                                Label {
                                    // @SOMEDAY i10n
                                    text: model.tracknumber + '. '
                                    wrapMode: Text.Wrap
                                }
                                Label {
                                    font.bold: true
                                    // @SOMEDAY i10n
                                    text: model.title
                                    wrapMode: Text.Wrap
                                }
                                Label {
                                    font.bold: listItem.isQueueItem(model)
                                    // @SOMEDAY i18n
                                    text: " - " + FormatHelpers.artist(model)
                                    wrapMode: Text.Wrap
                                }
                            }
                            Row {
                                Layout.leftMargin: Kirigami.Units.largeSpacing

                                Label {
                                    font.bold: listItem.isQueueItem(model)
                                    // @SOMEDAY i10n
                                    text: model.album || ''
                                    wrapMode: Text.Wrap
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: " (" + model.time + ")"
                                    font.bold: listItem.isQueueItem(model)
                                    // font.italic: true
                                    // @SOMEDAY i10n
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    footer: QueuePageFooter {}
}
