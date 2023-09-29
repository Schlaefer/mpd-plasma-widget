import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    property bool cfgHorizontalLayout: Plasmoid.configuration.cfgHorizontalLayout
    property bool cfgSolidBackground: Plasmoid.configuration.cfgSolidBackground
    property int cfgCornerRadius: Plasmoid.configuration.cfgCornerRadius
    property int cfgFontSize: Plasmoid.configuration.cfgFontSize
    property int cfgShadowSpread: Plasmoid.configuration.cfgShadowSpread
    property string cfgAlignment: Plasmoid.configuration.cfgAlignment
    property string cfgCacheForDays: Plasmoid.configuration.cfgCacheForDays
    property string cfgCacheRoot: Plasmoid.configuration.cfgCacheRoot // without trailing slash
    property string cfgMpdHost: Plasmoid.configuration.cfgMpdHost
    property string cfgShadowColor: Plasmoid.configuration.cfgShadowColor

    property string appLastError: ""

    Layout.preferredWidth: 300
    Layout.preferredHeight: 410
    Plasmoid.backgroundHints: cfgSolidBackground ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

    Connections {
        function onCfgMpdHostChanged() {
            mpdState.connect()
        }
    }

    CoverManager {
        id: coverManager
    }

    MpdState {
        id: mpdState
        scriptRoot: plasmoid.file('', 'scripts/')
    }

    // Widget shown on desktop
    WidgetLayout {
        anchors.fill: parent
    }

    // Popup Dialog
    WidgetApplication {
        id: popupDialog
    }
}
