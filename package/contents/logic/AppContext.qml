pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import org.kde.kirigami as Kirigami
import "./../logic"

QtObject {
    id: root

    property int initialHeight: 900
    property int narrowBreakPoint: 520

    // Don't expose it raw, always isolate a specific functionality with a method here.
    property Kirigami.ApplicationItem _app

    property VolumeState _volumeState
    property Component _volumeStateComponent: Component { VolumeState { }}

    property CoverManager _coverManager
    property Component _coverManagerComponent: Component { CoverManager { }}

    property MpdState _mpdState
    property Component _mpdStateComponent:Component { MpdState { }}


    function bootstrap(config) {

        root._coverManager = _coverManagerComponent.createObject(null, {
            cfgCacheForDays: config.cfgCacheForDays,
            cfgCacheRoot: config.cfgCacheRoot,
        })

        root._mpdState = _mpdStateComponent.createObject(null, {
            cfgMpdHost: config.cfgMpdHost,
            cfgMpdPort: config.cfgMpdPort,
            scriptRoot: config.scriptRoot
        })
        root._mpdState.coverManager = root._coverManager

        root._volumeState = _volumeStateComponent.createObject(null, {
            mpdState: root._mpdState
        })

        root._coverManager.mpdState = root._mpdState

        root._coverManager.bootstrap()
        root._mpdState.connect()
    }

    function getCoverManager() {
        return root._coverManager
    }

    function getMpdState() {
        return root._mpdState
    }

    function getVolumeState() {
        return root._volumeState
    }

    function setApp(app) {
        root._app = app
    }

    function notify(msg, duration = Kirigami.Units.humanMoment) {
        root._app.showPassiveNotification(msg, duration)
    }
}
