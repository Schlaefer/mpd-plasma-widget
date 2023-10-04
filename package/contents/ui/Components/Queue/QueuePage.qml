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
                queueList.positionViewAtIndex(lastManipulatedItem,
                                              ListView.Center)
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
                backgroundColor: isQueueItem(
                                     model) ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor

                function isQueueItem(model) {
                    return (mpdState.mpdInfo.file == model.file)
                            && (mpdState.mpdInfo.position == model.position)
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
                                             queueList.model.move(oldIndex,
                                                                  newIndex, 1)
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
                        onToggled: {
                            if (checked) {
                                queueList.listManager.check(index)
                            } else {
                                queueList.listManager.uncheck(index)
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

                        onClicked: mouse => {
                                       if (mouse.button == Qt.LeftButton) {
                                        //    mpdState.playInQueue(model.position)
                                       }
                                       if (mouse.button == Qt.RightButton) {
                                           menu.visible ? menu.close(
                                                              ) : menu.popup()
                                       }
                                   }

                        Menu {
                            id: menu
                            MenuItem {
                                text: qsTr("Remove from Queue")
                                icon.name: "edit-delete"
                                onTriggered: {
                                    mpdState.removeFromQueue([model.position])
                                }
                            }
                            MenuSeparator {}
                            MenuItem {
                                text: qsTr("Select All")
                                // @TODO
                                // shortcut: "shift+v"
                                onTriggered: {
                                    queueList.listManager.checkAll(
                                                queueList.model)
                                    queueList.checkItems()
                                }
                            }
                            MenuItem {
                                text: qsTr("Deselect All")
                                // @TODO
                                // shortcut: "shift+v"
                                onTriggered: {
                                    queueList.listManager.reset()
                                    queueList.checkItems()
                                }
                            }
                            MenuSeparator {}
                            MenuItem {
                                text: qsTr('Select Neighbors by Album')
                                visible: !checkBox.checked
                                // @TODO Shortcut
                                // shortcut: "B"
                                onTriggered: {
                                    let albumItems = queueList.listManager.checkNeighboursAlbum(
                                            queueList.model, model, index)
                                    queueList.checkItems()
                                    itemPlaylistDialog.close()
                                }
                            }
                            MenuItem {
                                text: qsTr('Deselect Neighbors by Album')
                                visible: checkBox.checked
                                // @TODO Shortcut
                                // shortcut: "Shift+B"
                                onTriggered: {
                                    let albumItems = queueList.listManager.uncheckNeighboursAlbum(
                                            queueList.model, model, index)
                                    queueList.checkItems()
                                    itemPlaylistDialog.close()
                                }
                            }
                            MenuItem {
                                text: qsTr('Select Neighbors by Album-Artist')
                                visible: !checkBox.checked
                                // @TODO Shortcut
                                // shortcut: "B"
                                onTriggered: {
                                    let albumItems = queueList.listManager.checkNeighboursArtist(
                                            queueList.model, model, index)
                                    queueList.checkItems()
                                    itemPlaylistDialog.close()
                                }
                            }
                            MenuItem {
                                text: qsTr('Deselect Neighbors by Album-Artist')
                                visible: checkBox.checked
                                // @TODO Shortcut
                                // shortcut: "Shift+B"
                                onTriggered: {
                                    let albumItems = queueList.listManager.uncheckNeighboursArtist(
                                            queueList.model, model, index)
                                    queueList.checkItems()
                                    itemPlaylistDialog.close()
                                }
                            }
                            MenuSeparator {}
                            MenuItem {
                                text: qsTr('Select Songs Above')
                                onTriggered: {
                                    queueList.listManager.checkSongsAbove(
                                                queueList.model, index)
                                    queueList.checkItems()
                                    itemPlaylistDialog.close()
                                }
                                enabled: index > 0
                            }
                            MenuItem {
                                text: qsTr('Select Songs Below')
                                onTriggered: {
                                    queueList.listManager.checkSongsBelow(
                                                queueList.model, index)
                                    queueList.checkItems()
                                    itemPlaylistDialog.close()
                                }
                                enabled: index < queueList.count - 1
                            }
                        }

                        ColumnLayout {
                            spacing: 0

                            Row {
                                Label {
                                    height: Math.max(
                                                implicitHeight,
                                                Kirigami.Units.iconSizes.smallMedium)
                                    font.bold: true
                                    // @TODO i10n
                                    text: FormatHelpers.title(model)
                                    wrapMode: Text.Wrap
                                }
                                Label {
                                    height: Math.max(
                                                implicitHeight,
                                                Kirigami.Units.iconSizes.smallMedium)
                                    font.bold: listItem.isQueueItem(model)
                                    // @TODO i18n
                                    text: " - " + FormatHelpers.artist(model)
                                    wrapMode: Text.Wrap
                                }
                            }
                            Label {
                                Layout.fillWidth: true
                                height: Math.max(
                                            implicitHeight,
                                            Kirigami.Units.iconSizes.smallMedium)
                                font.bold: listItem.isQueueItem(model)
                                // @TODO i10n
                                text: model.album || ''
                                wrapMode: Text.Wrap
                            }
                        }
                    }
                }
            }
        }
    }

    footer: QueuePageFooter {}
}
