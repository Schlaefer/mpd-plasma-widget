pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import "./../../Mpdw.js" as Mpdw
import "./../../Components/"
import "./../../Components/Albumartists"
import "./../../Components/Application"
import "./../../Components/Elements"
import "./../../Components/Queue"
import "./../../Components/Playlists"
import "../../../scripts/formatHelpers.js" as FormatHelpers
import "../../../logic"

PlasmaCore.Window {
    id: win

    property int initialHeight: AppContext.initialHeight
    property alias narrowBreakPoint: app.narrowBreakPoint

    modality: Qt.NonModal
    flags: Qt.Dialog
    title: qsTr("MPD")

    maximumWidth: 719
    minimumWidth: 250
    minimumHeight: app.footer.height

    Component.onCompleted: {
        height = (initialHeight > 800 ? 0.8 : 0.95) * initialHeight
        width = height / 1.8
        AppContext.setApp(app)
        app.mpdState.registerClient()
    }

    Component.onDestruction: {
        app.mpdState.unregisterClient()
    }

    mainItem: Kirigami.ApplicationItem {
        id: app

        anchors.fill: parent

        property alias currentIndex: stackLayout.currentIndex
        readonly property MpdState mpdState: AppContext.getMpdState()
        readonly property VolumeState volumeState: AppContext.getVolumeState()
        property int narrowBreakPoint
        property bool narrowLayout: app.width < narrowBreakPoint
        property int windowPreMinimizeSize: -1

        /**
         * Global page properties
         */
        readonly property var pages: [
            {
                name: "queue",
                icon: Mpdw.icons.placeQueue,
                shortcut: "1",
                text: qsTr("Queue"),
                tooltip: qsTr("Show Queue"),
                layoutIndex: 0,
            },
            {
                name: "albumartists",
                icon: Mpdw.icons.placeArtist,
                shortcut: "2",
                text: qsTr("Artists"),
                tooltip: qsTr("Show Artists"),
                layoutIndex: 1,
            },
            {
                name: "playlist",
                icon: Mpdw.icons.placePlaylist,
                shortcut: "3",
                text: qsTr("Playlists"),
                tooltip: qsTr("Show Playlists"),
                layoutIndex: 2,
            }
        ]

        StackLayout {
            id: stackLayout
            anchors.fill: parent
            currentIndex: 0
            QueuePage {
                app: app
                mpdState: app.mpdState
                narrowLayout: app.narrowLayout

                onSearchLibrary: term => app.searchLibrary(term)
            }
            AlbumartistsPage {
                app: app
                mpdState: app.mpdState
                narrowLayout: app.narrowLayout
            }
            PlaylistsPage {
                app: app
                mpdState: app.mpdState
                narrowLayout: app.narrowLayout

                onSearchLibrary: term => app.searchLibrary(term)
            }
        }

        function showPage(name) {
            const entry = pages.find(p => p.name === name)
            stackLayout.currentIndex = entry.layoutIndex
            return stackLayout.itemAt(stackLayout.currentIndex)
        }

        function searchLibrary(term: string) {
            showPage('albumartists').search(term)
        }

        Repeater {
            id: shortcutRepeater
            model: app.pages
            // Anchor shortcut to an item in the scene since the delegates are created
            // dynamically.
            Item {
                id: root
                required property var modelData
                Shortcut {
                    sequence: root.modelData.shortcut
                    onActivated: function() {
                        app.showPage(root.modelData.name)
                    }
                }
            }
        }


        footer: ToolBar {
            // === Toolbar background ===
            background: Item {
                // === Fallback default background if no cover-image ===
                Rectangle {
                   anchors.fill: parent
                   color: Kirigami.Theme.backgroundColor
                }

                // === Blured cover-image background ===
                Image {
                    id: toolboxBackgroundImage
                    anchors.fill: parent
                    anchors.centerIn: parent
                    visible: source
                    fillMode: Image.PreserveAspectCrop

                    layer.enabled: source
                    layer.effect: MultiEffect {
                        autoPaddingEnabled: false
                        blurEnabled: true
                        blur: 0.8
                        blurMax: 128
                        saturation: 0.5
                    }
                }

                // Improve test and icon legibility
                Rectangle {
                    anchors.fill: parent
                    visible: toolboxBackgroundImage.source
                    color: Qt.rgba(
                        Kirigami.Theme.backgroundColor.r,
                        Kirigami.Theme.backgroundColor.g,
                        Kirigami.Theme.backgroundColor.b,
                        0.7
                    )
                }

                Connections {
                    target: coverImage
                    function onSourceChanged(source) {
                        toolboxBackgroundImage.source = source
                    }
                }
            }

            RowLayout {
                anchors.fill: parent
                RowLayout {
                    Layout.margins: Kirigami.Units.smallSpacing
                    spacing: Kirigami.Units.smallSpacing
                    Layout.alignment: Qt.AlignRight
                    Layout.fillHeight: true
                    Layout.fillWidth: true

                    WidgetCoverImage {
                        id: coverImage
                        Layout.preferredHeight: songinfo.height
                        Layout.preferredWidth: songinfo.height

                        sourceSize.height: songinfo.height
                        sourceSize.width: songinfo.height

                        mpdState: app.mpdState
                        volumeState: app.volumeState

                        MouseArea {
                            anchors.fill: coverImage
                            acceptedButtons: Qt.MiddleButton
                            onClicked: function (mouse) {
                                if (mouse.button === Qt.MiddleButton) {
                                    if (app.windowPreMinimizeSize === -1) {
                                        app.minimize()
                                    } else {
                                        app.maximize()
                                    }
                                }
                            }
                        }
                    }

                    ColumnLayout {
                        id: songinfo
                        spacing: 0
                        Layout.minimumWidth: 50
                        Layout.minimumHeight: 50
                        Layout.fillWidth: true

                        Item {
                            Layout.fillWidth: true
                            implicitWidth: innerLayout.implicitWidth
                            implicitHeight: innerLayout.implicitHeight

                            MouseArea {
                                anchors.fill: parent
                                onClicked: showCurrentSongAction.trigger()
                            }

                            ColumnLayout {
                                id: innerLayout
                                anchors.fill: parent

                                Text {
                                    id: songTitle
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Kirigami.Units.largeSpacing
                                    Layout.bottomMargin: (app.narrowLayout) ?  Kirigami.Units.largeSpacing : 0
                                    color: Kirigami.Theme.textColor
                                    font.bold: !app.narrowLayout
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText
                                    text: FormatHelpers.title(app.mpdState.mpdInfo)
                                }

                                Text {
                                    id: songArtist
                                    visible: !app.narrowLayout
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Kirigami.Units.largeSpacing
                                    color: Kirigami.Theme.textColor
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText
                                    text: FormatHelpers.artist(app.mpdState.mpdInfo)
                                }

                                Text {
                                    id: songAlbum
                                    visible: !app.narrowLayout
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Kirigami.Units.largeSpacing
                                    Layout.bottomMargin: Kirigami.Units.largeSpacing
                                    color: Kirigami.Theme.textColor
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText
                                    text: FormatHelpers.album(app.mpdState.mpdInfo)
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            RowLayout {
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                ToolButton {
                                    id: ppBtn
                                    icon.name: app.mpdState.isPlaying ? Mpdw.icons.queuePause : Mpdw.icons.queuePlay
                                    onClicked: mpdTogglePlayPauseAct.onTriggered()
                                    ToolTip { text: qsTr("Starts and pauses playback") + " (P)" }
                                }

                                PlasmaComponents.ToolButton {
                                    id: volmBtn
                                    icon.name: app.volumeState.volume > 75
                                               ? Mpdw.icons.volumeHigh
                                               : app.volumeState.volume > 25
                                                 ? Mpdw.icons.volumeMedium
                                                 : app.volumeState.volume > 0
                                                   ? Mpdw.icons.volumeLow
                                                   : Mpdw.icons.volumeMuted
                                    text: app.volumeState.volume
                                    Kirigami.MnemonicData.enabled: false
                                    ToolTip {text: qsTr("Volume (+/=/-/Scroll Wheel)")}
                                    Shortcut {
                                        sequences: ["+", "="]
                                        onActivated: app.volumeState.change(2)
                                    }
                                    Shortcut {
                                        sequence: "-"
                                        onActivated: app.volumeState.change(-2)
                                    }
                                    MouseArea {
                                        anchors.fill: parent
                                        onClicked: function (mouse) {
                                            volmSlider.visible = volmSlider.visible? false : true
                                        }
                                        onWheel: function (wheel) {
                                            app.volumeState.wheel(wheel.angleDelta.y)
                                        }
                                    }

                                    ToolTip {
                                        id: volmSlider
                                        delay: -1
                                        x: volmBtn.x - volmSlider.width / 2
                                        y: volmBtn.y
                                        // visible: true // debug
                                        contentItem: RowLayout {
                                            height:parent.height
                                            Kirigami.Icon {
                                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                                Layout.fillHeight: false
                                                source: Mpdw.icons.volumeMuted
                                            }
                                            PlasmaComponents.Slider {
                                                id: volumeSlider
                                                from: 0
                                                to: 100
                                                stepSize: 1
                                                onValueChanged: app.volumeState.set(volumeSlider.value)
                                                value: app.volumeState.volume
                                            }
                                            Kirigami.Icon {
                                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                                Layout.fillHeight: false
                                                source: Mpdw.icons.volumeHigh
                                            }

                                        }
                                    }
                                }

                                MessageIcon {
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.small
                                    Layout.preferredWidth: Layout.preferredHeight
                                }
                            }

                            // Buttons for repeat, random, consume playback
                            RowLayout {
                                Layout.fillWidth: true
                                Layout.rightMargin: Kirigami.Units.largeSpacing
                                Item { Layout.fillWidth: true } // push Repeater right
                                Repeater {
                                    model: [mpdToggleRepeatAct, mpdToggleRandomAct, mpdToggleConsumeAct]
                                    MpdToggleView {
                                        narrowLayout: app.narrowLayout
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }

        Kirigami.Action {
            shortcut: StandardKey.Find // "Ctrl+F"
            onTriggered: app.showPage("albumartists").search()
        }

        Kirigami.Action {
            shortcut:  "Ctrl+Shift+F"
            onTriggered: {
                const page = app.showPage("playlist")
                page.search()
            }
        }

        Kirigami.Action {
            id: mpdTogglePlayPauseAct
            shortcut: "p"
            onTriggered: { app.mpdState.togglePlayPause() }
        }

        MpdToggleAction {
            id: mpdToggleRepeatAct
            mpdOption: "repeat"
            mpdState: app.mpdState
            text: qsTr("Repeat")
            icon.name: Mpdw.icons.queueRepeat
            shortcut: "R"
            tooltip: "Toggle MPD's Repeat mode"
            onTriggered: app.mpdState.toggleOption("repeat")
        }
        MpdToggleAction {
            id: mpdToggleRandomAct
            mpdOption: "random"
            mpdState: app.mpdState
            text: qsTr("Random")
            icon.name: Mpdw.icons.queueRandom
            shortcut: "X"
            tooltip: "Toggle MPD's Random mode"
            onTriggered: app.mpdState.toggleOption("random")
        }
        MpdToggleAction {
            id: mpdToggleConsumeAct
            mpdOption: "consume"
            mpdState: app.mpdState
            text: qsTr("Consume")
            icon.name: Mpdw.icons.queueConsume
            shortcut: "C"
            tooltip: "Toggle MPD's Consume mode"
            onTriggered: app.mpdState.toggleOption("consume")
        }

        Kirigami.Action {
            id: showCurrentSongAction
            shortcut: "L"
            text: qsTr("Show Current Song")
            onTriggered: {
                const page = app.showPage('queue')
                page.followMode.autoMode = true
                page.followMode.showCurrent()
            }
        }

        Kirigami.Action {
            id: stashAction
            shortcut: "S"
            text: qsTr("Stash")
            tooltip: qsTr("Quick Save to Playlist and Clear Queue")
            onTriggered: {
                if (app.mpdState.mpdQueue.length === 0) {
                    AppContext.notify(qsTr("Nothing on Queue"))
                    return
                }
                const date = new Date()
                const day = Qt.formatDateTime(date, "yy-MM-dd")
                const time = date.toLocaleTimeString(Locale.ShortFormat)
                const song = app.mpdState.mpdQueue[0]
                const title = song.albumartist || song.artist || song.title
                const plTitle = qsTr("%1 %2 - %3").arg(day).arg(time).arg(title)
                app.mpdState.stashQueue(plTitle, (exitCode) => {
                    let message = "Stashed"
                    switch (exitCode) {
                        case MpdState.PlaylistSaveCodes.Success:
                            message = qsTr("Stashed")
                            break
                        case MpdState.PlaylistSaveCodes.PlaylistExists:
                            message = qsTr("Playlist With Same Name Exists")
                            break
                        case MpdState.PlaylistSaveCodes.UnknwonError:
                        default:
                            message = qsTr("Unknown Error Occured")
                    }
                    AppContext.notify(message)
                })
            }
        }

        Kirigami.Action {
            shortcut: "F9"
            onTriggered: {
                if (!debugWindowLoader.item) {
                    debugWindowLoader.source = "./../../Components/Debug/DebugIcons.qml"
                } else {
                    debugWindowLoader.item.visible = debugWindowLoader.item.visible ? false : true
                }
            }
        }
        Loader {
            id: debugWindowLoader
        }

        function minimize() {
            windowPreMinimizeSize = win.height
            win.height = footer.height
        }

        function maximize() {
            win.height = windowPreMinimizeSize
            windowPreMinimizeSize = -1
        }

        Connections {
            target: app
            function onHeightChanged() {
                if (app.windowPreMinimizeSize > 0 && (win.height > app.footer.height)) {
                    app.windowPreMinimizeSize = -1
                }
            }
        }
    }
}
