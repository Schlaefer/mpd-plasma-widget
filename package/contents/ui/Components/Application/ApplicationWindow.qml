import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore
import "./../../Components/"
import "./../../Components/Albumartists"
import "./../../Components/Application"
import "./../../Components/Queue"
import "./../../Components/Playlists"
import "../../../scripts/formatHelpers.js" as FormatHelpers

Kirigami.ApplicationWindow {
    id: root

    maximumWidth: 719
    minimumWidth: 280
    minimumHeight: footer.height

    property bool narrowLayout: appWindow.width < 520
    property int windowPreMinimizeSize: -1

    flags: Qt.Window
    title: qsTr("MPD")
    pageStack.initialPage: queuePage
//    pageStack.initialPage: albumartistsPage

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

    function showPage(page) {
        if (!page.visible) {
            while (appWindow.pageStack.depth > 0)
                appWindow.pageStack.pop()
            appWindow.pageStack.push(page)
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
                        wrapMode: Text.WordWrap

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
                        wrapMode: Text.WordWrap

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
                        wrapMode: Text.WordWrap

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
                                icon.name: mpdState.mpdPlaying ? "media-playback-pause" : "media-playback-start"
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
                                icon.name: "audio-volume-" + (mpdState.mpdVolume > 80  ? "high" : (mpdState.mpdVolume > 20 ? "medium" : (mpdState.mpdVolume > 0 ? "low" : "muted")))
                                text: mpdState.mpdVolume
                                ToolTip {text: qsTr("Volume (+/=/-/Scroll Wheel)")}
                                Shortcut {
                                    sequences: ["+", "="]
                                    onActivated: mpdState.setVolume("+2")
                                }
                                Shortcut {
                                    sequence: "-"
                                    onActivated: mpdState.setVolume("-2")
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: function (mouse) {
                                        volmSlider.visible = volmSlider.visible? false : true
                                    }
                                    onWheel: function (wheel) {
                                        widgetLayout.volume = widgetLayout.volume + wheel.angleDelta.y / 60
                                    }
                                }

                                ToolTip {
                                    id: volmSlider
                                    delay: -1
                                    x: volmBtn.x - volmSlider.width / 2
                                    y: volmBtn.y
//                                    visible: true
                                    contentItem:
                                        RowLayout {
                                        height:parent.height
                                        Kirigami.Icon {
                                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                            Layout.fillHeight: false
                                            source: "audio-volume-muted"
                                        }

                                        // @TODO refactor all volume sliders
                                        PlasmaComponents.Slider {
                                            id: slider
                                            minimumValue: 0
                                            maximumValue: 100
                                            // Leave at 1. Otherwise the slider fights with mpd if mpd sends a value that doesn't fit the step size.
                                            stepSize: 1
                                            value: mpdState.mpdVolume

                                            onValueChanged: {
                                                // Don't trigger sending to mpd again if we just received the "mixer"
                                                // event value from our own slider value change.
                                                if (slider.value !== mpdState.mpdVolume) {
                                                    mpdState.setVolume(value)
                                                }
                                            }

                                            Connections {
                                                function onMpdVolumeChanged() {
                                                    if (slider.value !== mpdState.mpdVolume)
                                                        slider.value = mpdState.mpdVolume
                                                }
                                                target: mpdState
                                            }

                                        }
                                        Kirigami.Icon {
                                            source: "audio-volume-high"
                                            Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                            Layout.fillHeight: false
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
                                    {
                                        itOpt: "repeat",
                                        itSc: "shift+z",
                                        iconName: "media-playlist-repeat",
                                        itTtp: "Toggle MPD's repeat mode",
                                    },
                                    {
                                        itOpt: "random",
                                        itSc: "z",
                                        iconName: "media-playlist-shuffle",
                                        itTtp: "Toogle MPD's random mode",
                                    },
                                    {
                                        itOpt: "consume",
                                        itSc: "r",
                                        iconName: "draw-eraser",
                                        itTtp: "Toogle MPD's consume mode",
                                    }
                                ]

                                MpdToggleOptionItem {
                                    iconName: modelData.iconName
                                    itSc: modelData.itSc
                                    itOpt: modelData.itOpt
                                    itTtp: modelData.itTtp
                                }
                            }

                        }
                    }
                }
            }
        }
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
