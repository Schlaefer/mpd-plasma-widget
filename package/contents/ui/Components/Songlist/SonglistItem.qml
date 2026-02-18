import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Components/Elements"
import "../../../scripts/formatHelpers.js" as FmH

Item {
    id: root

    property alias actions: listItem.actions
    property alias alternatingBackground: listItem.alternatingBackground
    property alias coverLoadingPriority: image.loadingPriority
    property bool isSortable: false
    property int carretIndex: -1
    property int playingIndex: -1
    property SonglistView parentView

    width: parentView.width
    implicitHeight: listItem.implicitHeight

    SwipeListItemGeneric {
        id: listItem
        width: root.width
        highlightIndex: root.playingIndex
        topPadding: 0
        bottomPadding: 0
        implicitHeight: mainLayout.implicitHeight

        Rectangle {
            id: currentlyPlayingBackgroundHighlight
            anchors.fill: parent
            color: Kirigami.Theme.highlightColor
            visible: root.playingIndex === index
            opacity: 0.35
        }

        Rectangle {
            id: bottomDivider
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color:  Qt.darker(Kirigami.Theme.backgroundColor, 1.3)
            // Draw bellow mouse hover highlight.
            z: -1
        }

        RowLayout {
            id: mainLayout
            anchors.fill: parent
            anchors.rightMargin: listItem.overlayWidth

            Kirigami.ListItemDragHandle {
                id: dragHandle
                property int startIndex: -1
                property int endIndex

                visible: root.isSortable

                Layout.preferredWidth: Kirigami.Units.iconSizes.medium

                listItem: listItem
                listView: root.parentView
                onMoveRequested: function(oldIndex, newIndex) {
                    if (startIndex === -1) {
                        startIndex = oldIndex
                    }
                    endIndex = newIndex
                    listView.model.move(oldIndex, newIndex, 1)
                }
                onDropped: {
                    root.parentView.userInteracted()
                    if (startIndex !== endIndex) {
                        mpdState.moveInQueue(startIndex, endIndex)
                    }

                    startIndex = -1
                }
            }

            ListCoverimage {
                id: image
                isSelected: model.checked
                // move image inside kirigami 6 hover highlight bubble
                Layout.leftMargin: root.isSortable ? 0 : Kirigami.Units.largeSpacing
            }

            Rectangle {
                id: cursorMarker
                Layout.fillHeight: true
                Layout.topMargin: Kirigami.Units.mediumSpacing
                Layout.bottomMargin: Kirigami.Units.mediumSpacing
                Layout.preferredWidth: Kirigami.Units.smallSpacing
                opacity: root.carretIndex === index
                color: Kirigami.Theme.hoverColor
            }

            ColumnLayout {
                id: textArea
                Layout.fillHeight: true
                Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                spacing: 0
                Layout.rightMargin: Kirigami.Units.mediumSpacing
                Text {
                    id: titleText
                    Layout.fillWidth: true
                    color: Kirigami.Theme.textColor
                    textFormat: Text.PlainText
                    font.bold: !win.narrowLayout
                    text: win.narrowLayout ? FmH.title(model) : model.title
                    wrapMode: Text.WordWrap
                }
                Text {
                    visible: !win.narrowLayout
                    Layout.fillWidth: true
                    color: titleText.color
                    textFormat: Text.PlainText
                    text: FmH.artist(model)
                    wrapMode: Text.WordWrap
                }

                Text {
                    visible: !win.narrowLayout
                    Layout.fillWidth: true
                    textFormat: Text.PlainText
                    color: titleText.color
                    text: FmH.queueAlbumLine(model)
                    wrapMode: Text.WordWrap
                }
            }
        }

        MouseArea {
            anchors.fill: mainLayout
            anchors.leftMargin: dragHandle.visible ? dragHandle.width : 0
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function (mouse) {
                root.parentView.userInteracted()
                if (mouse.button === Qt.LeftButton) {
                    if (mouse.modifiers & Qt.ShiftModifier) {
                        root.parentView.model.selectTo(index)
                    } else if (mouse.modifiers & Qt.ControlModifier) {
                        root.parentView.model.selectToggle(index)
                    } else {
                        root.parentView.model.selectToggle(index)
                    }
                    root.parentView.currentIndex = index
                }
                if (mouse.button === Qt.RightButton) {
                    menuLoader.source = "SonglistItemContextMenu.qml"
                    if (!menuLoader.item.visible) {
                        menuLoader.item.popup()
                    }
                }
            }
            Loader {
                id: menuLoader
            }
        }
    }
}
