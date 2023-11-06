import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../../Mpdw.js" as Mpdw

Kirigami.PromptDialog {
    id: root
    title: qsTr("Save Queue and Replace Playlist…")
    standardButtons: Kirigami.Dialog.NoButton
    showCloseButton: false

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
            iconName: Mpdw.icons.dialogOk
            onTriggered: {
                mpdState.replacePlaylistWithQueue(listCombo.currentText)
                root.close()
            }
        },
        Kirigami.Action {
            text: qsTr("Cancel")
            iconName: Mpdw.icons.dialogCancel
            onTriggered: {
                root.close()
            }
        }
    ]

    QQC2.ComboBox {
        id: listCombo
        model: ListModel {}

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
