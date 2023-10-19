import QtQuick 2.15
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.20 as Kirigami
import "../../Components/Elements"
import "../../../scripts/formatHelpers.js" as FormatHelpers

Item {
    id: root

    signal doubleClicked(var model, int index)

    property alias showSongMenu: showSongMenuBt.visible
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

        actions: [
            Kirigami.Action {
                id: showSongMenuBt
                visible: true
                icon.name: "application-menu"
                text: qsTr("Song Menu")
                onTriggered: {
                    menuLoader.source = "SonglistItemContextMenu.qml"
                    if (!menuLoader.item.visible) {
                        menuLoader.item.popup()
                    }
                }
            }
        ]

        MouseArea {
            implicitHeight: mainLayout.implicitHeight
            implicitWidth: mainLayout.implicitWidth
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            Timer {
                id: dblClTimer
                // Should be in Qt.application.styleHints.mouseDoubleClickInterval but isn't
                interval: 400
            }

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
                    dblClTimer.start()
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
            onDoubleClicked: {
                root.doubleClicked(model, index)
                if (dblClTimer.running) {
                    // Reverse the click action on doubleclick
                    parentView.selectToggle(index)
                    dblClTimer.stop()
                }
            }

            Loader {
                id: menuLoader
            }

            Rectangle {
                id: selectMarker
                implicitHeight: mainLayout.height
                width: Kirigami.Units.smallSpacing
                color: Kirigami.Theme.hoverColor
                opacity: model.checked ? 1 : 0
            }

            Rectangle {
                anchors.left: selectMarker.right
                implicitHeight: mainLayout.height
                width: Kirigami.Units.smallSpacing
                opacity: carretIndex === index
                color: Kirigami.Theme.hoverColor
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
                    Layout.leftMargin: isSortable ? 0 : selectMarker.width + 2 * Kirigami.Units.smallSpacing
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
                            Layout.leftMargin: Kirigami.Units.largeSpacing
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
                            Layout.leftMargin: Kirigami.Units.largeSpacing
                            Layout.rightMargin: Kirigami.Units.small
                            color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                            text: FormatHelpers.artist(model)
                            wrapMode: Text.WordWrap
                        }

                        Text {
                            visible: !appWindow.narrowLayout
                            Layout.fillWidth: true
                            Layout.leftMargin: Kirigami.Units.largeSpacing
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
