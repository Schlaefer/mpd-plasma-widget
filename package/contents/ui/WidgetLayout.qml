import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "./Mpdw.js" as Mpdw
import "./Components"
import "../logic"
import "../scripts/formatHelpers.js" as FormatHelpers

Item {
    id: root

    anchors.fill: parent

    property var main
    property MpdState mpdState
    property VolumeState volumeState

    GridLayout {
        columns: root.main.cfgHorizontalLayout ? 3 : 1
        rows: root.main.cfgHorizontalLayout ? 1 : 3
        anchors.fill: parent

        // Cover Image
        WidgetCoverImage {
            id: coverImageContainer

            coverRadius: root.main.cfgCornerRadius
            shadowColor: root.main.cfgShadowColor
            shadowSpread: root.main.cfgShadowSpread

            onHeightChanged: sourceSizeTimer.restart()
            onWidthChanged: sourceSizeTimer.restart()

            // Delay setting the source otherwise resizing the widget is very shoppy.
            Timer {
                id: sourceSizeTimer
                interval: 1000
                onTriggered: {
                    coverImageContainer.sourceSize.height = root.height
                    coverImageContainer.sourceSize.width = root.height
                }
            }

            Component.onCompleted: {
                sourceSizeTimer.start()
            }

            Layout.minimumWidth: root.main.cfgHorizontalLayout ? parent.height : parent.width
        }

        // Volume Slider
        PlasmaComponents.Slider {
            id: volumeSlider

            Layout.fillHeight: root.main.cfgHorizontalLayout
            Layout.fillWidth: !root.main.cfgHorizontalLayout
            Layout.leftMargin: !root.main.cfgHorizontalLayout ? Kirigami.Units.largeSpacing : 0
            Layout.rightMargin: !root.main.cfgHorizontalLayout ? Kirigami.Units.largeSpacing : 0

            // Orientation bugged? Hide on horizontal layout for now
            // See: https://bugs.kde.org/show_bug.cgi?id=474611
            // Layout.maximumWidth: cfgHorizontalLayout ? 15 : -1
            // orientation: cfgHorizontalLayout ? Qt.Vertical : Qt.Horizontal
            visible: !root.main.cfgHorizontalLayout
            from: 0
            to: 100
            stepSize: 1
            onValueChanged: root.volumeState.set(volumeSlider.value)
            value: root.volumeState.volume
        }

        // Title
        ColumnLayout {
            id: descriptionContainer
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing

            // Wrapper to attach MouseArea
            Item {
                Layout.fillWidth: true
                implicitHeight: innerLayout.implicitHeight

                ColumnLayout {
                    id: innerLayout 
                    opacity: notification.text ? 0 : 1
                    anchors.fill: parent
                    
                    WidgetLabel {
                        id: songTitle
                        font.weight: Font.Bold
                        Connections {
                            target: root.mpdState
                            function onMpdInfoChanged() {
                                if (root.mpdState.mpdQueue.length === 0) {
                                    songTitle.text = qsTr("Queue is empty")
                                    return
                                }
                                songTitle.text = FormatHelpers.title(mpdState.mpdInfo)
                            }
                        }
                    }

                    WidgetLabel {
                        id: songArtist
                        Connections {
                            target: root.mpdState
                            function onMpdInfoChanged() {
                                songArtist.text = FormatHelpers.artist(root.mpdState.mpdInfo)
                            }
                        }
                    }

                    WidgetLabel {
                        id: songAlbum
                        Connections {
                            target: root.mpdState

                            function onMpdInfoChanged() {
                                songAlbum.text = FormatHelpers.album(root.mpdState.mpdInfo)
                            }
                        }
                    }

                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        root.main.toggleAppWindow()
                    }
                }
            }

            // Notifications
            RowLayout {
                visible: !!notification.text
                WidgetLabel {
                    id: notification
                    Layout.fillWidth: true

                    visible: text.length > 0
                    font.italic: true
                    wrapMode: Text.Wrap

                    Connections {
                        function onAppLastErrorChanged() {
                            notification.text = root.main.appLastError
                        }

                        target: root.main
                    }
                }

                PlasmaComponents.ToolButton {
                    icon.name: Mpdw.icons.dialogClose
                    icon.height: Kirigami.Units.iconSizes.small
                    icon.width: Kirigami.Units.iconSizes.small
                    onClicked: notification.text = ''
                }
            }
        }
    }
}
