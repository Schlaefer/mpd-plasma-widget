pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import QtQuick.Layouts
import "../../../scripts/formatHelpers.js" as FmH

RowLayout {
    id: root

    required property bool narrowLayout

    Repeater {
        model: app.pages

        PlasmaComponents.ToolButton {
            id: button

            required property var modelData

            icon.name: modelData.icon
            text: root.narrowLayout ? "" : modelData.text
            checkable: true
            checked: app.currentPage === modelData.name
            onClicked: app.showPage(modelData.name)
            Kirigami.MnemonicData.enabled: false

            PlasmaComponents.ToolTip {
                text: FmH.tooltipWithShortcut(button.modelData.tooltip, button.modelData.shortcut)
            }
        }
    }
}
