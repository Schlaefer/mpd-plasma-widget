import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import "../../Mpdw.js" as Mpdw

QQC2.Menu {
    id: contextMenu
    QQC2.MenuItem {
        text: qsTr('Select Album')
        icon.name: Mpdw.icons.selectAlbum
        onTriggered: {
            parentView.selectNeighborsByAlbum(model, index)
        }
    }
    QQC2.MenuItem {
        text: qsTr('Select Album-Artist')
        icon.name: Mpdw.icons.selectArtist
        onTriggered: {
            parentView.selectNeighborsByAartist(model, index)
        }
    }
    QQC2.MenuSeparator {}
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
}
