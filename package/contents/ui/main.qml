import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: main

    property alias appWindow: appWindowLoader.item
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

    Component.onCompleted: {
    //    toggleAppWindow()
    }

    function toggleAppWindow() {
        if (!appWindowLoader.item) {
            appWindowLoader.setSource(
                        "Components/Application/ApplicationWindow.qml",
                        { initialHeight: 0.95 * Plasmoid.availableScreenRect.height })
        } else {
            appWindowLoader.item.visible = appWindowLoader.item.visible ? false : true
        }
        appWindowUnloader.restart()
    }

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
        // @TODO currently used to access volmeslider
        id: widgetLayout
        anchors.fill: parent
    }

    Loader {
        id: appWindowLoader
    }

    Timer {
        id: appWindowUnloader
        interval: 120000
        onTriggered: {
            if (appWindowLoader.item.visible) {
                start()
                return
            }
            appWindowLoader.source = ""
            mpdState.library = undefined
        }
    }
}
