import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import "../../Mpdw.js" as Mpdw

QQC2.Menu {
    id: contextMenu
    QQC2.MenuItem {
        text: qsTr("Replace Queue")
        icon.name: Mpdw.icons.queuePlay
        onTriggered: {
            let songs = parentView.getSelectedSongs().map(song => { return song.file })
            mpdState.replaceQueue(songs)
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr("Append")
        icon.name: Mpdw.icons.queueAppend
        onTriggered: {
            let songs = parentView.getSelectedSongs().map(song => { return song.file })
            mpdState.addSongsToQueue(songs)
        }
    }
    QQC2.MenuItem {
        text: qsTr("Insert")
        icon.name: Mpdw.icons.queueInsert
        onTriggered: {
            let songs = parentView.getSelectedSongs().map(song => { return song.file })
            mpdState.addSongsToQueue(songs, "insert")
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr("Select All")
        icon.name: Mpdw.icons.selectAll
        onTriggered: {
            parentView.selectAll(true)
        }
    }
    QQC2.MenuItem {
        text: qsTr("Deselect")
        icon.name: Mpdw.icons.selectNone
        onTriggered: {
            parentView.deselectAll()
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr('Select by Album')
        icon.name: Mpdw.icons.selectAlbum
        onTriggered: {
            parentView.selectNeighborsByAlbum(model, index)
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select by Album-Artist')
        icon.name: Mpdw.icons.selectArtist
        onTriggered: {
            parentView.selectNeighborsByAartist(model, index)
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select Above')
        icon.name: Mpdw.icons.selectAbove
        onTriggered: {
            parentView.selectAbove(index)
        }
        enabled: index > 0
    }
    QQC2.MenuItem {
        text: qsTr('Select Below')
        icon.name: Mpdw.icons.selectBelow
        onTriggered: {
            parentView.selectBelow(index)
        }
        enabled: index < parentView.count - 1
    }
}
