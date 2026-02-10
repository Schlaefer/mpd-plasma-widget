import QtQuick
import QtQuick.Controls
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

    property bool narrowLayout: app.width < 520
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

        pageStack.initialPage: queuePage
        // pageStack.initialPage: albumartistsPage
        // pageStack.initialPage: playlistPage

        function showPage(page) {
            if (!page.visible) {
                while (app.pageStack.depth > 0)
                    app.pageStack.pop()
                app.pageStack.push(page)
            }
        }

        QueuePage {
            id: queuePage
        }

        PlaylistsPage {
            id: playlistPage
        }

        AlbumartistsPage {
            id: albumartistsPage
        }

        Repeater {
            model: [queuePage, albumartistsPage, playlistPage]
            Item {
                Shortcut {
                    sequence: modelData.globalShortcut
                    onActivated: app.showPage(modelData)
                }
            }
        }

        footer: ToolBar {
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
                        Text {
                            id: songTitle
                            Layout.fillWidth: true
                            Layout.leftMargin: Kirigami.Units.largeSpacing
                            Layout.bottomMargin: (win.narrowLayout) ?  Kirigami.Units.largeSpacing : 0
                            color: Kirigami.Theme.textColor
                            font.bold: !win.narrowLayout
                            elide: Text.ElideRight
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

                            Connections {
                                target: app.mpdState
                                function onMpdInfoChanged() {
                                    songAlbum.text = FormatHelpers.album(app.mpdState.mpdInfo)
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
                if (!albumartistsPage.visible) { app.showPage(albumartistsPage) }
                while (app.pageStack.depth > 1) { app.pageStack.pop() } // Exit subviews
                albumartistsPage.viewState = "startSearch"
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
