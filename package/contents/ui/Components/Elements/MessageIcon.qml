pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw
import "../../../logic"

Kirigami.Icon {
    id: root

    visible: !!tooltip.text
    source: Mpdw.icons.appMpdError
    fallback: Mpdw.icons.appError

    MouseArea {
        id: meF

        anchors.fill: parent
        hoverEnabled: true

        ToolTip {
            id: tooltip
            visible: meF.containsMouse
        }
    }

    Component.onCompleted: {
        tooltip.text = ErrorHandler.lastError
    }

    Connections {
        target: ErrorHandler
        function onLastErrorChanged() {
            tooltip.text = ErrorHandler.lastError
        }
    }
}
