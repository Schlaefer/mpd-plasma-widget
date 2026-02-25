pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import "../../Mpdw.js" as Mpdw

QQC2.ToolBar {
    id: root

    required property Kirigami.PageRow pageStack
    required property string title

    RowLayout {
        anchors.fill: parent

         QQC2.ToolButton {
             id: backButton
             icon.name: Mpdw.icons.navBack
             onClicked: root.pageStack.pop()
         }

         QQC2.Label {
             id: titleLabel
             text: root.title
             Layout.fillWidth: true
         }
    }
}
