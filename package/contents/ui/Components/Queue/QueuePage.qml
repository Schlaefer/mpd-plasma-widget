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

                /**
                 * Song is the currenty playing/paused item in the queue
                 */
                property bool isCurrentQueuePosition: mpdState.mpdInfo.position === model.position

                width: queueList.width ? queueList.width : implicitWidth
                backgroundColor: isCurrentQueuePosition ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor

                actions: [
                    Kirigami.Action {
                        property bool isPlaying: (listItem.isCurrentQueuePosition && mpdState.mpdPlaying)
                        icon.name: isPlaying ? "media-playback-pause" : "media-playback-start"
                        text: qsTr("Play Now")
                        onTriggered: {
                            if (isPlaying) {
                                mpdState.toggle()
                            } else {
                                mpdState.playInQueue(model.position)
                            }
                        }
                    },
                    Kirigami.Action {
                        icon.name: "edit-delete"
                        text: qsTr("Remove from Queue")
                        visible: appWindow.width > appWindow.simpleLayoutBreakpoint
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
                        visible: appWindow.width > appWindow.simpleLayoutBreakpoint

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
                        visible: appWindow.width > appWindow.simpleLayoutBreakpoint
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

                        Layout.preferredHeight: Kirigami.Units.iconSizes.large
                        Layout.preferredWidth: Kirigami.Units.iconSizes.large
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

                    // We need a layout-"anchor" for the MouseArea *and* to allow
                    // fillWide-aware word-wrap on the text fields
                    ColumnLayout {
                        id: mouseAreaAnchor
                        spacing: 0
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        ColumnLayout {
                            spacing: 0
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                Layout.rightMargin: Kirigami.Units.largeSpacing
                                color: Kirigami.Theme.textColor
                                font.bold: true
                                text: model.title
                                wrapMode: Text.WordWrap
                            }
                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                Layout.rightMargin: Kirigami.Units.largeSpacing
                                color: Kirigami.Theme.textColor
                                font.bold: listItem.isCurrentQueuePosition
                                text: FormatHelpers.artist(model)
                                wrapMode: Text.WordWrap
                            }

                            Text {
                                Layout.fillWidth: true
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                Layout.rightMargin: Kirigami.Units.largeSpacing
                                color: Kirigami.Theme.textColor
                                font.bold: listItem.isCurrentQueuePosition
                                text: FormatHelpers.queueAlbumLine(model)
                                wrapMode: Text.WordWrap
                            }
                        }

                        MouseArea {
                            height: mouseAreaAnchor.height
                            width: mouseAreaAnchor.width

                            acceptedButtons: Qt.LeftButton | Qt.RightButton

                            onClicked: function (mouse) {
                                if (mouse.button == Qt.LeftButton) {
                                    model.checked = !model.checked
                                }
                                if (mouse.button == Qt.RightButton) {
                                    menuLoader.source = "QueueContextMenu.qml"
                                    menuLoader.item.visible ? menuLoader.item.close() : menuLoader.item.popup()
                                }
                            }
                        }

                        Loader {
                            id: menuLoader
                        }
                    }
                }
            }
        }
    }

    footer: QueuePageFooter {}
}
