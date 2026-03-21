import QtQuick
import QtQuick.Layouts
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

    RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 2 * Kirigami.Units.largeSpacing
        Layout.bottomMargin: 2 * Kirigami.Units.largeSpacing
        spacing: 2 * Kirigami.Units.largeSpacing
        Kirigami.Icon {
            id: icon
            Layout.preferredHeight: Kirigami.Units.iconSizes.medium
            Layout.preferredWidth: Layout.preferredHeight
            Layout.alignment: Qt.AlignTop
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            PlasmaComponents.Label {
                id: label
                Layout.fillWidth: true // explicitely set width to activate wrapMode
                textFormat: Text.PlainText
                visible: text
                wrapMode: Text.Wrap

            }
            PlasmaComponents.Label {
                id: item
                Layout.fillWidth: true // explicitely set width to activate wrapMode
                font.weight: Font.Bold
                textFormat: Text.PlainText
                visible: text
                wrapMode: Text.Wrap
            }
        }
    }
}
