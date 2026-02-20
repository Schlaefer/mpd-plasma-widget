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
import "./../../Components/Queue"
import "./../../Components/Playlists"
import "../../../scripts/formatHelpers.js" as FormatHelpers
import "../../../logic"

PlasmaCore.Window {
    id: win

    property alias app: app

    required property MpdState mpdState
    required property VolumeState volumeState

    property int narrowBreakPoint: 520
    property bool narrowLayout: app.width < narrowBreakPoint
    property int windowPreMinimizeSize: -1
    property int initialHeight: -1

    modality: Qt.NonModal
    flags: Qt.Dialog
    title: qsTr("MPD")

    maximumWidth: 719
    minimumWidth: 250
    minimumHeight: app.footer.height

    Component.onCompleted: {
        height = (initialHeight > 800 ? 0.7 : 0.95) * initialHeight
        width = height / 1.60
    }

    mainItem: Kirigami.ApplicationItem {
        id: app

        anchors.fill: parent

        property alias mpdState: win.mpdState
        property alias volumeState: win.volumeState
        property alias narrowLayout: win.narrowLayout
        property alias windowPreMinimizeSize: win.windowPreMinimizeSize
        property alias initialHeight: win.initialHeight


        /**
          * Global properties for pages
          */
        readonly property var pages: [
            {
                name: "queue",
                icon: Mpdw.icons.placeQueue,
                shortcut: "1",
                text: qsTr("Queue"),
                tooltip: qsTr("Show Queue"),
                component: () => queuePageComponent
            },
            {
                name: "albumartists",
                icon: Mpdw.icons.placeArtist,
                shortcut: "2",
                text: qsTr("Artists"),
                tooltip: qsTr("Show Artists"),
                component: () => albumartistsPageComponent
            },
            {
                name: "playlist",
                icon: Mpdw.icons.placePlaylist,
                shortcut: "3",
                text: qsTr("Playlists"),
                tooltip: qsTr("Show Playlists"),
                component: () => playlistPageComponent
            }
        ]

        /**
         * Current page according to pages.name
         */
        property string currentPage: "queue"

        /**
         * Set initial page from page cache
         */
        pageStack.initialPage: getPage(currentPage)

        /**
         * Cache for page components
         */
        property var pageCache: ({})

        function showPage(name) {
            if (currentPage === name) {
                return
            }

            currentPage = name

            while (app.pageStack.depth > 0) {
                app.pageStack.pop()
            }

            app.pageStack.push(getPage(name))
        }

        /**
         * Get page from component cache
         *
         * @param {string} name Human readable page.name
         */
        function getPage(name) {
            if (!pageCache[name]) {
                const entry = pages.find(p => p.name === name)
                pageCache[name] = entry.component().createObject(app)
            }
            return pageCache[name]
        }

        Component {
            id: queuePageComponent
            QueuePage { }
        }

        Component {
            id: albumartistsPageComponent
            AlbumartistsPage { }
        }

        Component {
            id: playlistPageComponent
            PlaylistsPage { }
        }

        Repeater {
            model: win.app.pages
            // Anchor shortcut to an item in the scene since the delegates are created
            // dynamically.
            Item {
                Shortcut {
                    sequence: modelData.shortcut
                    onActivated: function() {
                        win.app.showPage(modelData.name)
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
                                    Layout.bottomMargin: (win.narrowLayout) ?  Kirigami.Units.largeSpacing : 0
                                    color: Kirigami.Theme.textColor
                                    font.bold: !win.narrowLayout
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText

                                    Connections {
                                        target: app.mpdState
                                        function onMpdInfoChanged() {
                                            songTitle.text = FormatHelpers.title(app.mpdState.mpdInfo)
                                        }
                                    }
                                }

                                Text {
                                    id: songArtist
                                    visible: !win.narrowLayout
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Kirigami.Units.largeSpacing
                                    color: Kirigami.Theme.textColor
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText

                                    Connections {
                                        target: app.mpdState
                                        function onMpdInfoChanged() {
                                            songArtist.text = FormatHelpers.artist(app.mpdState.mpdInfo)
                                        }
                                    }
                                }

                                Text {
                                    id: songAlbum
                                    visible: !win.narrowLayout
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Kirigami.Units.largeSpacing
                                    Layout.bottomMargin: Kirigami.Units.largeSpacing
                                    color: Kirigami.Theme.textColor
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText

                                    Connections {
                                        target: app.mpdState
                                        function onMpdInfoChanged() {
                                            songAlbum.text = FormatHelpers.album(app.mpdState.mpdInfo)
                                        }
                                    }
                                }
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            RowLayout {
                                Layout.leftMargin: Kirigami.Units.largeSpacing
                                ToolButton {
                                    id: ppBtn
                                    icon.name: app.mpdState.mpdPlaying ? Mpdw.icons.queuePause : Mpdw.icons.queuePlay
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
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.rightMargin: Kirigami.Units.largeSpacing

                                //  Layout.alignment: Qt.AlignRight
                                Item { Layout.fillWidth: true }

                                Repeater {
                                    model: [
                                        mpdToggleRepeatAct,
                                        mpdToggleRandomAct,
                                        mpdToggleConsumeAct,
                                    ]
                                    MpdToggleOptionItem {}
                                }
                            }
                        }
                    }
                }
            }
        }

        Kirigami.Action {
            shortcut: StandardKey.Find
            onTriggered: {
                app.showPage("albumartists")
                while (app.pageStack.depth > 1) { app.pageStack.pop() } // Exit subviews
                app.getPage("albumartists").viewState = "startSearch"
            }
        }

        Kirigami.Action {
            id: mpdTogglePlayPauseAct
            shortcut: "p"
            onTriggered: { app.mpdState.togglePlayPause() }
        }

        Kirigami.Action {
            id: mpdToggleRepeatAct
            property string mpdOption: "repeat"
            text: qsTr("Repeat")
            icon.name: Mpdw.icons.queueRepeat
            shortcut: "R"
            tooltip: "Toggle MPD's Repeat mode"
            onTriggered: app.mpdState.toggleOption("repeat")
        }

        Kirigami.Action {
            id: mpdToggleRandomAct
            property string mpdOption: "random"
            text: qsTr("Random")
            icon.name: Mpdw.icons.queueRandom
            shortcut: "X"
            tooltip: "Toggle MPD's Random mode"
            onTriggered: app.mpdState.toggleOption("random")
        }
        Kirigami.Action {
            id: mpdToggleConsumeAct
            property string mpdOption: "consume"
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
            icon.name: Mpdw.icons.queueShowCurrent
            onTriggered: {
                app.showPage('queue')
                let page = app.getPage('queue')
                page.followMode.autoMode = true
                page.followMode.showCurrent()
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
