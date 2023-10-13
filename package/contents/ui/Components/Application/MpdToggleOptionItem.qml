import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2

QQC2.ToolButton {
    id: root

    property string iconName
    property string itSc
    property string itTtp
    property string itOpt

    checkable: true
    icon.name: modelData.iconName

    QQC2.ToolTip {
        text: modelData.itTtp + " (" + modelData.itSc.toUpperCase() + ")"
    }

    Shortcut {
        sequence: modelData.itSc
        onActivated: root.checked = !root.checked
    }

    onCheckedChanged: {
        // This catches ourself immediatly reversing the command we got from mpd
        let localState = mpdState.mpdOptions[itOpt] === "on"
        if (root.checked === localState) {
            return
        }
        mpdState.toggleOption(itOpt)
    }

    Connections {
        function onMpdOptionsChanged() {
            // This catches us getting our own cmd replied, so don't act on it.
            let localState = mpdState.mpdOptions[itOpt] === "on"
            if (root.checked === localState) {
                return
            }
            root.checked = mpdState.mpdOptions[itOpt] === "on"
        }
        target: mpdState
    }

}
