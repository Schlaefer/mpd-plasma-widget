import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import "./Components"
import "./Components/Queue"
import "../scripts/formatHelpers.js" as FormatHelpers

GridLayout {
    // @TODO better way to change volume globally
    // @TODO Consolidate all the sprinkled wheel change in one place
    property alias volume: volumeSlider.value

    columns: cfgHorizontalLayout ? 3 : 1
    rows: cfgHorizontalLayout ? 1 : 3

    // Cover Image
    WidgetCoverImage {
        id: coverImageContainer

        coverRadius: cfgCornerRadius
        shadowColor: cfgShadowColor
        shadowSpread: cfgShadowSpread

        // @BOGUS This seems bogus but is necessary since Image is wrapped by Item
        Layout.minimumWidth: cfgHorizontalLayout ? parent.height : parent.width
    }

    // Volume Slider
    PlasmaComponents.Slider {
        id: volumeSlider

        value: mpdState.mpdVolume
        Layout.fillHeight: cfgHorizontalLayout
        Layout.fillWidth: !cfgHorizontalLayout
        Layout.leftMargin: !cfgHorizontalLayout ? Kirigami.Units.largeSpacing : 0
        Layout.rightMargin: !cfgHorizontalLayout ? Kirigami.Units.largeSpacing : 0

        // Orientation bugged? Hide on horizontal layout for now
        // See: https://bugs.kde.org/show_bug.cgi?id=474611
        // Layout.maximumWidth: cfgHorizontalLayout ? 15 : -1
        // orientation: cfgHorizontalLayout ? Qt.Vertical : Qt.Horizontal
        visible: !cfgHorizontalLayout
        minimumValue: 0
        maximumValue: 100
        // Leave at 1. Otherwise the slider fights with mpd if mpd sends a value that doesn't fit the step size.
        stepSize: 1
        onValueChanged: {
            // Don't trigger sending to mpd again if we just received the "mixer"
            // event value from our own slider value change.
            if (volumeSlider.value !== mpdState.mpdVolume) {
                mpdState.setVolume(value)
            }
        }

        Connections {
            function onMpdVolumeChanged() {
                if (volumeSlider.value !== mpdState.mpdVolume)
                    volumeSlider.value = mpdState.mpdVolume
            }
            target: mpdState
        }
    }

    // Title
    ColumnLayout {
        id: descriptionContainer

        Layout.leftMargin: Kirigami.Units.largeSpacing
        Layout.rightMargin: Kirigami.Units.largeSpacing
        Layout.fillWidth: true
        Layout.fillHeight: true

        ColumnLayout {
            QueueEmptyPlaceholder {}

            WidgetLabel {
                id: songTitle
                font.weight: Font.Bold
                visible: mpdState.countQueue()

                Connections {
                    function onMpdInfoChanged() {
                        songTitle.text = FormatHelpers.title(mpdState.mpdInfo)
                    }
                    function onMpdQueueChanged() {
                        if (mpdState.countQueue() === 0) {
                            songTitle.text = ""
                        }
                    }
                    target: mpdState
                }

            }

            WidgetLabel {
                id: songArtist
                visible: (notification.text.length === 0 && mpdState.countQueue() )

                Connections {
                    function onMpdInfoChanged() {
                        songArtist.text = FormatHelpers.artist(mpdState.mpdInfo)
                    }
                    function onMpdQueueChanged() {
                        if (mpdState.countQueue() === 0) {
                            songArtist.text = ""
                        }
                    }
                    target: mpdState
                }
            }

            WidgetLabel {
                id: songAlbum
                visible: (notification.text.length === 0 && mpdState.countQueue() )

                Connections {
                    function onMpdInfoChanged() {
                        songAlbum.text = FormatHelpers.album(mpdState.mpdInfo)
                    }
                    function onMpdQueueChanged() {
                        if (mpdState.countQueue() === 0) {
                            songAlbum.text = ""
                        }
                    }
                    target: mpdState
                }
            }

            MouseArea {
                width: parent.width
                height: parent.height
                onClicked: {
                    main.toggleAppWindow()
                }
            }
        }
        // Notifications
        RowLayout {
            visible: !!notification.text
            WidgetLabel {
                id: notification

                visible: text.length > 0
                font.italic: true

                Connections {
                    function onAppLastErrorChanged() {
                        notification.text = main.appLastError
                    }

                    target: main
                }
            }

            ToolButton {
                icon.name: "dialog-close"
                icon.height: Kirigami.Units.iconSizes.small
                icon.width: Kirigami.Units.iconSizes.small
                onClicked: notification.text = ''
            }
        }
    }
}
