pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.components as PlasmaComponents
import "../../../scripts/formatHelpers.js" as FmH

PlasmaComponents.ToolButton {
    id: root

    required property bool narrowLayout
    required property var modelData

    checkable: true
    icon.name: modelData.icon.name
    visible: !root.narrowLayout || modelData.checked

    Binding {
        target: root.modelData
        property: "checked"
        value: root.checked
        when: true
    }
    checked: modelData.checked

    PlasmaComponents.ToolTip {
        text: FmH.tooltipWithShortcut(root.modelData.tooltip, root.modelData.shortcut)
    }
}
