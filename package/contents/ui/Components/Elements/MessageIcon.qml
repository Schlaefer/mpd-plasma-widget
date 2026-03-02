pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw

Kirigami.Icon {
    id: root

    property alias message: tooltip.text

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
}
