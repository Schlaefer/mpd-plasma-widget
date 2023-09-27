import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls

Kirigami.FormLayout {
    id: page

    property alias cfg_mpdHost: mpdHost.text
    property alias cfg_descriptionAlignment: descriptionAlignment.selected
    property alias cfg_cfgHorizontalLayout: cfgHorizontalLayout.checked
    property alias cfg_cfgFontSize: cfgFontSize.value
    property alias cfg_cfgCacheRoot: cfgCacheRoot.cleanPath
    property alias cfg_cfgCacheForDays: cfgCacheForDays.value
    property alias cfg_cfgCornerRadius: cfgCornerRadius.value
    property alias cfg_cfgShadowSpread: cfgShadowSpread.value
    property alias cfg_cfgShadowColor: cfgShadowColor.color

    Item {
        Kirigami.FormData.label: i18n("MPD Connection")
        Kirigami.FormData.isSection: true
    }

    TextField {
        id: mpdHost

        Kirigami.FormData.label: i18n("MPD Server Address:")
        placeholderText: i18n("192.168.y.x")
        Layout.preferredWidth: 200
    }

    Item {
        Kirigami.FormData.label: i18n("Local Covers")
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Path to Cover Folder:")

        TextField {
            id: cfgCacheRootText

            text: cfgCacheRoot.cleanPath
            placeholderText: i18n("No file selected.")
            Layout.preferredWidth: 200
        }

        Button {
            text: i18n("Select Folder")
            onClicked: cfgCacheRoot.open()
        }

        FileDialog {
            id: cfgCacheRoot

            property string cleanPath

            selectFolder: true
            title: i18n("Please Choose a Folder")
            folder: shortcuts.home
            onAccepted: {
                cleanPath = decodeURIComponent(cfgCacheRoot.fileUrl.toString(
                                                   ).replace(/^file:\/\//, ""))
            }
        }
    }

    SpinBox {
        id: cfgCacheForDays

        Kirigami.FormData.label: i18n("Cache Covers for Days:")
    }

    Item {
        Kirigami.FormData.label: i18n("Visuals")
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: cfgHorizontalLayout

        Kirigami.FormData.label: i18n("Horizontal Layout:")
    }

    GroupBox {
        Kirigami.FormData.label: i18n("Text Alignment:")

        RowLayout {
            id: descriptionAlignment

            property int selected

            Component.onCompleted: {
                if (selected === 1)
                    descriptionAlignmentCenter.checked = true
                else if (selected === 2)
                    descriptionAlignmentRight.checked = true
            }

            RadioButton {
                id: descriptionAlignmentLeft

                text: i18n("Left")
                checked: true
                onClicked: {
                    focus = true
                    descriptionAlignment.selected = 0
                }
            }

            RadioButton {
                id: descriptionAlignmentCenter

                text: i18n("Center")
                onClicked: {
                    focus = true
                    descriptionAlignment.selected = 1
                }
            }

            RadioButton {
                id: descriptionAlignmentRight

                text: i18n("Right")
                onClicked: {
                    focus = true
                    descriptionAlignment.selected = 2
                }
            }
        }
    }

    SpinBox {
        id: cfgFontSize

        to: 1000
        Kirigami.FormData.label: i18n("Font Size:")
    }

    SpinBox {
        id: cfgCornerRadius

        to: 10000
        Kirigami.FormData.label: i18n("Corner Radius:")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Shadow Size and Color:")
        SpinBox {
            id: cfgShadowSpread
        }

        KQControls.ColorButton {
            id: cfgShadowColor
            showAlphaChannel: true
        }
    }
}
