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

    PlaylistObject {
        id: plObj
        title: newTitle.text
        playlists: root.mpdState.mpdPlaylists

        Component.onCompleted: {
            root.mpdState.getPlaylists()
        }
    }

    customFooterActions: [
        Kirigami.Action {
            text: qsTr("Save")
            id: actionButton
            icon.name: Mpdw.icons.dialogOk
            enabled: plObj.canSave
            onTriggered: {
                root.mpdState.savedQueueAsPlaylist.connect(afterSave)
                root.mpdState.saveQueueAsPlaylist(plObj.title)
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
            id: newTitle

            Layout.fillWidth: true
            placeholderText: qsTr("New Playlist Name…")

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
                // Wait for popup sliding in to finish
                interval: Kirigami.Units.longDuration
                onTriggered: {
                    // Set cursor into textfield for quick type-ahead
                    newTitle.forceActiveFocus()
                }
            }
        }

        // === Validate Playlist Name
        Kirigami.InlineMessage {
            id: playlistInvalidMessage
            Layout.fillWidth: true
            visible: !plObj.isEmpty && !plObj.isValid
            type: Kirigami.MessageType.Warning
            text: qsTr("Playlist name invalid.")
        }

        // === Check if playlist exists ===
        // Prevent viusal noise if user uses a common prefix for their titles.
        Timer {
            id: playlistExistsTimer
            interval: 1000
            onTriggered: playlistExistsMessage.visible = !plObj.isUnique
        }

        Kirigami.InlineMessage {
            id: playlistExistsMessage
            Layout.fillWidth: true
            visible: false
            type: Kirigami.MessageType.Warning
            text: qsTr("Playlist with same name already exists.")

            Connections {
                target: plObj
                function onIsUniqueChanged() {
                    if (plObj.isUnique) {
                        playlistExistsMessage.visible = false
                        return
                    }
                    playlistExistsTimer.start()
                }
            }
        }

        // === Saving Playlist failed ===
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
