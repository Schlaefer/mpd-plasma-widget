import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.DataSource {
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
    onNewData: {
        var exitCode = data["exit code"]
        var exitStatus = data["exit status"]
        var stdout = data["stdout"]
        var stderr = data["stderr"]

        if (callbacks[sourceName]) {
            callbacks[sourceName](exitCode, exitStatus, stdout, stderr, sourceName)
            delete callbacks[sourceName]
        }

        exited(exitCode, exitStatus, stdout, stderr, sourceName)
        disconnectSource(sourceName)
    }
}
