import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0
import "./../logic"

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
    property string cfgMpdPort: Plasmoid.configuration.cfgMpdPort
    property string cfgShadowColor: Plasmoid.configuration.cfgShadowColor

    property string appLastError: ""

    // Make sure a somewhat reasonable layout with text and cover image is visible
    // when the user puts the widget on the desktop for the first time.
    Layout.minimumHeight: cfgHorizontalLayout ? 40 : 180
    Layout.minimumWidth: cfgHorizontalLayout ? 150 : 50
    Plasmoid.backgroundHints: cfgSolidBackground ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

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

    function unloadAppWindow() {
        appWindowLoader.source = ""
        mpdState.library = undefined
    }

    CoverManager {
        id: coverManager
    }

    MpdState {
        id: mpdState
        scriptRoot: plasmoid.file('', 'scripts/')
    }

    VolumeState {
        id: volumeState
    }

    // Widget shown on desktop
    WidgetLayout {
        id: widgetLayout
        anchors.fill: parent
    }

    Connections {
        function onCfgMpdHostChanged() {
            mpdState.connect()
        }
    }

    Connections {
        target: coverManager
        function onAfterReset() {
            unloadAppWindow()
        }
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
            main.unloadAppWindow()
        }
    }

    Timer {
        running: true
        interval: 200
        onTriggered: {
            // toggleAppWindow()
        }
    }
}
