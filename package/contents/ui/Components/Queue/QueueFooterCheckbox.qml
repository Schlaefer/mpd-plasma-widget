import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2

QQC2.CheckBox {
    id: root

    property string iconName
    property string itDesc
    property string itSc

    icon.name: iconName
    text: appWindow.width > appWindow.simpleLayoutBreakpoint ? itDesc : "" 


    QQC2.ToolTip {
        // @SOMEDAY i18n
        text: appWindow.width > appWindow.simpleLayoutBreakpoint ? root.itSc : itDesc + " (" + root.itSc + ")"
    }

    Shortcut {
        sequence: root.itSc
        onActivated: root.checked = !root.checked
    }

}
