import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: mpdRoot

    property var coverManager
    property string scriptRoot
    property string mpdHost: ""
    property string mpdFile: ""
    property int mpdVolume: 0
    property var mpdInfo: {

    }
    property var mpdQueue: {

    }
    property var mpdOptions: {

    }
    property var mpdPlaylists: {

    }

    function startup() {
        update()
        mpdRootIdleLoopTimer.start()
    }

    function reconnect() {
        mpdRootExecutable.sources.forEach(source => {
                                              mpdRootExecutable.disconnectSource(
                                                  source)
                                          })
        mpdRoot.update()
    }

    function update() {
        mpdRoot.getInfo()
        mpdRoot.getVolume()
        mpdRoot.getQueue()
        mpdRoot.getPlaylists()
        mpdRoot.getOptions()
    }

    function getVolume() {
        mpdRootExecutable.exec(
                    "mpc --host=" + mpdRoot.mpdHost + " volume" + " #getVolume")
    }

    function setVolume(value) {
        mpdRootExecutable.exec(
                    "mpc --host=" + mpdRoot.mpdHost + " volume " + value + " #update")
    }

    function run(cmd) {
        mpdCommandQueue.add(cmd)
    }

    function getInfo() {
        mpdRootExecutable.exec(
                    "mpc --host=" + mpdRoot.mpdHost
                    + " -f '{[\\n\"artist\": \"%artist%\", ][\\n\"albumartist\": \"%albumartist%\", ][\\n\"album\": \"%album%\", ][\\n\"tracknumber\": \"%track%\", ]\\n\"title\": \"%title%\", [\\n\"date\": \"%date%\", ]\\n\"file\": \"%file%\"\\n}' | head -n -2 #getInfo")
    }

    function removeFromQueue(position) {
        mpdCommandQueue.add(
                    "mpc --host=" + mpdRoot.mpdHost + " del " + position)
    }

    function playNext() {
        mpdRootExecutable.exec("mpc --host=" + mpdRoot.mpdHost + " next")
    }

    function toggle() {
        mpdRootExecutable.exec("mpc --host=" + mpdRoot.mpdHost + " toggle")
    }

    function clearPlaylist() {
        mpdCommandQueue.add("mpc --host=" + mpdRoot.mpdHost + " clear")
    }

    function getQueue() {
        mpdRootExecutable.exec(
                    "mpc --host=" + mpdRoot.mpdHost
                    + " playlist -f '\"%file%\": {[\\n\"artist\": \"%artist%\", ][\\n\"albumartist\": \"%albumartist%\", ][\\n\"album\": \"%album%\", ][\\n\"tracknumber\": \"%track%\", ]\\n\"title\": \"%title%\", [\\n\"date\": \"%date%\", ]\\n\"file\": \"%file%\",\\n\"position\": \"%position%\"},' #getQueue")
    }

    function debugJournal(msg) {
        mpdRootExecutable.exec('echo "' + msg + '" | systemd-cat -p err;')
    }

    function playInQueue(title) {
        mpdCommandQueue.add(
                    "sleep 1 && mpc --host=" + mpdRoot.mpdHost + " play \"" + title + "\"")
    }

    function getPlaylists() {
        mpdRootExecutable.exec(
                    "mpc --host=" + mpdRoot.mpdHost + " lsplaylist #getPlaylists")
    }

    function playPlaylist(playlist) {
        clearPlaylist()
        addPlaylistToQueue(playlist)
        playInQueue(1)
    }

    function getOptions() {
        mpdRootExecutable.exec(
                    "mpc --host=" + mpdRoot.mpdHost
                    + " status '{\"consume\": \"%consume%\", \"random\": \"%random%\"}' #getOptions")
    }

    function toggleRandom() {
        let newState = mpdRoot.mpdOptions.random === "on" ? "off" : "on"
        mpdCommandQueue.add(
                    "mpc --host=" + mpdRoot.mpdHost + " random " + newState)
    }

    function toggleConsume() {
        let newState = mpdRoot.mpdOptions.consume === "on" ? "off" : "on"
        mpdCommandQueue.add(
                    "mpc --host=" + mpdRoot.mpdHost + " consume " + newState)
    }

    function addPlaylistToQueue(playlist) {
        mpdCommandQueue.add(
                    "mpc --host=" + mpdRoot.mpdHost + " load \"" + playlist + "\"")
    }

    function getCover(title, ctitle, root, prefix) {
        let cmd = ''
        cmd += '/usr/bin/env bash'
        cmd += ' "' + mpdRoot.scriptRoot + '/downloadCover.sh"'
        cmd += ' ' + mpdRoot.mpdHost
        cmd += ' "' + title.replace(/"/g, '\\"') + '"'
        cmd += ' "' + root + '"'
        cmd += ' ' + prefix
        cmd += ' "' + ctitle.replace('/', '\\\\/') + '"'
        cmd += ' #readpicture'
        mpdRootExecutable.exec(cmd)
    }

    // Throttle commands so we don't miss results on the event loop because we
    // sending to fast.
    Timer {
        id: mpdCommandQueue

        property var cmdQueue: []

        function add(cmd) {
            cmdQueue.push(cmd)
        }

        interval: 500
        running: true
        repeat: true
        onTriggered: {
            if (cmdQueue.length === 0)
                return

            let cmd = cmdQueue.shift()
            mpdRootExecutable.exec(cmd)
        }
    }

    // Mpc idle loop. After a mpc-event is registered and handled almost
    // immediately reconnect the shut down connection.
    Timer {
        id: mpdRootIdleLoopTimer

        interval: 10
        running: false
        repeat: false
        onTriggered: {
            mpdRootExecutable.exec(
                        'mpc --host=' + mpdRoot.mpdHost
                        + ' idle player mixer playlist options #idleLoop')
        }
    }

    // Handles network issues. E.g. if the network card needs a few seconds to
    // become available after a system resume. Or the device is moved in and out
    // of places with the mpd server (un)available.
    Timer {
        id: mpdRootNetworkTimeout

        interval: 500
        running: false
        onTriggered: {
            // Gradually increase reconnect time until we find a minimum time
            // necessary for a device stationary within the mpd network (desktop).
            // At worst try a reconnect every minute (devices leaving the
            // local network like laptops).
            if (interval < 60000)
                interval = interval + 500

            mpdRoot.reconnect()
        }
    }

    // Watchdog for system sleep/wake cycles. If we detect a "lost timespan" we
    // assume the mpc idle connection is no longer valid and needs a reconnect.
    Timer {
        id: mpdRootReconnectTimer

        property int lastRun: Date.now() / 1000

        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            if ((2 * interval / 1000 + lastRun) < (Date.now() / 1000))
                mpdRoot.reconnect()

            lastRun = Date.now() / 1000
        }
    }

    PlasmaCore.DataSource {
        id: mpdRootExecutable

        signal exited(int exitCode, int exitStatus, string stdout, string stderr, string sourceName)

        function exec(cmd) {
            connectSource(cmd)
        }

        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"]
            var exitStatus = data["exit status"]
            var stdout = data["stdout"]
            var stderr = data["stderr"]
            exited(exitCode, exitStatus, stdout, stderr, sourceName)
            disconnectSource(sourceName) // cmd finished
        }
    }

    Connections {
        function onSourceRemoved(source) {
            // Restart the idle loop
            if (source.includes("#idleLoop"))
                mpdRootIdleLoopTimer.start()
        }

        function onExited(exitCode, exitStatus, stdout, stderr, source) {
            root.appLastError = stderr || ""

            if (stderr !== "" && !stderr.includes("No data")) {
                mpdRootNetworkTimeout.start()
                return
            }

            if (source.includes("#readpicture")) {
                coverManager.markFetched(stdout, !stderr.includes("No data"))
                return
            }

            if (source.includes("#idleLoop")) {
                if (stdout.includes('player'))
                    mpdRoot.getInfo()

                if (stdout.includes('mixer'))
                    mpdRoot.getVolume()

                if (stdout.includes('options'))
                    mpdRoot.getOptions()

                if (stdout.includes('playlist')) {
                    mpdRoot.getQueue()
                    mpdRoot.getPlaylists()
                    // Mpc spams a new "playlist" event for every song added to the
                    // queue, so maybe dozens if e.g. an album/playlist is added.
                    // That's to fast for us to catch the last "player" event. We have
                    // to check what is playing after the queue changes.
                    mpdRoot.getInfo()
                }
            } else if (source.includes("#getVolume")) {
                mpdRoot.mpdVolume = parseInt(stdout.match(/volume:\W*(\d*)/)[1])
            } else if (source.includes("#getInfo")) {
                // @TODO empty playlit
                if (!stdout)
                    return

                let data = JSON.parse(stdout)
                mpdRoot.mpdFile = data.file
                mpdRoot.mpdInfo = data
            } else if (source.includes("#getQueue")) {
                let queue = JSON.parse("{" + stdout.slice(0, -2) + "}")
                mpdRoot.mpdQueue = queue
            } else if (source.includes("#getPlaylists")) {
                let playlists = stdout.split("\n")
                playlists = playlists.filter(value => {
                                                 return value
                                                 && !value.includes('m3u')
                                             })
                playlists = playlists.sort((a, b) => {
                                               let textA = a.toUpperCase()
                                               let textB = b.toUpperCase()
                                               return (textA < textB) ? -1 : (textA > textB) ? 1 : 0
                                           })
                mpdRoot.mpdPlaylists = playlists
            } else if (source.includes("#getOptions")) {
                mpdRoot.mpdOptions = JSON.parse(stdout)
            }
        }

        target: mpdRootExecutable
    }
}
