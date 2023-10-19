import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2

QQC2.Menu {
    id: contextMenu
    QQC2.MenuItem {
        text: qsTr("Replace Queue with Song")
        icon.name: "media-play-playback"
        onTriggered: {
            mpdState.replaceQueue([model.file])
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr("Append Song to Queue")
        icon.name: "media-playlist-append"
        onTriggered: {
            mpdState.addSongsToQueue([model.file])
        }
    }
    QQC2.MenuItem {
        text: qsTr("Insert Song After Current")
        icon.name:"timeline-insert"
        onTriggered: {
            mpdState.addSongsToQueue([model.file], "insert")
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr("Select All")
        icon.name: "edit-select-all-symbolic"
        onTriggered: {
            root.parentView.selectAll(true)
        }
    }
    QQC2.MenuItem {
        text: qsTr("Deselect All")
        onTriggered: {
            root.parentView.selectAll(false)
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr('Select by Album')
        icon.name: "media-album-cover"
        onTriggered: {
            root.parentView.selectNeighborsByAlbum(model, index)
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select by Album-Artist')
        icon.name: "view-media-artist"
        onTriggered: {
            root.parentView.selectNeighborsByAartist(model, index)
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select Above')
        icon.name: "arrow-up"
        onTriggered: {
            root.parentView.selectAbove(index)
        }
        enabled: index > 0
    }
    QQC2.MenuItem {
        text: qsTr('Select Below')
        icon.name: "arrow-down"
        onTriggered: {
            root.parentView.selectBelow(index)
        }
        enabled: index < root.parentView.count - 1
    }
}
