import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import "../../Mpdw.js" as Mpdw

QQC2.Menu {
    id: contextMenu

    QQC2.Action {
        text: qsTr('Select Album')
        icon.name: Mpdw.icons.selectAlbum
        shortcut: "B"
        onTriggered: {
            parentView.selectNeighborsByAlbum(model, index)
        }
    }
    QQC2.Action {
        text: qsTr('Select Album-Artist')
        icon.name: Mpdw.icons.selectArtist
        onTriggered: {
            parentView.selectNeighborsByAartist(model, index)
        }
    }
    QQC2.MenuSeparator {}
    QQC2.Action {
        text: qsTr('Select Above')
        icon.name: Mpdw.icons.selectAbove
        onTriggered: {
            parentView.selectAbove(index)
        }
        enabled: index > 0
    }
    QQC2.Action {
        text: qsTr('Select Below')
        icon.name: Mpdw.icons.selectBelow
        onTriggered: {
            parentView.selectBelow(index)
        }
        enabled: index < parentView.count - 1
    }
    QQC2.MenuSeparator {}
    QQC2.Action {
        text: qsTr("Select All")
        icon.name: Mpdw.icons.selectAll
        shortcut: "ctrl+a"
        onTriggered: {
            parentView.selectAll(true)
        }
    }
    QQC2.Action {
        text: parentView.actionDeselect.text
        icon.name: parentView.actionDeselect.icon.name
        shortcut: parentView.actionDeselect.shortcut
        onTriggered: parentView.actionDeselect.onTriggered()
    }
}
