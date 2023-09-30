import "../scripts/formatHelpers.js" as FormatHelpers
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ScrollablePage {
    id: queuePage
    visible: false
    title: qsTr("Queue")

    Component {
        id: delegateComponent

        Kirigami.SwipeListItem {
            id: listItem
            width: ListView.view ? ListView.view.width : implicitWidth
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
                    icon.name: "edit-delete"
                    text: qsTr("Remove from Queue")
                    onTriggered: {
                        mpdState.removeFromQueue(model.position)
                    }
                }
            ]

            contentItem: RowLayout {
                RowLayout {
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

                        function onGotCover(coverPath) {
                            // @BOGUS Why did we do that? What's happening here?
                            if (typeof (coverManager) === "undefined") {
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
                        height: Math.max(implicitHeight,
                                         Kirigami.Units.iconSizes.smallMedium)
                        font.bold: isQueueItem(model)
                        text: FormatHelpers.oneLine(model)
                        wrapMode: Text.Wrap
                    }
                }
            }
        }
    }

    ListView {
        id: queueList

        delegate: delegateComponent

        // Scroll without animation when active item changes
        highlightMoveDuration: 0

        function showCurrentItemInList() {
            if (!appWindow.visible) {
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
    }

    footer: WidgetQueueFooter {}
}
