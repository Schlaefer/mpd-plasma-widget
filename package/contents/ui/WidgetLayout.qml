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
    property alias cornerRadius: coverImage.coverRadius
    property alias shadowColor: coverImage.shadowColor
    property alias shadowSpread: coverImage.shadowSpread

    anchors.fill: parent

    states: [
        State {
            name: "vertical"
            when: !root.horizontalLayout
            PropertyChanges {
                coverImage.Layout.fillWidth: true
                coverImage.Layout.minimumWidth: gridLayout.width

                gridLayout.columns: 1
                gridLayout.rows: 3

                volumeSlider.Layout.fillHeight: false
                volumeSlider.Layout.fillWidth: true
                volumeSlider.Layout.leftMargin: Kirigami.Units.largeSpacing
                volumeSlider.Layout.rightMargin: Kirigami.Units.largeSpacing
                volumeSlider.Layout.bottomMargin: 0
                volumeSlider.Layout.topMargin: 0
                volumeSlider.orientation: Qt.Horizontal
            }
        },
        State {
            name: "horizontal"
            when: root.horizontalLayout
            PropertyChanges {
                coverImage.Layout.fillWidth: false
                coverImage.Layout.minimumWidth: gridLayout.height

                gridLayout.columns: 3
                gridLayout.rows: 1

                volumeSlider.Layout.fillHeight: true
                volumeSlider.Layout.fillWidth: false
                volumeSlider.Layout.leftMargin: 0
                volumeSlider.Layout.rightMargin: 0
                volumeSlider.Layout.bottomMargin: Kirigami.Units.largeSpacing
                volumeSlider.Layout.topMargin: Kirigami.Units.largeSpacing
                volumeSlider.orientation: Qt.Vertical
            }
        }
    ]

    GridLayout {
        id: gridLayout
        anchors.fill: parent

        // Cover Image
        WidgetCoverImage {
            id: coverImage
            mpdState: root.mpdState
            volumeState: root.volumeState
            applyEffects: true
            overlayFeedback: true
            onHeightChanged: sourceSizeTimer.restart()
            onWidthChanged: sourceSizeTimer.restart()
            Layout.fillHeight: true

            // Delay setting the source otherwise resizing the widget is very shoppy.
            Timer {
                id: sourceSizeTimer
                interval: 1000
                onTriggered: {
                    coverImage.sourceSize.height = root.height
                    coverImage.sourceSize.width = root.height
                }
            }

            Component.onCompleted: sourceSizeTimer.start()
        }

        // Volume Slider
        PlasmaComponents.Slider {
            id: volumeSlider
            value: root.volumeState.volume
            visible: root.showVolumeSlider
            from: 0
            to: 100
            stepSize: 3
            onValueChanged: root.volumeState.set(volumeSlider.value)
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
