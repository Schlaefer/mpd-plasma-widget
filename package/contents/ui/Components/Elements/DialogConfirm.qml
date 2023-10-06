import QtQuick 2.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents

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

    customFooterActions: [
        Kirigami.Action {
            id: actionButton
            iconName: "dialog-ok"
            onTriggered: {
                if (onConfirmed) {
                    onConfirmed()
                }
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
