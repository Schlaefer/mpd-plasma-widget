import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kquickcontrols 2.0 as KQControls

Kirigami.FormLayout {
    id: root

    property alias cfg_cfgAlignment: cfgAlignment.selected
    property alias cfg_cfgHorizontalLayout: cfgHorizontalLayout.checked
    property alias cfg_cfgFontSize: cfgFontSize.value
    property alias cfg_cfgCornerRadius: cfgCornerRadius.value
    property alias cfg_cfgShadowSpread: cfgShadowSpread.value
    property alias cfg_cfgShadowColor: cfgShadowColor.color
    property alias cfg_cfgSolidBackground: cfgSolidBackground.checked

    Item {
        Kirigami.FormData.label: i18n("Layout")
        Kirigami.FormData.isSection: true
    }

    CheckBox {
        id: cfgHorizontalLayout

        Kirigami.FormData.label: i18n("Horizontal Layout:")
    }

    CheckBox {
        id: cfgSolidBackground

        Kirigami.FormData.label: i18n("Solid Background:")
    }

    Item {
        Kirigami.FormData.label: i18n("Text")
        Kirigami.FormData.isSection: true
    }

    GroupBox {
        Kirigami.FormData.label: i18n("Text Alignment:")

        RowLayout {
            id: cfgAlignment

            property int selected

            Component.onCompleted: {
                if (selected === 1)
                    cfgAlignmentCenter.checked = true
                else if (selected === 2)
                    cfgAlignmentRight.checked = true
            }

            RadioButton {
                id: cfgAlignmentLeft

                text: i18n("Left")
                checked: true
                onClicked: {
                    focus = true
                    cfgAlignment.selected = 0
                }
            }

            RadioButton {
                id: cfgAlignmentCenter

                text: i18n("Center")
                onClicked: {
                    focus = true
                    cfgAlignment.selected = 1
                }
            }

            RadioButton {
                id: cfgAlignmentRight

                text: i18n("Right")
                onClicked: {
                    focus = true
                    cfgAlignment.selected = 2
                }
            }
        }
    }

    SpinBox {
        id: cfgFontSize

        to: 1000
        Kirigami.FormData.label: i18n("Font Size:")
    }

    Item {
        Kirigami.FormData.label: i18n("Cover Image")
        Kirigami.FormData.isSection: true
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
