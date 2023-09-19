import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_mpdHost: mpdHost.text
    property alias cfg_descriptionAlignment: descriptionAlignment.selected
    property alias cfg_cfgHorizontalLayout: cfgHorizontalLayout.checked
    property alias cfg_cfgFontSize: cfgFontSize.text
    property alias cfg_cfgCacheRoot: cfgCacheRoot.cleanPath
    property alias cfg_cfgCacheMultiple: cfgCacheMultiple.checked

    Item {
        Kirigami.FormData.label: "MPD Connection"
        Kirigami.FormData.isSection: true
    }

    TextField {
        id: mpdHost

        Kirigami.FormData.label: i18n("MPD Server Address:")
        placeholderText: i18n("192.168.y.x")
        Layout.preferredWidth: 200
    }

    Item {
        Kirigami.FormData.label: "Local Covers"
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Path for cover directory:")

        TextField {
            id: cfgCacheRootText

            text: cfgCacheRoot.cleanPath
            placeholderText: i18n("No file selected.")
            Layout.preferredWidth: 200
        }

        Button {
            text: "Select Directory"
            onClicked: cfgCacheRoot.open()
        }

        FileDialog {
            id: cfgCacheRoot

            property string cleanPath

            selectFolder: true
            title: "Please choose a directory"
            folder: shortcuts.home
            onAccepted: {
                cleanPath = decodeURIComponent(cfgCacheRoot.fileUrl.toString().replace(/^file:\/\//, ""));
            }
        }

    }

    CheckBox {
        id: cfgCacheMultiple

        Kirigami.FormData.label: i18n("Cache covers for a while:")
    }

    Item {
        Kirigami.FormData.label: "Visuals"
        Kirigami.FormData.isSection: true
    }

    GroupBox {
        Kirigami.FormData.label: i18n("Text Alignment:")

        RowLayout {
            id: descriptionAlignment

            property int selected

            Component.onCompleted: {
                if (selected === 1)
                    descriptionAlignmentCenter.checked = true;
                else if (selected === 2)
                    descriptionAlignmentRight.checked = true;
            }

            ExclusiveGroup {
                id: tabPositionGroup
            }

            RadioButton {
                id: descriptionAlignmentLeft

                text: "Left"
                checked: true
                exclusiveGroup: tabPositionGroup
                onClicked: {
                    focus = true;
                    descriptionAlignment.selected = 0;
                }
            }

            RadioButton {
                id: descriptionAlignmentCenter

                text: "Center"
                exclusiveGroup: tabPositionGroup
                onClicked: {
                    focus = true;
                    descriptionAlignment.selected = 1;
                }
            }

            RadioButton {
                id: descriptionAlignmentRight

                text: "Right"
                exclusiveGroup: tabPositionGroup
                onClicked: {
                    focus = true;
                    descriptionAlignment.selected = 2;
                }
            }

        }

    }

    CheckBox {
        id: cfgHorizontalLayout

        Kirigami.FormData.label: i18n("Horizontal Layout:")
    }

    TextField {
        id: cfgFontSize

        Kirigami.FormData.label: i18n("Font Size")
        placeholderText: i18n("13")
        Layout.preferredWidth: 200
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Cache Root Path:")

        TextField {
            id: cfgCacheRootText

            text: cfgCacheRoot.cleanPath
            placeholderText: i18n("No file selected.")
            Layout.preferredWidth: 250
        }

        Button {
            text: "Select Directory"
            onClicked: cfgCacheRoot.open()
        }

        FileDialog {
            id: cfgCacheRoot

            property string cleanPath

            selectFolder: true
            title: "Please choose a directory"
            folder: shortcuts.home
            onAccepted: {
                cleanPath = decodeURIComponent(cfgCacheRoot.fileUrl.toString().replace(/^file:\/\//, ""));
            }
        }

    }

}
