import "../scripts/coverHelpers.js" as CoverHelpers
import QtQuick 2.15 as QQ2
import org.kde.plasma.core 2.0 as PlasmaCore

QQ2.Item {
    id: coverManager

    signal gotCover(string id)

    property bool fetching: false
    property var currentlyFetching
    property string filePrefix: "mpdcover-"
    property var covers: ({})
    property var fetchQueue: new CoverHelpers.FetchQueue()


    /**
     * @return {mixed}
     *  - string: Path to cover image
     *  - undefined: No cover information known (yet)
     *  - null: No cover available
     */
    function getCover(item, priority = 100) {
        let title = getId(item)
        if (title in covers) {
            if (covers[title] === null) {
                return null
            } else {
                return encodeURIComponent(covers[title].path)
            }
        }

        if (fetchQueue.has(title)) {
            return undefined
        }

        fetchQueue.add(title, item, priority)
        fetchingQueueTimer.start()
        return undefined
    }

    function getLocalCovers() {
        let cmd = 'find ' + cfgCacheRoot + ' -name "' + coverManager.filePrefix
            + '*" #getLocalCovers'
        coverManagerExecutable.exec(cmd)
    }

    function getId(itemInfo) {
        return (itemInfo.album || itemInfo.file)
    }

    function getCoverFileName(itemInfo) {
        // We assume that albums have the same cover, saving only one cover per
        // album, not for every song.
        let hash = encodeURIComponent(getId(itemInfo))
        return filePrefix + hash
    }

    function idFromCoverPath(path) {
        let id = path.replace(cfgCacheRoot + '/' + filePrefix, '')
        id = decodeURIComponent(id)
        return id
    }

    function markFetched(success) {
        let id = getId(currentlyFetching)
        let coverPath = cfgCacheRoot + '/' + getCoverFileName(currentlyFetching)

        let item = null
        if (success) {
            item = {
                "path": coverPath
            }
        }

        coverManager.covers[id] = item
        coverManager.fetchQueue.delete(id)
        fetching = false

        gotCover(id)
    }

    // Rotate cover cache
    QQ2.Timer {
        id: coverRotateTimer
        running: true
        interval: 10800000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let cmd = 'find "' + cfgCacheRoot + '" -type f -name "' + filePrefix
                + '*" -mtime +' + cfgCacheForDays + ' -exec rm "{}" \; #rotateCoverCache'
            coverManagerExecutable.exec(cmd)
        }
    }

    // Trigger fetching new covers
    QQ2.Timer {
        id: fetchingQueueTimer
        running: false
        repeat: true
        interval: 100
        triggeredOnStart: true
        onTriggered: {
            if (fetching) {
                return
            }
            let itemToFetch = fetchQueue.next()
            if (!itemToFetch) {
                fetchingQueueTimer.stop()
                return
            }

            fetching = true
            currentlyFetching = itemToFetch
            mpdState.getCover(itemToFetch.file, getCoverFileName(itemToFetch),
                              cfgCacheRoot, filePrefix)
        }
    }

    PlasmaCore.DataSource {
        id: coverManagerExecutable

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

    QQ2.Connections {
        function onExited(exitCode, exitStatus, stdout, stderr, source) {
            if (source.includes("#getLocalCovers")) {
                let lines = stdout.split("\n")
                lines.forEach(line => {
                                  if (!line) {
                                      return
                                  }

                                  let id = coverManager.idFromCoverPath(line)
                                  coverManager.covers[id] = {
                                      "path": line
                                  }
                              })
                mpdState.connect()
            } else if (source.includes("#rotateCoverCache")) {
                coverManager.getLocalCovers()
            }
        }

        target: coverManagerExecutable
    }
}
