import "../scripts/coverHelpers.js" as CoverHelpers
import QtQuick 2.15 as QQ2
import org.kde.plasma.core 2.0 as PlasmaCore

QQ2.Item {
    id: coverManager

    property var covers
    property var fetchQueue
    property bool fetching: false
    property string coverDirectory
    property string filePrefix: "mpdcover-"
    property var mpd
    property int cacheForDays

    function getCover(item, priority = 100) {
        let title = getId(item);
        if (title in covers)
            return encodeURIComponent(covers[title].path);

        if (fetchQueue.has(title))
            return false;

        fetchQueue.add(title, item, priority);
        return false;
    }

    function getLocalCovers() {
        let cmd = 'find ' + coverDirectory + ' -name "' + coverManager.filePrefix + '*" #getLocalCovers';
        coverManagerExecutable.exec(cmd);
    }

    function getId(itemInfo) {
        return (itemInfo.album || itemInfo.file);
    }

    function getCoverFileName(itemInfo) {
        // We assume that albums have the same cover, saving only one cover per
        // album, not for every song.
        let hash = encodeURIComponent(getId(itemInfo));
        return filePrefix + hash;
    }

    function idFromCoverPath(path) {
        let id = path.replace(coverDirectory + '/' + filePrefix, '');
        id = decodeURIComponent(id);
        return id;
    }

    function markFetched(coverPath) {
        let id = idFromCoverPath(coverPath);
        coverManager.covers[id] = {
            "path": coverPath
        };
        coverManager.fetchQueue.delete(id)
        fetching = false;
    }

    QQ2.Component.onCompleted: {
        covers = {
        };
        fetchQueue = new CoverHelpers.FetchQueue();
        fetching = false;
        coverManager.getLocalCovers();
    }

    // Clean cover cage
    QQ2.Timer {
        running: true
        interval: 86400
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            let cmd = 'find "' + coverDirectory + '" -type f -name "' + filePrefix + '*" -mtime +' + cacheForDays + ' -exec rm "{}" \; #rotateCoverCache';
            coverManagerExecutable.exec(cmd);
        }
    }

    QQ2.Timer {
        running: true
        repeat: true
        // @TODO better start
        interval: 200
        triggeredOnStart: true
        onTriggered: {
            let itemToFetch = fetchQueue.next()
            if (fetching || !itemToFetch)
                return ;

            fetching = true;
            mpd.getCover(itemToFetch.file, getCoverFileName(itemToFetch), coverDirectory, filePrefix);
        }
    }

    PlasmaCore.DataSource {
        id: coverManagerExecutable

        signal exited(int exitCode, int exitStatus, string stdout, string stderr, string sourceName)

        function exec(cmd) {
            connectSource(cmd);
        }

        engine: "executable"
        connectedSources: []
        onNewData: {
            var exitCode = data["exit code"];
            var exitStatus = data["exit status"];
            var stdout = data["stdout"];
            var stderr = data["stderr"];
            exited(exitCode, exitStatus, stdout, stderr, sourceName);
            disconnectSource(sourceName); // cmd finished
        }
    }

    QQ2.Connections {
        function onExited(exitCode, exitStatus, stdout, stderr, source) {
            if (source.includes("#getLocalCovers")) {
                let lines = stdout.split("\n");
                lines.forEach((line) => {
                    if (!line)
                        return ;

                    let id = coverManager.idFromCoverPath(line);
                    coverManager.covers[id] = {
                        "path": line
                    };
                });
                mpd.startup();
            } else if (source.includes("#rotateCoverCache")) {
                coverManager.getLocalCovers();
            }
        }

        target: coverManagerExecutable
    }

}
