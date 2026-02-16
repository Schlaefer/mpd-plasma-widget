import QtQuick
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
// @TODO QT6
import Qt5Compat.GraphicalEffects
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Label {
    property int fontSize

    // Naive way to find out if we are on light or dark theme/text
    property bool isDark: PlasmaCore.Theme.backgroundColor.hslLightness < 0.5

    font.pointSize: main.cfgFontSize
    horizontalAlignment: main.cfgAlignment == 2 ? Text.AlignRight : (main.cfgAlignment == 1 ? Text.AlignHCenter : Text.AlignLeft)
    elide: Text.ElideRight
    Layout.fillWidth: true

    layer.enabled: !main.cfgSolidBackground
    // @TODO looks to strong in light plasma theme/desktop background
    layer.effect: DropShadow {
        verticalOffset: 1
        horizontalOffset: 0
        color: isDark ? "#66000000" : "#20FFFFFF"
        spread: isDark ? 0.4 : 0.7
        radius: isDark ? 6 : 4
        samples: 17
    }
}
