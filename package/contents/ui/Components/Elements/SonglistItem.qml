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
    property int playingIndex: -1
    property var parentView

    width: parentView.width
    implicitHeight: listItem.implicitHeight

    SwipeListItemGeneric {
        id: listItem

        highlightIndex: playingIndex 

        RowLayout {
            width: root.width
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
                    // This should match the new state of mpd and prevents a
                    // queue redraw if our state is identical to mpd's queue.
                    listView.model.set(startIndex, {position: startIndex + 1 + ""})
                    listView.model.set(endIndex, {position: endIndex + 1 + ""})

                    // Send queue
                    mpdState.moveInQueue(startIndex + 1, endIndex + 1)

                    startIndex = -1
                }
            }

            CheckBox {
                id: checkBox
                checked: model.checked
                onCheckedChanged: {
                    if (checked) {
                        parentView.listManager.check(index)
                        model.checked = true
                    } else {
                        parentView.listManager.uncheck(index)
                        model.checked = false
                    }
                }
            }

            ListCoverimage {
                id: image

                MouseArea {
                    height: image.height
                    width: image.width

                    acceptedButtons: Qt.LeftButton | Qt.RightButton

                    onClicked: function (mouse) {
                        if (mouse.button === Qt.LeftButton) {
                            model.checked = !model.checked
                        }
                        if (mouse.button === Qt.RightButton) {
                            menuLoader.source = "SonglistItemContextMenu.qml"
                            if (!menuLoader.item.visible) {
                                menuLoader.item.popup()
                            }
                        }
                    }
                }
            }

            // We need a layout-"anchor" for the MouseArea *and* to allow
            // fillWide-aware word-wrap on the text fields
            ColumnLayout {
                id: mouseAreaAnchor
                spacing: 0
                Layout.fillWidth: true
                Layout.fillHeight: true

                ColumnLayout {
                    spacing: 0
                    Layout.fillWidth: true
                    Text {
                        Layout.fillWidth: true
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        Layout.rightMargin: Kirigami.Units.small
                        color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        font.bold: appWindow.width > appWindow.simpleLayoutBreakpoint
                        // @SOMEDAY make this look beautiful
                        text: ((appWindow.width > appWindow.simpleLayoutBreakpoint)
                               || !model.tracknumber ? "" : model.tracknumber + ". ") + model.title
                        wrapMode: Text.WordWrap
                    }
                    Text {
                        visible: appWindow.width > appWindow.simpleLayoutBreakpoint
                        Layout.fillWidth: true
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        Layout.rightMargin: Kirigami.Units.small
                        color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                        text: FormatHelpers.artist(model)
                        wrapMode: Text.WordWrap
                    }

                    Text {
                        visible: appWindow.width > appWindow.simpleLayoutBreakpoint
                        Layout.fillWidth: true
                        Layout.leftMargin: Kirigami.Units.largeSpacing
                        Layout.rightMargin: Kirigami.Units.small
                        color: (playingIndex === index) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.disabledTextColor
                        text: FormatHelpers.queueAlbumLine(model)
                        wrapMode: Text.WordWrap
                    }
                }


                /*
                MouseArea {
                    height: mouseAreaAnchor.height
                    width: mouseAreaAnchor.width
                }
                */

                Loader {
                    id: menuLoader
                }
            }
        }
    }
}
