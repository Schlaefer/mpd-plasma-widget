import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import "./Components"
import "../scripts/songLibrary.js" as SongLibrary

Item {
    id: mpdRoot

    signal gotPlaylist(var plData)
    signal onSaveQueueAsPlaylist(bool success)

    property bool mpcAvailable: false
    property bool mpcConnectionAvailable: false
    property int mpdVolume: 0
    property string mpdFile: ""
    property string scriptRoot
    property bool mpdPlaying: false
    property var library
    property bool libraryRequested: false
    property var mpdInfo: ({})
    property var mpdOptions: ({})
    property var mpdPlaylists: ({})
    property var mpdQueue: []
    readonly property string _songInfoQuery: '{[\x1Fartist\x1F:\x1F%artist%\x1F,][\x1Falbumartist\x1F:\x1F%albumartist%\x1F,][\x1Falbum\x1F:\x1F%album%\x1F,][\x1Ftracknumber\x1F:\x1F%track%\x1F,]\x1Ftitle\x1F:\x1F%title%\x1F,[\x1Fdate\x1F:\x1F%date%\x1F,]\x1Ftime\x1F:\x1F%time%\x1F,\x1Ffile\x1F:\x1F%file%\x1F,\x1Fposition\x1F:\x1F%position%\x1F},'

    readonly property var mpdCmds: {
        "cSongInfo": "-f '%1'",
        "connectionCheck": "mpc --host=%1 status",
        "lGet": "listall -f '%1'",
        "mpcCheck": "which mpc",
        "mpcIdleLoop": "idle player mixer playlist stored_playlist options",
        "optGet": "status '{\x1Fconsume\x1F:\x1F%consume%\x1F,\x1Frandom\x1F:\x1F%random%\x1F,\x1Frepeat\x1F:\x1F%repeat%\x1F}'",
        "optSet": "%1 %2",
        "plLoad": "load %1",
        "plGet": "playlist -f '%1' %2",
        "plRm": "rm -- %1",
        "plSave": "save -- %1",
        "plsGet": "lsplaylist",
        "qAdd": "add %1",
        "qClear": "clear",
        "qDel": "del %1",
        "qGet": "playlist -f '%1'",
        "qInsert": "insert %1",
        "qMove": "move %1 %2",
        "qNext": "next",
        "qPlay": "play %1",
        "qQueued": "queued -f '%1'",
        "qToggle": "toggle",
        "volumeGet": "volume",
        "volumeSet": "volume %1"
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
        executable.disconnect()
        mpdRoot.mpcConnectionAvailable = false
        mpdRootIdleLoopTimer.stop()
    }


    /**
     * Check if mpc binary available on the host system
     */
    function checkMpcAvailable() {
        let callback = function (exitCode) {
            if (exitCode !== 0) {
                return
            }

            mpdRoot.mpcAvailable = true
            mpdRoot.connect()
        }

        executable.exec(mpdCmds.mpcCheck, callback)
    }


    /**
     * Checks if mpc is able to connect to mpd
     */
    function checkMpcConnectionAvailable() {
        if (mpcAvailable !== true) {
            return
        }

        let callback = function (exitCode) {
            if (exitCode !== 0) {
                mpdRootNetworkTimeout.start()

                return
            }

            mpdRootNetworkTimeout.interval = mpdRootNetworkTimeout.startInterval
            mpdRootIdleLoopTimer.start()
            mpcConnectionAvailable = true
            update()

            if (libraryRequested) {
                getLibrary()
            }
        }

        // Bypass the build-in mpc faclities, they are gatekept by the result of this.
        executable.exec(mpdCmds.connectionCheck.arg(cfgMpdHost), callback)
    }

    function forceReloadEverything() {
        if (library) {
            mpdRoot.libraryRequested = true
        }
        connect()
    }

    /**
     * Inits update of all mpd data required by our plasmoid
     */
    // @TODO this should be disentangled and properly attached/requested by our now exiting
    // different views
    function update() {
        mpdRoot.getVolume()
        mpdRoot.getQueue()
        // @SOMEDAY make code more robust
        // Leave getInfo() after getQueue(), since it evaluates the queue content
        mpdRoot.getInfo()
        mpdRoot.getPlaylists()
        mpdRoot.getOptions()
    }


    /**
     * Download whole song library 
     */
    function getLibrary() {
        if (!mpcConnectionAvailable) {
            libraryRequested = true
        }
        executable.execMpc(mpdCmds.lGet.arg(_songInfoQuery), function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            library = new SongLibrary.SongLibrary(songInfoQueryResponseToJson(stdout))
        })
    }

    /**
     * Saves queue as playlist
     *
     * @param {sting} title playlist title in MPD
     */
    function saveQueueAsPlaylist(title) {
        executable.execMpc(mpdCmds.plSave.arg(bEsc(title)), function (exitCode) {
            if (exitCode !== 0) {
                return
            }
            onSaveQueueAsPlaylist(!exitCode)
        })
    }


    /**
     * Deletes a playlist
     *
     * @param {sting} title playlist title in MPD
     */
    function removePlaylist(title) {
        executable.execMpc(mpdCmds.plRm.arg(bEsc(title)))
    }


    /**
     * Moves song in queue
     *
     * @param {int} from Position of the song to move (current)
     * @param {int} to Positiong to move the song to (target)
     */
    function moveInQueue(from, to) {
        executable.execMpc(mpdCmds.qMove.arg(from).arg(to))
    }

    function getVolume() {
        executable.execMpc(mpdCmds.volumeGet, function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }

            let parsed = stdout.match(/volume:\W*(\d*)/)
            if (!parsed) {
                throw new Error("Invalid mpc response: No volume information in " + stdout)
            }

            mpdRoot.mpdVolume = parsed[1]
        })
    }

    /**
      * Set volume
      *
      * @param {string} Absolute <value> or +/-<value>
      */
    function setVolume(value) {
        executable.execMpc(mpdCmds.volumeSet.arg(value))
    }

    /**
      * Get info of currently playing song
      *
      * When mpd is stopped it evalutates what is going to be played next on
      * toggling "play".
      */
    function getInfo() {
        let cmd = mpdCmds.cSongInfo.arg(_songInfoQuery)
        executable.execMpc(cmd, function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            let info = stdout.split("\n")

            // Normal playback
            if (info.length > 2) {
                mpdInfo = songInfoQueryResponseToJson(info.shift())[0]
                mpdFile = mpdInfo.file

                mpdPlaying = info.shift().includes('[playing]')

                return
            }

            // Qeueue is paused or in stopped state
            mpdPlaying = false

            // Queue is empty, nothing will be played on a toggle
            if (mpdState.mpdQueue.length === 0) {
                return
            }

            // Only one item on the queue, it must be played on a toggle
            if (mpdState.mpdQueue.length === 1) {
                mpdInfo = mpdQueue[0]
                return
            }

            executable.execMpc(mpdCmds.qQueued.arg(_songInfoQuery), function (exitCode, stdout) {
                if (exitCode !== 0) {
                    return
                }

                if (stdout === "") {
                    // More than one item in Queue but nothing queued. a) Queue is
                    // stopped and was never started before (1st item will be played)
                    // or b) we are at the last item.
                    // Since we only create case (a) we ignore (b) for our purposes. 
                    mpdInfo = mpdQueue[0]
                    return
                }

                // Queue was started before, we just can't get the item directly,
                // so we cheat by asking for the next one.
                let queued = songInfoQueryResponseToJson(stdout)[0]
                mpdInfo = mpdQueue[queued.position - 2]
            })
        })
    }

    function getQueue() {
        let cmd = mpdCmds.qGet.arg(_songInfoQuery)
        executable.execMpc(cmd, function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            if (!stdout.length) {
                // Empty queue
                mpdQueue = []
                return
            }
            let queue = songInfoQueryResponseToJson(stdout)
            mpdRoot.mpdQueue = queue
        })
    }

    /**
      * Add songs to the queue
      *
      * @param {array} array of mpd file IDs
      * @param {string} insertion mode
      * - "append" at end of queue
      * - "insert" after currently playing track
      */
    function addSongsToQueue(items, mode = "append") {
        if (!Array.isArray(items)) {
            throw new Error("Invalid argument: items must be an array")
        }

        let cmd
        switch (mode) {
        case "append":
            cmd = mpdCmds.qAdd
            break
        case "insert":
            cmd = mpdCmds.qInsert
            break
        default:
            throw new Error("Invalid argument: unknown mode")
        }

        cmd = cmd.arg(items.map(function (item) { return bEsc(item) }).join(" "))

        mpdCommandQueue.add(cmd)
    }

    function replaceQueue(items) {
        clearQueue()
        addSongsToQueue(items)
        playInQueue(1)
    }

    /**
     * Removes items from the queue
     *
     * @param {array} positions Positions of items to remove from the queue
     */
    function removeFromQueue(positions) {
        if (!Array.isArray(positions)) {
            throw new Error("Invalid argument: positions must be an array")
        }
        executable.execMpc(mpdCmds.qDel.arg(positions.join(' ')))
    }

    function playNext() {
        executable.execMpc(mpdCmds.qNext)
    }

    function toggle() {
        executable.execMpc(mpdCmds.qToggle)
    }


    function clearQueue() {
        // @BOGUS mpd/mpc doens't execute if used to fast
        mpdCommandQueue.add(mpdCmds.qClear)
        // executable.execMpc(mpdCmds.qClear)
    }


    /**
     * Play specific item in queue
     *
     * @param {int} position Position in queue
     */
    function playInQueue(position) {
        mpdCommandQueue.add(mpdCmds.qPlay.arg(position))
        // executable.execMpc(mpdCmds.qPlay.arg(position))
    }

    function getPlaylists() {
        executable.execMpc(mpdCmds.plsGet, function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            let playlists = stdout.split("\n")
            playlists = playlists.filter(value => {
                                             return value && !value.includes('m3u')
                                         })
            playlists = playlists.sort((a, b) => {
                                           let textA = a.toUpperCase()
                                           let textB = b.toUpperCase()
                                           return (textA < textB) ? -1 : (textA > textB) ? 1 : 0
                                       })
            mpdRoot.mpdPlaylists = playlists
        })
    }

    function getPlaylist(playlist) {
        let cmd = mpdCmds.plGet.arg(_songInfoQuery).arg(bEsc(playlist))
        let clb = function (exitCode, stdout) {
            gotPlaylist(songInfoQueryResponseToJson(stdout))
        }
        executable.execMpc(cmd, clb)
    }

    function playPlaylist(playlist) {
        clearQueue()
        addPlaylistToQueue(playlist)
        playInQueue(1)
    }

    function getOptions() {
        executable.execMpc(mpdCmds.optGet, function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            mpdRoot.mpdOptions = songInfoQueryResponseToJson(stdout)[0]
        })
    }

    function toggleOption(option) {
        if (typeof option !==  'string') {
            throw new Error("Invalid argument: mpd-options must be an string")
        }
        if (!['consume', 'random', 'repeat'].includes(option)) {
            throw new Error("Invalid argument: mpd-option " + option)
        }

        let newState = mpdRoot.mpdOptions[option] === "on" ? "off" : "on"

        executable.execMpc(mpdCmds.optSet.arg(option).arg(newState))
    }

    function addPlaylistToQueue(playlist) {
        mpdCommandQueue.add(mpdCmds.plLoad.arg(bEsc(playlist)))
        // executable.execMpc(mpdCmds.plLoad.arg(bEsc(playlist)))
    }

    function getCover(title, ctitle, root, prefix) {
        let cmd = ''
        cmd += '/usr/bin/env bash'
        cmd += ' "' + mpdRoot.scriptRoot + '/downloadCover.sh"'
        cmd += ' ' + cfgMpdHost
        cmd += ' ' + bEsc(title)
        cmd += ' "' + root + '"'
        cmd += ' ' + prefix
        cmd += ' "' + ctitle.replace('/', '\\\\/') + '"'

        let clb = function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }

            coverManager.markFetched(!stdout.includes("No data"))
        }
        executable.exec(cmd, clb)
    }

    function countQueue() {
        return Object.keys(mpdRoot.mpdQueue).length
    }


    /**
     * Escape special characters from strings before using as mpc arguments
     *
     * @param {string} str The string to quote
     * @param {bool} quote Wrap the string in double quotes
     * @return {string} The escaped string
     */
    function bEsc(str, quote = true) {
        let specialChars = ['$', '`', '"', '\\']
        let escapedStr = str.split('').map(character => {
                                               if (specialChars.includes(character)) {
                                                   return '\\' + character
                                               } else {
                                                   return character
                                               }
                                           }).join('')
        if (quote) {
            escapedStr = "\"" + escapedStr + "\""
        }
        return escapedStr
    }


    /**
     * Parses a response made in the songInfoQuery-format to JSON
     *
     * Main task is to solve " quoting issues
     *
     * @param {string} response The raw text of the mpd response
     * @return {array} Array of JSON objects each representing one song
     */
    function songInfoQueryResponseToJson(response) {
        // [profiling] parse takes 90%+ of time
        return JSON.parse('[' + response.replace(/"/g, '\\"').replace(/\x1F/g, '"').replace(/,\n?$/, "") + ']')
    }


    /**
     * Replace mpc error messages with our own
     *
     * @param {string} msg The mpc error message
     */
    function fmtErrorMessage(msg) {
        let fmtMsg = msg
        if (fmtMsg.includes("No route to host")) {
            fmtMsg = qsTr("Can't find the MPD-server. - Check the MPD-address in the widget configuration.")
        } else if (fmtMsg.includes("Network is unreachable")) {
            fmtMsg = qsTr("No network connection.")
        } else if (fmtMsg.includes("no mpc in")) {
            fmtMsg = qsTr("'mpc' binary wasn't found. - Please install mpc on your system. It should be available in your system's package manager.")
        }

        return fmtMsg
    }

    // Throttle commands so we don't miss results on the event loop because we
    // sending to fast.
    Timer {
        id: mpdCommandQueue

        property var cmdQueue: []

        // The statusUpdateTimer is chained to this!
        interval: 200
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
            executable.execMpc(cmd)
        }
    }

    // If something is happening on the queue let's have it settle on the mpd side.
    Timer {
        id: statusUpdateTimer
        // If we populate the queue and send play we have to wait long enough to catch
        // our own cmd.
        interval: 2 * mpdCommandQueue.interval
        onTriggered: {
            mpdRoot.getQueue()
            // Mpc spams a new "playlist" event for every song added to the queue, so
            // maybe dozens if e.g. an album/playlist is added. Sometimes that's too
            // fast for us to catch the last "player" event indicated the new populate
            // queue started. We have to check what is playing after the queue
            // changes.
            mpdRoot.getInfo()
            mpdRoot.getPlaylists()
        }
    }

    // Mpc idle loop. After a mpc-event is registered and handled almost
    // immediately reconnect the shut down connection.
    Timer {
        id: mpdRootIdleLoopTimer
        interval: 10
        onTriggered: {
            let clb = function (exitCode, stdout) {
                if (exitCode !== 0) {
                    return
                }

                // Restart the idle loop
                mpdRootIdleLoopTimer.start()

                if (stdout.includes('player')) {
                    mpdRoot.getInfo()
                }

                if (stdout.includes('mixer'))
                    mpdRoot.getVolume()

                if (stdout.includes('options'))
                    mpdRoot.getOptions()

                if (stdout.includes('playlist') || stdout.includes('stored_playlist')) {
                    statusUpdateTimer.restart()
                }
            }
            executable.execMpc(mpdCmds.mpcIdleLoop, clb)
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
            if ((2 * interval / 1000 + lastRun) < (Date.now() / 1000)) {
                mpdRoot.forceReloadEverything()
            }

            lastRun = Date.now() / 1000
        }
    }

    ExecMpc {
        id: executable
    }

    Connections {
        function onExited(exitCode, stdout, stderr, exitStatus, cmd) {
            main.appLastError = ""
            if (exitCode !== 0) {
                if (stderr.includes("No data")) {
                    // "No data" answer from mpd is a succesfull request for us.
                    return
                }
                main.appLastError = fmtErrorMessage(stderr)
                mpdRootNetworkTimeout.start()

                return
            }
            main.appLastError = stderr || ""
        }

        target: executable
    }
}
