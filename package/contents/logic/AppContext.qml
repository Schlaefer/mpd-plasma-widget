pragma ComponentBehavior: Bound
pragma Singleton

import QtQuick
import org.kde.kirigami as Kirigami
import "./../logic"

QtObject {
    id: root

    property int initialHeight: 900
    property int narrowBreakPoint: 520
    property string cacheRoot
    property string cacheForDays
    property string mpdHost
    property string mpdPort

    // Don't expose it raw, always isolate a specific functionality with a method here.
    property Kirigami.ApplicationItem _app

    property VolumeState _volumeState
    property Component _volumeStateComponent: Component { VolumeState { }}

    property CoverManager _coverManager
    property Component _coverManagerComponent: Component { CoverManager { }}

    property MpdState _mpdState
    property Component _mpdStateComponent:Component { MpdState { }}


    function bootstrap(config) {
        if (!cacheRoot || !cacheForDays || !mpdHost || !mpdPort) {
            throw new Error("AppContext.bootstrap failed without proper initialization.")
        }

        root._coverManager = _coverManagerComponent.createObject(null, {
            cfgCacheForDays: Qt.binding(() => root.cacheForDays),
            cfgCacheRoot: Qt.binding(() => root.cacheRoot),
        })

        root._mpdState = _mpdStateComponent.createObject(null, {
            cfgMpdHost: Qt.binding(() => root.mpdHost),
            cfgMpdPort: Qt.binding(() => root.mpdPort),
            scriptRoot: config.scriptRoot
        })
        root._mpdState.coverManager = root._coverManager

        root._volumeState = _volumeStateComponent.createObject(null, {
            mpdState: root._mpdState
        })

        root._coverManager.mpdState = root._mpdState

        root._coverManager.bootstrap()
        root._mpdState.connect()

        return true
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
