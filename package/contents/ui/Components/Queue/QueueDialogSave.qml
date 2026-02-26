pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../Mpdw.js" as Mpdw
import "../../../logic"

Kirigami.PromptDialog {
    id: root

    required property MpdState mpdState

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
                root.mpdState.savedQueueAsPlaylist.connect(afterSave)
                root.mpdState.saveQueueAsPlaylist(newPlaylistTitle.text)
            }

            function afterSave(success) {
                if (success) {
                    newPlaylistErrorMsg.visible = false // Flashes for a moment while dialog closes
                    playlistExistsMessage.visible = false
                    AppContext.notify(qsTr('Saved'))
                    root.close()
                } else {
                    newPlaylistErrorMsg.visible = true
                }
                root.mpdState.savedQueueAsPlaylist.disconnect(afterSave)
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

            property bool playlistTitleExists

            Layout.fillWidth: true
            placeholderText: qsTr("New Playlist Name…")

            function updatePlaylistTitleExists() {
                playlistTitleExists = root.mpdState.mpdPlaylists.indexOf(text) !== -1
            }

            onTextChanged: {
                updatePlaylistTitleExists()
            }

            Connections {
                target: root.mpdState

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

            Component.onCompleted: {
                root.mpdState.getPlaylists()
            }

            Timer {
                id: waitForAnimationToFinish
                running: false
                // Wait for popup sliding in to finish
                interval: Kirigami.Units.longDuration
                onTriggered: {
                    // Set cursor into textfield for quick type-ahead
                    newPlaylistTitle.forceActiveFocus()
                }
            }

        }

        Kirigami.InlineMessage {
            id: playlistExistsMessage
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
