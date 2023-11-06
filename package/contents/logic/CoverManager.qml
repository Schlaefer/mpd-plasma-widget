import QtQuick 2.15 as QQ2
import org.kde.plasma.core 2.0 as PlasmaCore
import "coverHelpers.js" as CoverHelpers

QQ2.Item {
    id: coverManager

    signal gotCover(string id)
    signal afterReset

    property bool fetching: false
    property var currentlyFetching
    property string filePrefix: "mpdcover-"
    property var covers: ({})
    property var fetchQueue: new CoverHelpers.FetchQueue()

    function reset() {
        covers = {}
        getLocalCovers()
        afterReset()
    }

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

        fetchQueue.add(title, item, priority)
        fetchingQueueTimer.start()
        return undefined
    }

    function getLocalCovers() {
        let cmd = 'find ' + cfgCacheRoot + ' -name "' + coverManager.filePrefix + '*-large.jpg"'
        executable.exec(cmd, function (exitCode, stdout) {
            let lines = stdout.split("\n")
            lines.forEach(function (line) {
                if (!line) {
                    return
                }

                line = line.replace("-large.jpg", "")
                let id = coverManager.idFromCoverPath(line)
                coverManager.covers[id] = {
                    "path": line
                }
            })
            mpdState.connect()
        })
    }

    function getId(itemInfo) {
        let id = itemInfo.file
        if (itemInfo.album && (itemInfo.albumartist || itemInfo.artist)) {
            id = (itemInfo.albumartist || itemInfo.artist) + " - " + itemInfo.album
        }

        return id
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

    function clearCache() {
        let cmd = "rm " + cfgCacheRoot + "/" + filePrefix + "*"
        executable.exec(cmd, function () { coverManager.reset() })
    }

    // Rotate cover cache
    QQ2.Timer {
        id: coverRotateTimer
        running: true
        interval: 10800000
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let cmd = 'find "' + cfgCacheRoot + '" -type f -name "' + filePrefix + '*" -mtime +' + cfgCacheForDays + ' -exec rm "{}" \\;'
            executable.exec(cmd, function () { coverManager.reset() })
        }
    }

    // Trigger fetching new covers
    QQ2.Timer {
        id: fetchingQueueTimer

        property int watchdog

        repeat: true
        interval: 500
        triggeredOnStart: true
        onTriggered: {
            if (fetching && watchdog !== 0) {
                watchdog--
                return
            }
            let itemToFetch = fetchQueue.next()
            if (!itemToFetch) {
                fetchingQueueTimer.stop()
                return
            }

            watchdog = 120
            fetching = true
            currentlyFetching = itemToFetch
            mpdState.getCover(itemToFetch.file, getCoverFileName(itemToFetch), cfgCacheRoot, filePrefix)
        }
    }

    ExecGeneric {
        id: executable
    }
}
