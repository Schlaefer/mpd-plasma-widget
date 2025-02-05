import QtQuick
import QtQuick.Layouts
// @TODO QT6
import Qt5Compat.GraphicalEffects
import org.kde.plasma.components as PlasmaComponents

PlasmaComponents.Label {
    property int fontSize

    font.pointSize: main.cfgFontSize
    horizontalAlignment: main.cfgAlignment == 2 ? Text.AlignRight : (main.cfgAlignment == 1 ? Text.AlignHCenter : Text.AlignLeft)
    elide: Text.ElideRight
    Layout.fillWidth: true

    layer.enabled: !main.cfgSolidBackground
    // @TODO looks to strong in light plasma theme/desktop background
    layer.effect: DropShadow {
        verticalOffset: 1
        horizontalOffset: 0
        color: "#66000000"
        spread: 0.4
        radius: 6
        samples: 17
    }
}
