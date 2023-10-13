import QtQuick 2.15
import QtQuick.Controls 2.3 as QQC2
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami

Kirigami.PromptDialog {
    id: dialot
    title: qsTr("Clear Queue")

    standardButtons: Kirigami.Dialog.NoButton

    customFooterActions: [
        Kirigami.Action {
            text: qsTr("Clear Queue")
            iconName: "dialog-ok"
            onTriggered: {
                mpdState.clearQueue()
                dialog.close()
            }
        },
        Kirigami.Action {
            text: qsTr("Cancel")
            iconName: "cancel" // Icon for the button
            onTriggered: {
                dialog.close()
            }
        }
    ]

    Kirigami.InlineMessage {
        Layout.fillWidth: true
        visible: true
        type: Kirigami.MessageType.Warning
        text: qsTr("The Queue will be empty afterwards.")
    }
}
