import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../Mpdw.js" as Mpdw

Kirigami.PromptDialog {
    id: root

    property alias icon: icon.source
    property alias label: label.text
    property alias buttonText: actionButton.text
    property alias itemTitle: item.text
    // @SOMEDAY figure out how to use as a property
    property var onConfirmed: null

    standardButtons: Kirigami.Dialog.NoButton
    showCloseButton: false

    dialogType: Kirigami.PromptDialog.None
    iconName: ""

    customFooterActions: [
        Kirigami.Action {
            id: actionButton
            icon.name: Mpdw.icons.dialogOk
            onTriggered: {
                if (onConfirmed) {
                    onConfirmed()
                }
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

    Row {
        spacing: Kirigami.Units.largeSpacing
        Kirigami.Icon {
            id: icon
            height: Kirigami.Units.iconSizes.huge
            width: Kirigami.Units.iconSizes.huge
        }
        Column {
            PlasmaComponents.Label {
                id: label
            }
            PlasmaComponents.Label {
                id: item
                font.weight: Font.Bold
            }
        }
    }
}
