import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import "../../Mpdw.js" as Mpdw

QQC2.ToolBar {
    RowLayout {
        anchors.fill: parent

         QQC2.ToolButton {
             id: backButton
             icon.name: Mpdw.icons.navBack
             onClicked: app.pageStack.pop()
         }

         QQC2.Label {
             id: titleLabel
             text: root.title
             Layout.fillWidth: true
             horizontalAlignment: Text.AlignHLeft
         }
    }
}
