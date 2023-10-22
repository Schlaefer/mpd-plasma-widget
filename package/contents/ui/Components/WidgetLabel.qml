import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.Label {
    property int fontSize

    font.pointSize: cfgFontSize
    horizontalAlignment: cfgAlignment == 2 ? Text.AlignRight : (cfgAlignment == 1 ? Text.AlignHCenter : Text.AlignLeft)
    elide: Text.ElideRight
    Layout.fillWidth: true

    layer.enabled: !cfgSolidBackground
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
