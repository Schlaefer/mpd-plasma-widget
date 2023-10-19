import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import "../../Components/Elements"
import "../../../scripts/formatHelpers.js" as FormatHelpers

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

        highlightIndex: playingIndex

        MouseArea {
            implicitHeight: mainLayout.implicitHeight
            implicitWidth: mainLayout.implicitWidth
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
                    // If we click on selected items we wanna act on them in the
                    // context menu. Right clicking on a deselected item creates
                    // a new selection.
                    if (!model.checked) {
                        parentView.deselectAll()
                        parentView.select(index)
                        parentView.currentIndex = index
                    }
                    menuLoader.source = "SonglistItemContextMenu.qml"
                    if (!menuLoader.item.visible) {
                        menuLoader.item.popup()
                    }
                }
            }

            Loader {
                id: menuLoader
            }

            RowLayout {
                id: mainLayout
                width: root.width
                // Without we don't have word wrap with the text below!
                anchors.fill: parent

                Kirigami.ListItemDragHandle {
                    property int startIndex: -1
                    property int endIndex
                    visible: isSortable

                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.leftMargin: -Kirigami.Units.gridUnit / 2

                    listItem: listItem
                    listView: parentView
                    onMoveRequested: (oldIndex, newIndex) => {
                                         if (startIndex === -1) {
                                             startIndex = oldIndex
                                         }
                                         endIndex = newIndex
                                         listView.model.move(oldIndex, newIndex, 1)
                                     }
                    onDropped: {
                        parentView.userInteracted()
                        if (startIndex !== endIndex) {
                            mpdState.moveInQueue(startIndex + 1, endIndex + 1)
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
                    color: Kirigami.Theme.hoverColor
                    border.color: Kirigami.Theme.hoverColor
                }

                // We need a layout-"anchor" for the MouseArea *and* to allow
                // fillWide-aware word-wrap on the text fields
                ColumnLayout {
                    id: mouseAreaAnchor
                    spacing: 0
                    Layout.fillHeight: true

                    ColumnLayout {
                        spacing: 0
                        Text {
                            Layout.fillWidth: true
//                            Layout.leftMargin: Kirigami.Units.largeSpacing
                            Layout.rightMargin: Kirigami.Units.small
                            color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            font.bold: !appWindow.narrowLayout
                            // @SOMEDAY make this look beautiful
                            text: (!appWindow.narrowLayout || !model.tracknumber ? "" : model.tracknumber + ". ") + model.title
                            wrapMode: Text.WordWrap
                        }
                        Text {
                            visible: !appWindow.narrowLayout
                            Layout.fillWidth: true
//                            Layout.leftMargin: Kirigami.Units.largeSpacing
                            Layout.rightMargin: Kirigami.Units.small
                            color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                            text: FormatHelpers.artist(model)
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            visible: !appWindow.narrowLayout
                            Layout.fillWidth: true
//                            Layout.leftMargin: Kirigami.Units.largeSpacing
                            Layout.rightMargin: Kirigami.Units.small
                            color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                            text: FormatHelpers.queueAlbumLine(model)
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }
    }
}
