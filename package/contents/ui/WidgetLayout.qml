import "../scripts/formatHelpers.js" as FormatHelpers
import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents

GridLayout {
    property var mpd
    property var coverManager
    property alias cornerRadius: coverImageContainer.radius
    property alias shadowSpread: coverImageContainer.shadowSpread
    property alias shadowColor: effect.color

    columns: cfgHorizontalLayout ? 3 : 1
    rows: cfgHorizontalLayout ? 1 : 3
    Item {
        id: coverImageContainer

        property var radius: 0
        property var shadowSpread: 0

        Layout.fillHeight: true
        // @TODO This seems bogus but is necessary since Image is wrapped by Item
        Layout.minimumWidth: cfgHorizontalLayout ? parent.height : parent.width
        MouseArea {
            anchors.fill: parent
            onClicked: mpd.toggle()
            onWheel: wheel => {
                         volumeSlider.value = volumeSlider.value + wheel.angleDelta.y / 60
                     }
            onDoubleClicked: {
                mpd.playNext()
            }
        }

        RectangularGlow {
            id: effect
            anchors.centerIn: coverImage
            height: coverImage.paintedHeight
            width: coverImage.paintedWidth
            glowRadius: coverImageContainer.shadowSpread
            spread: 0
            cornerRadius: coverImageContainer.radius
            visible: coverImageContainer.shadowSpread > 0
        }

        // Cover Image
        Image {
            id: coverImage

            visible: false
            cache: false
            mipmap: true
            anchors.fill: parent
            // Layout.fillWidth: true
            // Layout.fillHeight: true
            Layout.maximumWidth: height > height ? width : height
            fillMode: Image.PreserveAspectFit

            // @TODO
            // fillMode: Image.PreserveAspectCrop
            Timer {
                id: coverCheck
                interval: 500
                repeat: true
                triggeredOnStart: true
                onTriggered: {
                    let cover = coverManager.getCover(mpd.mpdInfo, 1)
                    if (typeof (cover) === 'undefined') {
                        return
                    }
                    stop()
                    if (cover === null) {
                        return
                    }
                    // @TODO there must be a better way to force an update
                    // Leave for uncached version which doesn't change file name
                    coverImage.source = ""
                    coverImage.source = cover
                }
            }

            Connections {
                function onMpdInfoChanged() {
                    coverCheck.start()
                }

                target: mpd
            }
        }
        Item {
            id: mask
            anchors.fill: coverImage
            visible: false

            Rectangle {
                color: "white"
                radius: coverImageContainer.radius
                anchors.centerIn: parent
                width: coverImage.paintedWidth
                height: coverImage.paintedHeight
            }
        }

        OpacityMask {
            anchors.fill: coverImage
            source: coverImage
            maskSource: mask
        }
    }

    // Volume Slider
    PlasmaComponents.Slider {
        id: volumeSlider

        property bool dontSendRequestOnRead: false

        value: mpdState.mpdVolume
        Layout.fillHeight: cfgHorizontalLayout
        Layout.fillWidth: !cfgHorizontalLayout
        // @TODO There must be a way to do this
        Layout.maximumWidth: cfgHorizontalLayout ? 15 : 40000
        Layout.leftMargin: !cfgHorizontalLayout ? 10 : 0
        Layout.rightMargin: !cfgHorizontalLayout ? 10 : 0
        // Orientation bugged? Disabled on horizontal layout for now
        // See: https://bugs.kde.org/show_bug.cgi?id=474611
        // orientation: cfgHorizontalLayout ? Qt.Vertical : Qt.Horizontal
        visible: !cfgHorizontalLayout
        minimumValue: 0
        maximumValue: 100
        // Leave at 1. Otherwise the slider fights with mpd if mpd sends a value that doesn't fit the step size.
        stepSize: 1
        onValueChanged: {
            // Don't trigger a send to mpd again if just received the "mixer"
            // event value from our own slider value change.
            if (volumeSlider.value !== mpd.mpdVolume)
                mpd.setVolume(value)
        }

        Connections {
            function onMpdVolumeChanged() {
                if (volumeSlider.value !== mpd.mpdVolume)
                    volumeSlider.value = mpd.mpdVolume
            }

            target: mpd
        }
    }

    // Title
    ColumnLayout {
        id: descriptionContainer

        Layout.leftMargin: cfgFontSize
        Layout.rightMargin: cfgFontSize
        Layout.fillWidth: true
        Layout.fillHeight: true

        MouseArea {
            width: parent.width
            height: parent.height
            onClicked: {
                popupDialog.visible = !popupDialog.visible
            }
        }

        Connections {
            function onMpdInfoChanged() {
                let data = mpd.mpdInfo
                songTitle.text = FormatHelpers.title(data)
                songArtist.text = FormatHelpers.artist(data)
                songAlbum.text = FormatHelpers.album(data)
            }

            target: mpd
        }

        PlasmaComponents.Label {
            id: songTitle

            font.pixelSize: cfgFontSize
            font.weight: Font.Bold
            horizontalAlignment: descriptionAlignment == 2 ? Text.AlignRight : (descriptionAlignment == 1 ? Text.AlignHCenter : Text.AlignLeft)
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        PlasmaComponents.Label {
            id: songArtist

            font.pixelSize: cfgFontSize
            horizontalAlignment: descriptionAlignment == 2 ? Text.AlignRight : (descriptionAlignment == 1 ? Text.AlignHCenter : Text.AlignLeft)
            wrapMode: Text.Wrap
            visible: text.length > 0
            Layout.fillWidth: true
        }

        PlasmaComponents.Label {
            id: songAlbum

            font.pixelSize: cfgFontSize
            horizontalAlignment: descriptionAlignment == 2 ? Text.AlignRight : (descriptionAlignment == 1 ? Text.AlignHCenter : Text.AlignLeft)
            wrapMode: Text.Wrap
            Layout.fillWidth: true
        }

        PlasmaComponents.Label {
            id: songYear

            font.pixelSize: cfgFontSize
            horizontalAlignment: descriptionAlignment == 2 ? Text.AlignRight : (descriptionAlignment == 1 ? Text.AlignHCenter : Text.AlignLeft)
            visible: text.length > 0
            Layout.fillWidth: true
        }
        // Error messages
        PlasmaComponents.Label {
            id: notification

            wrapMode: Text.Wrap
            Layout.fillWidth: true
            visible: text.length > 0

            Connections {
                function onAppLastErrorChanged() {
                    notification.text = root.appLastError
                }

                target: root
            }
        }
    }
}
