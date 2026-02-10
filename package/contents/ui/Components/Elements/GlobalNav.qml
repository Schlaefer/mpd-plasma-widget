import QtQuick
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import QtQuick.Layouts
import "../../Mpdw.js" as Mpdw
import "../../../scripts/formatHelpers.js" as FmH

RowLayout {
    Repeater {
        model: win.app.pages

        PlasmaComponents.ToolButton {
            icon.name: modelData.icon
            text: win.narrowLayout ? "" : modelData.text
            checkable: true
            checked: win.app.currentPage === modelData.name
            onClicked: win.app.showPage(modelData.name)
            Kirigami.MnemonicData.enabled: false

            PlasmaComponents.ToolTip {
                text: FmH.tooltipWithShortcut(modelData.tooltip, modelData.shortcut)
            }
        }
    }
}
