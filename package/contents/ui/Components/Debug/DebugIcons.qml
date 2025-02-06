import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import "../../Mpdw.js" as Mpdw

Kirigami.ApplicationWindow {

    Kirigami.ScrollablePage {
        id: root
        anchors.fill: parent

        readonly property list<string> keys: [
            "textColor",
            "disabledTextColor",
            "highlightedTextColor",
            "activeTextColor",
            "linkColor",
            "visitedLinkColor",
            "negativeTextColor",
            "neutralTextColor",
            "positiveTextColor",
            "backgroundColor",
            "highlightColor",
            "activeBackgroundColor",
            "linkBackgroundColor",
            "visitedLinkBackgroundColor",
            "negativeBackgroundColor",
            "neutralBackgroundColor",
            "positiveBackgroundColor",
            "alternateBackgroundColor",
            "focusColor",
            "hoverColor",
        ];

        function setName(id: int): string {
            switch (id) {
            case Kirigami.Theme.View:
                return "Theme.View";
            case Kirigami.Theme.Window:
                return "Theme.Window";
            case Kirigami.Theme.Button:
                return "Theme.Button";
            case Kirigami.Theme.Selection:
                return "Theme.Selection";
            case Kirigami.Theme.Tooltip:
                return "Theme.Tooltip";
            case Kirigami.Theme.Complementary:
                return "Theme.Complementary";
            case Kirigami.Theme.Header:
                return "Theme.Header";
            }
        }

        function preProcessWrap(string: string): string {
            // split camelCase string with ZWSP (Zero-width space) characters, so it can word-wrap on sub-word boundaries.
            // This is very rudimentary replacement; a better algorithm is in kcoreaddons KStringHandler::preProcessWrap.
            return string.replace(/[A-Z]/g, "\u200b$&");
        }

        Column {

            GridLayout {
                columns: 3

                Repeater {
                    model: Object.keys(Mpdw.icons).map(function(title) {
                        return {title: title, icon: Mpdw.icons[title]}
                    })
                    delegate: RowLayout {
                        Kirigami.Icon {
                            source: modelData.icon
                        }
                        PlasmaComponents.Label {
                            Layout.preferredWidth: 200
                            text: modelData.title
                        }
                    }

                }
            }



            Kirigami.Heading {
                text: "Colors by Theme.colorSet"
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                bottomPadding: Kirigami.Units.largeSpacing
            }

            Repeater {
                model: Kirigami.Theme.ColorSetCount
                delegate: Column {
                    id: colorSetDelegate

                    required property int index

                    width: parent.width

                    Kirigami.Heading {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter

                        topPadding: Kirigami.Units.gridUnit
                        bottomPadding: Kirigami.Units.largeSpacing

                        level: 2
                        text: root.index
                    }

                    Flow {
                        id: view

                        Kirigami.Theme.colorSet: colorSetDelegate.index
                        Kirigami.Theme.inherit: false

                        anchors.horizontalCenter: parent.horizontalCenter
                        width: Math.floor(parent.width / (Kirigami.Units.gridUnit * 9)) * (Kirigami.Units.gridUnit * 9)

                        Repeater {
                            model: root.keys

                            delegate: ColumnLayout {
                                id: colorDelegate

                                required property string modelData

                                width: Kirigami.Units.gridUnit * 9

                                Rectangle {
                                    Layout.alignment: Qt.AlignHCenter
                                    width: Kirigami.Units.gridUnit * 7
                                    height: Kirigami.Units.gridUnit * 3
                                    color: Kirigami.Theme[colorDelegate.modelData]
                                    border {
                                        width: 1
                                        color: "black"
                                    }
                                }

                                Kirigami.SelectableLabel {
                                    Kirigami.Theme.colorSet: Kirigami.Theme.Window
                                    Kirigami.Theme.inherit: false
                                    Layout.fillWidth: true
                                    Layout.leftMargin: Kirigami.Units.gridUnit
                                    Layout.rightMargin: Kirigami.Units.gridUnit
                                    Layout.bottomMargin: Kirigami.Units.gridUnit
                                    horizontalAlignment: TextEdit.AlignHCenter
                                    text: root.preProcessWrap(colorDelegate.modelData)
                                    wrapMode: Text.Wrap
                                }
                            }
                        }
                    }
                }
            }
        }

    }
}
