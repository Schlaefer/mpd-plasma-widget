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

    required property CoverManager coverManager
    required property MpdState mpdState
    required property VolumeState volumeState
    property bool applyEffects: false
    property int coverRadius: 0
    property int shadowSpread: 0
    property string shadowColor
    property alias sourceSize: coverImage.sourceSize

    Layout.fillHeight: true
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
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

            }
        }

        onWheel: function (wheel) {
            root.volumeState.wheel(wheel.angleDelta.y)
        }
        onDoubleClicked: {
            root.mpdState.playNext()
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
                        root.coverManager.clearCache()
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
                return
            }

            let cover = root.coverManager.getCover(root.mpdState.mpdInfo, 1)
            if (typeof (cover) === "undefined") {
                root.coverManager.gotCover.connect(updateCover)
                return
            }
            root.coverManager.gotCover.disconnect(updateCover)
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

        onSourceChanged: {
            root.sourceChanged(coverImage.source)
        }

        Component.onCompleted: {
            coverImage.updateCover()
        }

        Connections {
            target: root.mpdState

            function onMpdInfoChanged() {
                coverImage.updateCover()
            }

            function onMpdQueueChanged() {
                if (root.mpdState.mpdQueue.length === 0) {
                    coverImage.source = ""
                }
            }
        }

        Connections {
            target: root.coverManager
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
}
