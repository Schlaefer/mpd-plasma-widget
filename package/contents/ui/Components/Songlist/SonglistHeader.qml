import QtQuick 2.15
import QtQuick.Layouts 1.0
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.20 as Kirigami
import QtGraphicalEffects 1.12
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

        QQC2.Button{
            required property var modelData
            icon.name: modelData.icon.name
            text: appWindow.narrowLayout ? "" : modelData.text
            onClicked: modelData.triggered()
            enabled: modelData.enabled
            flat: true
            QQC2.ToolTip {
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
