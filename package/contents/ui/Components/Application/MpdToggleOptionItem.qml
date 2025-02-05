import QtQuick 2.15
import org.kde.plasma.components as PlasmaComponents
import "../../../scripts/formatHelpers.js" as FmH

PlasmaComponents.ToolButton {
    id: root

    checkable: true
    icon.name: modelData.icon.name
    visible: !main.appWindow.narrowLayout || checked

    PlasmaComponents.ToolTip {
        text: FmH.tooltipWithShortcut(modelData.tooltip, modelData.shortcut)
    }

    function update() {
        // This catches us getting our own cmd replied, so don't act on it.
        let localState = mpdState[modelData.mpdOption]
        if (root.checked === localState) {
            return
        }
        root.checked = mpdState[modelData.mpdOption]
    }

    onCheckedChanged: {
        let localState = mpdState[modelData.mpdOption]
        if (root.checked === localState) {
            return
        }
        modelData.onTriggered()
    }

    Component.onCompleted: {
        let option = modelData.mpdOption
        let connection = option.charAt(0).toUpperCase() + option.slice(1);
        mpdState["on" + connection + "Changed"].connect(update)
        update()
    }
}
