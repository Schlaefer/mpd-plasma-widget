import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "./../logic"

PlasmoidItem {
    id: main

    property bool cfgHorizontalLayout: Plasmoid.configuration.cfgHorizontalLayout
    property bool cfgSolidBackground: Plasmoid.configuration.cfgSolidBackground
    property int cfgnarrowBreakPoint: Plasmoid.configuration.cfgnarrowBreakPoint
    property int cfgCornerRadius: Plasmoid.configuration.cfgCornerRadius
    property int cfgFontSize: Plasmoid.configuration.cfgFontSize
    property int cfgShadowSpread: Plasmoid.configuration.cfgShadowSpread
    property string cfgAlignment: Plasmoid.configuration.cfgAlignment
    property string cfgCacheForDays: Plasmoid.configuration.cfgCacheForDays
    property string cfgCacheRoot: Plasmoid.configuration.cfgCacheRoot // without trailing slash
    property string cfgMpdHost: Plasmoid.configuration.cfgMpdHost
    property string cfgMpdPort: Plasmoid.configuration.cfgMpdPort
    property string cfgShadowColor: Plasmoid.configuration.cfgShadowColor

    property var _appWindow: null
    property string appLastError: ""

    // Make sure a somewhat reasonable layout with text and cover image is visible
    // when the user puts the widget on the desktop for the first time.
    // Layout.minimumHeight: cfgHorizontalLayout ? 40 : 180
    // Layout.minimumWidth: cfgHorizontalLayout ? 150 : 50
    // @TODO QT6
    width: 300
    height: 410

    Plasmoid.backgroundHints: cfgSolidBackground ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground

    function toggleAppWindow() {
        if (!_appWindow) {
            var component = Qt.createComponent("Components/Application/ApplicationWindow.qml")

            if (component.status === Component.Error) {
                console.error(component.errorString());
                return;
            }

            main._appWindow = component.createObject(null, {
                initialHeight: availableScreenRect.height,
                mpdState: mpdState,
                narrowBreakPoint: cfgnarrowBreakPoint,
                volumeState: volumeState
            })
            main._appWindow.visible = true
        } else {
            main._appWindow.visible = !main._appWindow.visible
        }
    }

    function unloadAppWindow() {
        if (_appWindow) {
            _appWindow?.destroy()
            _appWindow = null
        }

        mpdState.clearLibrary()
    }

    CoverManager {
        id: coverManager
    }

    MpdState {
        id: mpdState
        // @TODO does this need decodeURIComponent?
        scriptRoot: Qt.resolvedUrl('../scripts').toString().replace("file://", "")
    }

    VolumeState {
        id: volumeState
    }

    // Widget shown on desktop
    WidgetLayout {
        id: widgetLayout
        anchors.fill: parent

        main: main
        mpdState: mpdState
        volumeState: volumeState
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

    Connections {
        id: appWindowConnections
        target: main._appWindow

        function onVisibleChanged() {
            if (main._appWindow && main._appWindow.visible) {
                appWindowUnloader.stop()
            } else {
                appWindowUnloader.start()
            }
        }
    }

    Timer {
        id: appWindowUnloader
        interval: 120000
        onTriggered: {
            if (main._appWindow.visible) {
                start()
                return
            }
            main.unloadAppWindow()
        }
    }

    // Development convenience to automatically open the app window on widget start.
    Timer {
        running: true
        interval: 200
        onTriggered: {
           // toggleAppWindow()
        }
    }
}
