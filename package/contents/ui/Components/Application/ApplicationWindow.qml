import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import "./../../Mpdw.js" as Mpdw
import "./../../Components/"
import "./../../Components/Albumartists"
import "./../../Components/Application"
import "./../../Components/Queue"
import "./../../Components/Playlists"
import "../../../scripts/formatHelpers.js" as FormatHelpers

Kirigami.ApplicationWindow {
    id: root

    property bool narrowLayout: appWindow.width < 520
    property int windowPreMinimizeSize: -1
    property int initialHeight: -1

    flags: Qt.Window
    title: qsTr("MPD")
    maximumWidth: 719
    minimumWidth: 250
    minimumHeight: footer.height

    pageStack.initialPage: queuePage
//   pageStack.initialPage: albumartistsPage

    function showPage(page) {
        if (!page.visible) {
            while (appWindow.pageStack.depth > 0)
                appWindow.pageStack.pop()
            appWindow.pageStack.push(page)
        }
    }

    Component.onCompleted: {
        if (initialHeight > 800) {
            height = initialHeight
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
                onActivated: showPage(modelData)
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
                                if (root.windowPreMinimizeSize === -1) {
                                    root.minimize()
                                } else {
                                    root.maximize()
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
                        Layout.bottomMargin: (appWindow.narrowLayout) ?  Kirigami.Units.largeSpacing : 0
                        color: Kirigami.Theme.textColor
                        font.bold: !appWindow.narrowLayout
                        elide: Text.ElideRight
                        Connections {
                            function onMpdInfoChanged() {
                                songTitle.text = FormatHelpers.title(mpdState.mpdInfo)
                            }
                            target: mpdState
                        }
                    }
                    Text {
                        id: songArtist
                        visible: !appWindow.narrowLayout
                        Layout.fillWidth: true
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.textColor
                        elide: Text.ElideRight

                        Connections {
                            function onMpdInfoChanged() {
                                songArtist.text = FormatHelpers.artist(mpdState.mpdInfo)
                            }
                            target: mpdState
                        }
                    }

                    Text {
                        id: songAlbum
                        visible: !appWindow.narrowLayout
                        Layout.fillWidth: true
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        Layout.bottomMargin: Kirigami.Units.largeSpacing
                        color: Kirigami.Theme.textColor
                        elide: Text.ElideRight

                        Connections {
                            function onMpdInfoChanged() {
                                songAlbum.text = FormatHelpers.album(mpdState.mpdInfo)
                            }
                            target: mpdState
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        RowLayout {
                            Layout.leftMargin: Kirigami.Units.largeSpacing
                            ToolButton {
                                id: ppBtn
                                icon.name: mpdState.mpdPlaying ? Mpdw.icons.queuePause : Mpdw.icons.queuePlay
                                function toggle() { mpdState.toggle() }
                                onClicked:  ppBtn.toggle()
                                Shortcut {
                                    sequence: "p"
                                    onActivated: ppBtn.toggle()
                                }
                                ToolTip { text: qsTr("Starts and pauses playback") + " (P)" }
                            }

                            ToolButton {
                                id: volmBtn
                                icon.name: volumeState.volume > 75
                                    ? Mpdw.icons.volumeHigh
                                    : volumeState.volume > 25
                                        ? Mpdw.icons.volumeMedium
                                        : volumeState.volume > 0
                                        ? Mpdw.icons.volumeLow
                                        : Mpdw.icons.volumeMuted
                                text: volumeState.volume
                                ToolTip {text: qsTr("Volume (+/=/-/Scroll Wheel)")}
                                Shortcut {
                                    sequences: ["+", "="]
                                    onActivated: volumeState.change(2)
                                }
                                Shortcut {
                                    sequence: "-"
                                    onActivated: volumeState.change(-2)
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: function (mouse) {
                                        volmSlider.visible = volmSlider.visible? false : true
                                    }
                                    onWheel: function (wheel) {
                                        volumeState.wheel(wheel.angleDelta.y)
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
                                            minimumValue: 0
                                            maximumValue: 100
                                            stepSize: 1
                                            onValueChanged: volumeState.set(volumeSlider.value)
                                            value: volumeState.volume
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
        id: mpdToggleRepeatAct
        property string mpdOption: "repeat"
        text: qsTr("Repeat")
        icon.name: Mpdw.icons.queueRepeat
        shortcut: "Shift+Z"
        tooltip: "Toggle MPD's Repeat mode"
        onTriggered: { mpdState.toggleOption("repeat") }
    }

    Kirigami.Action {
        id: mpdToggleRandomAct
        property string mpdOption: "random"
        text: qsTr("Random")
        icon.name: Mpdw.icons.queueRandom
        shortcut: "Z"
        tooltip: "Toggle MPD's Random mode"
        onTriggered: { mpdState.toggleOption("random") }
    }
    Kirigami.Action {
        id: mpdToggleConsumeAct
        property string mpdOption: "consume"
        text: qsTr("Consume")
        icon.name: Mpdw.icons.queueConsume
        shortcut: "R"
        tooltip: "Toggle MPD's Consume mode"
        onTriggered: { mpdState.toggleOption("consume") }
    }

    Kirigami.Action {
        shortcut: "F10"
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
        windowPreMinimizeSize = root.height
        root.height = footer.height
    }

    function maximize() {
        root.height = windowPreMinimizeSize
        windowPreMinimizeSize = -1
    }

    Connections {
        target: root
        function onHeightChanged() {
            if (root.height > footer.height) {
                windowPreMinimizeSize = -1
            }
        }
    }
}
