import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2

QQC2.ToolButton {
    id: root

    checkable: true
    icon.name: modelData.icon.name
    visible: checked

    QQC2.ToolTip {
        text: modelData.tooltip + " (" + modelData.shortcut.toUpperCase() + ")"
    }

    onCheckedChanged: {
        let localState = mpdState.mpdOptions[modelData.mpdOption] === "on"
        if (root.checked === localState) {
            return
        }
        modelData.onTriggered()
    }

    Connections {
        function onMpdOptionsChanged() {
            // This catches us getting our own cmd replied, so don't act on it.
            let localState = mpdState.mpdOptions[modelData.mpdOption] === "on"
            if (root.checked === localState) {
                return
            }
            root.checked = mpdState.mpdOptions[modelData.mpdOption] === "on"
        }
        target: mpdState
    }
}
