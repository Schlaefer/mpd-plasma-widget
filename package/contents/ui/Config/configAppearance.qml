import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQControls

Kirigami.FormLayout {
    id: root

    property alias cfg_cfgAlignment: cfgAlignment.selected
    property alias cfg_cfgHorizontalLayout: cfgHorizontalLayout.checked
    property alias cfg_cfgFontSize: cfgFontSize.value
    property alias cfg_cfgCornerRadius: cfgCornerRadius.value
    property alias cfg_cfgnarrowBreakPoint: cfgnarrowBreakPoint.value
    property alias cfg_cfgShadowSpread: cfgShadowSpread.value
    property alias cfg_cfgShadowColor: cfgShadowColor.color
    property alias cfg_cfgSolidBackground: cfgSolidBackground.checked

    Item {
        Kirigami.FormData.label: i18n("Layout")
        Kirigami.FormData.isSection: true
    }

    PlasmaComponents.CheckBox {
        id: cfgHorizontalLayout

        Kirigami.FormData.label: i18n("Horizontal Layout:")
    }

    PlasmaComponents.CheckBox {
        id: cfgSolidBackground

        Kirigami.FormData.label: i18n("Solid Background:")
    }

    Item {
        Kirigami.FormData.label: i18n("Text")
        Kirigami.FormData.isSection: true
    }

    PlasmaComponents.GroupBox {
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

            PlasmaComponents.RadioButton {
                id: cfgAlignmentLeft

                text: i18n("Left")
                checked: true
                onClicked: {
                    focus = true
                    cfgAlignment.selected = 0
                }
            }

            PlasmaComponents.RadioButton {
                id: cfgAlignmentCenter

                text: i18n("Center")
                onClicked: {
                    focus = true
                    cfgAlignment.selected = 1
                }
            }

            PlasmaComponents.RadioButton {
                id: cfgAlignmentRight

                text: i18n("Right")
                onClicked: {
                    focus = true
                    cfgAlignment.selected = 2
                }
            }
        }
    }

    PlasmaComponents.SpinBox {
        id: cfgFontSize

        to: 1000
        Kirigami.FormData.label: i18n("Font Size:")
    }

    Item {
        Kirigami.FormData.label: i18n("Cover Image")
        Kirigami.FormData.isSection: true
    }

    PlasmaComponents.SpinBox {
        id: cfgCornerRadius

        to: 10000
        Kirigami.FormData.label: i18n("Corner Radius:")
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Shadow Size and Color:")
        PlasmaComponents.SpinBox {
            id: cfgShadowSpread
        }

        KQControls.ColorButton {
            id: cfgShadowColor
            showAlphaChannel: true
        }
    }

    Item {
        Kirigami.FormData.label: i18n("Manager")
        Kirigami.FormData.isSection: true
    }

    RowLayout {
        Kirigami.FormData.label: i18n("Narrow Layout Breakpoint:")

        PlasmaComponents.Slider{
            id: cfgnarrowBreakPoint
            from: 0
            to: 720
            stepSize: 10
        }

        PlasmaComponents.Label { text: cfgnarrowBreakPoint.value }
    }
}
