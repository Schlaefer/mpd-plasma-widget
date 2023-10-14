import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import "../../Components/Elements"
import "../../../scripts/listManager.js" as ListManager

ListViewGeneric {
    id: root

    property var listManager: new ListManager.ListManager()
    property var actionsHook

    function replaceQueue() {
        mpdState.replaceQueue(getSelectedFilesOrAll())
    }

    function addToQueue() {
        mpdState.addSongsToQueue(getSelectedFilesOrAll())
    }

    /**
      * Get all the selected files in the list or all if none is selected
      *
      * @return {array} selected files
      */
    function getSelectedFilesOrAll() {
        let items = root.listManager.getChecked()
        let files = []

        if (items.length === 0) {
            for (var i = 0; i < root.count; i++) {
                files.push(root.model.get(i).file)
            }
        } else {
            items.forEach(function (position) {
                files.push(root.model.get(position).file)
            })
            // @TODO
            root.checkItems()
            root.listManager.reset()
        }

        return files
    }

    function checkItems() {
        let items = root.listManager.getChecked()
        for (var i = 0; i < model.count; i++) {
            model.setProperty(i, 'checked', items.indexOf(i) > -1)
        }
    }

    // onCountChanged: {
    // }
    Connections {
        function onVisibleChanged() {
//            root.showCurrentItemInList()
        }

        target: appWindow
    }

    model: ListModel {}

    moveDisplaced: Transition {
        YAnimator {
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
    }

    Component.onCompleted: {
        if (actionsHook) {
            let menu = contextualMenuItems.createObject(actionsHook.parent)
            // @SOMEDAY why is that not working adding items to the Queue menu in queue?
//            actionsHook.push(menu.children[0])
            actionsHook.push(menu)
        }
    }

    Component {
        id: contextualMenuItems

        Kirigami.Action {
            text: qsTr("Songs")
            Kirigami.Action {
                text:  qsTr("Replace Queue")
                icon.name: "media-play-playback"
                onTriggered: replaceQueue()
            }
            Kirigami.Action {
                text: qsTr("Append to Queue")
                icon.name: "media-playlist-append"
                onTriggered: addToQueue()
            }
            Kirigami.Action {
                separator: true
            }
            Kirigami.Action {
                text: qsTr("Select All")
                icon.name: "edit-select-all-symbolic"
                onTriggered: {
                    listView.listManager.checkAll(listView.model)
                    listView.checkItems()
                }
            }
            Kirigami.Action {
                text: qsTr("Deselect All")
                onTriggered: {
                    listView.listManager.reset()
                    listView.checkItems()
                }
            }
        }
    }
}
