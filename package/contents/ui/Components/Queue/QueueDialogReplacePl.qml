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

    function selectPlaylist(playlist) {
        let found = listCombo.find(playlist)
        if (found !== -1) {
            listCombo.currentIndex = found
        }
    }

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

        function populateModel() {
            listCombo.model.clear()
            let playlists = mpdState.mpdPlaylists
            for (let i in playlists) {
                listCombo.model.append({ "title": playlists[i] })
            }
        }

        Component.onCompleted: { populateModel() }

        Connections {
            target: mpdState
            function onMpdPlaylistsChanged() {
                listCombo.populateModel()
            }
            function onPlayedPlaylist(playlist) {
                queueDialogReplacePl.selectPlaylist(playlist)
            }
        }
    }
}
