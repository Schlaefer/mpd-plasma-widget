pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "./Components"
import "./Components/Elements"
import "../logic"
import "../scripts/formatHelpers.js" as FormatHelpers

Item {
    id: root

    anchors.fill: parent

    required property int alignment
    required property int fontSize
    required property bool useCustomFontColor
    required property string customFontColor
    required property bool horizontalLayout
    required property bool showVolumeSlider
    required property bool solidBackground
    required property var main
    required property MpdState mpdState
    required property VolumeState volumeState
    property alias cornerRadius: coverImageContainer.coverRadius
    property alias shadowColor: coverImageContainer.shadowColor
    property alias shadowSpread: coverImageContainer.shadowSpread

    GridLayout {
        columns: root.horizontalLayout ? 3 : 1
        rows: root.horizontalLayout ? 1 : 3
        anchors.fill: parent

        // Cover Image
        WidgetCoverImage {
            id: coverImageContainer
            mpdState: root.mpdState
            volumeState: root.volumeState
            applyEffects: true
            overlayFeedback: true
            onHeightChanged: sourceSizeTimer.restart()
            onWidthChanged: sourceSizeTimer.restart()
            Layout.fillHeight: true
            Layout.fillWidth: root.horizontalLayout ? false : true

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

            Layout.minimumWidth: root.horizontalLayout ? parent.height : parent.width
        }

        // Volume Slider
        PlasmaComponents.Slider {
            id: volumeSlider

            Layout.fillHeight: root.horizontalLayout
            Layout.fillWidth: !root.horizontalLayout
            Layout.leftMargin: !root.horizontalLayout ? Kirigami.Units.largeSpacing : 0
            Layout.rightMargin: !root.horizontalLayout ? Kirigami.Units.largeSpacing : 0

            visible: root.showVolumeSlider
            orientation: root.horizontalLayout ? Qt.Vertical : Qt.Horizontal
            from: 0
            to: 100
            stepSize: 3
            onValueChanged: root.volumeState.set(volumeSlider.value)
            value: root.volumeState.volume
        }

        // Wrapper for info/error icon
        Item {
            id: descriptionContainerWrapper
            Layout.fillWidth: true
            implicitHeight: innerLayout.implicitHeight

            // Title
            ColumnLayout {
                anchors.fill: parent
                Layout.leftMargin: Kirigami.Units.largeSpacing
                Layout.rightMargin: Kirigami.Units.largeSpacing

                // Wrapper to attach App-window MouseArea
                Item {
                    Layout.fillWidth: true
                    implicitHeight: innerLayout.implicitHeight

                    ColumnLayout {
                        id: innerLayout
                        anchors.fill: parent

                        WidgetLabel {
                            id: songTitle
                            alignment: root.alignment
                            fontSize: root.fontSize
                            font.weight: Font.Bold
                            solidBackground: root.solidBackground
                            color: root.useCustomFontColor ? root.customFontColor : Kirigami.Theme.textColor
                            Component.onCompleted: {
                                // A) If the queue is empty on startup, then no mpdInfo change event
                                // will come. We have to trigger the title "empty queue message" now.
                                // B) No change event when opening CompactRepresentation.
                                songTitle.setSongTitle()
                            }
                            Connections {
                                target: root.mpdState
                                function onMpdInfoChanged() {
                                    songTitle.setSongTitle()
                                }
                            }

                            function setSongTitle() {
                                if (!root.mpdState.mpdInfo) {
                                    songTitle.text = qsTr("Queue is empty")
                                    return
                                }
                                songTitle.text = FormatHelpers.title(root.mpdState.mpdInfo)
                            }
                        }

                        WidgetLabel {
                            id: songArtist
                            fontSize: root.fontSize
                            alignment: root.alignment
                            solidBackground: root.solidBackground
                            color: root.useCustomFontColor ? root.customFontColor : Kirigami.Theme.textColor
                            text: FormatHelpers.artist(root.mpdState.mpdInfo)
                        }

                        WidgetLabel {
                            id: songAlbum
                            fontSize: root.fontSize
                            alignment: root.alignment
                            solidBackground: root.solidBackground
                            color: root.useCustomFontColor ? root.customFontColor : Kirigami.Theme.textColor
                            text: FormatHelpers.album(root.mpdState.mpdInfo)
                            Layout.rightMargin: (errorIcon.visible ? (root.alignment !== 2 ? errorIcon.implicitWidth : undefined) : undefined)
                            Layout.leftMargin: (errorIcon.visible ?  (root.alignment !== 2 ? undefined : errorIcon.implicitWidth) : undefined)
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            root.main.toggleAppWindow()
                        }
                    }
                }
            }

            MessageIcon {
                id: errorIcon
                anchors.bottom: parent.bottom
                anchors.margins: Kirigami.Units.smallSpacing
                height: Kirigami.Units.iconSizes.small
                width: height

                states: [
                    State {
                        name: "left"
                        when: root.alignment === 2
                        AnchorChanges {
                            target: errorIcon
                            anchors.left: descriptionContainerWrapper.left
                            anchors.right: undefined
                        }
                    },
                    State {
                        name: "right"
                        when: root.alignment !== 2
                        AnchorChanges {
                            target: errorIcon
                            anchors.right: descriptionContainerWrapper.right
                            anchors.left: undefined
                        }
                    }
                ]
            }
        }
    }
}
