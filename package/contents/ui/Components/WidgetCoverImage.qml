pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import org.kde.kirigami as Kirigami
import "./../Mpdw.js" as Mpdw
import "../../logic"

Item {
    id: root

    signal sourceChanged(string source)

    required property MpdState mpdState
    required property VolumeState volumeState
    property bool applyEffects: false
    property bool overlayFeedback: false
    property int coverRadius: 0
    property int shadowSpread: 0
    property string shadowColor
    property alias sourceSize: coverImage.sourceSize
    readonly property int _overlayFadeOutTime: 400
    readonly property real _overlayOpacity: 0.8
    readonly property int _overlayShowTimeDefault: 100
    readonly property int _overlayShowTimeLong: 2000

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                if (mouse.modifiers & Qt.ShiftModifier) {
                    nextSong()
                    return
                }
                mpdStateConnection.enabled = true
                feedbackOverlayTimer.restart()
                root.mpdState.togglePlayPause()
            } else if (mouse.button === Qt.RightButton) {
                if (!contextMenuLoader.item) {
                    contextMenuLoader.sourceComponent = contextMenuComponent
                }
                if (contextMenuLoader.item.visible) {
                    contextMenuLoader.item.close()
                } else {
                    contextMenuLoader.item.popup()
                }
            } else if (mouse.button === Qt.MiddleButton) {
                nextSong()
            }

        }

        onWheel: function (wheel) {
            volumeStateConnection.enabled = true
            feedbackOverlayTimer.restart()
            root.volumeState.wheel(wheel.angleDelta.y)
        }

        function nextSong() {
            root.mpdState.playNext()
            root.showFeedback({icon: Mpdw.icons.queueSkipNext})
        }

        Loader {
            id: contextMenuLoader
        }

        Component {
            id: contextMenuComponent
            Menu {
                id: contextMenu
                MenuItem {
                    text: qsTr("Update MPD Data")
                    icon.name: Mpdw.icons.mpdUpdate
                    onTriggered: {
                        root.mpdState.forceReloadEverything()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Clear Cover Cache")
                    icon.name: Mpdw.icons.clearCache
                    onTriggered: {
                        AppContext.getCoverManager().clearCache()
                    }
                }
            }
        }
    }

    Kirigami.Icon {
        id: coverPlaceholderIcon
        source: Mpdw.icons.queuePlaceholderCover
        anchors.fill: parent
        visible: !coverImage.source.toString()
    }

    Image {
        id: coverImage

        visible: false
        mipmap: true
        anchors.fill: parent
        Layout.maximumWidth: height > height ? width : height
        fillMode: Image.PreserveAspectFit

        function updateCover() {
            if (!root.mpdState.mpdInfo) {
                // Queue got emptied.
                coverImage.source = ""
                return
            }
            let cover = AppContext.getCoverManager().getCover(root.mpdState.mpdInfo, 1)
            if (typeof (cover) === "undefined") {
                AppContext.getCoverManager().gotCover.connect(updateCover)
                return
            }
            AppContext.getCoverManager().gotCover.disconnect(updateCover)
            if (cover === null) {
                coverImage.source = ""
                return
            }
            // Force QML to update even if cover file stays the same. This helps if
            // the cover "got stuck" for whatever reason: a play next even in the same
            // album will always trigger.
            coverImage.source = ""
            coverImage.source = "file://" + cover + "-large.jpg"
        }

        Component.onCompleted: {
            // @SOMEDAY Do better.
            //
            // Case A) mpdInfo may still not be fetched from the server when started
            // as a desktop widget. That will work fine though being bound to
            // onMpdInfoChanged.
            //
            // Case B) mpdInfo is usually always available for the app footer image
            // But showing the image isn't triggered by onMpdInfoChanged, so we have
            // to trigger it manually but guard against case A.
            if (root.mpdState.mpdInfo) {
                updateCover()
            }
        }

        onSourceChanged: {
            root.sourceChanged(coverImage.source)
        }

        Connections {
            target: root.mpdState

            function onMpdInfoChanged() {
                coverImage.updateCover()
            }
        }

        Connections {
            target: AppContext.getCoverManager()
            function onAfterReset() {
                coverImage.source = ""
                coverImage.updateCover()
            }
        }
    }

    // === Cover Effects ===
    // Create rounded corner mask
    Item {
        id: mask
        anchors.fill: coverImage
        visible: false

        Rectangle {
            color: "white"
            radius: root.coverRadius
            anchors.centerIn: parent
            width: coverImage.paintedWidth
            height: coverImage.paintedHeight
        }
    }

    // Apply mask and drop-shadow
    OpacityMask {
        anchors.fill: coverImage
        source: coverImage
        maskSource: mask

        layer.enabled: root.applyEffects && root.shadowSpread > 0
                       && !!coverImage.source.toString()
        layer.effect: DropShadow {
            verticalOffset: 0
            horizontalOffset: 0
            color: root.shadowColor
            radius: root.shadowSpread
            samples: 17
        }
    }

    // #############################################
    // # Overlay for play/pause and volume
    // #############################################
    Item {
        id: overlay
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        opacity: 0

        Behavior on opacity {
            enabled: overlay.opacity > 0
            OpacityAnimator {
                duration: root._overlayFadeOutTime
                easing.type: Easing.InQuad
            }
        }

        // Backdrop
        Rectangle {
            id: backdrop
            anchors.centerIn: parent
            width: (overlayIcon.width > overlayText.width ? overlayIcon.width : overlayIcon.height) + 20
            height: width
            radius: width / 2
            opacity: root._overlayOpacity
            color: Qt.rgba(
                Kirigami.Theme.backgroundColor.r,
                Kirigami.Theme.backgroundColor.g,
                Kirigami.Theme.backgroundColor.b,
                0.6
            )
        }

        DropShadow {
            anchors.fill: backdrop
            radius: 8
            color: backdrop.color
            source: backdrop
        }

        Kirigami.Icon {
            id: overlayIcon
            anchors.centerIn: parent
            width: coverImage.paintedHeight / 5
            height: width
            source: Mpdw.icons.queuePlay
            visible: false
        }

        Label {
            id: overlayText
            anchors.centerIn: parent
            width: coverImage.paintedHeight / 7
            height: width
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pointSize: width / 3 < 10 ? 10 : width / 3
            visible: false
        }


    }

    // Controls fading out the overlay
    Timer {
        id: fadeOutTimer
        interval: root._overlayShowTimeDefault
        repeat: false
        onTriggered: overlay.opacity = 0
    }


    // I only want to emit overlay change info for events on the cover which have no
    // other indicator. This is surely personal taste, but I find feedback from other
    // sources distracting.
    Timer {
        id: feedbackOverlayTimer
        interval: 500
        onTriggered: {
            mpdStateConnection.enabled = false
            volumeStateConnection.enabled = false
        }
    }

    Connections {
        id: mpdStateConnection
        target: root.mpdState
        enabled: false
        function onIsPlayingChanged() {
            root.showFeedback({icon: root.mpdState.isPlaying ? Mpdw.icons.queuePlay : Mpdw.icons.queuePause})
        }
    }

    Connections {
        id: volumeStateConnection
        target: root.volumeState
        enabled: false
        function onVolumeChanged() {
            root.showFeedback({text: qsTr("%1\%").arg(root.volumeState.volume)}, root._overlayShowTimeLong)
        }
    }

    function showFeedback(item, duration) {
        if (!root.overlayFeedback) {
            return
        }

        // Hide all overlays
        overlayIcon.visible = false
        overlayText.visible = false

        if (item.icon) {
            // Icon overlay
            overlayIcon.source = item.icon
            overlayIcon.visible = true
        } else if (item.text) {
            // Text overlay
            overlayText.text = item.text
            overlayText.visible = true
        } else {
            return
        }

        // Fade in
        overlay.opacity = 1
        fadeOutTimer.interval = duration || root._overlayShowTimeDefault
        fadeOutTimer.restart()
    }
}
