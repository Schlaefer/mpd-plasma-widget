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
        implicitHeight: mainLayout.implicitHeight

        Rectangle {
            id: bottomDivider
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1
            color:  Qt.darker(Kirigami.Theme.backgroundColor, 1.5)
        }

        RowLayout {
            id: mainLayout

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
                spacing: 0
                // Layout.fillHeight: true
                // Layout.fillWidth: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing

                ColumnLayout {
                    Layout.fillHeight: true
                    spacing: 0
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    Text {
                        Layout.fillWidth: true
                        color: (root.playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        font.bold: !main.appWindow.narrowLayout
                        text: main.appWindow.narrowLayout ? FmH.title(model) : model.title
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        visible: !main.appWindow.narrowLayout
                        Layout.fillWidth: true
                        color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                        text: FmH.artist(model)
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        visible: !main.appWindow.narrowLayout
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
