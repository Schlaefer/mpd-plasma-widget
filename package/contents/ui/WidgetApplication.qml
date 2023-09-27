import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Kirigami.ApplicationWindow {
    id: appWindow

    property var mpd
    property var coverManager

    flags: Qt.Widget
    visible: false
    title: qsTr("MPD")
    pageStack.initialPage: queuePage

    WidgetQueuePage {
        id: queuePage

        mpd: appWindow.mpd
        coverManager: appWindow.coverManager
    }

    WidgetPlaylistPage {
        id: playlistPage

        mpd: appWindow.mpd
    }

    footer: Kirigami.NavigationTabBar {
        actions: [
            Kirigami.Action {
                iconName: "media-play"
                text: qsTr("Queue")
                checked: queuePage.visible
                onTriggered: {
                    if (!queuePage.visible) {
                        while (popupDialog.pageStack.depth > 0)popupDialog.pageStack.pop()
                        popupDialog.pageStack.push(queuePage);
                    }
                }
            },
            Kirigami.Action {
                iconName: "view-media-playlist"
                text: qsTr("Playlists")
                checked: playlistPage.visible
                onTriggered: {
                    if (!playlistPage.visible) {
                        while (popupDialog.pageStack.depth > 0)popupDialog.pageStack.pop()
                        popupDialog.pageStack.push(playlistPage);
                    }
                }
            }
        ]
    }

}
