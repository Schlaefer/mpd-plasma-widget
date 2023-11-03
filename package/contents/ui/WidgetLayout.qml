import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kirigami 2.20 as Kirigami
import "./Mpdw.js" as Mpdw
import "./Components"
import "./Components/Queue"
import "../scripts/formatHelpers.js" as FormatHelpers

Item {
    id: root

    anchors.fill: parent

    GridLayout {
        columns: cfgHorizontalLayout ? 3 : 1
        rows: cfgHorizontalLayout ? 1 : 3
        anchors.fill: parent

        // Cover Image
        WidgetCoverImage {
            id: coverImageContainer

            coverRadius: cfgCornerRadius
            shadowColor: cfgShadowColor
            shadowSpread: cfgShadowSpread

            onHeightChanged: sourceSizeTimer.restart()
            onWidthChanged: sourceSizeTimer.restart()

            // Delay setting the source otherwise resizing the widget is very shoppy.
            Timer {
                id: sourceSizeTimer
                interval: 1000
                onTriggered: {
                    coverImageContainer.sourceSize.height = height
                    coverImageContainer.sourceSize.width = height
                }
            }

            Component.onCompleted: {
                sourceSizeTimer.start()
            }

            Layout.minimumWidth: cfgHorizontalLayout ? parent.height : parent.width
        }

        // Volume Slider
        PlasmaComponents.Slider {
            id: volumeSlider

            Layout.fillHeight: cfgHorizontalLayout
            Layout.fillWidth: !cfgHorizontalLayout
            Layout.leftMargin: !cfgHorizontalLayout ? Kirigami.Units.largeSpacing : 0
            Layout.rightMargin: !cfgHorizontalLayout ? Kirigami.Units.largeSpacing : 0

            // Orientation bugged? Hide on horizontal layout for now
            // See: https://bugs.kde.org/show_bug.cgi?id=474611
            // Layout.maximumWidth: cfgHorizontalLayout ? 15 : -1
            // orientation: cfgHorizontalLayout ? Qt.Vertical : Qt.Horizontal
            visible: !cfgHorizontalLayout
            minimumValue: 0
            maximumValue: 100
            stepSize: 1
            onValueChanged: volumeState.set(volumeSlider.value)
            value: volumeState.volume
        }

        // Title
        ColumnLayout {
            id: descriptionContainer
            Layout.leftMargin: Kirigami.Units.largeSpacing
            Layout.rightMargin: Kirigami.Units.largeSpacing

            ColumnLayout {
                WidgetLabel {
                    id: songTitle
                    font.weight: Font.Bold
                    Connections {
                        target: mpdState
                        function onMpdInfoChanged() {
                            if (mpdState.mpdQueue.length === 0) {
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
                        target: mpdState
                        function onMpdInfoChanged() {
                            songArtist.text = FormatHelpers.artist(mpdState.mpdInfo)
                        }
                    }
                }

                WidgetLabel {
                    id: songAlbum
                    Connections {
                        target: mpdState

                        function onMpdInfoChanged() {
                            songAlbum.text = FormatHelpers.album(mpdState.mpdInfo)
                        }
                    }
                }

                MouseArea {
                    width: parent.width
                    height: parent.height
                    onClicked: {
                        main.toggleAppWindow()
                    }
                }
            }

            // Notifications
            RowLayout {
                visible: !!notification.text
                WidgetLabel {
                    id: notification

                    visible: text.length > 0
                    font.italic: true
                    // @TODO Error message elides instead of wraps

                    Connections {
                        function onAppLastErrorChanged() {
                            notification.text = main.appLastError
                        }

                        target: main
                    }
                }

                ToolButton {
                    icon.name: Mpdw.icons.dialogClose
                    icon.height: Kirigami.Units.iconSizes.small
                    icon.width: Kirigami.Units.iconSizes.small
                    onClicked: notification.text = ''
                }
            }
        }
    }
}
