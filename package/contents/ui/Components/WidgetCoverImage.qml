import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.20 as Kirigami
import "./../Mpdw.js" as Mpdw

Item {
    id: coverImageContainer

    property alias sourceSize: coverImage.sourceSize

    property int coverRadius: 0
    property int shadowSpread: 0
    property string shadowColor

    Layout.fillHeight: true
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function (mouse) {
            if (mouse.button === Qt.LeftButton) {
                mpdState.toggle()
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
            volumeState.wheel(wheel.angleDelta.y)
        }
        onDoubleClicked: {
            mpdState.playNext()
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
                        mpdState.forceReloadEverything()
                    }
                }
                MenuSeparator {}
                MenuItem {
                    text: qsTr("Clear Cover Cache")
                    icon.name: Mpdw.icons.clearCache
                    onTriggered: {
                        coverManager.clearCache()
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
            if (!mpdState.mpdInfo) {
                return
            }

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
            // Force QML to update even if cover file stays the same. This helps if
            // the cover "got stuck" for whatever reason: a play next even in the same
            // album will always trigger.
            coverImage.source = ""
            coverImage.source = cover + "-large.jpg"
        }

        Connections {
            target: mpdState

            function onMpdInfoChanged() {
                coverImage.updateCover()
            }

            function onMpdQueueChanged() {
                if (mpdState.mpdQueue.length === 0) {
                    coverImage.source = ""
                }
            }
        }

        Connections {
            target: coverManager
            function onAfterReset() {
                coverImage.source = ""
                coverImage.updateCover()
            }
        }
    }

    Item {
        id: mask
        anchors.fill: coverImage
        visible: false

        Rectangle {
            color: "white"
            radius: coverRadius
            anchors.centerIn: parent
            width: coverImage.paintedWidth
            height: coverImage.paintedHeight
        }
    }

    OpacityMask {
        anchors.fill: coverImage
        source: coverImage
        maskSource: mask

        layer.enabled: shadowSpread > 0 && !!coverImage.source.toString()
        layer.effect: DropShadow {
            verticalOffset: 0
            horizontalOffset: 0
            color: shadowColor
            radius: shadowSpread
            samples: 17
        }
    }
}
