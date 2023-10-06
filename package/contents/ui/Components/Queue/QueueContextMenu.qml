import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2

QQC2.Menu {
    id: contextMenu
    QQC2.MenuItem {
        text: qsTr("Select All")
        // @SOMEDAY shortcut
        onTriggered: {
            queueList.listManager.checkAll(queueList.model)
            queueList.checkItems()
        }
    }
    QQC2.MenuItem {
        text: qsTr("Deselect All")
        // @SOMEDAY shortcut
        onTriggered: {
            queueList.listManager.reset()
            queueList.checkItems()
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr('Select Neighbors by Album')
        visible: !checkBox.checked
        // @SOMEDAY shortcut
        onTriggered: {
            let albumItems = queueList.listManager.checkNeighboursAlbum(queueList.model, model, index)
            queueList.checkItems()
        }
    }
    QQC2.MenuItem {
        text: qsTr('Deselect Neighbors by Album')
        visible: checkBox.checked
        // @SOMEDAY shortcut
        onTriggered: {
            let albumItems = queueList.listManager.uncheckNeighboursAlbum(queueList.model, model, index)
            queueList.checkItems()
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select Neighbors by Album-Artist')
        visible: !checkBox.checked
        // @SOMEDAY shortcut
        onTriggered: {
            let albumItems = queueList.listManager.checkNeighboursArtist(queueList.model, model, index)
            queueList.checkItems()
        }
    }
    QQC2.MenuItem {
        text: qsTr('Deselect Neighbors by Album-Artist')
        visible: checkBox.checked
        // @SOMEDAY shortcut
        onTriggered: {
            let albumItems = queueList.listManager.uncheckNeighboursArtist(queueList.model, model, index)
            queueList.checkItems()
        }
    }
    QQC2.MenuSeparator {}
    QQC2.MenuItem {
        text: qsTr('Select Songs Above')
        // @SOMEDAY shortcut
        onTriggered: {
            queueList.listManager.checkSongsAbove(queueList.model, index)
            queueList.checkItems()
        }
        enabled: index > 0
    }
    QQC2.MenuItem {
        text: qsTr('Select Songs Below')
        // @SOMEDAY shortcut
        onTriggered: {
            queueList.listManager.checkSongsBelow(queueList.model, index)
            queueList.checkItems()
        }
        enabled: index < queueList.count - 1
    }
}
