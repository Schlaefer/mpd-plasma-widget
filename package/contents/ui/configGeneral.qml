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
    property alias cfg_cfgCacheRoot: fileDialog.folder

    TextField {
        id: mpdHost

        Kirigami.FormData.label: i18n("MPD Server Host Address:")
        placeholderText: i18n("192.168.1.….")
    }

    GroupBox {
        Kirigami.FormData.label: i18n("Text Alignment:")

        ColumnLayout {
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

    GroupBox {
        Kirigami.FormData.label: i18n("Horizontal Layout:")

        CheckBox {
            id: cfgHorizontalLayout
        }

    }

    TextField {
        id: cfgFontSize

        Kirigami.FormData.label: i18n("Font Size")
        placeholderText: i18n("13")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Cache Root Path:")

        TextField {
            id: cfgCacheRootText

            text: fileDialog.folder
            placeholderText: i18n("No file selected.")
            Layout.preferredWidth: 250
        }

        Button {
            text: "Select Directory"
            onClicked: fileDialog.open()
        }

        FileDialog {
            id: fileDialog

            title: "Please choose a directory"
            folder: shortcuts.home
            selectFolder: true
            onAccepted: {
                plasmoid.configuration.selectedDirectory = fileDialog.fileUrl;
            }
        }

    }

}
