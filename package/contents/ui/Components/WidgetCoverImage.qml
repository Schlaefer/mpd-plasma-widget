import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.core 2.0 as PlasmaCore

Item {
    id: coverImageContainer

    // property alias shadowColor: effect.color
    Layout.fillHeight: true
    // @BOGUS This seems bogus but is necessary since Image is wrapped by Item
    Layout.minimumWidth: cfgHorizontalLayout ? parent.height : parent.width
    MouseArea {
        anchors.fill: parent
        onClicked: mpdState.toggle()
        onWheel: wheel => {
                     volumeSlider.value = volumeSlider.value + wheel.angleDelta.y / 60
                 }
        onDoubleClicked: {
            mpdState.playNext()
        }
    }

    PlasmaCore.IconItem {
        id: coverPlaceholderIcon
        source: "media-default-album"
        anchors.fill: parent
        visible: !coverImage.source.toString()
    }

    Image {
        id: coverImage

        visible: false
        cache: false
        mipmap: true
        anchors.fill: parent
        Layout.maximumWidth: height > height ? width : height
        // @MAYBE fillMode: Image.PreserveAspectCrop
        fillMode: Image.PreserveAspectFit

        function updateCover() {
            let cover = coverManager.getCover(mpdState.mpdInfo, 1)
            if (typeof (cover) === "undefined") {
                coverManager.gotCover.connect(updateCover)
                return
            }
            coverManager.gotCover.disconnect(updateCover)
            if (cover === null) {
                coverImage.source = ""
                return
            }
            coverImage.source = cover
        }

        Connections {
            function onMpdInfoChanged() {
                coverImage.updateCover()
            }

            function onMpdQueueChanged() {
                if (mpdState.countQueue() === 0) {
                    coverImage.source = ""
                }
            }
            target: mpdState
        }
    }

    Item {
        id: mask
        anchors.fill: coverImage
        visible: false

        Rectangle {
            color: "white"
            radius: cfgCornerRadius
            anchors.centerIn: parent
            width: coverImage.paintedWidth
            height: coverImage.paintedHeight
        }
    }

    OpacityMask {
        anchors.fill: coverImage
        source: coverImage
        maskSource: mask

        layer.enabled: cfgShadowSpread > 0 && !!coverImage.source.toString()
        layer.effect: DropShadow {
            verticalOffset: 0
            horizontalOffset: 0
            color: cfgShadowColor
            radius: cfgShadowSpread
            samples: 17
        }
    }
}
