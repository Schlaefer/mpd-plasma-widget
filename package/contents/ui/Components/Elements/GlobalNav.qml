import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.15

RowLayout {
    property int parentWidth

    Repeater {
        model: [
            {
                icon: "media-playback-playing",
                page: queuePage,
                shortcut: queuePage.globalShortcut,
                text: qsTr("Queue"),
                tooltip: qsTr("Show Queue")
            },
            {
                icon: "view-media-artist",
                page: albumartistsPage,
                shortcut: albumartistsPage.globalShortcut,
                text: qsTr("Artists"),
                tooltip: qsTr("Show Artists")
            },
            {
                icon: "view-media-playlist",
                page: playlistPage,
                shortcut: playlistPage.globalShortcut,
                text: qsTr("Playlists"),
                tooltip: qsTr("Show Playlists"),
            }
        ]

        QQC2.ToolButton {
            icon.name: modelData.icon
            text: parentWidth > appWindow.simpleLayoutBreakpoint ? modelData.text : ""
            checkable: true
            checked: modelData.page.visible
            onClicked: appWindow.showPage(modelData.page)

            QQC2.ToolTip {
                text: modelData.tooltip + " (" + modelData.shortcut + ")"
            }
        }
    }
}
