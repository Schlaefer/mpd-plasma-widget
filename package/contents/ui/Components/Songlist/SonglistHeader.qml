import QtQuick
import QtQuick.Layouts
import org.kde.plasma.components as PlasmaComponents
import org.kde.kirigami as Kirigami
import "../../../scripts/formatHelpers.js" as FmH

Item {
    id: root

    property list<Kirigami.Action> leftActions
    property list<Kirigami.Action> rightActions
    property int numberSelected: 0

    z: 10
    width: parent.width
    height: row.height

    Rectangle
    {
        id: background
        height: row.height
        width: root.width
        color: Kirigami.Theme.backgroundColor
    }

    // Drop Shadow
    Rectangle
    {
        height: 4
        width: root.width
        anchors.top: background.bottom

        gradient: Gradient {
            GradientStop {
                position: 0.00;
                color: "#33000000"
            }
            GradientStop {
                position: 1.00;
                color: "#00000000";
            }
        }
    }

    Component {
        id: btnCmpt

        PlasmaComponents.Button{
            required property var modelData
            icon.name: modelData.icon.name
            text: win.narrowLayout ? "" : modelData.text
            onClicked: modelData.triggered()
            enabled: modelData.enabled
            flat: true
            PlasmaComponents.ToolTip {
                text: FmH.tooltipWithShortcut(modelData.tooltip, modelData.shortcut)
            }
        }
    }

    RowLayout {
        id: row
        width: root.width

        RowLayout {
            Layout.fillWidth: true
            Repeater {
                model: root.leftActions
                delegate: btnCmpt
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignRight
            Repeater {
                model: root.rightActions
                delegate: btnCmpt
            }
        }
    }
}
