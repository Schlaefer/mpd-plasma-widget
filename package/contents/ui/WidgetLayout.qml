import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import "./Mpdw.js" as Mpdw
import "./Components"
import "./Components/Queue"
import "../scripts/formatHelpers.js" as FormatHelpers

GridLayout {
    columns: cfgHorizontalLayout ? 3 : 1
    rows: cfgHorizontalLayout ? 1 : 3

    // Cover Image
    WidgetCoverImage {
        id: coverImageContainer

        coverRadius: cfgCornerRadius
        shadowColor: cfgShadowColor
        shadowSpread: cfgShadowSpread

        onHeightChanged: sourceSizeTimer.restart()
        onWidthChanged: sourceSizeTimer.restart()

        // Delay setting the source otherwise resizing the widget is very shoppy.
        Timer {
            id: sourceSizeTimer
            interval: 1000
            onTriggered: {
                coverImageContainer.sourceSize.height = height
                coverImageContainer.sourceSize.width = height
            }
        }

        Component.onCompleted: {
            sourceSizeTimer.start()
        }

        // @BOGUS This seems bogus but is necessary since Image is wrapped by Item
        Layout.minimumWidth: cfgHorizontalLayout ? parent.height : parent.width
    }

    // Volume Slider
    PlasmaComponents.Slider {
        id: volumeSlider

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
        stepSize: 1
        onValueChanged: volumeState.set(volumeSlider.value)

        Connections {
            target: volumeState
            function onVolumeChanged() {
                volumeSlider.value = volumeState.volume
            }
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
                icon.name: Mpdw.icons.dialogClose
                icon.height: Kirigami.Units.iconSizes.small
                icon.width: Kirigami.Units.iconSizes.small
                onClicked: notification.text = ''
            }
        }
    }
}
