pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Label {
    id: root

    required property int alignment
    required property int fontSize
    required property bool solidBackground

    // Naive way to find out if we are on light or dark theme/text
    property bool isDark: color.hslLightness < 0.5

    textFormat: Text.PlainText
    font.pointSize: root.fontSize
    horizontalAlignment: root.alignment == 2 ? Text.AlignRight : (root.alignment == 1 ? Text.AlignHCenter : Text.AlignLeft)
    elide: Text.ElideRight
    Layout.fillWidth: true

    layer.enabled: root.solidBackground
    layer.effect: DropShadow {
        verticalOffset: 1
        horizontalOffset: 0
        color: root.isDark ? "#66000000" : "#20FFFFFF"
        spread: root.isDark ? 0.4 : 0.7
        radius: root.isDark ? 6 : 4
        samples: 17
    }
}
