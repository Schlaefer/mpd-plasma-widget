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
    QQC2.MenuItem {
        text: qsTr("Append Song to Queue")
        icon.name: "media-playlist-append"
        onTriggered: {
            mpdState.addSongsToQueue([model.file])
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr("Select All")
        icon.name: "edit-select-all-symbolic"
        onTriggered: {
            root.parentView.listManager.checkAll(root.parentView.model)
            root.parentView.checkItems()
        }
    }
    QQC2.MenuItem {
        text: qsTr("Deselect All")
        onTriggered: {
            root.parentView.listManager.reset()
            root.parentView.checkItems()
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr('Select by Album')
        icon.name: "media-album-cover"
        visible: !checkBox.checked
        onTriggered: {
            let albumItems = root.parentView.listManager.checkNeighboursAlbum(root.parentView.model, model, index)
            root.parentView.checkItems()
        }
    }
    QQC2.MenuItem {
        text: qsTr('Deselect by Album')
        icon.name: "media-album-cover"
        visible: checkBox.checked
        onTriggered: {
            let albumItems = root.parentView.listManager.uncheckNeighboursAlbum(root.parentView.model, model, index)
            root.parentView.checkItems()
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select by Album-Artist')
        icon.name: "view-media-artist"
        visible: !checkBox.checked
        onTriggered: {
            let albumItems = root.parentView.listManager.checkNeighboursArtist(root.parentView.model, model, index)
            root.parentView.checkItems()
        }
    }
    QQC2.MenuItem {
        text: qsTr('Deselect by Album-Artist')
        icon.name: "view-media-artist"
        visible: checkBox.checked
        onTriggered: {
            let albumItems = root.parentView.listManager.uncheckNeighboursArtist(root.parentView.model, model, index)
            root.parentView.checkItems()
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr('Select Above')
        icon.name: "arrow-up"
        onTriggered: {
            root.parentView.listManager.checkSongsAbove(root.parentView.model, index)
            root.parentView.checkItems()
        }
        enabled: index > 0
    }
    QQC2.MenuItem {
        text: qsTr('Select Below')
        icon.name: "arrow-down"
        onTriggered: {
            root.parentView.listManager.checkSongsBelow(root.parentView.model, index)
            root.parentView.checkItems()
        }
        enabled: index < root.parentView.count - 1
    }
}
