import org.kde.plasma.plasma5support as P5Support

P5Support.DataSource {
    id: root

    signal exited(int exitCode, int exitStatus, string stdout, string stderr, string sourceName)

    property var callbacks: ({})

    function disconnect() {
        sources.forEach(function (source) {
            root.disconnectSource(source)
        })
    }

    function exec(command, callback) {
        let clbType = typeof (callback)
        if (clbType === 'function') {
            callbacks[command] = callback
        } else if (clbType !== 'undefined') {
            throw new Error("Invalid argument: callback must be a function - is " + clbType)
        }

        connectSource(command)
    }

    engine: "executable"
    connectedSources: []
    onNewData: function(sourceName, data) {
        var exitCode = data["exit code"]
        var exitStatus = data["exit status"]
        var stdout = data["stdout"]
        var stderr = data["stderr"]

        if (callbacks[sourceName]) {
            callbacks[sourceName](exitCode, stdout, stderr, exitStatus)
            delete callbacks[sourceName]
        }

        exited(exitCode, stdout, stderr, exitStatus, sourceName)
        disconnectSource(sourceName)
    }
}
