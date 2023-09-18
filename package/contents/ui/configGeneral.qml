import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4 as Kirigami

Kirigami.FormLayout {
    id: page

    property alias cfg_mpdHost: mpdHost.text
    property alias cfg_descriptionAlignment: descriptionAlignment.selected
    property alias cfg_cfgHorizontalLayout: cfgHorizontalLayout.checked
    property alias cfg_cfgFontSize: cfgFontSize.text

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
        Kirigami.FormData.label: i18n("Layout:")

        CheckBox {
            id: cfgHorizontalLayout

            text: i18n("Horizontal")
        }

    }

    TextField {
        id: cfgFontSize

        Kirigami.FormData.label: i18n("Font Size")
        placeholderText: i18n("13")
    }

}
