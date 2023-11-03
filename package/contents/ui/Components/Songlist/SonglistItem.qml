import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
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
        highlightIndex: playingIndex

        RowLayout {
            id: mainLayout

            Kirigami.ListItemDragHandle {
                id: dragHandle
                property int startIndex: -1
                property int endIndex

                visible: isSortable

                Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                Layout.leftMargin: -Kirigami.Units.gridUnit / 2

                listItem: listItem
                listView: parentView
                onMoveRequested: function(oldIndex, newIndex) {
                    if (startIndex === -1) {
                        startIndex = oldIndex
                    }
                    endIndex = newIndex
                    listView.model.move(oldIndex, newIndex, 1)
                }
                onDropped: {
                    parentView.userInteracted()
                    if (startIndex !== endIndex) {
                        mpdState.moveInQueue(startIndex, endIndex)
                    }

                    startIndex = -1
                }
            }

            ListCoverimage {
                id: image
                isSelected: model.checked
            }

            Rectangle {
                id: cursorMarker
                Layout.fillHeight: true
                width: Kirigami.Units.smallSpacing
                opacity: carretIndex === index
                color: playingIndex === index ? Kirigami.Theme.activeBackgroundColor : Kirigami.Theme.hoverColor
            }

            ColumnLayout {
                id: textArea
                spacing: 0
                Layout.fillHeight: true
                Layout.fillWidth: true

                ColumnLayout {
                    spacing: 0
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    Text {
                        Layout.fillWidth: true
                        color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        font.bold: !appWindow.narrowLayout
                        text: appWindow.narrowLayout ? FmH.title(model) : model.title
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        visible: !appWindow.narrowLayout
                        Layout.fillWidth: true
                        color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                        text: FmH.artist(model)
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        visible: !appWindow.narrowLayout
                        Layout.fillWidth: true
                        color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                        text: FmH.queueAlbumLine(model)
                        wrapMode: Text.WordWrap
                    }
                }
            }
        }
    }
    MouseArea {
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: dragHandle.width
        width: textArea.width + cursorMarker.width + image.width
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: function (mouse) {
            parentView.userInteracted()
            if (mouse.button === Qt.LeftButton) {
                if (mouse.modifiers & Qt.ShiftModifier) {
                    parentView.selectTo(index)
                } else if (mouse.modifiers & Qt.ControlModifier) {
                    parentView.selectToggle(index)
                } else {
                    parentView.selectToggle(index)
                }
                parent.forceActiveFocus()
                parentView.currentIndex = index
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
