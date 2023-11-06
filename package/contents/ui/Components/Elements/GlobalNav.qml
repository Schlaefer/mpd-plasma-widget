import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import "../../Mpdw.js" as Mpdw
import "../../../scripts/formatHelpers.js" as FmH

RowLayout {
    Repeater {
        model: [
            {
                icon: Mpdw.icons.placeQueue,
                page: queuePage,
                shortcut: queuePage.globalShortcut,
                text: qsTr("Queue"),
                tooltip: qsTr("Show Queue")
            },
            {
                icon: Mpdw.icons.placeArtist,
                page: albumartistsPage,
                shortcut: albumartistsPage.globalShortcut,
                text: qsTr("Artists"),
                tooltip: qsTr("Show Artists")
            },
            {
                icon: Mpdw.icons.placePlaylist,
                page: playlistPage,
                shortcut: playlistPage.globalShortcut,
                text: qsTr("Playlists"),
                tooltip: qsTr("Show Playlists"),
            }
        ]

        QQC2.ToolButton {
            icon.name: modelData.icon
            text: main.appWindow.narrowLayout ? "" : modelData.text
            checkable: true
            checked: modelData.page.visible
            onClicked: main.appWindow.showPage(modelData.page)

            QQC2.ToolTip {
                text: FmH.tooltipWithShortcut(modelData.tooltip, modelData.shortcut)
            }
        }
    }
}
