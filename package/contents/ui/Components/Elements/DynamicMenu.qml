import QtQuick
import QtQuick.Controls as QQC2

QQC2.Menu {
    id: root

    property var actions

    Repeater {
        model: root.actions

        delegate: DelegateChooser {
            id: chooser
            role: "separator"
            DelegateChoice {
                roleValue: true;
                QQC2.MenuSeparator {
                    required property var modelData
                    readonly property bool separator: true
                }
            }
            DelegateChoice {
                QQC2.MenuItem {
                    required property var modelData

                    visible: !modelData.separator
                    text: modelData.text ?? ""
                    icon.name: modelData.icon ?? ""

                    action: QQC2.Action {
                        shortcut: modelData.shortcut ?? ""
                        enabled: modelData.enabled ?? true
                        onTriggered: modelData.handler?.()
                    }
                }
            }
        }
    }
}