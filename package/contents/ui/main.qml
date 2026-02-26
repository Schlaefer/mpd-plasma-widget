pragma ComponentBehavior: Bound

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import "./../logic"
import "./Components/CompactPresentation"
import "../scripts/formatHelpers.js" as FormatHelpers

PlasmoidItem {
    id: main

    property bool cfgHorizontalLayout: Plasmoid.configuration.cfgHorizontalLayout
    property bool cfgSolidBackground: Plasmoid.configuration.cfgSolidBackground
    property int cfgNarrowBreakPoint: Plasmoid.configuration.cfgNarrowBreakPoint
    property int cfgCornerRadius: Plasmoid.configuration.cfgCornerRadius
    property int cfgFontSize: Plasmoid.configuration.cfgFontSize
    property int cfgShadowSpread: Plasmoid.configuration.cfgShadowSpread
    property int cfgAlignment: Plasmoid.configuration.cfgAlignment
    property string cfgCacheForDays: Plasmoid.configuration.cfgCacheForDays
    property string cfgCacheRoot: Plasmoid.configuration.cfgCacheRoot // without trailing slash
    property string cfgMpdHost: Plasmoid.configuration.cfgMpdHost
    property string cfgMpdPort: Plasmoid.configuration.cfgMpdPort
    property string cfgShadowColor: Plasmoid.configuration.cfgShadowColor

    property bool bootstrapFinished: false
    property MpdState mpdState
    property VolumeState volumeState

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

    Component.onCompleted: {
        AppContext.narrowBreakPoint = Qt.binding(() => main.cfgNarrowBreakPoint)
        AppContext.bootstrap({
            cfgCacheForDays: main.cfgCacheForDays,
            cfgCacheRoot: main.cfgCacheRoot,
            cfgMpdHost: main.cfgMpdHost,
            cfgMpdPort: main.cfgMpdPort,
            // @TODO does this need decodeURIComponent?
            scriptRoot: Qt.resolvedUrl('../scripts').toString().replace("file://", "")
        })
        main.mpdState = AppContext.getMpdState()
        main.volumeState = AppContext.getVolumeState()
        main.bootstrapFinished = true
    }

    compactRepresentation: Loader {
        active: main.bootstrapFinished
        sourceComponent: CompactPresentation {
            main: main
            mpdState: main.mpdState
            volumeState: main.volumeState
        }
    }

    // @BOGUS What does that do?
    Plasmoid.status: PlasmaCore.Types.PassiveStatus
    toolTipMainText: {
        if (!main.mpdState.mpdInfo || main.mpdState.mpdQueue.length === 0 ) {
            return qsTr("Queue is empty")
        }
        const out = FormatHelpers.title(main.mpdState.mpdInfo)
        + "\n" + FormatHelpers.artist(main.mpdState.mpdInfo)
        + "\n" + FormatHelpers.album(main.mpdState.mpdInfo)

        return out
    }
    toolTipSubText: qsTr("Middle-click to play/pause.\nScroll to adjust volume")
    toolTipTextFormat: Text.PlainText

    Plasmoid.contextualActions: [
        PlasmaCore.Action {
            text: qsTr("Open MPD Window")
            onTriggered: main.toggleAppWindow()
        },
        PlasmaCore.Action {
            isSeparator: true
            priority: PlasmaCore.Action.LowPriority
        },
        PlasmaCore.Action {
            text: qsTr("Pause")
            icon.name: "media-playback-pause"
            priority: PlasmaCore.Action.LowPriority
            visible: main.mpdState.mpdPlaying
            enabled: visible
            onTriggered: main.mpdState.togglePlayPause()
        },
        PlasmaCore.Action {
            text: qsTr("Play")
            icon.name: "media-playback-start"
            priority: PlasmaCore.Action.LowPriority
            visible: !main.mpdState.mpdPlaying && main.mpdState.mpdQueue.length > 0
            enabled: visible
            onTriggered: main.mpdState.togglePlayPause()
        },
        PlasmaCore.Action {
            text: qsTr("Next Track")
            icon.name: Application.layoutDirection === Qt.RightToLeft ? "media-skip-backward" : "media-skip-forward"
            priority: PlasmaCore.Action.LowPriority
            enabled: main.mpdState.mpdQueue.length > 0
            onTriggered: main.mpdState.playNext()
        },
        PlasmaCore.Action {
            isSeparator: true
        }
    ]

    // Widget shown on desktop
    fullRepresentation: Loader {
        active: main.bootstrapFinished
        sourceComponent: WidgetLayout {
            id: widgetLayout
            anchors.fill: parent

            alignment: main.cfgAlignment
            cornerRadius: main.cfgCornerRadius
            fontSize: main.cfgFontSize
            horizontalLayout: main.cfgHorizontalLayout
            shadowColor: main.cfgShadowColor
            shadowSpread: main.cfgShadowSpread
            solidBackground: main.cfgSolidBackground

            main: main
            mpdState: main.mpdState
            volumeState: main.volumeState
        }
    }

    Connections {
        function onCfgMpdHostChanged() {
            main.mpdState.connect()
        }
    }

    Connections {
        target: main.mpdState
        function onError(error) {
            main.appLastError = error
        }
    }

    Connections {
        target: AppContext.getCoverManager()
        function onAfterReset() {
            main.unloadAppWindow()
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

    function toggleAppWindow() {
        if (!_appWindow) {
            const component = Qt.createComponent("Components/Application/ApplicationWindow.qml")
            // Don't put into Component.onCompleted with the rest of the bootstrap. It
            // wont provide the right value.
            AppContext.initialHeight = availableScreenRect.height
            // Don't provide any initializing properties here. We want to keep the app
            // window isolated from the plasmoid utilizing AppContext as global config
            // provider.
            main._appWindow = component.createObject()
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

    // Development convenience to automatically open the app window on widget start.
    Timer {
        running: true
        interval: 400
        onTriggered: {
            // toggleAppWindow()
        }
    }
}
