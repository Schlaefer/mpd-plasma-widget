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
    property bool cfgShowVolumeSlider: Plasmoid.configuration.cfgShowVolumeSlider
    property int cfgNarrowBreakPoint: Plasmoid.configuration.cfgNarrowBreakPoint
    property int cfgCornerRadius: Plasmoid.configuration.cfgCornerRadius
    property int cfgFontSize: Plasmoid.configuration.cfgFontSize
    property bool cfgUseCustomFontColor: Plasmoid.configuration.cfgUseCustomFontColor
    property string cfgCustomFontColor: Plasmoid.configuration.cfgCustomFontColor
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

    height: cfgHorizontalLayout ? 80 : 410
    width: cfgHorizontalLayout ? 300 : 300

    Plasmoid.backgroundHints: cfgSolidBackground
        ? PlasmaCore.Types.StandardBackground
        : PlasmaCore.Types.NoBackground

    Component.onCompleted: {
        Plasmoid.configuration.runtimeIsClient = AppContext.bootstrapStarted
        if (!AppContext.bootstrapStarted) {
            AppContext.cacheRoot = Qt.binding(() => main.cfgCacheRoot)
            AppContext.cacheForDays = Qt.binding(() => main.cfgCacheForDays)
            AppContext.mpdHost = Qt.binding(() => main.cfgMpdHost)
            AppContext.mpdPort = Qt.binding(() => main.cfgMpdPort)
            const bootstrapped = AppContext.bootstrap({
                scriptRoot: decodeURIComponent(Qt.resolvedUrl('../scripts').toString().replace("file://", ""))
            })
            if (!bootstrapped) {
                throw new Error("Main bootstrapping failed.")
            }
        }

        main.mpdState = AppContext.getMpdState()
        main.volumeState = AppContext.getVolumeState()
        Plasmoid.configuration.appContext = AppContext
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

    toolTipMainText: {
        if (!main.mpdState.mpdInfo || main.mpdState.mpdQueue.length === 0 ) {
            return qsTr("Queue is empty")
        }
        return FormatHelpers.title(main.mpdState.mpdInfo)
    }
    toolTipSubText: {
        const out = [
            qsTr("by %1").arg(FormatHelpers.artist(main.mpdState.mpdInfo)),
            main.mpdState.isPlaying ?
                qsTr("Middle-click to pause") :
                qsTr("Middle-click to play"),
            qsTr("Scroll to adjust volume (%1\%)").arg(main.volumeState.volume),
        ]
        return out.join("\n")
    }
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
            visible: main.mpdState.isPlaying
            enabled: visible
            onTriggered: main.mpdState.togglePlayPause()
        },
        PlasmaCore.Action {
            text: qsTr("Play")
            icon.name: "media-playback-start"
            priority: PlasmaCore.Action.LowPriority
            visible: !main.mpdState.isPlaying && main.mpdState.mpdQueue.length > 0
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
            useCustomFontColor: main.cfgUseCustomFontColor
            customFontColor: main.cfgCustomFontColor
            horizontalLayout: main.cfgHorizontalLayout
            shadowColor: main.cfgShadowColor
            shadowSpread: main.cfgShadowSpread
            showVolumeSlider: main.cfgShowVolumeSlider
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
        interval: 120000 // 2 min
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
            if (component.status === Component.Error) {
                console.error("Component error:", component.errorString());
                return;
            }
            // Don't put into Component.onCompleted with the rest of the bootstrap. It
            // wont provide the right value.
            AppContext.initialHeight = availableScreenRect.height
            // Only provide initial values which are unique to the instance
            // configuration. We want to keep the app window isolated from the
            // plasmoid utilizing AppContext as global config provider.
            main._appWindow = component.createObject(null, {
                narrowBreakPoint: Qt.binding(() => main.cfgNarrowBreakPoint)
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
