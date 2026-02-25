import QtQuick
import "songLibrary.js" as SongLibrary

Item {
    id: root

    signal error(string message)
    signal gotPlaylist(var plData)
    signal savedQueueAsPlaylist(bool success)

    required property string cfgMpdHost
    required property string cfgMpdPort
    property var coverManager
    property string scriptRoot
    property string _lastError

    /**
      * Properties of currently playing song (title, albumartist, file, ...)
      *
      * Can be undefined if e.g. queue is empty
      */
    property var mpdInfo: undefined
    property var mpdQueue: []
    property bool mpdPlaying
    property var mpdPlaylists: ({})
    property string lastPlayedPlaylist: ""
    property var library
    property bool consume: false
    property bool repeat: false
    property bool random: false
    property int volume: 100

    property bool binaryAvailable: false
    property bool mpdConnectionAvailable: false
    property bool libraryRequested: false

    property int _playState
    enum PlayState {
        Play,
        Pause,
        Stop
    }

    /**
     * Starts the bootstrap process of a fresh connection to the mpd instance
     */
    function connect() {
        if (root.binaryAvailable !== true) {
            root.checkBinaryAvailable()
            return
        }

        disconnect()
        root.checkMpdConnectionAvailable()
    }

    function forceReloadEverything() {
        if (library) {
            root.libraryRequested = true
        }
        connect()
    }

    /**
     * Check if python binary available on the host system
     */
    function checkBinaryAvailable() {
        // keep expected stderr in sync with fmtErrorMessages
        executable.exec("which python3",  function (exitCode) {
            if (exitCode !== 0) {
                return
            }

            binaryAvailable = true
            connect()
        })
    }

    /**
     * Checks if mpc is able to connect to mpd
     */
    function checkMpdConnectionAvailable() {
        if (binaryAvailable !== true) {
            return
        }

        let callback = function (exitCode, stdout, stderr) {
            if (exitCode !== 0) {
                mpdNetworkTimeoutTimer.start()
                return
            }

            mpdNetworkTimeoutTimer.interval = mpdNetworkTimeoutTimer.startInterval
            mpdIdleLoopTimer.start()
            mpdConnectionAvailable = true

            update()
            if (libraryRequested) {
                getLibrary()
            }
        }

        // Bypass the build-in normal cmd faclities, they are gatekept by the result of this.
        executable.execRaw("--cmd status", callback)
    }

    function disconnect() {
        mpdIdleLoopTimer.stop()
        mpdNetworkTimeoutTimer.stop()
    }

    /**************************************************************************/

    /**
     * Inits update of all mpd data required by our plasmoid
     */
    function update() {
        root._getStatus()
        root._getQueue() // also calls getInfo()
    }

    /**
      * Get info of currently playing song
      *
      * When mpd is stopped it evalutates what is going to be played next on
      * toggling "play".
      */
    function _getInfo() {
        executable.execCmd('currentsong', [], function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }

            if (stdout)  {
                // Queue is playing, paused, or stopped after a playing.
                mpdInfo = JSON.parse(stdout)
                return
            }

            // Queue is empty
            if (root.mpdQueue.length === 0) {
                mpdInfo = undefined
                return
            }

            // Queue was cleared, filled, but never left the "stop" state.
            // Sending a play event will start the first song.
            if (root.mpdQueue.length > 0) {
                mpdInfo = mpdQueue[0]
                return
            }
        })
    }

    function _getQueue() {
        executable.execCmd("playlistinfo", [], function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            if (stdout) {
                let queue = JSON.parse(stdout)
                root.mpdQueue = queue
            } else {
                mpdQueue = []
            }

            // Info evaluates queue data
            _getInfo()
        })
    }

    function _getStatus() {
        executable.execCmd("status", [], function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }

            try {
                var parsed = JSON.parse(stdout)
            }  catch (erro) {
                throw new Error("Invalid mpd response: no status information in " + stdout)
            }

            root.volume = parseInt(parsed.volume)
            root.consume = parsed.consume === "1"
            root.random = parsed.random === "1"
            root.repeat = parsed.repeat === "1"

            switch (parsed.state) {
                case("play"):
                    root._playState = MpdState.PlayState.Play
                    root.mpdPlaying = true
                    break
                case("pause"):
                    root._playState = MpdState.PlayState.Pause
                    root.mpdPlaying = false
                    break
                case("stop"):
                    root._playState = MpdState.PlayState.Stop
                    root.mpdPlaying = false
                    break
                default:
                    throw new Error("Unknown mpd play status " + parsed.state)
            }

        })
    }

    /**
      * Clear the song library
      */
    function clearLibrary() {
        library = null
    }

    /**
     * Download whole song library
     */
    function getLibrary() {
        if (!mpdConnectionAvailable) {
            libraryRequested = true
            return
        }

        executable.execCmd("listallinfo", [], function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            if (stdout) {
                stdout = JSON.parse(stdout)
            } else {
                stdout = []
            }
            library = new SongLibrary.SongLibrary(stdout)
            libraryRequested = false
        })
    }

    function togglePlayPause() {
        // Sending play/pause doesn't start from stopped state in python-mpd2
        if (root._playState === MpdState.PlayState.Stop && root.mpdInfo) {
            playInQueue(root.mpdInfo.pos)
            return
        }

        executable.execCmd("pause")
    }

    /**
     * Play specific item in queue
     *
     * @param {int} position Position in queue
     */
    function playInQueue(position) {
        executable.execCmd("play", [position])
    }

    function playNext() {
        executable.execCmd("next")
    }

    function toggleOption(option) {
        if (typeof option !==  'string') {
            throw new Error("Invalid argument: mpd-option must be an string")
        }
        if (!['consume', 'random', 'repeat'].includes(option)) {
            throw new Error("Invalid argument: Unknown mpd-option " + option)
        }


        let newState = root[option] ? 0 : 1
        executable.execCmd(option, [newState])
    }

    /**
      * Add songs to the queue
      *
      * @param {array} items - array of mpd file IDs
      * @param {string} mode - insertion mode
      * - "append" at end of queue
      * - "insert" after currently playing track
      * @param {requestCallback} callback - callback after execution
      */
    function addSongsToQueue(items, mode = "append", callback) {
        if (!Array.isArray(items)) {
            throw new Error("Invalid argument: items must be an array")
        }

        var position = root.mpdInfo ? parseInt(root.mpdInfo.pos) + 1 : 0
        executable.startList()
        items.forEach(function(song) {
            let args = [song]
            if (mode === "insert") { args = args.concat([position++]) }
            executable.execCmd("add", args)
        })
        executable.execList(callback)
    }

    function clearQueue() {
        executable.execCmd("clear")
    }

    function replaceQueue(songs) {
        executable.startList()
        clearQueue()
        addSongsToQueue(songs)
        playInQueue(0)
        executable.execList()
    }

    /**
      * Appends a playlist to the queue
      *
      * @param {string} playlist - mpd playlist title
      * @param {requestCallback} callback - callback after execution
      */
    function loadPlaylist(playlist, callback) {
        executable.execCmd("load", [playlist], callback)
    }

    function playPlaylist(playlist) {
        executable.startList()
        clearQueue()
        loadPlaylist(playlist)
        playInQueue(0)
        executable.execList(() => root.lastPlayedPlaylist = playlist)
    }

    function getPlaylists() {
        executable.execCmd("listplaylists", [], function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            let playlists = JSON.parse(stdout)
            playlists = playlists.map((playlist) => playlist.playlist)
            playlists = playlists.sort(function (a, b) {
                let textA = a.toLowerCase()
                let textB = b.toLowerCase()
                return (textA < textB) ? -1 : (textA > textB) ? 1 : 0
            })
            root.mpdPlaylists = playlists
        })
    }

    function getPlaylist(playlist) {
        executable.execCmd("listplaylistinfo", [playlist], function(exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }
            gotPlaylist(JSON.parse(stdout))
        })
    }

    /**
     * Deletes a playlist
     *
     * @param {sting} title playlist title in MPD
     */
    function removePlaylist(title) {
        executable.execCmd("rm", [title])
    }

    /**
     * Saves queue as playlist
     *
     * @param {sting} title playlist title in MPD
     */
    function saveQueueAsPlaylist(title) {
        executable.execCmd("save", [title], function (exitCode) {
            savedQueueAsPlaylist(!exitCode)
        })
    }

    function replacePlaylistWithQueue(title) {
        executable.startList()
        removePlaylist(title)
        saveQueueAsPlaylist(title)
        executable.execList()
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

        executable.startList()
        positions.sort((a,b) => {return a-b}).reverse().forEach(function(position) {
            executable.execCmd("delete", [position])
        })
        executable.execList()
    }

    /**
     * Moves song in queue
     *
     * @param {int} from Position of the song to move (current)
     * @param {int} to Positiong to move the song to (target)
     */
    function moveInQueue(from, to) {
        executable.execCmd("move", [from, to])
    }

    /**
     * Set volume
     *
     * @param {string} Absolute <value> or +/-<value>
     */
    function setVolume(value) {
        executable.execCmd("setvol", [value])
    }

    function getCover(title, ctitle, directory, prefix) {
        let cmd = ''
        cmd += '/usr/bin/env bash'
        cmd += ' "' + scriptRoot + '/downloadCover.sh"'
        cmd += ' ' + root.cfgMpdHost
        cmd += ' ' + bEsc(title)
        cmd += ' "' + directory + '"'
        cmd += ' ' + root.cfgMpdPort
        cmd += ' "' + ctitle.replace('/', '\\\\/') + '"'

        let clb = function (exitCode, stdout) {
            if (exitCode !== 0) {
                return
            }

            root.coverManager.markFetched(!stdout.includes("No data"))
        }
        executable.exec(cmd, clb)
    }

    /**************************************************************************/

    // If something is happening on the queue let's have it settle on the mpd side.
    Timer {
        id: statusUpdateTimer
        interval: 100
        onTriggered: {
            root._getQueue()
        }
    }

    Timer {
        id: infoUpdateTimer
        interval: 100
        onTriggered: {
            root._getStatus()
            root._getInfo()
        }
    }

    Timer {
        id: mpdIdleLoopTimer
        interval: 10
        onTriggered: {
            let clb = function (exitCode, stdout, stderr) {
                if (exitCode !== 0) {
                    return
                }
                // console.log(stdout)

                // Restart the idle loop
                mpdIdleLoopTimer.start()

                if (stdout.includes('player')) {
                    infoUpdateTimer.start()
                }

                if (stdout.includes('"mixer"')) {
                    root._getStatus()
                }

                if (stdout.includes('"options"')) {
                    root._getStatus()
                }

                if (stdout.includes('playlist')) {
                    statusUpdateTimer.restart()
                }

                if (stdout.includes('stored_playlist')) {
                    root.getPlaylists()
                }
            }

            executable.execCmd("idle", [], clb)
        }
    }

    // Handles network issues. E.g. if the network card needs a few seconds to
    // become available after a system resume. Or the device is moved in and out
    // of places with the mpd server (un)available.
    Timer {
        id: mpdNetworkTimeoutTimer

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

            root.checkMpdConnectionAvailable()
        }
    }

    // Watchdog for system sleep/wake cycles. If we detect a "lost timespan" we
    // assume the mpc idle connection is no longer valid and needs a reconnect.
    Timer {
        id: mpdRootReconnectTimer

        property int lastRun: Date.now() / 1000

        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            if ((2 * interval / 1000 + lastRun) < (Date.now() / 1000)) {
                root.forceReloadEverything()
            }

            lastRun = Date.now() / 1000
        }
    }

    /**************************************************************************/

    /**
     * Escape special characters from arguments before using them in the CLI
     *
     * @param {string} str The string to quote
     * @param {bool} quote Wrap the string in double quotes
     * @return {string} The escaped string
     */
    function bEsc(str, quote = true) {
        if (typeof(str) !== "string") {
            throw new Error("Invalid argument error: expected string, got " + typeof(str))
        }
        if (str === "") {
            throw new Error("bEsc - Invalid argument error: got empty string")
        }
        let specialChars = ['$', '`', '"', '\\']
        let escapedStr = str.split('').map(function(character) {
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

    ExecGeneric {
        id: executable

        property int cmdList: 0
        property var cmdListCmds: []

        function startList() {
            cmdList++
        }

        function execList(callback) {
            cmdList--
            if (cmdList !== 0) {
                return
            }
            execCmd(undefined, undefined, callback)
        }

        function execCmd(command, args = [], callback) {
            if (binaryAvailable !== true || mpdConnectionAvailable !== true) {
                return
            }

            if (cmdList > 0) {
                cmdListCmds.push([command].concat(args))
                return
            }

            var finalCmd = []
            var cmdsToProcess = []

            if (command) {
                cmdsToProcess.push([command].concat(args))
            } else if (cmdListCmds.length > 0) {
                finalCmd.push("--cmd command_list_ok_begin")
                cmdsToProcess = cmdsToProcess.concat(cmdListCmds)
            } else {
                throw new Error("Failure state. Commands in list when list stack should be empty.")
            }

            cmdsToProcess.forEach(function(cmd) {
                finalCmd.push("--cmd " + cmd.shift())
                cmd = cmd.map(function(a) { return bEsc(a + "") })
                finalCmd.push(cmd.join(" "))
            })

            if (cmdListCmds.length > 0) {
                finalCmd.push("--cmd command_list_end")
                cmdListCmds = []
            }
            // console.log(finalCmd.join(" "))
            execRaw(finalCmd.join(" "), callback)
        }

        function execRaw(command, callback) {
            let cmd = []
            cmd.push("/usr/bin/env python3")
            cmd.push('"' + root.scriptRoot + '/mpdPlasmaWidgetExec.py"')
            cmd.push("--host " + root.cfgMpdHost)
            cmd.push("--port " + root.cfgMpdPort)

            exec(cmd.join(" ") + " " + command, callback)
        }
    }

    /**
     * Replace mpc error messages with our own
     *
     * @param {string} msg The mpc error message
     */
    function fmtErrorMessage(msg) {
        let fmtMsg = msg
        if (fmtMsg.includes("ConnectionRefusedError")) {
            fmtMsg = qsTr("Connection refused. - Check the MPD server configuration in the widget settings.")
        } else if (fmtMsg.match(/Errno [-9|101]/)) {
            fmtMsg = qsTr("No network connection")
        } else if (fmtMsg.includes("no python in")) {
            fmtMsg = qsTr("'python3' wasn't found. - Please install it on your system. It should be available in your system's package manager.")
        }

        return fmtMsg
    }

    Connections {
        function onExited(exitCode, stdout, stderr, exitStatus, cmd) {
            root._lastError = ""
            if (exitCode !== 0) {
                if (stderr.includes("No data")) {
                    // "No data" answer from mpd is a succesfull request for us.
                    return
                }
                root._lastError = fmtErrorMessage(stderr)
                root.error(root._lastError)
                mpdNetworkTimeoutTimer.start()

                return
            }
            root._lastError = stderr || ""
            root.error(root._lastError)
        }

        target: executable
    }
}
