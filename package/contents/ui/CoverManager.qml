import "../scripts/coverHelpers.js" as CoverHelpers
import QtQuick 2.15 as QQ2
import org.kde.plasma.core 2.0 as PlasmaCore

QQ2.Item {
    id: coverManager

    signal gotCover(var status)

    property var covers
    property var fetchQueue
    property bool fetching: false
    property string filePrefix: "mpdcover-"


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

    function markFetched(coverPath, success) {
        let id = idFromCoverPath(coverPath)
        let item = null
        if (success) {
            item = {
                "path": coverPath
            }
        }
        coverManager.covers[id] = item
        coverManager.fetchQueue.delete(id)
        fetching = false

        gotCover(coverPath)
    }

    QQ2.Component.onCompleted: {
        covers = {}
        fetchQueue = new CoverHelpers.FetchQueue()
        fetching = false
        coverRotateTimer.start()
    }

    // Rotate cover cache
    QQ2.Timer {
        id: coverRotateTimer
        running: false
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

            // Alas we can't return, we just have to pound the fetch again, and again,
            // and again … because Plasmacore.DataSource.exec loves to terminate
            // scripts early. It just does it. We can't be sure that a fetch did
            // actually make it through. Luckily PlamaCore.DataSource.exec recognizes
            // if the same cmd was started before, is still running and therefore
            // doesn't start it again. So there's no penalty trying to start it
            // another time.
            // @MAYBE Check if we can catch if we don't get an expected stdout (e.g.
            // path) on the fetch result
            // if (fetching) {
            // return;
            // }
            let itemToFetch = fetchQueue.next()
            if (!itemToFetch) {
                fetchingQueueTimer.stop()
                return
            }

            fetching = true
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
                mpdState.startup()
            } else if (source.includes("#rotateCoverCache")) {
                coverManager.getLocalCovers()
            }
        }

        target: coverManagerExecutable
    }
}
