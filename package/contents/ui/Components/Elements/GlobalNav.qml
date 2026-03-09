pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import QtQuick.Layouts
import "../../../scripts/formatHelpers.js" as FmH

RowLayout {
    id: root

    required property Kirigami.ApplicationItem app
    required property bool narrowLayout

    Repeater {
        model: root.app.pages

        PlasmaComponents.ToolButton {
            id: button

            required property var modelData

            icon.name: modelData.icon
            text: root.narrowLayout ? "" : modelData.text
            checkable: true
            checked: root.app.currentPage === modelData.name
            onClicked: root.app.showPage(modelData.name)
            Kirigami.MnemonicData.enabled: false

            PlasmaComponents.ToolTip {
                text: FmH.tooltipWithShortcut(button.modelData.tooltip, button.modelData.shortcut)
            }
        }
    }
}
