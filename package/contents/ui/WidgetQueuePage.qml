import "../scripts/formatHelpers.js" as FormatHelpers
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ScrollablePage {
    id: queuePage

    property var mpd

    visible: false
    title: qsTr("Queue")

    Component {
        id: delegateComponent

        Kirigami.SwipeListItem {
            id: listItem

            alternatingBackground: true
            backgroundColor: mpd.mpdFile == model.file ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
            width: ListView.view ? ListView.view.width : implicitWidth
            onClicked: {
            }
            actions: [
                Kirigami.Action {
                    icon.name: "media-play"
                    text: "Play Now"
                    onTriggered: {
                        mpd.playInQueue(model.position);
                    }
                },
                Kirigami.Action {
                    icon.name: "edit-delete"
                    text: "Remove from Queue"
                    onTriggered: {
                        mpd.removeFromQueue(model.position);
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
                        // @TODO spams error if file does not exits
                        source: mpd.getCoverFilePath(model)

                        Connections {
                            function onMpdCoverFileChanged() {
                                if (image.status !== Image.Error)
                                    return ;

                                if ((mpd.mpdInfo.album === model.album) || (mpd.mpdInfo.file === model.file)) {
                                    image.source = '';
                                    image.source = mpd.mpdCoverFile;
                                }
                            }

                            target: mpd
                        }

                    }

                    Label {
                        Layout.fillWidth: true
                        height: Math.max(implicitHeight, Kirigami.Units.iconSizes.smallMedium)
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
                queueList.model.clear();
                for (let i in mpdState.mpdQueue) {
                    queueList.model.append(mpdState.mpdQueue[i]);
                }
            }

            target: mpd
        }

        model: ListModel {
        }

    }

    footer: WidgetQueueFooter {
        mpd: queuePage.mpd
    }

}
