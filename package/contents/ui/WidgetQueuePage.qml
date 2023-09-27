import "../scripts/formatHelpers.js" as FormatHelpers
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ScrollablePage {
    id: queuePage

    property var mpd
    property var coverManager

    visible: false
    title: qsTr("Queue")

    Component {
        id: delegateComponent

        Kirigami.SwipeListItem {
            id: listItem

            width: ListView.view ? ListView.view.width : implicitWidth
            alternatingBackground: true
            alternateBackgroundColor: mpd.mpdFile == model.file ? Kirigami.Theme.highlightColor : Kirigami.Theme.alternateBackgroundColor
            backgroundColor: mpd.mpdFile == model.file ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor

            actions: [
                Kirigami.Action {
                    icon.name: "media-playback-start"
                    text: qsTr("Play Now")
                    onTriggered: {
                        mpd.playInQueue(model.position)
                    }
                },
                Kirigami.Action {
                    icon.name: "edit-delete"
                    text: qsTr("Remove from Queue")
                    onTriggered: {
                        mpd.removeFromQueue(model.position)
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
                            if (!coverManager) {
                                return
                            }
                            let cover = queuePage.coverManager.getCover(model)
                            if (typeof (cover) === 'undefined') {
                                return false
                            }
                            queuePage.coverManager.gotCover.disconnect(
                                        onGotCover)
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
                        font.bold: mpd.mpdFile == model.file ? true : false
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

        Connections {
            function onMpdQueueChanged() {
                queueList.model.clear()
                for (let i in mpdState.mpdQueue) {
                    queueList.model.append(mpdState.mpdQueue[i])
                }
            }

            target: mpd
        }

        model: ListModel {}
    }

    footer: WidgetQueueFooter {
        mpd: queuePage.mpd
    }
}
