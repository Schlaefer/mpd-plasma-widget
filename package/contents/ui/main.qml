import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.plasmoid 2.0

Item {
    id: root

    property string mpdHost: Plasmoid.configuration.mpdHost
    // @TODO make path configurable
    // @TODO move to ~/.cache per default
    property string coverImagePath: "/tmp"
    property string appLastError: ""

    Layout.preferredWidth: 300
    Layout.preferredHeight: 400
    // Allow user to toggle background transparency
    Plasmoid.backgroundHints: PlasmaCore.Types.StandardBackground | PlasmaCore.Types.ConfigurableBackground
    Component.onCompleted: {
        mpdState.startup();
    }

    Connections {
        function onMpdHostChanged() {
            mpdState.startup();
        }

    }

    Item {
        id: mpdState

        property string mpdFile: ""
        property int mpdVolume: 0
        property string mpdCoverFile: ""
        property var mpdInfo: {
        }

        function startup() {
            update()
            mpdStateIdleLoopTimer.start();
        }

        function update() {
            mpdState.getInfo();
            mpdState.getVolume();
        }

        function getVolume() {
            mpdStateExecutable.exec("mpc --host=" + mpdHost + " volume" + " #getVolume");
        }

        function setVolume(value) {
            mpdStateExecutable.exec("mpc --host=" + mpdHost + " volume " + value + " #update");
        }

        function getInfo() {
            mpdStateExecutable.exec("mpc --host=" + mpdHost + " -f '{[\\n\"artist\": \"%artist%\", ][\\n\"albumartist\": \"%albumartist%\", ][\\n\"album\": \"%album%\", ][\\n\"tracknumber\": \"%track%\", ]\\n\"title\": \"%title%\", [\\n\"date\": \"%date%\", ]\\n\"file\": \"%file%\"\\n}' | head -n -2 #getInfo");
        }

        function playNext() {
            mpdStateExecutable.exec("mpc --host=" + mpdHost + " next");
        }

        function toggle() {
            mpdStateExecutable.exec("mpc --host=" + mpdHost + " toggle");
        }

        function getCover() {
            let cmd = '';
            cmd += 'bash';
            cmd += ' "' + plasmoid.file('', 'scripts/downloadCover.sh') + '"';
            cmd += ' ' + mpdHost;
            cmd += ' "' + mpdState.mpdFile.replace(/"/g, '\\"') + '"';
            cmd += ' ' + root.coverImagePath;
            cmd += ' com.siezi.plasma-mpd.cover';
            // @TODO setting to disable caching option
            cmd += ' yes';
            cmd += ' #readpicture';
            mpdStateExecutable.exec(cmd);
        }

        Timer {
            id: mpdStateIdleLoopTimer

            interval: 10
            running: false
            repeat: false
            onTriggered: {
                mpdStateExecutable.exec('mpc --host=' + mpdHost + ' idle player mixer #idleLoop');
            }
        }

        Timer {
            id: mpdStateWatchDogTimer

            property int lastRun: Date.now() / 1000

            interval: 2000
            running: true
            repeat: true
            onTriggered: {
                if ((2 * interval/1000 + lastRun) < (Date.now()/1000)) {

                    mpdStateExecutable.sources.forEach((source) => {
                        if (source.includes("#readpicture")) {
                            mpdStateExecutable.disconnectSource(source)
                        }
                        mpdState.update()
                    });
                    console.log('watchtimer did run.');
                }
                lastRun = Date.now() / 1000
            }
        }

        PlasmaCore.DataSource {
            id: mpdStateExecutable

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

        Connections {
            function onSourceRemoved(source) {
                // Restart the idle loop
                if (source.includes("#idleLoop"))
                    mpdStateIdleLoopTimer.start();

            }

            function onExited(exitCode, exitStatus, stdout, stderr, source) {
                root.appLastError = stderr || "";
                if (stderr !== "")
                    return ;

                if (source.includes("#idleLoop")) {
                    if (stdout.includes('player'))
                        mpdState.getInfo();
                    else if (stdout.includes('mixer'))
                        mpdState.getVolume();
                } else if (source.includes("#getVolume")) {
                    mpdState.mpdVolume = parseInt(stdout.match(/volume:\W*(\d*)/)[1]);
                } else if (source.includes("#getInfo")) {
                    let data = JSON.parse(stdout);
                    mpdState.mpdFile = data.file;
                    mpdState.mpdInfo = data;
                } else if (source.includes("#readpicture")) {
                    mpdState.mpdCoverFile = stdout;
                }
            }

            target: mpdStateExecutable
        }

        Connections {
            function onMpdFileChanged() {
                mpdState.getCover();
            }

            target: mpdState
        }

    }

    // Main layout of the widget
    GridLayout {
        anchors.fill: parent
        columns: parent.height > 350 ? 1 : 3
        rows: parent.height > 350 ? 3 : 1

        // Cover Image
        Image {
            id: coverImage

            cache: false
            mipmap: true
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.maximumWidth: height > height ? width : height
            fillMode: Image.PreserveAspectFit
            source: mpdState.mpdCoverFile

            MouseArea {
                anchors.fill: parent
                onClicked: mpdState.toggle()
                onWheel: (wheel) => {
                    volumeSlider.value = volumeSlider.value + wheel.angleDelta.y / 60;
                }
                onDoubleClicked: {
                    mpdState.playNext();
                }
            }

            Connections {
                function onMpdCoverFileChanged() {
                    // @TODO there must be a better way to force an update
                    // Leave for uncached version which doesn't change file name
                    coverImage.source = "";
                    coverImage.source = mpdState.mpdCoverFile;
                }

                target: mpdState
            }

        }

        // Volume Slider
        PlasmaComponents.Slider {
            id: volumeSlider

            property bool dontSendRequestOnRead: false

            value: mpdState.mpdVolume
            Layout.fillHeight: parent.height <= 350
            Layout.fillWidth: parent.height > 350
            Layout.maximumWidth: parent.height > 350 ? 400000 : 15
            // Orientation bugged? Disabled on small layout for now
            // See: https://bugs.kde.org/show_bug.cgi?id=474611
            // orientation: parent.height > 350 ? Qt.Horizontal : Qt.Vertical
            visible: parent.height > 350
            minimumValue: 0
            maximumValue: 100
            // Leave at 1. Otherwise the slider fights with mpd if mpd sends a value that doesn't fit the step size.
            stepSize: 1
            onValueChanged: {
                // Don't send again the if just got the "mixer" event value from our own value change
                if (volumeSlider.value !== mpdState.mpdVolume)
                    mpdState.setVolume(value);

            }

            Connections {
                function onMpdVolumeChanged() {
                    if (volumeSlider.value !== mpdState.mpdVolume)
                        volumeSlider.value = mpdState.mpdVolume;

                }

                target: mpdState
            }

        }

        // Title
        ColumnLayout {
            id: descriptionContainer

            Layout.fillWidth: true
            Layout.fillHeight: true

            Connections {
                function onMpdInfoChanged() {
                    let data = mpdState.mpdInfo;
                    let title = data.title;
                    if (data.tracknumber)
                        title = data.tracknumber + ". " + title;

                    songTitle.text = title;
                    songArtist.text = data.artist || data.albumartist || "";
                    let album = data.album || "";
                    if (album && data.date)
                        album += " (" + data.date + ")";

                    songAlbum.text = album;
                }

                target: mpdState
            }

            PlasmaComponents.Label {
                id: songTitle

                font.weight: Font.Bold
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                id: songArtist

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: text.length > 0
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                id: songAlbum

                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                id: songYear

                horizontalAlignment: Text.AlignHCenter
                visible: text.length > 0
                Layout.fillWidth: true
            }

        }

        // Error messages
        PlasmaComponents.Label {
            id: notification

            wrapMode: Text.Wrap
            Layout.fillWidth: true
            visible: text.length > 0

            Connections {
                function onAppLastErrorChanged() {
                    notification.text = root.appLastError;
                }

                target: root
            }

        }

    }

}
