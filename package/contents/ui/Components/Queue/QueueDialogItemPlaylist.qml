import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami

Kirigami.MenuDialog {
    title: qsTr("Modify Playlist")

    actions: [
        Kirigami.Action {
            text: qsTr('Remove Songs Above')
            onTriggered: {
                let i = index
                let itemsToRemove = []
                for (i; i > 0; i--) {
                    itemsToRemove.push(i)
                }
                mpdState.removeFromQueue(itemsToRemove)
                queueList.lastManipulatedItem = index
            }
            enabled: index > 0
            tooltip: qsTr("Remove Songs Above")
        },
        Kirigami.Action {
            text: qsTr('Remove Songs Below')
            onTriggered: {
                let i = queueList.count - 1
                let itemsToRemove = []
                for (i; i > index; i--) {
                    itemsToRemove.push(i + 1)
                }
                mpdState.removeFromQueue(itemsToRemove)
                queueList.lastManipulatedItem = index
            }
            enabled: index < queueList.count - 1
            tooltip: qsTr("Remove Songs Below")
        }
    ]
}
