import "../scripts/formatHelpers.js" as FormatHelpers
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

Kirigami.ApplicationWindow {
    id: appWindow

    property var mpd

    flags: Qt.Popup | Qt.Dialog
    visible: false
    title: "MPD"
    pageStack.initialPage: queuePage

    WidgetQueuePage {
        id: queuePage

        mpd: appWindow.mpd
    }

    WidgetPlaylistPage {
        id: playlistPage

        mpd: appWindow.mpd
    }

    footer: Kirigami.NavigationTabBar {
        actions: [
            Kirigami.Action {
                iconName: "media-play"
                text: "Queue"
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
                text: "Playlists"
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