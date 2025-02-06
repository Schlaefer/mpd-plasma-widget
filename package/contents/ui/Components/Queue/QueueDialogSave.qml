import QtQuick
import org.kde.plasma.components as PlasmaComponents
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../Mpdw.js" as Mpdw
import "../Elements"

Kirigami.PromptDialog {
    id: root
    title: qsTr("Save Queue as New Playlist")
    standardButtons: Kirigami.Dialog.NoButton
    showCloseButton: false

    dialogType: Kirigami.PromptDialog.None
    iconName: ""

    customFooterActions: [
        Kirigami.Action {
            text: qsTr("Save")
            id: actionButton
            icon.name: Mpdw.icons.dialogOk
            enabled: !newPlaylistTitle.playlistTitleExists && newPlaylistTitle.text
            onTriggered: {
                mpdState.savedQueueAsPlaylist.connect(afterSave)
                mpdState.saveQueueAsPlaylist(newPlaylistTitle.text)
            }

            function afterSave(success) {
                if (success) {
                    newPlaylistErrorMsg.visible = false
                    showPassiveNotification(qsTr('Saved'), 2000)
                    root.close()
                } else {
                    newPlaylistErrorMsg.visible = true
                }
                mpdState.savedQueueAsPlaylist.disconnect(afterSave)
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

    ColumnLayout {
        PlasmaComponents.TextField {
            id: newPlaylistTitle
            Layout.fillWidth: true
            property bool playlistTitleExists
            placeholderText: qsTr("New Playlist Name…")
            // Doesn't work due to animation(?), we use a timer instead.

            function updatePlaylistTitleExists() {
                playlistTitleExists = mpdState.mpdPlaylists.indexOf(text) !== -1
            }

            onTextChanged: {
                updatePlaylistTitleExists()
            }

            Connections {
                target: mpdState

                function onMpdPlaylistsChanged() {
                    newPlaylistTitle.updatePlaylistTitleExists()
                }
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
