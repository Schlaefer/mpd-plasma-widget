import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2

QQC2.Menu {
    id: contextMenu
    QQC2.MenuItem {
        text: qsTr("Replace Queue")
        icon.name: "media-play-playback"
        onTriggered: {
            let songs = parent.getSelectedSongs().map(song => { return song.file })
            mpdState.replaceQueue(songs)
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr("Append")
        icon.name: "media-playlist-append"
        onTriggered: {
            let songs = parent.getSelectedSongs().map(song => { return song.file })
            mpdState.addSongsToQueue(songs)
        }
    }
    QQC2.MenuItem {
        text: qsTr("Insert")
        icon.name:"timeline-insert"
        onTriggered: {
            let songs = parent.getSelectedSongs().map(song => { return song.file })
            mpdState.addSongsToQueue(songs, "insert")
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr("Select All")
        icon.name: "edit-select-all-symbolic"
        onTriggered: {
            parentView.selectAll(true)
        }
    }
    QQC2.MenuItem {
        text: qsTr("Deselect")
        icon.name: "edit-select-none"
        onTriggered: {
            parentView.deselectAll()
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr('Select by Album')
        icon.name: "media-album-cover"
        onTriggered: {
            parentView.selectNeighborsByAlbum(model, index)
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select by Album-Artist')
        icon.name: "view-media-artist"
        onTriggered: {
            parentView.selectNeighborsByAartist(model, index)
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select Above')
        icon.name: "arrow-up"
        onTriggered: {
            parentView.selectAbove(index)
        }
        enabled: index > 0
    }
    QQC2.MenuItem {
        text: qsTr('Select Below')
        icon.name: "arrow-down"
        onTriggered: {
            parentView.selectBelow(index)
        }
        enabled: index < parentView.count - 1
    }
}
