import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../Mpdw.js" as Mpdw

Kirigami.PromptDialog {
    id: root
    title: qsTr("Save Queue and Replace Playlist…")
    standardButtons: Kirigami.Dialog.NoButton
    showCloseButton: false

    dialogType: Kirigami.PromptDialog.None
    iconName: ""

    customFooterActions: [
        Kirigami.Action {
            text: qsTr("Replace Playlist")
            id: actionButton
            icon.name: Mpdw.icons.dialogOk
            onTriggered: {
                mpdState.replacePlaylistWithQueue(listCombo.currentText)
                root.close()
            }
        },
        Kirigami.Action {
            text: qsTr("Cancel")
            icon.name: Mpdw.icons.dialogCancel
            onTriggered: {
                root.close()
            }
        }
    ]

    PlasmaComponents.ComboBox {
        id: listCombo
        model: ListModel {}
        implicitWidth: parent.width

        function selectLastPlayedPlaylist() {
            const lastPl = mpdState.lastPlayedPlaylist
            if (!lastPl) {
                return
            }
            const found = listCombo.find(lastPl)
            if (found !== -1) {
                listCombo.currentIndex = found
            }
        }

        function populateModel() {
            listCombo.model.clear()
            let playlists = mpdState.mpdPlaylists
            for (let i in playlists) {
                listCombo.model.append({ "title": playlists[i] })
            }
            listCombo.selectLastPlayedPlaylist()
        }

        Component.onCompleted: {
            mpdState.getPlaylists()
        }

        Connections {
            target: mpdState
            function onMpdPlaylistsChanged() {
                listCombo.populateModel()
            }
            function onLastPlayedPlaylistChanged() {
                listCombo.selectLastPlayedPlaylist()
            }
        }
    }
}
