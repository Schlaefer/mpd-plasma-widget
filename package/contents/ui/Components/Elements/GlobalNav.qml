import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
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

        PlasmaComponents.ToolButton {
            icon.name: modelData.icon
            text: win.narrowLayout ? "" : modelData.text
            checkable: true
            checked: modelData.page.visible
            onClicked: win.app.showPage(modelData.page)
            Kirigami.MnemonicData.enabled: false

            PlasmaComponents.ToolTip {
                text: FmH.tooltipWithShortcut(modelData.tooltip, modelData.shortcut)
            }
        }
    }
}
