import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents

Kirigami.PromptDialog {
    id: root
    title: qsTr("Replace Playlist")
    standardButtons: Kirigami.Dialog.NoButton
    showCloseButton: false

    customFooterActions: [
        Kirigami.Action {
            text: qsTr("Replace Playlist")
            id: actionButton
            iconName: "dialog-ok"
            icon.name: "document-new-symbolic"
            onTriggered: {
                mpdState.removePlaylist(listCombo.currentText)
                mpdState.saveQueueAsPlaylist(listCombo.currentText)
                root.close()
            }
        },
        Kirigami.Action {
            text: qsTr("Cancel")
            iconName: "cancel"
            onTriggered: {
                root.close()
            }
        }
    ]

    QQC2.ComboBox {
        id: listCombo
        model: ListModel {}
        Connections {
            function onMpdPlaylistsChanged() {
                listCombo.model.clear()
                let playlists = mpdState.mpdPlaylists
                for (let i in playlists) {
                    listCombo.model.append({
                                               "title": playlists[i]
                                           })
                }
            }

            target: mpdState
        }
    }
}
