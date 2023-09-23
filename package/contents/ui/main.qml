import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    property string mpdHost: Plasmoid.configuration.mpdHost
    property string descriptionAlignment: Plasmoid.configuration.descriptionAlignment
    property bool cfgHorizontalLayout: Plasmoid.configuration.cfgHorizontalLayout
    property int cfgFontSize: Plasmoid.configuration.cfgFontSize
    // path without leading slash
    property string cfgCacheRoot: Plasmoid.configuration.cfgCacheRoot
    property bool cfgCacheMultiple: Plasmoid.configuration.cfgCacheMultiple
    property string appLastError: ""

    Layout.preferredWidth: 300
    Layout.preferredHeight: 410
    // Allow user to toggle background transparency
    Plasmoid.backgroundHints: PlasmaCore.Types.StandardBackground | PlasmaCore.Types.ConfigurableBackground
    Component.onCompleted: {
        mpdState.startup();
    }

    Connections {
        function onMpdHostChanged() {
            mpdState.startup();
        }

    }

    MpdState {
        id: mpdState

        mpdHost: root.mpdHost
        cacheRoot: root.cfgCacheRoot
        cacheMultiple: root.cfgCacheMultiple
        scriptRoot: plasmoid.file('', 'scripts/')
    }

    // Main layout of the widget
    WidgetLayout {
        anchors.fill: parent
        mpd: mpdState
    }

    WidgetApplication {
        id: popupDialog

        mpd: mpdState
    }

}
