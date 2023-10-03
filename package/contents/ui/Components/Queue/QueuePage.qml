import "../../../scripts/formatHelpers.js" as FormatHelpers
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ScrollablePage {
    id: queuePage
    visible: false
    title: qsTr("Queue")
    Layout.fillWidth: true

    actions {
        main: Kirigami.Action {
            icon.name: "document-save-as"
            text: qsTr("Save Queue")
            tooltip: qsTr("Shift+S")
            checkable: true
            checked: queueDialogSave.visible
            shortcut: "shift+s"
            onTriggered: {
                queueDialogSave.open()
            }
        }
    }

    QueueDialogSave {
        id: queueDialogSave
    }

    ListView {
        id: queueList

        property int lastManipulatedItem: -1

        // Scroll without animation when active item changes
        highlightMoveDuration: 0

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
                    queueList.model.append(mpdState.mpdQueue[i])
                }
                queueList.showCurrentItemInList()
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
                alternatingBackground: true
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
                        icon.name: "view-media-playlist"
                        text: qsTr("Modify Playlist…")
                        onTriggered: {
                            itemPlaylistDialog.open()
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
                    Kirigami.ListItemDragHandle {
                        property int startIndex: -1
                        property int endIndex

                        Layout.preferredWidth: Kirigami.Units.iconSizes.huge

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

                    Image {
                        id: image

                        Layout.preferredHeight: 30
                        Layout.preferredWidth: 30
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

                    Label {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        height: Math.max(implicitHeight,
                                         Kirigami.Units.iconSizes.smallMedium)
                        font.bold: listItem.isQueueItem(model)
                        text: FormatHelpers.oneLine(model)
                        wrapMode: Text.Wrap

                        /*
                        MouseArea {
                            anchors.fill: parent
                            acceptedButtons: Qt.LeftButton | Qt.RightButton
                            onClicked: mouse => {
                                           if (mouse.button == Qt.LeftButton)
                                           parent.color = 'blue'
                                           else
                                           parent.color = 'red'
                                       }
                        }
                        */
                    }

                    QueueDialogItemPlaylist {
                        id: itemPlaylistDialog
                    }
                }
            }
        }
    }

    footer: QueuePageFooter {}
}
