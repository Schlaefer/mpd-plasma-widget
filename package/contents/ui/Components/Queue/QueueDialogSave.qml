import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import "../Elements"

Kirigami.PromptDialog {
    id: root
    title: qsTr("Save to New Playlist")
    standardButtons: Kirigami.Dialog.NoButton
    showCloseButton: false

    customFooterActions: [
        Kirigami.Action {
            text: qsTr("Save")
            id: actionButton
            iconName: "dialog-ok"
            icon.name: "document-new-symbolic"
            enabled: !newPlaylistTitle.playlistTitleExists && newPlaylistTitle.text
            onTriggered: {
                mpdState.onSaveQueueAsPlaylist.connect(afterSave)
                mpdState.saveQueueAsPlaylist(newPlaylistTitle.text)
            }

            function afterSave(success) {
                if (success) {
                    newPlaylistErrorMsg.visible = false
                    root.close()
                } else {
                    newPlaylistErrorMsg.visible = true
                }
                mpdState.onSaveQueueAsPlaylist.disconnect(afterSave)
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

    ColumnLayout {
        QQC2.TextField {
            id: newPlaylistTitle
            Layout.fillWidth: true
            property bool playlistTitleExists
            placeholderText: qsTr("Playlist Name…")
            // Doesn't work due to animation(?), we use a timer instead.

            function updatePlaylistTitleExists() {
                playlistTitleExists = mpdState.mpdPlaylists.indexOf(text) !== -1
            }

            onTextChanged: {
                updatePlaylistTitleExists()
            }

            Connections {
                function onMpdPlaylistsChanged() {
                    newPlaylistTitle.updatePlaylistTitleExists()
                }
                target: mpdState
            }

            Connections {
                function onVisibleChanged() {
                    if (root.visible) {
                        waitForAnimationToFinish.start()
                    }
                }
                target: root
                }

            Timer {
                id: waitForAnimationToFinish
                running: false
                interval: Kirigami.Units.longDuration
                onTriggered: {
                    newPlaylistTitle.forceActiveFocus()
                }
            }

        }

        Kirigami.InlineMessage {
            id: msg
            Layout.fillWidth: true
            visible: newPlaylistTitle.playlistTitleExists
            type: Kirigami.MessageType.Warning
            text: qsTr("Playlist with same name already exists.")
        }

        Kirigami.InlineMessage {
            id: newPlaylistErrorMsg
            Layout.fillWidth: true
            visible: false
            type: Kirigami.MessageType.Error
            // @SOMEDAY Better text
            text: qsTr("Saving playlist failed.")
        }
    }
}
