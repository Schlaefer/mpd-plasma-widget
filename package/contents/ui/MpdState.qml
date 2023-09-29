import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: mpdRoot

    property bool mpcAvailable: false
    property bool mpcConnectionAvailable: false
    property string scriptRoot
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


    /**
     * Starts the bootstrap process of a fresh connection to the mpd instance
     */
    function connect() {
        if (mpcAvailable !== true) {
            mpdRoot.checkMpcAvailable()
            return
        }

        disconnect()
        checkMpcConnectionAvailable()
    }


    /**
     * Stops the current connection to the mpd instance
     */
    function disconnect() {
        mpdRootExecutable.sources.forEach(source => {
                                              mpdRootExecutable.disconnectSource(
                                                  source)
                                          })
        mpdRoot.mpcConnectionAvailable = false
        mpdRootIdleLoopTimer.stop()
    }


    /**
     * Inits check if mpc binary available on the host system
     */
    function checkMpcAvailable() {
        mpdRootExecutable.exec('which mpc #checkMpcAvailable')
    }


    /**
     * Evaluates result if mpc binary is available on the host system
     *
     * Bootstraps MpdState executation if mpc binary is found. If so try to connect.
     */
    function onExecCheckMpcAvailable(exitCode, exitStatus, stdout, stderr) {
        if (exitCode !== 0) {
            root.appLastError = qsTr(
                        "'mpc' binary wasn't found. - Please install mpc on your system. It is probably available in your system's package manager.")

            return
        }

        mpdRoot.mpcAvailable = true
        mpdRoot.connect()
    }


    /**
     * Inits request if mpc is able to connect to mpd
     */
    function checkMpcConnectionAvailable() {
        if (mpcAvailable !== true) {
            return
        }

        mpdRootExecutable.exec(
                    "mpc --host=" + cfgMpdHost + " status #checkMpcConnectionAvailable")
    }


    /**
     * Evaluates check if mpc was able to connect to mpd
     */
    function onExecCheckMpcConnectionAvailable(exitCode, exitStatus, stdout, stderr) {
        if (exitCode !== 0) {
            root.appLastError = fmtErrorMessage(stderr)
            mpdRootNetworkTimeout.start()

            return
        }

        mpdRootNetworkTimeout.interval = mpdRootNetworkTimeout.startInterval
        mpdRootIdleLoopTimer.start()
        mpcConnectionAvailable = true
        update()
    }


    /**
     * Replace mpc error messages with our own
     *
     * @param {string} msg The mpc error message
     */
    function fmtErrorMessage(msg) {
        let fmtMsg = msg
        if (fmtMsg.includes("No route to host")) {
            fmtMsg = qsTr(
                        "Can't find the MPD-server. - Check the MPD-address in the widget configuration.")
        } else if (fmtMsg.includes("Network is unreachable")) {
            fmtMsg = qsTr("No network connection.")
        }

        return fmtMsg
    }


    /**
     * Inits update of all mpd data required by our plasmoid
     */
    function update() {
        mpdRoot.getInfo()
        mpdRoot.getVolume()
        mpdRoot.getQueue()
        mpdRoot.getPlaylists()
        mpdRoot.getOptions()
    }

    function getVolume() {
        mpcExec("volume" + " #getVolume")
    }

    function setVolume(value) {
        mpcExec("volume " + value + " #update")
    }

    function getInfo() {
        mpcExec("-f '{[\\n\"artist\": \"%artist%\", ][\\n\"albumartist\": \"%albumartist%\", ][\\n\"album\": \"%album%\", ][\\n\"tracknumber\": \"%track%\", ]\\n\"title\": \"%title%\", [\\n\"date\": \"%date%\", ]\\n\"file\": \"%file%\"\\n}' | head -n -2 #getInfo")
    }

    function removeFromQueue(position) {
        mpdCommandQueue.add("del " + position)
    }

    function playNext() {
        mpcExec("next")
    }

    function toggle() {
        mpcExec("toggle")
    }

    function clearPlaylist() {
        mpdCommandQueue.add("clear")
    }

    function getQueue() {
        mpcExec("playlist -f '\"%file%\": {[\\n\"artist\": \"%artist%\", ][\\n\"albumartist\": \"%albumartist%\", ][\\n\"album\": \"%album%\", ][\\n\"tracknumber\": \"%track%\", ]\\n\"title\": \"%title%\", [\\n\"date\": \"%date%\", ]\\n\"file\": \"%file%\",\\n\"position\": \"%position%\"},' #getQueue")
    }

    function playInQueue(title) {
        mpdCommandQueue.add("play \"" + title + "\"")
    }

    function getPlaylists() {
        mpcExec("lsplaylist #getPlaylists")
    }

    function playPlaylist(playlist) {
        clearPlaylist()
        addPlaylistToQueue(playlist)
        playInQueue(1)
    }

    function getOptions() {
        mpcExec("status '{\"consume\": \"%consume%\", \"random\": \"%random%\"}' #getOptions")
    }

    function toggleRandom() {
        let newState = mpdRoot.mpdOptions.random === "on" ? "off" : "on"
        mpdCommandQueue.add("random " + newState)
    }

    function toggleConsume() {
        let newState = mpdRoot.mpdOptions.consume === "on" ? "off" : "on"
        mpdCommandQueue.add("consume " + newState)
    }

    function addPlaylistToQueue(playlist) {
        mpdCommandQueue.add("load \"" + playlist + "\"")
    }

    function getCover(title, ctitle, root, prefix) {
        let cmd = ''
        cmd += '/usr/bin/env bash'
        cmd += ' "' + mpdRoot.scriptRoot + '/downloadCover.sh"'
        cmd += ' ' + cfgMpdHost
        cmd += ' "' + title.replace(/"/g, '\\"') + '"'
        cmd += ' "' + root + '"'
        cmd += ' ' + prefix
        cmd += ' "' + ctitle.replace('/', '\\\\/') + '"'
        cmd += ' #readpicture'
        mpdRootExecutable.exec(cmd)
    }

    function countQueue() {
        return Object.keys(mpdRoot.mpdQueue).length
    }


    /**
     * Executes mpc commands
     *
     * @param {string} cmd Command to execute
     */
    function mpcExec(cmd) {
        if (mpcAvailable !== true || mpcConnectionAvailable !== true) {
            return
        }
        mpdRootExecutable.exec("mpc --host=" + cfgMpdHost + " " + cmd)
    }

    // Throttle commands so we don't miss results on the event loop because we
    // sending to fast.
    Timer {
        id: mpdCommandQueue

        property var cmdQueue: []

        interval: 500
        running: true
        repeat: true

        function add(cmd) {
            cmdQueue.push(cmd)
        }

        onTriggered: {
            if (cmdQueue.length === 0) {
                return
            }

            let cmd = cmdQueue.shift()
            mpdRoot.mpcExec(cmd)
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
            mpdRoot.mpcExec('idle player mixer playlist options #idleLoop')
        }
    }

    // Handles network issues. E.g. if the network card needs a few seconds to
    // become available after a system resume. Or the device is moved in and out
    // of places with the mpd server (un)available.
    Timer {
        id: mpdRootNetworkTimeout

        property int startInterval: 500

        interval: startInterval
        running: false
        triggeredOnStart: true
        onTriggered: {
            disconnect()

            // Gradually increase reconnect time until we find a minimum time
            // necessary for a device stationary within the mpd network (desktop).
            // At worst try a reconnect every minute (devices leaving the
            // local network like laptops).
            if (interval < 60000)
                interval = interval + 500

            mpdRoot.checkMpcConnectionAvailable()
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
                mpdRoot.startup()

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
        function onExited(exitCode, exitStatus, stdout, stderr, source) {
            root.appLastError = ""

            if (source.includes("#checkMpcAvailable")) {
                onExecCheckMpcAvailable(exitCode, exitStatus, stdout, stderr)
                return
            }

            if (source.includes("#checkMpcConnectionAvailable")) {
                onExecCheckMpcConnectionAvailable(exitCode, exitStatus,
                                                  stdout, stderr)
                return
            }

            if (exitCode !== 0) {
                if (stderr.includes("No data")) {
                    // "No data" answer from mpd is a succesfull request for us.
                    return
                }

                root.appLastError = fmtErrorMessage(stderr)
                mpdRootNetworkTimeout.start()

                return
            }

            if (source.includes("#readpicture")) {
                coverManager.markFetched(stdout, !stderr.includes("No data"))
                return
            }

            root.appLastError = stderr || ""

            if (source.includes("#idleLoop")) {
                // Restart the idle loop
                mpdRootIdleLoopTimer.start()

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
                    // @MAYBE Performance: could be throttled (with a timer?) so we don't constantly trigger a the queue/playlists refresh
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
