import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents

Kirigami.PromptDialog {
    id: dialog

    title: qsTr("Save Queue")
    standardButtons: Kirigami.Dialog.NoButton

    ColumnLayout {
        Kirigami.FormLayout {
            Item {
                Kirigami.FormData.label: qsTr("Save as New Playlist")
                Kirigami.FormData.isSection: true
            }

            Kirigami.InlineMessage {
                id: newPlaylistErrorMsg
                Layout.fillWidth: true
                visible: false
                type: Kirigami.MessageType.Error
                // @SOMEDAY Better text
                text: qsTr("Saving playlist failed.")
            }

            QQC2.TextField {
                id: newPlaylistTitle
                property bool playlistTitleExists

                Kirigami.FormData.label: qsTr("Playlist Name")

                placeholderText: qsTr("Playlist Name…")
                // @SOMEDAY Doesn't work.
                focus: true

                function updatePlaylistTitleExists() {
                    playlistTitleExists = mpdState.mpdPlaylists.indexOf(
                                text) !== -1
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
            }

            QQC2.Button {
                text: qsTr("Create Playlist")
                icon.name: "document-new-symbolic"
                enabled: !newPlaylistTitle.playlistTitleExists
                         && newPlaylistTitle.text
                onClicked: {
                    mpdState.onSaveQueueAsPlaylist.connect(afterSave)
                    mpdState.saveQueueAsPlaylist(newPlaylistTitle.text)
                }

                function afterSave(success) {
                    if (success) {
                        newPlaylistErrorMsg.visible = false
                        dialog.close()
                    } else {
                        newPlaylistErrorMsg.visible = true
                    }
                    mpdState.onSaveQueueAsPlaylist.disconnect(afterSave)
                }
            }

            QQC2.Label {
                id: msg
                text: newPlaylistTitle.playlistTitleExists ? "Playlist already exists!" : ""
            }

            Item {
                Kirigami.FormData.label: qsTr("Replace Existing Playslist")
                Kirigami.FormData.isSection: true
            }

            QQC2.ComboBox {
                id: listCombo
                Kirigami.FormData.label: qsTr("Playlist Name")
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

            QQC2.Button {
                text: qsTr("Replace Playlist")
                icon.name: "document-replace"
                enabled: listCombo.currentText
                onClicked: {
                    playlistReplaceConfirmDialog.open()
                }

                Kirigami.PromptDialog {
                    id: playlistReplaceConfirmDialog
                    title: qsTr("Replace Playlist")

                    showCloseButton: false
                    standardButtons: Kirigami.Dialog.NoButton

                    customFooterActions: [
                        Kirigami.Action {
                            text: qsTr("Replace Playlist")
                            iconName: "dialog-ok"
                            onTriggered: {
                                mpdState.removePlaylist(listCombo.currentText)
                                mpdState.saveQueueAsPlaylist(
                                    listCombo.currentText)
                                playlistReplaceConfirmDialog.close()
                                dialog.close()
                            }
                        },
                        Kirigami.Action {
                            text: qsTr("Cancel")
                            iconName: "cancel"
                            onTriggered: {
                                playlistReplaceConfirmDialog.close()
                            }
                        }
                    ]

                    ColumnLayout {
                        spacing: Kirigami.Units.largeSpacing

                        PlasmaComponents.Label {
                            text: qsTr(
                                      "The following playlist will be replaced:")
                        }
                        PlasmaComponents.Label {
                            text: listCombo.currentText
                            font.weight: Font.Bold
                        }
                        Kirigami.InlineMessage {
                            Layout.fillWidth: true
                            visible: true
                            type: Kirigami.MessageType.Warning
                            text: qsTr("This is a permanent operation.")
                        }
                    }
                }
            }
        }
    }
}
